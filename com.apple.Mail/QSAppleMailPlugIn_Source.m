//
//  QSAppleMailPlugIn_Source.m
//  QSAppleMailPlugIn
//
//  Created by Nicholas Jitkoff on 9/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSAppleMailPlugIn_Source.h"
//#import <QSCore/QSObject.h>
//
//#import <QSCore/QSCore.h>
//#import <QSFoundation/QSFoundation.h>

#define SPECIAL_ARRAY [NSArray arrayWithObjects:@"Inbox",@"Out",@"Drafts",@"Sent",@"Trash",@"Junk",nil]

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
		[object setIcon:[QSResourceManager imageNamed:@"GenericFolderIcon"]];
	}else{
		[object setIcon:[QSResourceManager imageNamed:@"MailMessage"]];
		
	}
	return NO;
	
}


- (BOOL)loadIconForObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:kQSAppleMailMailboxType]){
		NSString *mailbox=[object objectForType:kQSAppleMailMailboxType];
		
		if ([SPECIAL_ARRAY containsObject:mailbox]){
			NSImage *image=[QSResourceManager imageNamed:[NSString stringWithFormat:@"MailMailbox-%@",mailbox]];
			[object setIcon:image];
			return YES;
		}
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
		
		[object setChildren:objects];
		return YES; 
	}
	
	if ([[object primaryType]isEqualToString:kQSAppleMailMessageType]){
		
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
		
		
		[object setChildren:objects];
		return YES;
	}
	
	
	
	return NO;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	return [self allMailboxes];
}
- (NSArray *)allMailboxes{
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	NSFileManager *manager=[NSFileManager defaultManager];
	
	
	NSEnumerator *e=[SPECIAL_ARRAY objectEnumerator];
	
	NSString *path;
	while(path=[e nextObject]){
		newObject=[QSObject objectWithName:path];
		[newObject setObject:path forType:kQSAppleMailMailboxType];
		[newObject setPrimaryType:kQSAppleMailMailboxType];
		[objects addObject:newObject];
	}
	
	
	NSDirectoryEnumerator *de=[manager enumeratorAtPath:[@"~/Library/Mail/Mailboxes/" stringByStandardizingPath]];
	
	while(path=[de nextObject]){
		if ([[path pathExtension]isEqual:@"mbox"]){
			newObject=[QSObject objectWithName:[[path lastPathComponent]stringByDeletingPathExtension]];
			[newObject setObject:[path stringByDeletingPathExtension] forType:kQSAppleMailMailboxType];
			[newObject setPrimaryType:kQSAppleMailMailboxType];
			[objects addObject:newObject];
			[de skipDescendents];
		}
	}
	
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
