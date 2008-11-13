//
//  QSGooglePlugIn_Action.m
//  QSGooglePlugIn
//
//  Created by Nicholas Jitkoff on 1/1/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSGooglePlugIn_Action.h"
#import "QSGoogleStub.h"

@implementation QSGooglePlugIn_Action


#define kQSGooglePlugInAction @"QSGooglePlugInAction"

- (QSObject *)searchForTextOnGoogle:(QSObject *)dObject{
	
	NSString *string=[dObject stringValue];
	NSString *key=[[NSUserDefaults standardUserDefaults]stringForKey:@"QSGoogleAPIKey"];
	NSDictionary * results=[GoogleSearchService doGoogleSearch:key
											in_q:string
										in_start:0
								   in_maxResults:10 
									   in_filter:(BOOL) TRUE
									 in_restrict:@"" 
								   in_safeSearch:(BOOL) FALSE 
										   in_lr:@"" 
										   in_ie:@"latin1" 
										   in_oe:@"latin1"];
	
	//NSLog(@"?? %@",[results description]);
	//[whatever writeToFile:@"test.plist" atomically:YES];
	NSMutableArray *array=[NSMutableArray array];
	
	NSEnumerator *e=[[results objectForKey:@"resultElements"]objectEnumerator];
	
	NSDictionary *item=nil;
	while (item=[e nextObject]){
		NSString *title=[item objectForKey:@"title"];
		
		if ([title isKindOfClass:[NSNull class]])title=nil;
		
	
		title=[[[NSAttributedString alloc]initWithHTML:[title dataUsingEncoding:NSISOLatin1StringEncoding]
									documentAttributes:nil]string];
		title=[title stringByAppendingFormat:@" - %@",[item objectForKey:@"URL"]];		
		NSString *snippet=[item objectForKey:@"snippet"];
		if ([snippet isKindOfClass:[NSNull class]])snippet=nil;
		snippet=[[[NSAttributedString alloc]initWithHTML:[snippet dataUsingEncoding:NSISOLatin1StringEncoding]
									documentAttributes:nil]string];
		
		QSObject *o=[QSObject URLObjectWithURL:[item objectForKey:@"URL"]
										 title:title];
		[o setDetails:snippet];
		[array addObject:o];
	}
	
	id controller=[[NSApp delegate]interfaceController];
	[controller showArray:array];
	
	
	return nil;
}
@end
