//
//  MTByteBuffer.h
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Sun Dec 23 2001.
//  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
//

#import "MTBuffer.h"


@interface MTByteBuffer : MTBuffer {
	unsigned char * myBuffer;
}

- initWithCapacity:(unsigned)capacity;

- (unsigned) writeFromBytes:(void *)theBytes count:(unsigned)count waitForRoom:(Boolean)wait;
- (unsigned) readToBytes:   (void *)theBytes count:(unsigned)count waitForData:(Boolean)wait;

/*
** the following methods are implemented by the superclass.  they're
** included here for documentation purposes

- (unsigned) count;
- (unsigned) capacity;
- (void) flush;

*/

@end
