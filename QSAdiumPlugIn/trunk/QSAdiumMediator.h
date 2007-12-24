//
//  QSAdiumMediator.h
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on Tue Oct 05 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSConnection.h>

#import "QSChatMediator.h"
//#import <QSCore/NSAppleScript_BLTRExtensions.h>
#import <QSFoundation/NSString_BLTRExtensions.h>
#import <QSCore/QSMacros.h>
#import <QSCore/QSCore.h>
#import <QSCore/QSBadgeImage.h>
#import <QSCore/QSLibrarian.h>

typedef enum {
	AIAvailableStatus = 'avaL',
	AIAwayStatus = 'awaY',
	AIIdleStatus = 'idlE',
	AIAwayAndIdleStatus = 'aYiE',
	AIOfflineStatus = 'offL',
	AIUnknownStatus = 'unkN'
} AIStatusSummary;

@interface QSAdiumMediator : NSObject <QSChatMediator> {
	NSArray *availableAccounts;
	NSDate  *availableAccountsDate;
}

+ (NSProxy *)createAdiumProxy;
+ (NSArray *)supportedAccountTypes;
+ (int)supportedChatTypes;

- (NSArray *)availableAccounts;
- (NSString *)statusForAccount:(NSString *)accountID;
- (BOOL)accountIsAvailable:(NSString *)accountID;
- (BOOL)initiateChat:(QSChatType)serviceType withAccounts:(NSArray *)accountIDs info:(id)info;
- (int)capabilitiesOfAccount:(NSString *)accountID;

@end
