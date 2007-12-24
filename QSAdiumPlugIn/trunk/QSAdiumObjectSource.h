//
//  QSAdiumObjectSource.h
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on 11/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QSCore/QSLibrarian.h>
#import <QSFoundation/NSBundle_BLTRExtensions.h>
#import "QSAdiumMediator.h"
#import "QSObject_BDExtensions.h"
#import "NSArray_BDExtensions.h"

#define kQSAdiumGroupType		@"com.adiumX.group"
#define kQSAdiumChatList		@"com.adiumX.chatlist"
#define kQSAdiumContactType		@"com.adiumX.contact"
#define kQSAdiumMetaContactType	@"com.adiumX.metacontact"
#define kQSAdiumOnline			@"com.adiumX.contact.online"

@interface QSAdiumObjectSource : QSObjectSource {

}

- (NSMutableArray *)chats;
- (NSMutableArray *)groups;
- (NSMutableArray *)contacts;
- (NSMutableArray *)contactsWithGroupUID:(NSString *)groupUID;

@end
