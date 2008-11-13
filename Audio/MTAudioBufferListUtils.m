/*
 *  MTAudioBufferListUtils.m
 *  MTCoreAudio
 *
 *  Created by Michael Thornburgh on Fri Apr 02 2004.
 *  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
 *
 */

#include "MTAudioBufferListUtils.h"
#include <string.h>
#include <stdlib.h>

void MTAudioBufferListDispose ( AudioBufferList * aList )
{
	unsigned buffer;
	
	if ( aList )
	{
		for ( buffer = 0; buffer < aList->mNumberBuffers; buffer++ )
		{
			if ( NULL != aList->mBuffers[buffer].mData )
			{
				free ( aList->mBuffers[buffer].mData );
			}
		}
		free ( aList );
	}
}

static AudioBufferList * _ABLCreateInterleaved ( unsigned channels, unsigned frames )
{
	AudioBufferList * rv = calloc ( sizeof(AudioBufferList), 1 );
	
	if ( NULL == rv )
		return rv;
	
	rv->mNumberBuffers = 1;
	rv->mBuffers[0].mNumberChannels = channels;
	rv->mBuffers[0].mDataByteSize = sizeof(Float32) * channels * frames;
	rv->mBuffers[0].mData = calloc ( rv->mBuffers[0].mDataByteSize, 1 );
	if ( NULL == rv->mBuffers[0].mData )
	{
		MTAudioBufferListDispose ( rv );
		rv = NULL;
	}
	
	return rv;
}

static AudioBufferList * _ABLCreateDeInterleaved ( unsigned channels, unsigned frames )
{
	AudioBufferList * rv = calloc ( sizeof(AudioBufferList) + sizeof(AudioBuffer) * channels, 1 );
	unsigned buffer;
	unsigned eachBufferSize = frames * sizeof(Float32);
	
	if ( NULL == rv )
		return rv;
	
	rv->mNumberBuffers = channels;
	for ( buffer = 0; buffer < channels; buffer++ )
	{
		rv->mBuffers[buffer].mNumberChannels = 1;
		rv->mBuffers[buffer].mDataByteSize = eachBufferSize;
		rv->mBuffers[buffer].mData = calloc ( eachBufferSize, 1 );
		if ( NULL == rv->mBuffers[buffer].mData )
		{
			MTAudioBufferListDispose ( rv );
			rv = NULL;
			break;
		}
	}
	
	return rv;
}

AudioBufferList * MTAudioBufferListNew ( unsigned channels, unsigned frames, Boolean interleaved )
{
	if (( 0 == channels ) || ( 0 == frames ))
		return NULL;
	
	if ( interleaved )
		return _ABLCreateInterleaved ( channels, frames );
	else
		return _ABLCreateDeInterleaved ( channels, frames );
}

static Boolean _ABLsCanDoCompatibleCopy ( const AudioBufferList * buf1, const AudioBufferList * buf2 )
{
	unsigned buffersToCheck = MIN ( buf1->mNumberBuffers, buf2->mNumberBuffers );
	unsigned buffer;
	
	for ( buffer = 0; buffer < buffersToCheck; buffer++ )
	{
		if ( buf1->mBuffers[buffer].mNumberChannels != buf2->mBuffers[buffer].mNumberChannels )
			return NO;
	}
	return YES;
}

static unsigned _ABLCompatibleCopy ( const AudioBufferList * src, unsigned srcOffset, AudioBufferList * dst, unsigned dstOffset, unsigned count )
{
	unsigned buffersToCopy = MIN ( src->mNumberBuffers, dst->mNumberBuffers );
	unsigned buffer;
	unsigned bytesToCopy, srcByteOffset, dstByteOffset;
	unsigned channelsThisBuffer;
	unsigned char * srcBytes, *dstBytes;
	
	for ( buffer = 0; buffer < buffersToCopy; buffer++ )
	{
		channelsThisBuffer = dst->mBuffers[buffer].mNumberChannels;
		bytesToCopy = count * sizeof(Float32) * channelsThisBuffer;
		srcByteOffset = srcOffset * sizeof(Float32) * channelsThisBuffer;
		dstByteOffset = dstOffset * sizeof(Float32) * channelsThisBuffer;
		srcBytes = src->mBuffers[buffer].mData;
		dstBytes = dst->mBuffers[buffer].mData;
		memcpy ( dstBytes + dstByteOffset, srcBytes + srcByteOffset, bytesToCopy );
	}
	for ( ; buffer < dst->mNumberBuffers; buffer++ )
	{
		channelsThisBuffer = dst->mBuffers[buffer].mNumberChannels;
		bytesToCopy = count * sizeof(Float32) * channelsThisBuffer;
		dstByteOffset = dstOffset * sizeof(Float32) * channelsThisBuffer;
		dstBytes = dst->mBuffers[buffer].mData;
		memset ( dstBytes + dstByteOffset, 0, bytesToCopy );
	}
	return count;
}

