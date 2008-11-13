//
//  QSTextMatePlugIn_Action.m
//  QSTextMatePlugIn
//
//  Created by Nicholas Jitkoff on 3/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSTextMatePlugIn_Action.h"

@implementation QSTextMatePlugIn_Action

- (QSObject *)openLineReference:(QSObject *)dObject{
	NSString *file=[[dObject objectForType:@"QSLineReferenceType"]objectForKey:@"path"];
	NSNumber *line=[[dObject objectForType:@"QSLineReferenceType"]objectForKey:@"line"];
	NSString *urlString=[NSString stringWithFormat:@"txmt://open?url=file://%@&line=%@",[file URLEncoding],line];
//	NSString *urlString=[NSString stringWithFormat:@"txmt:open?url=%@&line=%@",[[NSURL fileURLWithPath:file]absoluteString],line];
	NSLog(@"showref %@ %@",[dObject objectForType:@"QSLineReferenceType"], urlString);

	[[NSWorkspace sharedWorkspace]openURL:[NSURL URLWithString:urlString]];
		return nil;
}
@end

