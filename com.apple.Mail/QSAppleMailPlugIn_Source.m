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
	return NO;
}


- (id)initFileObject:(QSObject *)object ofType:(NSString *)type{
	NSString *filePath=[object singleFilePath];
	NSString *iden=[[filePath lastPathComponent]stringByDeletingPathExtension];
	NSString *mailbox=[[[filePath stringByDeletingLastPathComponent]stringByDeletingLastPathComponent]lastPathComponent];
	NSString *messagePath=[NSString stringWithFormat:@"%@//%@",mailbox,iden];
	
	NSMetadataItem *mditem=[NSMetadataItem itemWithPath:filePath];
	[object setName:[mditem valueForAttribute:kMDItemDisplayName]];
	[object setObject:messagePath forType:kQSAppleMailMessageType];
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

- (BOOL)objectHasChildren:(QSObject *)object{
	if ([object objectForMeta:@"loadChildren"] != nil && ![[object objectForMeta:@"loadChildren"] boolValue]) {
		return NO;
	}
	if([[object primaryType] isEqualToString:kQSAppleMailMailboxType])
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		/* NSLog(@"file path: %@", [NSString stringWithFormat:@"%@/%@.%@/Messages",
								 [object objectForMeta:@"accountPath"],
								 [object objectForMeta:@"mailboxName"],
								 [object objectForMeta:@"mailboxType"]]); */
		if([fm fileExistsAtPath:[NSString stringWithFormat:@"%@/%@.%@/Messages",
								 [object objectForMeta:@"accountPath"],
								 [object objectForMeta:@"mailboxName"],
								 [object objectForMeta:@"mailboxType"]]])
			return YES;
		else {
			return NO;
		}
}
	return NO;
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
	if ([object objectForMeta:@"loadChildren"] != nil && ![[object objectForMeta:@"loadChildren"] boolValue]) {
		return NO;
	}

	if ([[object primaryType]isEqualToString:QSFilePathType]){
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
	NSString *mailboxType = [mailbox pathExtension];
	NSString *mailboxName = [mailbox stringByDeletingPathExtension];

	QSObject *newObject = [QSObject objectWithName:mailboxName];
	[newObject setObject:mailboxName forType:kQSAppleMailMailboxType];
	[newObject setLabel:[NSString stringWithFormat:@"%@ %@", accountName, mailboxName]];
	[newObject setDetails:accountName];
	[newObject setObject:accountId forMeta:@"accountId"];
	[newObject setObject:mailboxType forMeta:@"mailboxType"];
	[newObject setIdentifier:[NSString stringWithFormat:@"mailbox:%@//%@", accountName, mailboxName]];
	[newObject setObject:[[MAILPATH stringByAppendingPathComponent:file] stringByStandardizingPath] forMeta:@"accountPath"];
	[newObject setObject:mailboxName forMeta:@"mailboxName"];
	[newObject setObject:[NSNumber numberWithBool:loadChildren] forMeta:@"loadChildren"];
	[newObject setPrimaryType:kQSAppleMailMailboxType];
	return newObject;
}

- (NSArray *)mailsForMailbox:(QSObject *)object {
	NSString *mailboxName=[object objectForType:kQSAppleMailMailboxType];
	NSString *accountName=[object objectForMeta:@"accountId"];
	NSString *accountPath=[object objectForMeta:@"accountPath"];
	
	// make 'Envelop Index' compatible mailbox-url
	NSString *mailboxUrl;
	if ([accountName isEqualToString:@"Local Mailbox"]) {
		mailboxUrl = [NSString stringWithFormat:@"%@/%@",
					  @"local://",
					  [mailboxName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	} else {
		// replace special chars with % representation 
		// but not last @. strange Envelop Index / ~Library/Mail/ format requires that
		NSRange r = [accountName rangeOfString:@"@" options:NSBackwardsSearch];
		// If there's @ sign existed in the accountName string
		if(r.location != NSNotFound)
		{
			NSString *p1, *p2;
			p1 = [accountName substringToIndex:r.location];
			p1 = [p1 stringByReplacing:@"@" with:@"%40"];
			p2 = [accountName substringFromIndex:r.location + 1];
			mailboxUrl = [NSString stringWithFormat:@"%@@%@/%@",
						  p1,
						  p2,
						  [mailboxName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
		// If the @ sign didn't exist (e.g. Mobile Me accounts)
		else {
			mailboxUrl =  [NSString stringWithFormat:@"%@@mail.mac.com/%@",accountName,[mailboxName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	// NSLog(@"Mailbox URL: %@", mailboxUrl);
	// read mails for mailbox from SQLite DB Envelop Index
	NSString *dbPath = [[MAILPATH stringByAppendingString:@"/Envelope Index"] stringByStandardizingPath];
	FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
	if (![db open]) {
		NSLog(@"Could not open db.");
		return NO;
	}
	// kind of experimentalish.
	[db setShouldCacheStatements:YES];

	// build SQL query
	NSString *subject, *sender, *mailPath, *mailboxType;
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:0];
	QSObject *newObject;
	NSString *query = [NSString stringWithFormat:@"SELECT "
					   "mailboxes.url AS url, "
					   "messages.ROWID AS message_id, "
					   "messages.subject_prefix AS subject_prefix, "
					   "subjects.subject AS subject, "
					   "addresses.address AS sender "
					   "FROM mailboxes "
					   "LEFT JOIN messages ON messages.mailbox = mailboxes.ROWID "
					   "LEFT JOIN subjects ON subjects.ROWID = messages.subject "
					   "LEFT JOIN addresses ON addresses.ROWID = messages.sender "
					   "WHERE url LIKE '%%%@'"
					   "ORDER BY messages.date_received DESC",
					   mailboxUrl];
	FMResultSet *rs = [db executeQuery:query];
	if ([db hadError]) {
		NSLog(@"Error %d: %@", [db lastErrorCode], [db lastErrorMessage]);
		return NO;
	}
	while ([rs next]) {
		subject = [[rs stringForColumn:@"subject_prefix"] stringByAppendingString:[rs stringForColumn:@"subject"]];
		sender = [rs stringForColumn:@"sender"];
		if ([subject length] == 0 && [sender length] == 0) {
			// sometimes there is no sender/subject
			// I don't know why they appear, they are not really messages.
			// So, just skip them.
			continue;
		}

		if ([[rs stringForColumn:@"url"] rangeOfString:@"local" options:NSCaseInsensitiveSearch].location != NSNotFound ||
			[[rs stringForColumn:@"url"] rangeOfString:@"pop" options:NSCaseInsensitiveSearch].location != NSNotFound) {
			mailboxType = @"mbox";
		} else {
			mailboxType = @"imapmbox";
		}

		mailPath = [NSString stringWithFormat:@"%@/%@.%@/Messages/%@.emlx",
					accountPath,
					mailboxName,
					mailboxType,
					[rs stringForColumn:@"message_id"]];

		newObject=[QSObject objectWithName:subject];
		[newObject setObject:subject forType:kQSAppleMailMessageType];
		[newObject setDetails:sender];
		[newObject setParentID:[object identifier]];
		[newObject setIdentifier:[NSString stringWithFormat:@"message:%d", [rs intForColumn:@"message_id"]]];
		[newObject setObject:mailPath forMeta:@"mailPath"];
		[newObject setObject:mailPath forMeta:@"mailPath"];
		[newObject setObject:[rs stringForColumn:@"message_id"] forMeta:@"message_id"];
		[newObject setObject:mailboxName forMeta:@"mailboxName"];
		[newObject setObject:accountPath forMeta:@"accountPath"];
		[newObject setPrimaryType:kQSAppleMailMessageType];
		[objects addObject:newObject];
	}

	[rs close];
	[db close];
	return objects;
}

- (NSArray *)mailContent:(QSObject *)object {
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	QSObject *newObject;

	// read mail file
	NSError *err = nil;
	NSString *fileContents = [NSString stringWithContentsOfFile:[object objectForMeta:@"mailPath"] encoding:NSASCIIStringEncoding error:&err];
	if (!fileContents || err) {
		NSLog(@"Couldn't read mail. Error: %@ (%i - %@)", [err localizedDescription], [err code], [object objectForMeta:@"mailPath"]);
		return nil;
	}

	// remove non-MIME-stuff
	NSCharacterSet *cs = [NSCharacterSet newlineCharacterSet];
	NSRange r = [fileContents rangeOfCharacterFromSet:cs];
	fileContents = [fileContents substringFromIndex:(r.location+r.length)];
	fileContents = [fileContents substringToIndex:[fileContents rangeOfString:@"<?xml"].location];

	// make sure, it an ASCII string
	if (![fileContents canBeConvertedToEncoding:NSASCIIStringEncoding]) {
		NSData *d = [fileContents dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		fileContents = [[[NSString alloc] initWithData:d encoding:NSASCIIStringEncoding] autorelease];
	}

	// parse message
	CTCoreMessage *message =  [[CTCoreMessage alloc] initWithString:fileContents];
	[message fetchBody];

	// create QSObjects
	newObject=[QSObject objectWithString:[[message body] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
	[newObject setParentID:[object identifier]];
	[objects addObject:newObject];

	CTCoreAddress * from = [[message from] anyObject];
	[message release];

	newObject=[QSObject objectWithName:[from email]];
	[newObject setObject:[from email] forType:QSEmailAddressType];
	[newObject setDetails:[from name]];
	[newObject setParentID:[object identifier]];
	[newObject setPrimaryType:QSEmailAddressType];
	[objects addObject:newObject];

	return objects;
}

@end
