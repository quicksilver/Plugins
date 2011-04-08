//
//  QSAppleMailPlugIn_Source.m
//  QSAppleMailPlugIn
//
//  Created by Nicholas Jitkoff on 9/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSAppleMailPlugIn_Source.h"

@interface QSAppleMailPlugIn_Source (hidden)
- (QSObject *)makeMailboxObject:(NSString *)mailbox withAccountName:(NSString *)accountName withAccountId:(NSString *)accountId withFile:(NSString *)file withChildren:(BOOL)loadChildren;
- (NSArray *)mailsForMailbox:(QSObject *)object;
- (NSArray *)mailContent:(QSObject *)object;
@end

@implementation QSAppleMailPlugIn_Source
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}

- (void)setQuickIconForObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:kQSAppleMailMailboxType]){
		NSString *mailboxName = [object objectForType:kQSAppleMailMailboxType];
		if ([mailboxName rangeOfString:@"Junk" options:NSCaseInsensitiveSearch].location != NSNotFound ||
			[mailboxName rangeOfString:@"Spam" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			[object setIcon:[QSResourceManager imageNamed:@"MailMailbox-Junk"]];
		} else if ([mailboxName rangeOfString:@"Drafts" options:NSCaseInsensitiveSearch].location != NSNotFound){
			[object setIcon:[QSResourceManager imageNamed:@"MailMailbox-Drafts"]];
		} else if ([mailboxName rangeOfString:@"Sent" options:NSCaseInsensitiveSearch].location != NSNotFound){
			[object setIcon:[QSResourceManager imageNamed:@"MailMailbox-Sent"]];
		} else if ([mailboxName rangeOfString:@"Trash" options:NSCaseInsensitiveSearch].location != NSNotFound ||
				   [mailboxName rangeOfString:@"Deleted" options:NSCaseInsensitiveSearch].location != NSNotFound){
			[object setIcon:[QSResourceManager imageNamed:@"TrashIcon"]];
		} else if ([mailboxName rangeOfString:@"Inbox" options:NSCaseInsensitiveSearch].location != NSNotFound){
			[object setIcon:[QSResourceManager imageNamed:@"MailMailbox-Inbox"]];
		} else {
			[object setIcon:[QSResourceManager imageNamed:@"MailMailbox"]];
		}
		return;
	}
	if ([[object primaryType]isEqualToString:kQSAppleMailMessageType]){
		[object setIcon:[QSResourceManager imageNamed:@"MailMessage"]];
		return;
	}
}


- (BOOL)loadIconForObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:kQSAppleMailMailboxType]){
//		NSString *mailbox=[object objectForType:kQSAppleMailMailboxType];
//		
//		if ([SPECIAL_ARRAY containsObject:mailbox]){
//			NSImage *image=[QSResourceManager imageNamed:[NSString stringWithFormat:@"MailMailbox-%@",mailbox]];
//			[object setIcon:image];
//			return YES;
//		}
	}
	return NO;
	
}


- (id)initFileObject:(QSObject *)object ofType:(NSString *)type{
	NSString *filePath=[object singleFilePath];
	NSString *iden=[[filePath lastPathComponent]stringByDeletingPathExtension];
	NSString *mailbox=[[[filePath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]lastPathComponent];
	NSString *messagePath=[NSString stringWithFormat:@"%@//%@",mailbox,iden];
	
	NSMetadataItem *mditem=[NSMetadataItem itemWithPath:filePath];
	[object setName:[mditem valueForAttribute:kMDItemDisplayName]];
//	NSLog(@"path:%@ %@",messagePath,[object name]);
	[object setObject:messagePath forType:kQSAppleMailMessageType];
//	[object setPrimaryType:kQSAppleMailMessageType];
	[object setDetails:[[mditem valueForAttribute:kMDItemAuthors]lastObject]];
	return object;
	
}

- (NSString *)detailsOfObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:kQSAppleMailMailboxType]){
		
		NSString *mailbox=[object objectForType:kQSAppleMailMailboxType];
		return [mailbox stringByDeletingLastPathComponent]; 
	}
	return nil;
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSFilePathType] && [NSApp featureLevel]>1){
		[object setChildren:[self objectsForEntry:nil]];
		return YES;
	}
	if ([[object primaryType]isEqualToString:kQSAppleMailMailboxType]){
		[object setChildren:[self mailsForMailbox:object]];
		return YES; 
	}
	if ([[object primaryType]isEqualToString:kQSAppleMailMessageType]){
		[object setChildren:[self mailContent:object]];
		return YES;
	}
	return NO;
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	return [self allMailboxes];
}

- (NSArray *)allMailboxes {
	return [self allMailboxes:YES];
}