static unsigned _ABLGenericCopy ( const AudioBufferList * src, unsigned srcOffset, AudioBufferList * dst, unsigned dstOffset, unsigned count )
{
	Boolean leftoverDstChannels = ( MTAudioBufferListChannelCount(dst) > MTAudioBufferListChannelCount(src) );
	unsigned frame;
	Float32 * srcSample, * dstSample;
	unsigned srcNumberBuffers = src->mNumberBuffers;
	unsigned dstNumberBuffers = dst->mNumberBuffers;
	unsigned srcBuffer, dstBuffer;
	unsigned srcChan, dstChan;
	unsigned srcChansThisBuffer, dstChansThisBuffer;
	
	for ( frame = 0; frame < count; frame++, srcOffset++, dstOffset++ )
	{
		srcBuffer = dstBuffer = 0;
		srcChan = dstChan = 0;
		srcChansThisBuffer = src->mBuffers[srcBuffer].mNumberChannels;
		dstChansThisBuffer = dst->mBuffers[dstBuffer].mNumberChannels;
		srcSample = ((Float32 *)src->mBuffers[srcBuffer].mData ) + srcOffset * srcChansThisBuffer;
		dstSample = ((Float32 *)dst->mBuffers[dstBuffer].mData ) + dstOffset * dstChansThisBuffer;
		while ( 1 )
		{
			dstSample[dstChan] = srcSample[srcChan];
			
			srcChan++;
			if ( srcChan >= srcChansThisBuffer )
			{
				srcChan = 0;
				srcBuffer++;
				if ( srcBuffer >= srcNumberBuffers )
				{
					break;
				}
				srcChansThisBuffer = src->mBuffers[srcBuffer].mNumberChannels;
				srcSample = ((Float32 *)src->mBuffers[srcBuffer].mData ) + srcOffset * srcChansThisBuffer;
			}
			
			dstChan++;
			if ( dstChan >= dstChansThisBuffer )
			{
				dstChan = 0;
				dstBuffer++;
				if ( dstBuffer >= dstNumberBuffers )
				{
					break;
				}
				dstChansThisBuffer = dst->mBuffers[dstBuffer].mNumberChannels;
				dstSample = ((Float32 *)dst->mBuffers[dstBuffer].mData ) + dstOffset * dstChansThisBuffer;
			}
		}
		while ( leftoverDstChannels )
		{
			dstChan++;
			if ( dstChan >= dstChansThisBuffer )
			{
				dstChan = 0;
				dstBuffer++;
				if ( dstBuffer >= dstNumberBuffers )
				{
					break;
				}
				dstChansThisBuffer = dst->mBuffers[dstBuffer].mNumberChannels;
				dstSample = ((Float32 *)dst->mBuffers[dstBuffer].mData ) + dstOffset * dstChansThisBuffer;
			}
			dstSample[dstChan] = 0.0;
		}
	}
	
	return frame;
}

unsigned MTAudioBufferListCopy ( const AudioBufferList * src, unsigned srcOffset, AudioBufferList * dst, unsigned dstOffset, unsigned count )
{
	unsigned srcTotalFrames = MTAudioBufferListFrameCount ( src );
	unsigned dstTotalFrames = MTAudioBufferListFrameCount ( dst );
	
	if (( srcOffset > srcTotalFrames ) || ( dstOffset > dstTotalFrames ))
		return 0;
	
	count = MIN ( count, srcTotalFrames - srcOffset );
	count = MIN ( count, dstTotalFrames - dstOffset );
	
	if ( 0 == count )
		return 0;
	
	if ( _ABLsCanDoCompatibleCopy ( src, dst ))
		return _ABLCompatibleCopy ( src, srcOffset, dst, dstOffset, count );
	else
		return _ABLGenericCopy ( src, srcOffset, dst, dstOffset, count );
}

unsigned MTAudioBufferListClear ( AudioBufferList * aList, unsigned offset, unsigned count )
{
	unsigned buffer;
	unsigned channelsThisBuffer;
	unsigned totalFrames;
	unsigned char * dstBytes;
	unsigned numBytesToClear;
	unsigned byteOffset;
	
	totalFrames = MTAudioBufferListFrameCount ( aList );
	if ( offset > totalFrames )
		return 0;
	count = MIN ( count, totalFrames - offset );
	
	for ( buffer = 0; buffer < aList->mNumberBuffers; buffer++ )
	{
		channelsThisBuffer = aList->mBuffers[buffer].mNumberChannels;
		numBytesToClear = count * sizeof(Float32) * channelsThisBuffer;
		byteOffset = offset * sizeof(Float32) * channelsThisBuffer;
		dstBytes = aList->mBuffers[buffer].mData;
		memset ( dstBytes + byteOffset, 0, numBytesToClear );
	}
	return count;
}

unsigned MTAudioBufferListFrameCount ( const AudioBufferList * buf )
{
	return (( buf->mBuffers[0].mDataByteSize / buf->mBuffers[0].mNumberChannels ) / sizeof(Float32));
}

unsigned MTAudioBufferListChannelCount ( const AudioBufferList * buf )
{
	unsigned rv = 0;
	unsigned buffer;
	
	for ( buffer = 0; buffer < buf->mNumberBuffers; buffer++ )
	{
		rv += buf->mBuffers[buffer].mNumberChannels;
	}
	return rv;
}

