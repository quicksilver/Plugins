//
//  MTCoreAudioIOProcMux.m
//  MTCoreAudio
//
//  Created by Michael Thornburgh on Wed Oct 02 2002.
//  Copyright (c) 2002 Michael Thornburgh. All rights reserved.
//

#import "MTCoreAudioStreamDescription.h"
#import "MTCoreAudioTypes.h"
#import "MTCoreAudioStream.h"
#import "MTCoreAudioDevice.h"
#import "MTCoreAudioDevicePrivateAdditions.h"

#import "MTCoreAudioIOProcMux.h"

#import <vecLib/vecLib.h>

#include <string.h>



@interface MTCoreAudioIOProcMux(MTCoreAudioIOProcMuxPrivateMethods)
- (OSStatus) dispatchIOProcsWithTimeStamp:(const AudioTimeStamp *)inNow inputData:(const AudioBufferList *)inInputData inputTime:(const AudioTimeStamp *)inInputTime outputData:(AudioBufferList *)outOutputData outputTime:(const AudioTimeStamp *)inOutputTime;
@end

static NSMutableDictionary * deviceMultiplexers;


static OSStatus demuxIOProc (
        AudioDeviceID           inDevice,
        const AudioTimeStamp*   inNow,
        const AudioBufferList*  inInputData,
        const AudioTimeStamp*   inInputTime,
        AudioBufferList*        outOutputData, 
        const AudioTimeStamp*   inOutputTime,
        void*                   inClientData
)
{
	MTCoreAudioIOProcMux * theMux = inClientData;
	
	return [theMux dispatchIOProcsWithTimeStamp:inNow inputData:inInputData inputTime:inInputTime outputData:outOutputData outputTime:inOutputTime];
}


@implementation MTCoreAudioIOProcMux
+ (void) initialize
{
	deviceMultiplexers = [NSMutableDictionary new];
}

- init
{
	[self dealloc];
	return nil;
}

- (MTCoreAudioIOProcMux *) initWithAudioDeviceID:(AudioDeviceID)deviceID
{
	[super init];
	myDeviceID = deviceID;
	deviceProxies = [NSMutableSet new];
	lock = [NSLock new];
	registrationLock = [NSRecursiveLock new];
	eachOutputData = 0;
	return self;
}

+ (MTCoreAudioIOProcMux *) muxForDevice:(MTCoreAudioDevice *)theDevice
{
	MTCoreAudioIOProcMux * rv;
	NSNumber * deviceID = [NSNumber numberWithUnsignedLong:[theDevice deviceID]];
	
	rv = [deviceMultiplexers objectForKey:deviceID];
	if ( nil == rv )
	{
		rv = [[[self class] alloc] initWithAudioDeviceID:[deviceID unsignedLongValue]];
		[deviceMultiplexers setObject:rv forKey:deviceID];  // retain
		[rv release]; // balance the retain above
	}
	return rv;
}

- (void) updateDeviceProxyCache
{
	[deviceProxyListCache release];
	deviceProxyListCache = [[deviceProxies allObjects] retain];
	deviceProxyCountCache = [deviceProxies count];
}

- (void) unRegisterDevice:(MTCoreAudioDevice *)theDevice
{
	NSValue * myProxy = [NSValue valueWithNonretainedObject:theDevice];
	Boolean shouldStop = NO;

	[registrationLock lock];
	[lock lock];
	
	[deviceProxies removeObject:myProxy];
	[self updateDeviceProxyCache];
	if (( 0 == deviceProxyCountCache ) && isRunning )
	{
		isRunning = NO;
		shouldStop = YES;
	}
	
	[lock unlock];
	
	if ( shouldStop )
	{
		// these can't be done inside the same lock that's held by the IOProc
		// dispatcher, because this can lead to a deadlock with CoreAudio's CAGuard lock
		AudioDeviceStop ( myDeviceID, demuxIOProc );
		AudioDeviceRemoveIOProc ( myDeviceID, demuxIOProc );
	}
	
	[registrationLock unlock];
}

