

#import "QSWebSearchPlugInDefines.h"
#import "QSURLSearchActions.h"

# define kURLSearchAction @"QSURLSearchAction"
# define kURLSearchForAction @"QSURLSearchForAction"
# define kURLSearchForAndReturnAction @"QSURLSearchForAndReturnAction"
# define kURLFindWithAction @"QSURLFindWithAction"


@implementation QSURLSearchActions
- (NSString *) defaultWebClient{
	
	NSURL *appURL = nil; 
	OSStatus err; 
	err = LSGetApplicationForURL((CFURLRef)[NSURL URLWithString: @"http:"],kLSRolesAll, NULL, (CFURLRef *)&appURL); 
	if (err != noErr) NSLog(@"error %ld", err); 
	// else NSLog(@"%@", appURL); 
	
	return [appURL path];
	
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	//  NSLog(@"request");
	
	if ([action isEqualToString:kURLSearchForAction] || [action isEqualToString:kURLSearchForAndReturnAction]){
		NSString *webSearchString=[[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSStringPboardType];
		return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:(webSearchString?webSearchString:@"")]]; //[QSLibarrayForType:NSFilenamesPboardType];
		// return [NSArray arrayWithObject:[QSTextEntryProxy sharedInstance]]; //[QSLibarrayForType:NSFilenamesPboardType];
	}
	
	return nil;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	NSString *urlString=[[dObject arrayForType:QSURLType]lastObject];
	
	NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
	if (urlString){
		NSURL *url=[NSURL URLWithString:urlString];
		NSString *query=[url absoluteString];
		if (query && [query rangeOfString:QUERY_KEY].location!=NSNotFound){
			[newActions addObject:kURLSearchAction];
			[newActions addObject:kURLSearchForAction];
			[newActions addObject:kURLSearchForAndReturnAction];
		}
		
	} else if ([dObject containsType:QSTextType] && ![dObject containsType:QSFilePathType]){   
		[newActions addObject:kURLFindWithAction];
	}
	
	return newActions;
}


- (QSObject *)doURLSearchAction:(QSObject *)dObject{
	NSURL *url=[NSURL URLWithString:[dObject objectForType:QSURLType]];
	[[NSClassFromString(@"QSWebSearchController") sharedInstance] searchURL:url];
	return nil;
}
- (QSObject *)doURLSearchForAction:(QSObject *)dObject withString:(QSObject *)iObject{
	
	for(NSString * urlString in [dObject arrayForType:QSURLType]){
		NSURL *url=[NSURL URLWithString:urlString];
		
		NSString *string=[iObject stringValue];
		CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
		[[NSClassFromString(@"QSWebSearchController") sharedInstance] searchURL:url forString:string encoding:encoding];
	}
	return nil;
}
- (QSObject *)doURLSearchForAndReturnAction:(QSObject *)dObject withString:(QSObject *)iObject{
	for(NSString * urlString in [dObject arrayForType:QSURLType]){
		NSURL *url=[NSURL URLWithString:urlString];
		NSString *string=[iObject stringValue];
		CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
		NSString *query=[[NSClassFromString(@"QSWebSearchController") sharedInstance] resolvedURL:url forString:string encoding:encoding];
		BOOL post=NO;
		NSURL *queryURL=nil;
		if ([[url scheme]isEqualToString:@"qssp-http"]){
			query=[self openPOSTURL:[NSURL URLWithString:[query stringByReplacing:@"qssp-http" with:@"http"]]];  
		//	return;
		} else if ([[url scheme]isEqualToString:@"http-post"]){
			NSBeep();
			post=YES;
			query=[query stringByReplacing:@"http-post" with:@"http"];  
		//	return;
		} else if ([[url scheme]isEqualToString:@"qss-http"]){
			query=[query stringByReplacing:@"qss-http" with:@"http"];  
		}else{
	}
		
		
		id <QSParser> parser=[QSReg instanceForKey:@"html" inTable:@"QSURLTypeParsers"];
		//NSLog(@" %@ %@",type,parser);
		
		[QSTasks updateTask:@"DownloadPage" status:@"Downloading Page" progress:0];
		NSArray *children=[parser objectsFromURL:[NSURL URLWithString:query] withSettings:nil];
		[QSTasks removeTask:@"DownloadPage"];
		
		[[QSReg preferredCommandInterface]showArray:children];
		
		
		
	}
	

	return nil;
}
@end