#import "QSWebSearchPlugInDefines.h"
#import "QSWebSearchController.h"



@implementation QSWebSearchController
+ (id)sharedInstance {
    static id _sharedInstance;
    if (!_sharedInstance) {
		_sharedInstance = [[[self class] allocWithZone:[self zone]] init];
	}
    return _sharedInstance;  
}

- (id)init {
    self = [super init]; // initWithWindowNibName:@"WebSearch"]; 
    if (self) {
		[[self window] setLevel:NSFloatingWindowLevel];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window]setHidesOnDeactivate:NO];
	//    [webSearchWindow setFrameTopLeftPoint:[mainWindow frame].origin];
}

- (void)searchURL:(NSURL *)searchURL {
	//    NSLog(@"SEARCH: %@",searchURL);
    [self setWebSearch:searchURL];
    //performingWebSearch=YES;
    [self showSearchView:self];
	[[self window] makeKeyAndOrderFront:self];
}

//kQSStringEncoding
- (NSString *)resolvedURL:(NSString *)searchURL forString:(NSString *)string  encoding:(CFStringEncoding)encoding {
	if(!encoding) {
		encoding = NSUTF8StringEncoding;
	}
	
	// escape URL, but not # or %
	NSString *query = [searchURL URLEncoding];
		
	// Escape everything in the query string
    NSString *searchTerm = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
																			   (CFStringRef) string,
																			   NULL,
																			   (CFStringRef) @"!*'();:@&=+$,/?%#[]",
																			   kCFStringEncodingUTF8);
	
	// Query key set in QSDefines.h - QS Code (typically ***)
    query = [query stringByReplacing:QUERY_KEY with:searchTerm];
	return query;
}

- (void)searchURL:(NSString *)searchURL forString:(NSString *)string  encoding:(CFStringEncoding)encoding {    
    NSPasteboard *findPboard=[NSPasteboard pasteboardWithName:NSFindPboard];
    [findPboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
    [findPboard setString:string forType:NSStringPboardType];
    NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
	
	NSString *query = [self resolvedURL:searchURL forString:string encoding:encoding];
	NSURL *url = [NSURL URLWithString:query];
	if ([[url scheme]isEqualToString:@"qss-http"]){
		query = [query stringByReplacing:@"qss-http" with:@"http"];  
		[workspace openURL:[NSURL URLWithString:query]];
	}
	else if ([[url scheme] isEqualToString:@"qss-https"]) {
		query = [query stringByReplacing:@"qss-https" with:@"https"];  
		[workspace openURL:[NSURL URLWithString:query]];
	}
	else if ([[url scheme] isEqualToString:@"qssp-http"]){
		//  query=[query stringByReplacing:OLD_QUERY_KEY with:searchTerm]; // allow old query for now
		[self openPOSTURL:[NSURL URLWithString:[query stringByReplacing:@"qssp-http" with:@"http"]]];  
		return;
	}
	else if ([[url scheme] isEqualToString:@"qssp-https"]) {
		[self openPOSTURL:[NSURL URLWithString:[query stringByReplacing:@"qssp-https" with:@"https"]]];
		return;
	}
	else if ([[url scheme] isEqualToString:@"http-post"]){
		[self openPOSTURL:[NSURL URLWithString:[query stringByReplacing:@"http-post" with:@"http"]]];  
		return;
	}
	else{
		NSURL *queryURL=[NSURL URLWithString:query];
		[workspace openURL:queryURL];
	}
}

- (void)searchURL:(NSString *)searchURL forString:(NSString *)string{    
	[self searchURL:(NSString *)searchURL forString:(NSString *)string  encoding:(CFStringEncoding)nil];   
}

- (void)openPOSTURL:(NSURL *)searchURL{
    NSMutableString *form=[NSMutableString stringWithCapacity:100];
    
    [form appendString:@"<html><head><title>Quicksilver Search Submitter</title></head><body onLoad=\"document.qsform.submit()\">"];
    [form appendFormat:@"<form name=\"qsform\" action=\"%@\" method=\"POST\">",[[[searchURL absoluteString]componentsSeparatedByString:@"?"]objectAtIndex:0]];
    NSString *component;
    NSEnumerator *queryEnumerator=[[[searchURL query]componentsSeparatedByString:@"&"]objectEnumerator];
    while (component = [queryEnumerator nextObject]){
        NSArray *nameAndValue=[component componentsSeparatedByString:@"="];
        [form appendFormat:@"<input type=hidden name=\"%@\" value=\"%@\">",
            [[[nameAndValue objectAtIndex:0]URLDecoding]stringByReplacing:@"+" with:@" "],
            [[[nameAndValue objectAtIndex:1]URLDecoding]stringByReplacing:@"+" with:@" "]];
    }
    [form appendString:@"</body></html>"];
    NSString *postFile=[NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"QSPOST-%@.html",[NSString uniqueString]]]; 
	// ***warning   * delete these files
    [form writeToFile:postFile atomically:NO];
    [[NSWorkspace sharedWorkspace]openFile:postFile];
}

- (IBAction)submitWebSearch:(id)sender {
    if ([[webSearchField stringValue]length]){
		[self searchURL:webSearch forString:[webSearchField stringValue]];
		[self setWebSearch:nil];
		[[self window] orderOut:self];
    }
}

- (IBAction) showSearchView:sender {
    NSPasteboard *findPboard=[NSPasteboard pasteboardWithName:NSFindPboard];
    NSString *webSearchString=[findPboard stringForType:NSStringPboardType];
    if (webSearchString) [webSearchField setStringValue:webSearchString];
    [[self window] orderFront:self];
}

- (void)windowDidResignKey:(NSNotification *)aNotification {
	[[self window] orderOut:self];
}

- (id)webSearch {
	return [[webSearch retain] autorelease];
}

- (void)setWebSearch:(id)newWebSearch {
    [webSearch release];
    webSearch = [newWebSearch retain];
}

@end