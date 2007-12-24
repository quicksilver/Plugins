//
//  QSAdiumMediator.m
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on Tue Oct 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "QSAdiumMediator.h"
#import "QSAdiumObjectSource.h"
#import <Foundation/NSUserDefaults.h>
#import <QSCore/QSNotifyMediator.h>

@implementation QSAdiumMediator

+ (NSProxy *)createAdiumProxy {
	NSLog([[NSUserDefaults standardUserDefaults] stringForKey:@"AdiumPluginInstalled"]);
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"AdiumPluginInstalled"]) {
		[[NSWorkspace sharedWorkspace] openFile:[[NSBundle bundleForClass:[QSAdiumMediator class]] pathForResource:@"Quicksilver"
																											ofType:@"AdiumPlugin"]];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"AdiumPluginInstalled"];
		return nil;
	}
	return [NSConnection rootProxyForConnectionWithRegisteredName:@"AdiumQuicksilverPlugin" host:nil];
}

- (id)init {
	if (self = [super init]) {
		availableAccounts = nil;
		availableAccountsDate = nil;
		return self;
	}
	return nil;
}

- (void)dealloc {
	[availableAccounts release];
	[availableAccountsDate release];
	
	[super dealloc];
}
/*
- (BOOL)canHandle:(id)transferType toAccount:(id)accountID{
	if( ![accountID hasPrefix:@"AIM:"] &&
		![accountID hasPrefix:@"MSN:"] &&
		![accountID hasPrefix:@"Mac:"] &&
		![accountID hasPrefix:@"Yahoo!:"] &&
		![accountID hasPrefix:@"ICQ:"] &&
		![accountID hasPrefix:@"Jabber:"] &&
		![accountID hasPrefix:@"Rendezvous:"] )
		return NO;
	if ([transferType isEqualToString:kQSChat])
		return YES;
	if ([transferType isEqualToString:kQSChatText])
		return YES;
	return NO;
}
*/
- (BOOL)chatWithAccount:(NSString *)accountID {
	NSLog( @"chatWithAccount: %@", accountID );
	NSProxy *adium = [QSAdiumMediator createAdiumProxy];
	
	if ([accountID rangeOfString:@"Group."].length != 0) {
		/* this is a whole GROUP we've been asked to chat with */
		accountID = [accountID substringFromIndex:[@"Group." length]];
		
		BOOL success = YES;

		foreach (contact, [adium consolidatedContactsWithGroupUID:accountID restrictingToVisible:YES]) {
			if ([[contact className] isEqualToString:@"AIMetaContact"]) {
				contact = [contact preferredContact];
			}
			
			accountID = [NSString stringWithFormat:@"%@:%@", [contact serviceID], [contact UID]];
			success &= [self chatWithAccount:accountID];
		}
		
		return success;
	}
	
	NSArray *serviceAndUsername = [accountID componentsSeparatedByString:@":"];
	id contact = [adium contactWithServiceID:[serviceAndUsername objectAtIndex:0]
										 UID:[serviceAndUsername objectAtIndex:1]
					   forSendingContentType:@"Message"];
	if (!contact)
		return NO;
	NSLog(@"contact:%@", [contact displayName]);
	[adium openChatWithContact:contact active:YES];
	return YES;
}

- (BOOL)sendFile:(NSString *)text toAccount:(NSString *)accountID {
	NSLog( @"sendFile: %@%@", text, accountID );
	return NO;
}

- (BOOL)sendText:(id)text toAccount:(id)accountID {
	NSLog( @"sendText: \"%@\" toAccout: \"%@\"", text, accountID );
	NSProxy *adium = [QSAdiumMediator createAdiumProxy];
	
	if ([accountID rangeOfString:@"Group."].length != 0) {
		/* this is a whole GROUP we've been asked to send a message to */
		accountID = [accountID substringFromIndex:[@"Group." length]];
		
		BOOL success = YES;
		
		foreach (contact, [adium consolidatedContactsWithGroupUID:accountID restrictingToVisible:YES]) {
			if ([[contact className] isEqualToString:@"AIMetaContact"]) {
				contact = [contact preferredContact];
			}
			
			accountID = [NSString stringWithFormat:@"%@:%@", [contact serviceID], [contact UID]];
			success &= [self sendText:text toAccount:accountID];
		}
		
		return success;
	}
	
	NSArray *serviceAndUsername = [accountID componentsSeparatedByString:@":"];
	if ([serviceAndUsername count] < 2) return NO;
	
	int status = (int)[adium sendMessage:text
						  toContact:[serviceAndUsername objectAtIndex:1]
					  withServiceID:[serviceAndUsername objectAtIndex:0]
						  autoreply:NO
						  laterIfOffline:YES];
	NSLog(@"value returned was %i", status);
	switch(status) {
		case 0:
			// sent immediately
			break;
		case 1:
			// will be sent later
			QSShowNotifierWithAttributes(
				[NSDictionary dictionaryWithObjectsAndKeys:
								@"Message queued", QSNotifierTitle,
								[NSString stringWithFormat:@"Your message to \"%@\" will be sent when you are both online.", [serviceAndUsername objectAtIndex:1]], QSNotifierText,
								nil]);
			break;
		default:
			return NO;
	}
		
	return YES;
}

