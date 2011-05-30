

#import "QSWebSearchPlugInDefines.h"
#import "QSURLSearchActions.h"
#import "QSWebSearchController.h"

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
	// if it's a 'find with...' action, only return valid URLs with *** in them
	if ([action isEqualToString:kURLFindWithAction]) {
		// Get a list of all 
		NSMutableArray *urlObjects=[QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:QSURLType]];
		NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
		for(QSObject *individual in urlObjects){
			// For some reason QSLib returns folders as QSURLType. This checks to make sure they're URLs
			NSString *urlString=[[individual arrayForType:QSURLType]lastObject];
			if(urlString){
			NSURL *url=[NSURL URLWithString:[urlString URLEncoding]];
			NSString *query=[url absoluteString];
			if ([query rangeOfString:QUERY_KEY].location!=NSNotFound){
				[objects addObject:individual];
			}
			}
		}
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
	NSString *urlString=[[dObject arrayForType:QSURLType]lastObject];
	
	NSMutableArray *newActions=[NSMutableArray arrayWithCapacity:1];
	if (urlString){
		NSURL *url=[NSURL URLWithString:[urlString URLEncoding]];
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
	// define encoding of the string
	CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
	if(!encoding)
		encoding = NSUTF8StringEncoding;
	
	// get an NSURL

	[[QSWebSearchController sharedInstance] searchURL:[dObject objectForType:QSURLType]];
	return nil;
}
// The encoding of the object is returning null. This will break in a future release of OS X
- (QSObject *)doURLSearchForAction:(QSObject *)dObject withString:(QSObject *)iObject{
	
	for(NSString * urlString in [dObject arrayForType:QSURLType]){
		CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
		// Make sure characters such as | are escaped
		if(!encoding)
			encoding = NSUTF8StringEncoding;

		NSString *string=[iObject stringValue];
		[[QSWebSearchController sharedInstance] searchURL:urlString forString:string encoding:encoding];
	}
	return nil;
}
- (QSObject *)doURLSearchForAndReturnAction:(QSObject *)dObject withString:(QSObject *)iObject{
	for(NSString * urlString in [dObject arrayForType:QSURLType]){
		CFStringEncoding encoding=[[dObject objectForMeta:kQSStringEncoding]intValue];
		if(!encoding)
			encoding = NSUTF8StringEncoding;

		NSString *string=[iObject stringValue];
		
		NSString *query=[[QSWebSearchController sharedInstance] resolvedURL:urlString forString:string encoding:encoding];
		BOOL post=NO;
		NSURL *url = [NSURL URLWithString:query];
		if ([[url scheme]isEqualToString:@"qssp-http"]){
			[[QSWebSearchController sharedInstance] openPOSTURL:[NSURL URLWithString:[query stringByReplacing:@"qssp-http" with:@"http"]]];  
		//	return;
		} else if ([[url scheme]isEqualToString:@"http-post"]){
			NSBeep();
			post=YES;
			query=[query stringByReplacing:@"http-post" with:@"http"];  
		//	return;
		} else if ([[url scheme]isEqualToString:@"qss-http"]){
			query=[query stringByReplacing:@"qss-http" with:@"http"];
		} else if ([[url scheme]isEqualToString:@"qss-https"]) {
			query=[query stringByReplacing:@"qss-https" with:@"https"];  			
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