+ (void) unRegisterDevice:(MTCoreAudioDevice *)theDevice
{
	[[[self class] muxForDevice:theDevice] unRegisterDevice:theDevice];
}

- (Boolean) registerDevice:(MTCoreAudioDevice *)theDevice
{
	NSValue * myProxy = [NSValue valueWithNonretainedObject:theDevice];
	Boolean shouldStart = NO;
	Boolean didStart = YES;
	OSStatus rv = noErr;
	
	[registrationLock lock];
	[lock lock];
	
	[deviceProxies addObject:myProxy];
	[self updateDeviceProxyCache];
	if ( ! isRunning )
	{
		isRunning = YES;
		shouldStart = YES;
	}
	
	[lock unlock];
	
	if ( shouldStart )
	{
		// these can't be done inside the same lock that's held by the IOProc
		// dispatcher, because this can lead to a deadlock with CoreAudio's CAGuard lock
		rv = AudioDeviceAddIOProc ( myDeviceID, demuxIOProc, self );
		if ( noErr == rv )
		{
			rv = AudioDeviceStart ( myDeviceID, demuxIOProc );
		}
		
		if ( noErr != rv )
		{
			[self unRegisterDevice:theDevice];
			didStart = NO;
		}
	}
	
	[registrationLock unlock];
	
	if ( ! didStart )
	{
		[theDevice dispatchIOStartDidFailForReason:rv];
	}
	
	return didStart;
}

+ (Boolean) registerDevice:(MTCoreAudioDevice *)theDevice
{
	return [[[self class] muxForDevice:theDevice] registerDevice:theDevice];
}

- (void) setPause:(Boolean)shouldPause forDevice:(MTCoreAudioDevice *)theDevice
{
	[lock lock];
	[theDevice doSetPause:shouldPause];
	[lock unlock];
}

+ (void) setPause:(Boolean)shouldPause forDevice:(MTCoreAudioDevice *)theDevice
{
	[[[self class] muxForDevice:theDevice] setPause:shouldPause forDevice:theDevice];
}


- (void) releaseAudioBufferList
{
	UInt32 x;
	
	if ( 0 == eachOutputData )
		return;

	for ( x = 0; x < eachOutputData->mNumberBuffers; x++ )
	{
		free ( eachOutputData->mBuffers[x].mData );
	}
	free ( eachOutputData );
	eachOutputData = 0;
}

- (Boolean) bufferIsEquivalentToAudioBufferList:(AudioBufferList *)aBuffer
{
	UInt32 x;
	
	if (( NULL == aBuffer ) && ( NULL == eachOutputData ))
		return YES;
	
	if (( NULL == aBuffer ) || ( NULL == eachOutputData ))
		return NO;
	
	if ( aBuffer->mNumberBuffers != eachOutputData->mNumberBuffers )
		return NO;
	
	for ( x = 0; x < eachOutputData->mNumberBuffers; x++ )
	{
		if ( aBuffer->mBuffers[x].mNumberChannels != eachOutputData->mBuffers[x].mNumberChannels )
			return NO;
		if ( aBuffer->mBuffers[x].mDataByteSize != eachOutputData->mBuffers[x].mDataByteSize )
			return NO;
	}
	return YES;
}

