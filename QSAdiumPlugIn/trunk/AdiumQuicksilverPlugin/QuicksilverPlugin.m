//
//  QuicksilverPlugin.m
//  AdiumQuicksilverPlugin
//
//  Created by Brian Donovan on 08/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QuicksilverPlugin.h"

@implementation QuicksilverPlugin

#pragma mark Adium

- (AIAdium *)adium {
	return adium;
}

#pragma mark Contacts

// transforms the contact array into an array of metacontacts where they are available, discarding duplicates
- (NSArray *)consolidateContacts:(NSArray *)contacts {
	NSMutableArray *contactList = [NSMutableArray arrayWithCapacity:[contacts count]];

	foreach (contact, contacts) {
		contact = [[adium contactController] parentContactForListObject:contact];
		if (![contactList containsObject:contact])
			[contactList addObject:contact];
	}
	
	return contactList;
}

// gets all contacts
- (NSArray *)contacts {
	return [[[adium contactController] allContactsInGroup:nil subgroups:YES onAccount:nil] allObjects];
}

// gets all groups
- (NSArray *)groups {
	return [[[[adium contactController] contactList] objectEnumerator] allObjects];
}

// gets all groups with visible contacts (online)
- (NSArray *)groupsRestrictingToVisible:(BOOL)visible {
	int i = 0;
	NSMutableArray *groups = [NSMutableArray arrayWithArray:[self groups]];
	
	if (visible) {
		while (i < [groups count]) {
			/* check that there are online contacts in the group */
			BOOL online = NO;

			foreach (contact, [self contactsInGroup:[groups objectAtIndex:i]]) {
				online |= [contact online];
			}
			
			/* if the group is empty, remove it */
			if (!online)
				[groups removeObjectAtIndex:i];
			else
				i++;
		}
	}
	
	return groups;
}

// gets all open chats
- (NSArray *)chats {
	return [[adium interfaceController] openChats];
}

// gets all contacts in the given group
- (NSArray *)contactsInGroup:(AIListGroup *)group {
	return [[adium contactController] allContactsInGroup:group
											   subgroups:YES
											   onAccount:nil];	
}

// gets all contacts in the group with the given groupUID
- (NSArray *)contactsWithGroupUID:(NSString *)groupUID {
	return [self contactsInGroup:[self groupWithUID:groupUID]];
}

// gets all contacts in the group with the given groupUID, optionally restricting to online contacts
- (NSArray *)contactsWithGroupUID:(NSString *)groupUID restrictingToVisible:(BOOL)visible {
	if (!visible)
		return [self contactsWithGroupUID:groupUID];
	
	NSMutableArray *contacts = [NSMutableArray arrayWithArray:[self contactsWithGroupUID:groupUID]];
	
	int i;
	for (i = 0; i < [contacts count]; i++) {
		if (![[contacts objectAtIndex:i] online])
			[contacts removeObjectAtIndex:i--];
	}
	
	NSLog(@"got group with %i contacts", [contacts count]);
	return [NSArray arrayWithArray:contacts];
}

// gets all metacontacts where applicable in the group with the given groupUID, optionally restricting to online contacts
- (NSArray *)consolidatedContactsWithGroupUID:(NSString *)groupUID restrictingToVisible:(BOOL)visible {
	return [self consolidateContacts:[self contactsWithGroupUID:groupUID restrictingToVisible:visible]];
}

// gets the group with the given groupUID
- (AIListGroup *)groupWithUID:(NSString *)groupUID {
	return [[adium contactController] groupWithUID:groupUID];
}

// gets all contacts in a given metacontact
- (NSArray *)contactsForMetaContact:(AIMetaContact *)metaContact {
	return [metaContact listContacts];
}

// gets all contacts in a metacontact with the given ID
- (NSArray *)contactsForMetaContactWithID:(NSString *)contactID {
	AIListObject *contact = [[adium contactController] existingListObjectWithUniqueID:contactID];
	
	return [contact isKindOfClass:[AIMetaContact class]] ? [contact listContacts] : nil;
}

