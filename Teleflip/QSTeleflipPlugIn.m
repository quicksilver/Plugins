//
//  QSTeleflipPlugIn.m
//  QSTeleflipPlugIn
//
//  Created by Nicholas Jitkoff on 8/16/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSTeleflipPlugIn.h"
#import <QSCore/QSLibrarian.h>
#import <QSCore/QSRegistry.h>

@implementation QSTeleflipPlugIn
- (QSObject *)sendSMS:(QSObject *)dObject toPhone:(QSObject *)iObject{
	NSMutableString *string=[[[iObject stringValue] mutableCopy]autorelease];
	NSRange range;
	NSCharacterSet *set=[[NSCharacterSet decimalDigitCharacterSet]invertedSet];
	while ((range=[string rangeOfCharacterFromSet:set]).location!=NSNotFound)
		[string deleteCharactersInRange:range];
	
	[string appendString:@"@teleflip.com"];
	NSLog(@"send '%@' to %@",[dObject stringValue],string);
	
	[[QSReg bundleWithIdentifier:@"com.blacktree.Quicksilver.QSEmailSupport"]load];
	[[QSReg QSMailMediator] sendEmailTo:[NSArray arrayWithObject:string] from:@"" subject:[dObject stringValue] body:[dObject stringValue] attachments:nil sendNow:YES];
	
	return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	//if ([action isEqualToString:kEmailItemAction] || [action isEqualToString:kComposeEmailItemAction]){
		return nil;
	//}else if ([action isEqualToString:kEmailItemReverseAction] ||[action isEqualToString:kDirectEmailItemReverseAction] || [action isEqualToString:kComposeEmailItemReverseAction]){
		NSMutableArray *objects=[QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:QSContactPhoneType]];
		return [NSArray arrayWithObjects:[NSNull null],objects,nil];
//	}
//	return nil;
}

@end
