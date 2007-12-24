//
//  QSAdiumObjectSource.m
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on 11/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSAdiumObjectSource.h"

@implementation QSAdiumObjectSource

- (NSMutableArray *)contacts {
	return [self contactsWithGroupUID:nil];
}

- (NSMutableArray *)contactsWithGroupUID:(NSString *)groupUID {
	/* get the contacts from Adium */
	return [NSMutableArray arrayWithArray:[QSObject objectsForAdiumContacts:[[QSAdiumMediator createAdiumProxy] consolidatedContactsWithGroupUID:groupUID restrictingToVisible:NO]]];
}

- (NSMutableArray *)chats {
	NSArray *chats = [[QSAdiumMediator createAdiumProxy] chats];
	return [[QSObject objectsForArray:chats
								 type:kQSAdiumChatList
								value:@selector(uniqueChatID)
								 name:@selector(name)
							  details:nil]
		
							  setIcon:@selector(chatImage)
						  withDefault:[[QSResourceManager sharedInstance] imageNamed:@"AdiumDefaultContactIcon"]
							fromArray:chats];
}

- (NSMutableArray *)groups {
	NSArray *adiumGroups;
	NSMutableArray *qsGroups;
	
	adiumGroups = [[QSAdiumMediator createAdiumProxy] groupsRestrictingToVisible:YES];
	/* create QS objects */
	qsGroups = [[[QSObject objectsForArray:adiumGroups
									  type:kQSAdiumGroupType
									 value:@selector(UID)
									  name:@selector(displayName)
								   details:@selector(notes)]
				/* and set their icons */
				setIcon:@selector(userIconData)
			withDefault:[[NSBundle bundleForClass:[QSAdiumObjectSource class]] imageNamed:@"DefaultGroup.png"]
			  fromArray:adiumGroups]
				/* and set their UIDs */
			  setObject:@selector(internalObjectID)
				forType:QSIMAccountType
			  fromArray:adiumGroups];

	return qsGroups;
}

- (NSMutableArray *)contactsForMetaContact:(QSObject *)metaContact {
	return [QSObject objectsForAdiumContacts:[[QSAdiumMediator createAdiumProxy] contactsForMetaContactWithID:[metaContact objectForType:kQSAdiumContactType]]];
}

- (NSMutableArray *)logsForContact:(NSString *)username {
	/* TODO */
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
	NSMutableArray *children = nil, *altChildren = nil;
	
	if ([[object primaryType] isEqualToString:kQSAdiumChatList]) {
		/* get all chats from Adium */
		children = [self chats];
	} else if ([[object primaryType] isEqualToString:kQSAdiumGroupType]) {
		/* get all contacts in the group from Adium */
		/* alternate children are all contacts regardless of online status */
		/* this sometimes fails, why? */
		altChildren = [self contactsWithGroupUID:[object objectForType:kQSAdiumGroupType]];
		/* children are the online contacts */
		children = [altChildren arrayWithMeta:kQSAdiumOnline havingValue:@"online"];
	} else if ([[object primaryType] isEqualToString:NSFilenamesPboardType]) {
		/* get children of Adium */
		/* get all the groups */
		children = [self groups];

		/* add the All Contacts group */
		[children insertObject:[QSObject objectWithType:kQSAdiumGroupType value:@"" name:@"Online Contacts"] atIndex:0];
		[[children objectAtIndex:0] setObject:@"Group." forType:QSIMAccountType];
		[[children objectAtIndex:0] setDetails:@"Contacts in all groups"];
		[[children objectAtIndex:0] setIcon:[[NSBundle bundleForClass:[QSAdiumObjectSource class]] imageNamed:@"DefaultGroup.png"]];
		
		/* add the Chats list */
		/*
		[children insertObject:[QSObject objectWithType:kQSAdiumChatList value:@"" name:@"Chats"] atIndex:0];
		[[children objectAtIndex:0] setDetails:@"Active chats"];
		*/
	} else if ([[object primaryType] isEqualToString:kQSAdiumContactType]) {
		/* get the contents of the contact */
		
		if ([[object types] containsObject:kQSAdiumMetaContactType]) {
			/* this contact is a meta contact, contents are contacts */
			altChildren = [self contactsForMetaContact:object];
			children = [altChildren arrayWithMeta:kQSAdiumOnline havingValue:@"online"];
		} else {
			/* this contact is a normal contact, contents are logs */
		}
	}
	
	// score the strings
/*	if (children)
		children = [[QSLibrarian sharedInstance] scoredArrayForString:nil inSet:children];
	if (altChildren)
		altChildren = [[QSLibrarian sharedInstance] scoredArrayForString:nil inSet:altChildren];*/
	
	[object setChildren:children];
	if (altChildren)
		[object setAltChildren:altChildren];
	return (children != nil) || (altChildren != nil);
}

- (BOOL)objectHasChildren:(QSObject *)object {
	if ([[object primaryType] isEqualToString:NSFilenamesPboardType]) {
		return YES;
	}
}

@end