// sends a message to a named contact on a particular service, optionally as an autoreply
- (int)sendMessage:(NSString *)message toContact:(NSString *)username withServiceID:(NSString *)service autoreply:(BOOL)autoreply laterIfOffline:(BOOL)laterIfOffline {
	AIListContact *contact;
	
	contact = [self contactWithServiceID:service UID:username forSendingContentType:@"Message"];

	if (contact) {
		if (laterIfOffline && ![contact online]) {
			[self sendMessageLater:message
						 toContact:contact
						 autoreply:autoreply];
			return 1;
		} else {
			[self sendMessage:message
					toContact:contact
					autoreply:autoreply];
			return 0;
		}
	}
	return -1;
}

// sends a message to a contact, optionally as an autoreply
- (void)sendMessage:(NSString *)message toContact:(AIListContact *)contact autoreply:(BOOL)autoreply {
	AIChat *chat = nil;
//	NSAttributedString  *attributedMessage = [AIHTMLDecoder decodeHTML:message];
	
	AIContentMessage *messageContent;
	
	/* get an existing chat */
	chat = [[adium contentController] existingChatWithContact:contact];
	
	if (!chat) {
		/* no chat exists with this contact, create one */
		chat = [[adium contentController] openChatWithContact:contact];
	}
	
	/* create the message to send */
	messageContent = [AIContentMessage messageInChat:chat
										  withSource:[chat account]
										 destination:contact
												date:nil
											 message:nil
										   autoreply:autoreply];
	[messageContent setMessageHTML:message];
	/* send the message */
	[[adium contentController] sendContentObject:messageContent];
}

- (void)sendMessageLater:(NSString *)message toContact:(AIListContact *)contact autoreply:(BOOL)autoreply {
	AIListObject *listObject;
	
	//Put the alert on the metaContact containing this listObject if applicable
	listObject = [[adium contactController] parentContactForListObject:contact];
	
	if (listObject) {
		NSMutableDictionary *detailsDict, *alertDict;
		
		detailsDict = [NSMutableDictionary dictionary];
		[detailsDict setObject:[[[adium accountController] preferredAccountForSendingContentType:@"Message" toContact:listObject] internalObjectID] forKey:@"Account ID"];
		[detailsDict setObject:[NSNumber numberWithBool:YES] forKey:@"Allow Other"];
		[detailsDict setObject:[listObject internalObjectID] forKey:@"Destination ID"];
		
		alertDict = [NSMutableDictionary dictionary];
		[alertDict setObject:detailsDict forKey:@"ActionDetails"];
		[alertDict setObject:CONTACT_SEEN_ONLINE_YES forKey:@"EventID"];
		[alertDict setObject:@"SendMessage" forKey:@"ActionID"];
		[alertDict setObject:[NSNumber numberWithBool:YES] forKey:@"OneTime"];
		
		[alertDict setObject:listObject forKey:@"TEMP-ListObject"];
		
		[[adium contentController] filterAttributedString:[[[NSAttributedString alloc] initWithString:message] autorelease]
										  usingFilterType:AIFilterContent
												direction:AIFilterOutgoing
											filterContext:listObject
										  notifyingTarget:self
												 selector:@selector(gotFilteredMessageToSendLater:receivingContext:)
												  context:alertDict];
		}	
}

- (void)gotFilteredMessageToSendLater:(NSAttributedString *)filteredMessage receivingContext:(NSMutableDictionary *)alertDict
{
	NSMutableDictionary	*detailsDict;
	AIListObject		*listObject;
	
	detailsDict = [alertDict objectForKey:@"ActionDetails"];
	[detailsDict setObject:[filteredMessage dataRepresentation] forKey:@"Message"];
	
	listObject = [[alertDict objectForKey:@"TEMP-ListObject"] retain];
	[alertDict removeObjectForKey:@"TEMP-ListObject"];
	
	[[adium contactAlertsController] addAlert:alertDict 
								 toListObject:listObject
							 setAsNewDefaults:NO];
	[listObject release];
}

