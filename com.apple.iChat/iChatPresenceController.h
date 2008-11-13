//
//  iChatPresenceController.h
//  iChatElement
//
//  Created by Nicholas Jitkoff on 12/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface iChatPresenceController : NSObject {
  NSMutableArray *identities;
  NSMutableDictionary *identitiesByAccount;
  NSMutableDictionary *infoForAllScreenNames;
}
@property(retain) NSMutableArray *identities;
@property(retain) NSMutableDictionary *identitiesByAccount;
@property(retain) NSMutableDictionary *infoForAllScreenNames;


- (NSArray *)onlineBuddies;
@end
