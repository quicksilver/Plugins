//
//  QSYojimboPlugInAction.m
//  QSYojimboPlugIn
//
//  Created by Nicholas Jitkoff on 5/14/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSYojimboPlugInAction.h"

@implementation QSYojimboPlugInAction


#define kQSYojimboPlugInAction @"QSYojimboPlugInAction"
- (NSAppleScript *)script{
	NSString *scriptPath=[[NSBundle bundleForClass:[self class]]pathForResource:@"Yojimbo" ofType:@"scpt"];
	if (!scriptPath)return nil;
	NSAppleScript *script=[[NSAppleScript alloc]initWithContentsOfURL:[NSURL fileURLWithPath:scriptPath] error:nil];
	return script;
}
- (QSObject *)addObject:(QSObject *)dObject{
	BOOL isURL=[dObject containsType:QSURLType];
	NSAppleEventDescriptor *ident=[[self script] executeSubroutine:isURL?@"add_url":@"add_note" arguments:[NSArray arrayWithObjects:[dObject displayName],[dObject stringValue],nil]
															 error:nil];
	
	NSString *uuid=	[ident stringValue];
	QSObject *newObject=[QSObject objectWithIdentifier:uuid];	
	[newObject setName:[dObject name]];
	[newObject setIdentifier:uuid];
	[newObject setObject:uuid forType:kQSYojimboPlugInType];
	[newObject setPrimaryType:kQSYojimboPlugInType];
	return newObject;
}

- (QSObject *)appendToNote:(QSObject *)dObject content:(QSObject *)iObject{
	NSString *uuid=[dObject objectForType:kQSYojimboPlugInType];
	NSString *body=[dObject objectForType:QSTextType];
	NSString *text=[iObject stringValue];
	body=[body stringByAppendingFormat:@"\r%@",text];//
//	NSDictionary *attributes=[NSDictionary dictionaryWithObject:[NSFont boldSystemFontOfSize:24] forKey:NSFontAttributeName];
//	NSAttributedString *string=[[[NSAttributedString alloc]initWithString:body attributes:attributes]autorelease];
	
//	NSLog(@"str %@ %@",string,[NSAppleEventDescriptor descriptorWithObjectAPPLE:string]);
	NSAppleEventDescriptor *ident=[[self script] executeSubroutine:@"set_note" arguments:[NSArray arrayWithObjects:uuid,body,nil]
															 error:nil];
	
	[dObject setObject:body forType:QSTextType];
	return nil;
}

- (QSObject *)addObjectArchive:(QSObject *)dObject{
	NSAppleEventDescriptor *ident=[[self script] executeSubroutine:@"add_url_archive" arguments:[NSArray arrayWithObject:[dObject objectForType:QSURLType]]
															 error:nil];
	NSString *uuid=	[ident stringValue];
	QSObject *newObject=[QSObject objectWithIdentifier:uuid];	
	[newObject setName:[dObject name]];
	[newObject setIdentifier:uuid];
	[newObject setObject:uuid forType:kQSYojimboPlugInType];
	[newObject setPrimaryType:kQSYojimboPlugInType];
	//NSLog(@"newob %@",newObject);
	return newObject;
	
}

- (QSObject *)showObject:(QSObject *)dObject{
	NSString *uuid=[dObject objectForType:kQSYojimboPlugInType];
	NSString *path=[[NSString stringWithFormat:@"~/Library/Caches/Metadata/com.barebones.yojimbo/%@.yojimboitem",uuid]stringByStandardizingPath];
	[[NSWorkspace sharedWorkspace]openFile:path];
	return nil;
}


- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	if ([dObject containsType:kQSYojimboPlugInType]) return [NSArray arrayWithObject:@"QSYojimboAppendAction"];
	else return [NSArray arrayWithObject:@"QSYojimboAddAction"];
	
}



- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
//	if ([action isEqualToString:@"QSTextPrependAction"]|| [action isEqualToString:@"QSTextAppendAction"])
//		return nil;
	QSObject *textObject=[QSObject textProxyObjectWithDefaultValue:@""];
	return [NSArray arrayWithObject:textObject]; //[QSLibarrayForType:NSFilenamesPboardType];
}


@end
