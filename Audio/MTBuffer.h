//
//  MTBuffer.h
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Mon Mar 22 2004.
//  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MTBuffer : NSObject {
	NSConditionLock * readLock, * writeLock;
	NSLock * generalLock;
	unsigned bufferHead, framesInBuffer;
	unsigned bufferSize;
}

- initWithCapacity:(unsigned)capacity;

- (void) flush;
- (unsigned) capacity;
- (unsigned) count;

- (unsigned) writeFromContext:(void *)theContext count:(unsigned)count waitForRoom:(Boolean)wait;
- (unsigned) readToContext:   (void *)theContext count:(unsigned)count waitForData:(Boolean)wait;


// the following methods are intended to be overridden by subclasses.
// MTBuffer's implementation does nothing

- (void) bufferDidEmpty;

- (void) performWriteFromContext:(void *)theContext offset:(unsigned)theOffset count:(unsigned)count;
- (void) performReadToContext:   (void *)theContext offset:(unsigned)theOffset count:(unsigned)count;

@end
