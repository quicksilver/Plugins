//
//  QSAppleMailPlugIn_Action.m
//  QSAppleMailPlugIn
//
//  Created by Nicholas Jitkoff on 9/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSAppleMailPlugIn_Action.h"
#import "QSAppleMailPlugIn_Source.h"
@implementation QSAppleMailPlugIn_Action


#define kQSAppleMailPlugInAction @"QSAppleMailPlugInAction"

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	return [[QSReg getClassInstance:@"QSAppleMailPlugIn_Source"] allMailboxes];

}

- (QSObject *)revealMailbox:(QSObject *)dObject{
	NSString *mailbox=[dObject objectForType:kQSAppleMailMailboxType];
	NSArray *arguments=[NSArray arrayWithObjects:mailbox,[dObject objectForMeta:@"accountPath"],nil];

	NSAppleScript *script=[(QSAppleMailMediator *)[QSReg getClassInstance:@"QSAppleMailMediator"] mailScript];
	NSDictionary *err = nil;
	[script executeSubroutine:@"open_mailbox" arguments:arguments error:&err];
	if (err) {
		NSLog(@"AppleMailPlugin revealMailbox: Applescirpt error %@", err);
		return nil;
	}
	return nil;
}

- (QSObject *)revealMessage:(QSObject *)dObject{
	NSAppleEventDescriptor *arguments = [NSAppleEventDescriptor listDescriptor];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[[dObject objectForMeta:@"message_id"] intValue]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[dObject objectForMeta:@"mailboxName"]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[dObject objectForMeta:@"accountPath"]] atIndex:0];

	NSAppleScript *script=[(QSAppleMailMediator *)[QSReg getClassInstance:@"QSAppleMailMediator"] mailScript];
	NSDictionary *err = nil;
	[script executeSubroutine:@"open_message" arguments:arguments error:&err];
	if (err) {
		NSLog(@"AppleMailPlugin revealMessage: Applescirpt error %@", err);
		return nil;
	}
	return nil;
}

- (QSObject *)deleteMessage:(QSObject *)dObject{
	NSAppleEventDescriptor *arguments = [NSAppleEventDescriptor listDescriptor];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[[dObject objectForMeta:@"message_id"] intValue]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[dObject objectForMeta:@"mailboxName"]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[dObject objectForMeta:@"accountPath"]] atIndex:0];

	NSAppleScript *script=[(QSAppleMailMediator *)[QSReg getClassInstance:@"QSAppleMailMediator"] mailScript];
	NSDictionary *err = nil;
	[script executeSubroutine:@"delete_message" arguments:arguments error:&err];
	if (err) {
		NSLog(@"AppleMailPlugin deleteMessage: Applescirpt error %@", err);
		return nil;
	}
	return nil;
}
- (QSObject *)moveMessage:(QSObject *)dObject toMailbox:(QSObject *)iObject{
	NSAppleEventDescriptor *arguments = [NSAppleEventDescriptor listDescriptor];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[[dObject objectForMeta:@"message_id"] intValue]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[dObject objectForMeta:@"mailboxName"]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[dObject objectForMeta:@"accountPath"]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[iObject objectForMeta:@"mailboxName"]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[iObject objectForMeta:@"accountPath"]] atIndex:0];

	NSAppleScript *script=[(QSAppleMailMediator *)[QSReg getClassInstance:@"QSAppleMailMediator"] mailScript];
	NSDictionary *err = nil;
	[script executeSubroutine:@"move_message" arguments:arguments error:&err];
	if (err) {
		NSLog(@"AppleMailPlugin moveMessage: Applescirpt error %@", err);
		return nil;
	}
	return nil;
}

@end
