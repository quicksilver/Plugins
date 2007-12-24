//
//  NSDICTURLProtocol.h
//  DictProtocolTest
//
//  Created by Kevin Ballard on 11/2/04.
//  Copyright 2004 Kevin Ballard. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <CoreFoundation/CFSocket.h>

@interface NSDICTURLProtocol : NSURLProtocol {
	CFSocketRef socketRef;
	CFRunLoopSourceRef socketRunLoopSource;
	NSTimer *timeoutTimer;
	NSString *action;
	NSArray *args;
	NSNumber *responseIndex;
	
	BOOL _receivedResponse;
}

@end