// opens a chat with a named contact on a given service, optionally activating it
- (AIChat *)openChatWithContact:(NSString *)username withServiceID:(NSString *)serviceID active:(BOOL)active {
	AIListContact *contact;
	
	contact = [self contactWithServiceID:serviceID UID:username forSendingContentType:@"Message"];
	
	if (contact)
		[self openChatWithContact:contact active:active];
}

// opens a chat with a contact, optionally activating it
- (AIChat *)openChatWithContact:(AIListContact *)contact active:(BOOL)active {
//	NSLog(@"openChatWithContact:%@ active:%@", [contact displayName], active);
	
	/* get an existing chat */
	AIChat *chat = [[adium contentController] existingChatWithContact:contact];
	
	if (!chat) {
		/* no chat exists, create it */
		chat = [[adium contentController] openChatWithContact:contact];
	}
	
	if (active && chat) {
		/* activate the chat and Adium */
		[[adium interfaceController] setActiveChat:chat];
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	}
	
	return chat;
}

/*!
 * @brief Sets the user's status to available with a message.
 *
 * @param message The message to use as the available message.
 */
- (void)setAvailableMessage:(NSString *)message {
	[self setAwayMessage:message];
}

/*!
 * @brief Sets the user's status to away with a message.
 *
 * @param message The message to use as the away message.
 */
- (void)setAwayMessage:(NSString *)message {
	//Take the string and turn it into an attributed string (in case we were passed HTML)
	NSData  *attributedStatusMessage = [[AIHTMLDecoder decodeHTML:message] dataRepresentation];
	
	//Set the away
    [[adium preferenceController] setPreference:attributedStatusMessage forKey:@"AwayMessage" group:GROUP_ACCOUNT_STATUS];
    [[adium preferenceController] setPreference:nil forKey:@"Autoresponse" group:GROUP_ACCOUNT_STATUS];	
}

/*!
 * @brief Gets the preferred contact for the named service, username, and content type.
 *
 * This is just a wrapper for [AIContactController preferredContactWithUID:andServiceID:forSendingContentType]
 * which is used to reduce the number of NSProxy calls.
 *
 * @param serviceID The identifier for the service to use.
 * @param username The named user to get the contact for (not fully qualified).
 * @param type The type of content we want to send.
 * 
 * @result An AIListContact which points to the same person as specified by serviceID and username.
 */
- (AIListContact *)contactWithServiceID:(NSString *)serviceID UID:(NSString *)username forSendingContentType:(NSString *)type {
	return [[adium contactController] preferredContactWithUID:username
												 andServiceID:serviceID
										forSendingContentType:type];
}

/*!
 * @brief Gets the status for a contact as an attributed string.
 *
 * @param serviceID The identifier for the service to use.
 * @param username The named user to get the contact for (not fully qualified).
 *
 * @result An attributed string describing the status message of the contact.
 */
- (NSAttributedString *)statusMessageForContactWithServiceID:(NSString *)serviceID UID:(NSString *)username {
	return [[self contactWithServiceID:serviceID UID:username forSendingContentType:@"Message"] statusMessage];
}
/*!
 * @brief Installs this plugin
 */
- (void)installPlugin {
	if (conn = [[NSConnection alloc] initWithReceivePort:[NSPort port] sendPort:nil]) {
		[conn setRootObject:self];
		if ([conn registerName:@"AdiumQuicksilverPlugin"] == NO) {
			NSLog(@"registerName: failed");
			conn = nil;
		} else {
			NSLog(@"registerName: success!");
		}
	}
}

- (void)dealloc {
	[conn invalidate];
	[conn release];
	conn = nil;
	[super dealloc];
}

- (void)uninstallPlugin {
	[conn invalidate];
	[conn release];
	conn = nil;
}

@end