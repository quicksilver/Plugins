//
//  MTBuffer.m
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Mon Mar 22 2004.
//  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
//

#import "MTBuffer.h"

enum {
	kMTBufferEmpty,
	kMTBufferDirty,
	kMTBufferSpaceLeft,
	kMTBufferFull,
};


@implementation MTBuffer

- init
{
	[self dealloc];
	return nil;
}

- initWithCapacity:(unsigned)capacity
{
	[super init];
	bufferSize = capacity;
	bufferHead = 0;
	framesInBuffer = 0;
	readLock = [[NSConditionLock alloc] initWithCondition:kMTBufferEmpty];
	writeLock = [[NSConditionLock alloc] initWithCondition:kMTBufferSpaceLeft];
	generalLock = [[NSLock alloc] init];
	if ((readLock == nil) || (writeLock == nil) || (generalLock == nil))
	{
		[self release];
		return nil;
	}
	return self;
}

- (void) performWriteFromContext:(void *)theContext offset:(unsigned)theOffset count:(unsigned)count
{ }

- (void) performReadToContext:   (void *)theContext offset:(unsigned)theOffset count:(unsigned)count
{ }

- (void) bufferDidEmpty
{ }


- (unsigned) writeFromContext:(void *)theContext count:(unsigned)count waitForRoom:(Boolean)wait
{
	unsigned rv = 0;
	unsigned idx;
	unsigned framesToCopy;
	Boolean keepTrying;
	
	keepTrying = ( count > 0 );
	
	while (keepTrying)
	{
		if ( wait )
			[writeLock lockWhenCondition:kMTBufferSpaceLeft];
		else
			[writeLock lock];
		[generalLock lock];
		idx = bufferHead + framesInBuffer;
		while (( framesInBuffer < bufferSize) && count )
		{
			if (idx >= bufferSize) idx -= bufferSize;
			framesToCopy = MIN (( bufferSize - framesInBuffer ), count );
			framesToCopy = MIN ( framesToCopy, ( bufferSize - idx ));
			[self performWriteFromContext:theContext offset:idx count:framesToCopy];
			idx += framesToCopy;
			rv += framesToCopy;
			count -= framesToCopy;
			framesInBuffer += framesToCopy;
		}
		[readLock unlockWithCondition:kMTBufferDirty];
		if (framesInBuffer == bufferSize) // buffer full
			[writeLock unlockWithCondition:kMTBufferFull];
		else
			[writeLock unlockWithCondition:kMTBufferSpaceLeft];
		[generalLock unlock];
		keepTrying = wait && ( count > 0 );
	}
	return rv;
}


- (unsigned) readToContext:   (void *)theContext count:(unsigned)count waitForData:(Boolean)wait
{
	unsigned rv = 0;
	unsigned framesToCopy;
	Boolean keepTrying;
	
	keepTrying = ( count > 0 );
	
	while (keepTrying)
	{
		if ( wait )
			[readLock lockWhenCondition:kMTBufferDirty];
		else
			[readLock lock];
		[generalLock lock];
		while (framesInBuffer && count)
		{
			framesToCopy = MIN ( framesInBuffer, count );
			framesToCopy = MIN ( framesToCopy, ( bufferSize - bufferHead ));
			[self performReadToContext:theContext offset:bufferHead count:framesToCopy];
			framesInBuffer -= framesToCopy;
			rv += framesToCopy;
			count -= framesToCopy;
			bufferHead += framesToCopy;
			if (bufferHead >= bufferSize) bufferHead = 0;
		}
		[writeLock unlockWithCondition:kMTBufferSpaceLeft];
		if (framesInBuffer == 0)
		{
			[self bufferDidEmpty];
			[readLock unlockWithCondition:kMTBufferEmpty];
		}
		else
			[readLock unlockWithCondition:kMTBufferDirty];
		[generalLock unlock];
		keepTrying = wait && ( count > 0 );
	}
	return rv;
}

- (void) flush
{
	[generalLock lock];
	framesInBuffer = 0;
	[self bufferDidEmpty];
	[writeLock unlockWithCondition:kMTBufferSpaceLeft];
	[readLock unlockWithCondition:kMTBufferEmpty];
	[generalLock unlock];
}

- (unsigned) capacity
{
	return bufferSize;
}

- (unsigned) count
{
	return framesInBuffer;
}

- (void) dealloc
{
	if (readLock) [readLock release];
	if (writeLock) [writeLock release];
	if (generalLock) [generalLock release];
	[super dealloc];
}

@end
