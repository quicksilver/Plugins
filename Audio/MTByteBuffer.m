//
//  MTByteBuffer.m
//  MTCoreAudio.framework
//
//  Created by Michael Thornburgh on Sun Dec 23 2001.
//  Copyright (c) 2004 Michael Thornburgh. All rights reserved.
//

#import "MTByteBuffer.h"

struct copyContext {
	unsigned char * userBuffer;
};

@implementation MTByteBuffer

- initWithCapacity:(unsigned)capacity
{
	self = [super initWithCapacity:capacity];
	if ( ! self )
		return self;
	myBuffer = (unsigned char *) malloc ( capacity );
	if (myBuffer == NULL)
	{
		[self release];
		return nil;
	}
	return self;
}

- (void) performWriteFromContext:(void *)theContext offset:(unsigned)theOffset count:(unsigned)count
{
	struct copyContext * ctx = theContext;
	memcpy ( myBuffer + theOffset, ctx->userBuffer, count );
	ctx->userBuffer += count;
}

- (void) performReadToContext: (void *)theContext offset:(unsigned)theOffset count:(unsigned)count
{
	struct copyContext * ctx = theContext;
	memcpy ( ctx->userBuffer, myBuffer + theOffset, count );
	ctx->userBuffer += count;
}


- (unsigned) writeFromBytes:(void *)theBytes count:(unsigned)count waitForRoom:(Boolean)wait
{
	struct copyContext theContext = { theBytes };
	return [self writeFromContext:&theContext count:count waitForRoom:wait];
}

- (unsigned) readToBytes:(void *)theBytes count:(unsigned)count waitForData:(Boolean)wait
{
	struct copyContext theContext = { theBytes };
	return [self readToContext:&theContext count:count waitForData:wait];
}

- (void) dealloc
{
	if (myBuffer) free(myBuffer);
	[super dealloc];
}

@end
