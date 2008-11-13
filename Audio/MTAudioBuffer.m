//
//  MTAudioBuffer.m
//  MTCoreAudio
//
//  Created by Michael Thornburgh on Wed Mar 31 2004.
//  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
//

#import "MTAudioBuffer.h"
#import "MTAudioBufferListUtils.h"

struct copyContext {
	AudioBufferList * userBuffer;
	const AudioBufferList * userBufferRO;
	unsigned userBufferOffset;
	Float64 rateScalar;
};

@implementation MTAudioBuffer

- init
{
	return [self initWithCapacityFrames:44100 channels:2];
}

- initWithCapacityFrames:(unsigned)frames channels:(unsigned)channels
{
	if ( 0 == channels )
	{
		[self dealloc];
		return nil;
	}
	
	self = [super initWithCapacity:frames];
	if ( ! self )
		return self;

	effectiveRateScalar = 1.0;
	
	myBuffer = MTAudioBufferListNew ( channels, frames, NO );
	if ( NULL == myBuffer )
	{
		[self dealloc];
		return nil;
	}
	
	return self;
}

- initWithCapacity:(unsigned)frames
{
	return [self initWithCapacityFrames:frames channels:2];
}

- (void) bufferDidEmpty
{
	[super bufferDidEmpty];
	effectiveRateScalar = 1.0;
	scaledFramesInBuffer = 0.0;
}

- (void) performWriteFromContext:(void *)theContext offset:(unsigned)theOffset count:(unsigned)count
{
	struct copyContext * ctx = theContext;
	MTAudioBufferListCopy ( ctx->userBufferRO, ctx->userBufferOffset, myBuffer, theOffset, count );
	scaledFramesInBuffer += count * ctx->rateScalar;
	effectiveRateScalar = scaledFramesInBuffer / ( framesInBuffer + count );
	ctx->userBufferOffset += count;
}

- (void) performReadToContext: (void *)theContext offset:(unsigned)theOffset count:(unsigned)count
{
	struct copyContext * ctx = theContext;
	MTAudioBufferListCopy ( myBuffer, theOffset, ctx->userBuffer, ctx->userBufferOffset, count );
	scaledFramesInBuffer = ( framesInBuffer - count ) * effectiveRateScalar;
	ctx->userBufferOffset += count;
}

- (unsigned) writeFromAudioBufferList:(const AudioBufferList *)theABL maxFrames:(unsigned)count rateScalar:(Float64)rateScalar waitForRoom:(Boolean)wait
{
	struct copyContext theContext;
	
	theContext.userBuffer = NULL;
	theContext.userBufferRO = theABL;
	theContext.userBufferOffset = 0;
	theContext.rateScalar = rateScalar;
	
	count = MIN ( count, MTAudioBufferListFrameCount ( theABL ));
	
	return [self writeFromContext:&theContext count:count waitForRoom:wait];
}

- (unsigned) readToAudioBufferList:(AudioBufferList *)theABL maxFrames:(unsigned)count waitForData:(Boolean)wait
{
	struct copyContext theContext;
	
	theContext.userBuffer = theABL;
	theContext.userBufferRO = NULL;
	theContext.userBufferOffset = 0;
	theContext.rateScalar = 1.0;
	
	count = MIN ( count, MTAudioBufferListFrameCount ( theABL ));
	
	return [self readToContext:&theContext count:count waitForData:wait];
}

- (Float64) rateScalar
{
	return effectiveRateScalar;
}

- (Float64) scaledCount
{
	return scaledFramesInBuffer;
}

- (unsigned) channels
{
	return MTAudioBufferListChannelCount ( myBuffer );
}

- (void) dealloc
{
	MTAudioBufferListDispose ( myBuffer );
	[super dealloc];
}

@end
