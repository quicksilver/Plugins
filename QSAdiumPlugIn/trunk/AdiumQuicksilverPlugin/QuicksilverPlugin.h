//
//  QuicksilverPlugin.h
//  AdiumQuicksilverPlugin
//
//  Created by Brian Donovan on 08/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSConnection.h>
#import <Adium/Adium.h>
/*#import <Adium/AIListContact.h>
#import <Adium/AIContentMessage.h>
#import <Adium/AIContactController.h>
#import <Adium/AIMetaContact.h>
#import <Adium/ESApplescriptabilityController.h>*/

#define foreach(x,y) id x;NSEnumerator *rwEnum=[y objectEnumerator];while(x=[rwEnum nextObject])

@class AIHTMLDecoder;
#define GROUP_ACCOUNT_STATUS   @"Account Status"
#define CONTACT_SEEN_ONLINE_YES				@"Contact_SeenOnlineYes"

typedef enum {
	AIFilterIncoming = 0,   // Content we are receiving
	AIFilterOutgoing		// Content we are sending
} AIFilterDirection;

typedef enum {
	AIFilterContent = 0,		// Changes actual message and non-message content
	AIFilterDisplay,			// Changes only how non-message content is displayed locally (Profiles, aways, auto-replies, ...)
	AIFilterMessageDisplay,  	// Changes only how messages are displayed locally
	
	//A special content mode for AIM auto-replies that will only apply to bounced away messages.  This allows us to
	//filter %n,%t,... just like the official client.  A small tumor in our otherwise beautiful filter system *cry*/
	AIFilterAutoReplyContent
	
} AIFilterType;

@interface QuicksilverPlugin : AIPlugin {
	NSConnection *conn;
}

/* retrieving information */
- (AIAdium *)adium;
- (NSArray *)contacts;
- (NSArray *)groups;
- (NSArray *)groupsRestrictingToVisible:(BOOL)visible;
- (NSArray *)chats;
- (AIListContact *)contactWithServiceID:(NSString *)serviceID UID:(NSString *)username forSendingContentType:(NSString *)type;
- (NSArray *)contactsInGroup:(AIListGroup *)group;
- (NSArray *)contactsWithGroupUID:(NSString *)groupUID;
- (NSArray *)contactsWithGroupUID:(NSString *)groupUID restrictingToVisible:(BOOL)visible;
- (AIListGroup *)groupWithUID:(NSString *)groupUID;
- (NSArray *)consolidateContacts:(NSArray *)contacts;
- (NSArray *)consolidatedContactsWithGroupUID:(NSString *)groupUID restrictingToVisible:(BOOL)visible;
- (NSAttributedString *)statusMessageForContactWithServiceID:(NSString *)serviceID UID:(NSString *)username;

/* sending content */
- (void)sendMessage:(NSString *)message toContact:(AIListContact *)contact autoreply:(BOOL)autoreply;
- (int)sendMessage:(NSString *)message toContact:(NSString *)username withServiceID:(NSString *)service autoreply:(BOOL)autoreply laterIfOffline:(BOOL)laterIfOffline;
- (void)sendMessageLater:(NSString *)message toContact:(AIListContact *)contact autoreply:(BOOL)autoreply;

/* opening chats */
- (AIChat *)openChatWithContact:(AIListContact *)contact active:(BOOL)active;
- (AIChat *)openChatWithContact:(NSString *)username withServiceID:(NSString *)serviceID active:(BOOL)active;

/* setting properties */
- (void)setAvailableMessage:(NSString *)message;

@end
