//
//  QSiChatMediator.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 7/5/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "iChatPresenceController.h"

#import <Cocoa/Cocoa.h>
@interface QSiChatMediator : NSObject {
  iChatPresenceController *presenceController;
}

- (BOOL)chatWithPerson:(NSString *)personID;
- (BOOL)sendText:(NSString *)text toAccount:(NSString *)accountID;
- (NSArray *)onlineBuddies;
- (BOOL)sendFile:(NSString *)path toAccount:(NSString *)accountID;
- (BOOL)initiateAudioWithAccount:(NSString *)accountID;
- (BOOL)initiateVideoWithAccount:(NSString *)accountID;
@end