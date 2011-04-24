//
//  QSAppleMailPlugIn_Action.m
//  QSAppleMailPlugIn
//
//  Created by Nicholas Jitkoff on 9/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSAppleMailPlugIn_Action.h"
#import "QSAppleMailPlugIn_Source.h"
@interface QSAppleMailPlugIn_Action (hidden)
- (NSString *)makeAccountPath:(QSObject *)object;
@end

@implementation QSAppleMailPlugIn_Action

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	return [[QSReg getClassInstance:@"QSAppleMailPlugIn_Source"] allMailboxes:NO];
}

- (QSObject *)revealMailbox:(QSObject *)dObject{
	NSString *mailbox=[dObject objectForType:kQSAppleMailMailboxType];
	NSArray *arguments=[NSArray arrayWithObjects:mailbox,[self makeAccountPath:dObject],nil];

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
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[self makeAccountPath:dObject]] atIndex:0];

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
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[self makeAccountPath:dObject]] atIndex:0];

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
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[self makeAccountPath:dObject]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[iObject objectForMeta:@"mailboxName"]] atIndex:0];
	[arguments insertDescriptor:[NSAppleEventDescriptor descriptorWithString:[self makeAccountPath:iObject]] atIndex:0];

	NSAppleScript *script=[(QSAppleMailMediator *)[QSReg getClassInstance:@"QSAppleMailMediator"] mailScript];
	NSDictionary *err = nil;
	[script executeSubroutine:@"move_message" arguments:arguments error:&err];
	if (err) {
		NSLog(@"AppleMailPlugin moveMessage: Applescirpt error %@", err);
		return nil;
	}
	return nil;
}

- (NSString *)makeAccountPath:(QSObject *)object {
	if ([[object objectForMeta:@"accountId"] isEqualToString:@"Local Mailbox"]) {
		return @"local";
	} else {
		return [object objectForMeta:@"accountPath"];
	}
}

@end
