

#import "QSWebSearchPlugInDefines.h"
#import "QSURLSearchActions.h"

# define kURLSearchAction @"QSURLSearchAction"
# define kURLSearchForAction @"QSURLSearchForAction"
# define kURLSearchForAndReturnAction @"QSURLSearchForAndReturnAction"
# define kURLFindWithAction @"QSURLFindWithAction"
# define kQSSearchURLType @"QSSearchURLType"

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
	// if it's a 'find with...' action, only return valid URLs with *** in them (type QSSearchURLType)
	if ([action isEqualToString:kURLFindWithAction]) {
		NSMutableArray *objects=[QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:@"QSSearchURLType"]];
		return [NSArray arrayWithObjects:[NSNull null],objects,nil];
	}
	// if it's a 'search for...' action, return a text bot for text
	else if ([action isEqualToString:kURLSearchForAction] || [action isEqualToString:kURLSearchForAndReturnAction]){
		NSString *webSearchString=[[NSPasteboard pasteboardWithName:NSFindPboard] stringForType:NSStringPboardType];
		return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:(webSearchString?webSearchString:@"")]]; //[QSLibarrayForType:NSFilenamesPboardType];
		// return [NSArray arrayWithObject:[QSTextEntryProxy sharedInstance]]; //[QSLibarrayForType:NSFilenamesPboardType];
	}
	
	return nil;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	
	NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
	if ([[dObject primaryType] isEqualToString:kQSSearchURLType]){
			[newActions addObject:kURLSearchAction];
			[newActions addObject:kURLSearchForAction];
			[newActions addObject:kURLSearchForAndReturnAction];

		
	} else if ([dObject containsType:QSTextType] && ![dObject containsType:QSFilePathType]){   
		[newActions addObject:kURLFindWithAction];
	}
	
	return newActions;
}


- (QSObject *)doURLSearchAction:(QSObject *)dObject{
	// define encoding of the string
	CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
	// get an NSURL, escaping the characters
	NSURL *url=[NSURL URLWithString:[[dObject objectForType:QSURLType] stringByAddingPercentEscapesUsingEncoding:encoding]];
	[[NSClassFromString(@"QSWebSearchController") sharedInstance] searchURL:url];
	return nil;
}
#warning encoding here is returning 'null'
// The encoding of the object is returning null. This will break in a future release of OS X
- (QSObject *)doURLSearchForAction:(QSObject *)dObject withString:(QSObject *)iObject{
	
	for(NSString * urlString in [dObject arrayForType:QSURLType]){
		CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
		// Make sure characters such as | are escaped
		if(!encoding)
			encoding = kCFStringEncodingUTF8;
		NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:encoding]];
		
		NSString *string=[iObject stringValue];
		[[NSClassFromString(@"QSWebSearchController") sharedInstance] searchURL:url forString:string encoding:encoding];
	}
	return nil;
}
- (QSObject *)doURLSearchForAndReturnAction:(QSObject *)dObject withString:(QSObject *)iObject{
	for(NSString * urlString in [dObject arrayForType:QSURLType]){
		CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
		if(!encoding)
			encoding = kCFStringEncodingUTF8;
		// get an NSURL, escaping scary characters like |
		NSURL *url=[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:encoding]];
		NSString *string=[iObject stringValue];
		NSString *query=[[NSClassFromString(@"QSWebSearchController") sharedInstance] resolvedURL:url forString:string encoding:encoding];
		BOOL post=NO;
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