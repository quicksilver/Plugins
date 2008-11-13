// $Id: SkypeAPI.h,v 1.4 2005/04/17 00:12:09 teelem Exp $
//
//  SkypeAPI.h
//  SkypeMac
//
//  Created by Janno Teelem on 12/04/2005.
//  Copyright (c) 2005 Skype Technologies S.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SkypeAPIDelegate;

@interface SkypeAPI : NSObject 
{

}

+ (BOOL)isSkypeRunning;

+ (void)setSkypeDelegate:(NSObject<SkypeAPIDelegate>*)aDelegate;
+ (NSObject<SkypeAPIDelegate>*)skypeDelegate;
+ (void)removeSkypeDelegate;

+ (void)connect;
+ (void)disconnect;

+ (void)sendSkypeCommand:(NSString*)aCommandString;
@end


// delegate protocol
@protocol SkypeAPIDelegate
- (NSString*)clientApplicationName;
@end

// delegate informal protocol
@interface NSObject (SkypeAPIDelegateInformalProtocol)
- (void)skypeNotificationReceived:(NSString*)aNotificationString;
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode;				// 0 - failed, 1 - success
- (void)skypeBecameAvailable:(NSNotification*)aNotification;
- (void)skypeBecameUnavailable:(NSNotification*)aNotification;
@end