/*
- (BOOL)chatWithPerson:(NSString *)personID {
	NSLog(@"chatWithPerson:%@", personID);
	return NO;
}
*/

- (NSString *)formatStatusMessage:(NSString *)status {
	NSMutableString *formatted = [NSMutableString stringWithString:status];
	[formatted replaceOccurrencesOfString : @"\n"
							   withString : @" / "
								  options : 0 range : NSMakeRange( 0, [status length] )];
	[formatted replaceOccurrencesOfString : @"\r"
							   withString : @" / "
								  options : 0 range : NSMakeRange( 0, [status length] )];
	return formatted;
}

#pragma mark Chat Mediator B41

/*!
 * @abstract Gets the types of actions this plugin is capable of.
 * @result A bitmask representing the possible actions.
 */
+ (int)supportedChatTypes {
	return QSChatInitMask | QSChatTextMask | QSChatFileMask | QSChatRoomMask;
}

/*!
 * @abstract Lists supported account types.
 * @result A list of the account types supported by this plugin.
 */
+ (NSArray *)supportedAccountTypes {
	return [NSArray arrayWithObjects:@"AIM", @"MSN", @"Yahoo!", @"Yahoo!-Japan", @"Napster", @"GroupWise", @"SameTime", @"ICQ", @"Jabber", @"Rendezvous", @"Mac", @"Gadu-Gadu", QSIMMultiAccountType, nil];
}

/*!
 * @abstract Gets the actions this account can perform.
 * @param accountID The account to get information about.
 * @result A bitmask representing the account's capabilities.
 */
- (int)capabilitiesOfAccount:(NSString *)accountID {
	/* TODO: determine the correct value for a given account */
	return QSChatInitMask | QSChatTextMask;
}

/*!
 * @abstract Perform an action on a variable number of accounts.
 * @param serviceType The type of action to perform.
 * @param accountIDs The list of accounts to perform the action on.
 * @param info Extra information related to serviceType.
 * @result YES if successful, NO otherwise.
 */
- (BOOL)initiateChat:(QSChatType)serviceType withAccounts:(NSArray *)accountIDs info:(id)info {
	switch (serviceType) {
		case QSChatInitType:
			// open a chat window with each account in accountIDs
			{foreach (accountID, accountIDs)
				[self chatWithAccount:accountID];
			}
			break;
		case QSChatTextType:
			// send text to each account in accountIDs
			// info is message (NSString e.g. @"hello")
			{foreach(accountID, accountIDs)
				[self sendText:info toAccount:accountID];
			}
			break;
		case QSChatFileType:
			// send file to each account in accountIDs
			// info is list of file paths (NSArray of NSString e.g. {@"~/Desktop/coolpic.jpg"})
			break;
		case QSChatRoomType:
			// open chat room and invite each account in accountIDs
			// info is name of room (NSString @"AIM:qsdevmeeting")
			break;
		default:
			// unsupported action
			return NO;
	}
	
	return NO;
}

/*!
 * @abstract Gets a flat list of available accounts.
 * @discussion This is not neccesarily the same as the children of the chat app (e.g. Adium.app).
 * @result Returns a list of QSObjects.
 */
- (NSArray *)availableAccounts {
	if (availableAccounts) {
		if (fabs([availableAccountsDate timeIntervalSinceNow]) < 5 * 60) {
			NSLog(@"using cache for availableAccounts");
			return availableAccounts;
		} else {
			NSLog(@"clearing cache");
			[availableAccounts release];
			[availableAccountsDate release];
			availableAccounts = nil;
			availableAccountsDate = nil;
		}
	}
	
	availableAccountsDate = [[NSDate date] retain];
	return availableAccounts = [[NSArray arrayWithArray:[[[[QSAdiumObjectSource alloc] init] autorelease] contacts]] retain];
}

/*!
 * @abstract Determines whether or not the account is available.
 * @param accountID The account to check for availability.
 * @result Returns YES if the account is available, NO otherwise.
 */
- (BOOL)accountIsAvailable:(NSString *)accountID {
	return NO;
}

/*!
 * @abstract Gets a status string for the given account.
 * @param accountID The account to get the status for.
 * @result Returns a description of the status of the given account.
 */
- (NSString *)statusForAccount:(NSString *)accountID {
	NSProxy *adium = [QSAdiumMediator createAdiumProxy];
	NSArray *serviceAndUsername = [accountID componentsSeparatedByString:@":"];

	if ([serviceAndUsername length] < 2) return nil;
	return [[adium statusMessageForContactWithServiceID:[serviceAndUsername objectAtIndex:0] UID:[serviceAndUsername objectAtIndex:1]] string];
}

@end