- (Boolean) matchBufferToAudioBufferList:(AudioBufferList *)liveAudioBufferList
{
	UInt32 x;
	
	if ( [self bufferIsEquivalentToAudioBufferList:liveAudioBufferList] )
		return YES;
		
	[self releaseAudioBufferList];
	
	if ( NULL == liveAudioBufferList )
		return YES;
	
	eachOutputData = calloc ( 1, sizeof(AudioBufferList) + sizeof(AudioBuffer) * liveAudioBufferList->mNumberBuffers );
	if ( NULL == eachOutputData )
		return NO;

	eachOutputData->mNumberBuffers = liveAudioBufferList->mNumberBuffers;
	for ( x = 0; x < liveAudioBufferList->mNumberBuffers; x++ )
	{
		eachOutputData->mBuffers[x].mNumberChannels = liveAudioBufferList->mBuffers[x].mNumberChannels;
		eachOutputData->mBuffers[x].mDataByteSize = liveAudioBufferList->mBuffers[x].mDataByteSize;
		eachOutputData->mBuffers[x].mData = malloc ( liveAudioBufferList->mBuffers[x].mDataByteSize );
		if ( NULL == eachOutputData->mBuffers[x].mData )
		{
			[self releaseAudioBufferList];
			return NO;
		}
	}
	return YES;
}

- (void) mixIntoAudioBufferList:(AudioBufferList *)liveAudioBufferList
{
	unsigned x, numSamples;
	Float32 * srcBuffer, *dstBuffer;

	if ( NULL == eachOutputData )
		return;
	
	for ( x = 0; x < eachOutputData->mNumberBuffers; x++ )
	{
		numSamples = ( MIN(eachOutputData->mBuffers[x].mDataByteSize, liveAudioBufferList->mBuffers[x].mDataByteSize)) / sizeof(Float32);
		srcBuffer = eachOutputData->mBuffers[x].mData;
		dstBuffer = liveAudioBufferList->mBuffers[x].mData;
		vadd ( srcBuffer, 1, dstBuffer, 1, dstBuffer, 1, numSamples );
	}
}

- (void) clearAudioBufferList
{
	unsigned x;
	
	if ( NULL == eachOutputData )
		return;
	
	for ( x = 0; x < eachOutputData->mNumberBuffers; x++ )
	{
		memset ( eachOutputData->mBuffers[x].mData, 0, eachOutputData->mBuffers[x].mDataByteSize );
	}
}

- (void) resetAudioBufferListBufferSizesFrom:(AudioBufferList *)liveAudioBufferList
{
	unsigned x;
	
	if ( NULL == eachOutputData )
		return;
	
	for ( x = 0; x < eachOutputData->mNumberBuffers; x++ )
	{
		eachOutputData->mBuffers[x].mDataByteSize = liveAudioBufferList->mBuffers[x].mDataByteSize;
	}
}

- (OSStatus) dispatchIOProcsWithTimeStamp:(const AudioTimeStamp *)inNow inputData:(const AudioBufferList *)inInputData inputTime:(const AudioTimeStamp *)inInputTime outputData:(AudioBufferList *)outOutputData outputTime:(const AudioTimeStamp *)inOutputTime
{
	MTCoreAudioDevice * theDevice;
	OSStatus rv = noErr;
	UInt32 x;
	
	[lock lock];
	
	if ( 1 == deviceProxyCountCache )
	{
		// if there's only one registrant, avoid all that clearing and mixing business
		[[[deviceProxyListCache objectAtIndex:0] nonretainedObjectValue] dispatchIOProcWithTimeStamp:inNow inputData:inInputData inputTime:inInputTime outputData:outOutputData outputTime:inOutputTime];
	}
	else
	{
		if ( [self matchBufferToAudioBufferList:outOutputData] )
		{		
			for ( x = 0; x < deviceProxyCountCache; x++ )
			{
				theDevice = [[deviceProxyListCache objectAtIndex:x] nonretainedObjectValue];
				[self clearAudioBufferList];
				[theDevice dispatchIOProcWithTimeStamp:inNow inputData:inInputData inputTime:inInputTime outputData:eachOutputData outputTime:inOutputTime];
				[self mixIntoAudioBufferList:outOutputData];
				[self resetAudioBufferListBufferSizesFrom:outOutputData];
			}
		}
	}
	[lock unlock];
	
	return rv;
}

- (void) dealloc
{
	[self releaseAudioBufferList];
	[lock release];
	[registrationLock release];
	[deviceProxyListCache release];
	[deviceProxies release];
	[super dealloc];
}
@end