- (NSArray *)allMailboxes:(BOOL)loadChildren{
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;

	NSString *path = [MAILPATH stringByStandardizingPath];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSDirectoryEnumerator *accountEnum = [fm enumeratorAtPath:path];
	NSDirectoryEnumerator *mailboxEnum;

	// find real names for accounts
	NSArray *pl = (NSArray *)CFPreferencesCopyAppValue(CFSTR("MailAccounts"), CFSTR("com.apple.mail"));
	NSMutableDictionary *realAccountNames = [NSMutableDictionary dictionaryWithCapacity:[pl count]];
	for(NSDictionary *dict in pl) {
		if ([dict objectForKey:@"AccountPath"] != nil && [dict objectForKey:@"AccountName"] != nil) {
			[realAccountNames setObject:[dict objectForKey:@"AccountName"] forKey:[dict objectForKey:@"AccountPath"]];
		}
	}

	NSString *file, *accountName, *accountId, *mb;
	while (file = [accountEnum nextObject]) {
		// skip everything that's not a mailbox directory
		if ([[accountEnum fileAttributes] fileType] != NSFileTypeDirectory ||
			!([file hasPrefix:@"IMAP-"] || [file hasPrefix:@"Mac-"] || [file hasPrefix:@"POP-"] || [file isEqualToString:@"Mailboxes"])) {
			[accountEnum skipDescendants];
			continue;
		}

		if ([file isEqualToString:@"Mailboxes"]) {
			accountName = @"Local Mailbox";
			accountId = accountName;
		} else {
			accountName = [realAccountNames objectForKey:[NSString stringWithFormat:@"%@/%@", MAILPATH, file]];
			accountId = [file substringFromIndex:[file rangeOfString:@"-"].location + 1];
		}

		// scan account folder
		mailboxEnum = [fm enumeratorAtPath:[path stringByAppendingPathComponent:file]];
		while (mb = [mailboxEnum nextObject]) {
			if ([[mailboxEnum fileAttributes] fileType] != NSFileTypeDirectory) {
				continue;
			}

			// IMAP- & MoblieMe-Accounts
			if ([[mb pathExtension] isEqualToString:@"imapmbox"]) {
				newObject = [self makeMailboxObject:mb
									withAccountName:accountName
									  withAccountId:accountId
										   withFile:file
									   withChildren:loadChildren];

				[objects addObject:newObject];
				[mailboxEnum skipDescendants];
			}

			// POP-accounts & local mailboxes
			if ([[mb pathExtension] isEqualToString:@"mbox"]) {
				newObject = [self makeMailboxObject:mb
									withAccountName:accountName
									  withAccountId:accountId
										   withFile:file
									   withChildren:loadChildren];

				[objects addObject:newObject];
				[mailboxEnum skipDescendants];
			}
		}
		[accountEnum skipDescendents];
	}
	return objects;
}

- (QSObject *)makeMailboxObject:(NSString *)mailbox withAccountName:(NSString *)accountName withAccountId:(NSString *)accountId withFile:(NSString *)file withChildren:(BOOL)loadChildren {
	NSString *mailboxName = [mailbox stringByDeletingPathExtension];

	QSObject *newObject = [QSObject objectWithName:mailboxName];
	[newObject setObject:mailboxName forType:kQSAppleMailMailboxType];
	[newObject setLabel:[NSString stringWithFormat:@"%@ %@", accountName, mailboxName]];
	[newObject setDetails:accountName];
	[newObject setObject:accountId forMeta:@"accountId"];
	[newObject setIdentifier:[NSString stringWithFormat:@"mailbox:%@//%@", accountName, mailboxName]];
	[newObject setObject:[[MAILPATH stringByAppendingPathComponent:file] stringByStandardizingPath] forMeta:@"accountPath"];
	[newObject setObject:mailboxName forMeta:@"mailboxName"];
	[newObject setObject:[NSNumber numberWithBool:loadChildren] forMeta:@"loadChildren"];
	[newObject setPrimaryType:kQSAppleMailMailboxType];
	return newObject;
}

- (NSArray *)mailsForMailbox:(QSObject *)object {
	NSString *mailbox=[object objectForType:kQSAppleMailMailboxType];

	NSAppleScript *script=[[QSReg getClassInstance:@"QSAppleMailMediator"] mailScript];

	id result=[[script executeSubroutine:@"list_messages"
							   arguments:mailbox
								   error:nil]objectValue];
	//NSLog(@"res %@",result);
	NSArray *ids=[result objectAtIndex:0];
	NSArray *subjects=[result objectAtIndex:1];
	NSArray *senders=[result objectAtIndex:2];
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;

	int i;
	for (i=0;i<[ids count];i++){
		NSString *messagePath=[NSString stringWithFormat:@"%@//%@",mailbox,[ids objectAtIndex:i]];
		newObject=[QSObject objectWithName:[subjects objectAtIndex:i]];
		[newObject setObject:messagePath forType:kQSAppleMailMessageType];
		[newObject setPrimaryType:kQSAppleMailMessageType];
		[newObject setDetails:[senders objectAtIndex:i]];
		[objects addObject:newObject];
	}
	
	return objects;
}

- (NSArray *)mailContent:(QSObject *)object {
	NSArray *message=[[object objectForType:kQSAppleMailMessageType]componentsSeparatedByString:@"//"];
	NSAppleScript *script=[[QSReg getClassInstance:@"QSAppleMailMediator"] mailScript];
	id result=[[script executeSubroutine:@"get_message_contents" arguments:message error:nil]objectValue];
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;
	if (!result) return NO;
	newObject=[QSObject objectWithString:[result objectAtIndex:0]];
	[objects addObject:newObject];
	
	newObject=[QSObject objectWithName:[result objectAtIndex:1]];
	[newObject setObject:[result objectAtIndex:1] forType:QSEmailAddressType];
	[newObject setPrimaryType:QSEmailAddressType];
	[objects addObject:newObject];

	return objects;
}

// Object Handler Methods

/*
 - (void)setQuickIconForObject:(QSObject *)object{
	 [object setIcon:nil]; // An icon that is either already in memory or easy to load
 }
 - (BOOL)loadIconForObject:(QSObject *)object{
	 return NO;
	 id data=[object objectForType:QSAppleMailPlugInType];
	 [object setIcon:nil];
	 return YES;
 }
 */


@end
