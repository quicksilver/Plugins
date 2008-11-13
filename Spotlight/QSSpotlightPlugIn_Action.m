//
//  QSSpotlightPlugIn_Action.m
//  QSSpotlightPlugIn
//
//  Created by Nicholas Jitkoff on 10/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSpotlightPlugIn_Action.h"
#import <Carbon/Carbon.h>
#import "QSMDFindWrapper.h"
#import "QSNSMDQueryWrapper.h"

#import <QSInterface/QSInterfaceController.h>
// Allow us to bind to the icon of a NSMetadataItem by extending it

@implementation NSMetadataItem (ItemExtras)
- (NSImage *)icon {
    NSString *path = [self valueForKey:(id)kMDItemPath];
    return [[NSWorkspace sharedWorkspace] iconForFile:path];
}
- (NSString *)displayName{
	return [self valueForAttribute:kMDItemDisplayName];
}
+ (NSMetadataItem *)itemWithPath:(NSString *)path{
	MDItemRef ref=MDItemCreate(NULL,(CFStringRef)path);
	[[[self alloc]_init:ref]autorelease];
}
//+ (NSArray *)itemsWithPaths:(NSArray *)paths{
//}
@end

@implementation QSSpotlightPlugIn_Action


#define kQSSpotlightPlugInAction @"QSSpotlightPlugInAction"

- (QSObject *)internalSpotlightSearchForString:(QSObject *)dObject{
	NSString *query=[dObject stringValue];
	
	if ([query rangeOfString:@"kMDItem"].location==NSNotFound){
		query=[NSString stringWithFormat:@"((kMDItemFSName = '%@*'cd)||kMDItemTextContent = '%@*'cd)",query,query];
	}
	
	
	QSNSMDQueryWrapper *wrap=[QSNSMDQueryWrapper findWrapperWithQuery:query path:nil keepalive:NO];
	NSMutableArray *results=[wrap results];
	[wrap startQuery];
	
	QSInterfaceController *controller=[[NSApp delegate]interfaceController];
	[controller showArray:results];
	return nil;
}

- (QSObject *)finderSpotlightSearchForString:(QSObject *)dObject{
	NSString *query=[dObject stringValue];
	[self runQueryInFinder:[self trueQueryFor:query] name:query scope:nil];
	return nil;
}

	
- (QSObject *)spotlightSearchForString:(QSObject *)dObject{
//	id item=[NSMetadataItem itemWithPath:@"/Volumes/Lore/Library/Mail/Mailboxes/2005/01.mbox/Messages/43592.emlx"];
//	NSLog(@"Value %@",[item valueForAttribute:kMDItemDisplayName]);
	
	OSStatus resultCode=noErr;
	resultCode=HISearchWindowShow((CFStringRef)[dObject stringValue],kNilOptions);
	if (resultCode != noErr) {
		// failed to open the panel
		// present an error to the user
    }
}

- (QSObject *)spotlightSearchInFolder:(QSObject *)dObject forString:(QSObject *)iObject{
	NSString *path=[dObject singleFilePath];
	NSString *query=[iObject stringValue];
	
	//NSLog(@"search in %@ for %@",path, query);
	query=[NSString stringWithFormat:@"((kMDItemFSName = '%@*'cd)||kMDItemTextContent = '%@*'cd)  && (kMDItemContentType != com.apple.mail.emlx) && (kMDItemContentType != public.vcard)",query,query];
	
	QSNSMDQueryWrapper *wrap=[QSNSMDQueryWrapper findWrapperWithQuery:query path:path keepalive:NO];
	NSMutableArray *results=[wrap results];
	[wrap startQuery];
	
	QSInterfaceController *controller=[[NSApp delegate]interfaceController];
	[controller showArray:results];
	return nil;
}
- (QSObject *)spotlightSearchFinderInFolder:(QSObject *)dObject forString:(QSObject *)iObject{
	NSString *query=[iObject stringValue];
	[self runQueryInFinder:[self trueQueryFor:query] name:query scope:[dObject singleFilePath]];
	return nil;
}
- (NSString *)trueQueryFor:(NSString *)query{
	if ([query rangeOfString:@"kMD"].location==NSNotFound)
		return [NSString stringWithFormat:@"((kMDItemFSName = '%@*'cd)||kMDItemTextContent = '%@*'cd)  && (kMDItemContentType != com.apple.mail.emlx) && (kMDItemContentType != public.vcard)",query,query];
	else
		return query;
}
- (QSObject *)spotlightSearchFilenamesInFolder:(QSObject *)dObject forString:(QSObject *)iObject{
	NSString *path=[dObject singleFilePath];
	NSString *query=[iObject stringValue];
	
	query=[NSString stringWithFormat:@"(kMDItemFSName = '%@*'cd) && (kMDItemContentType != com.apple.mail.emlx) && (kMDItemContentType != public.vcard)",query];
	
	QSNSMDQueryWrapper *wrap=[QSNSMDQueryWrapper findWrapperWithQuery:query path:path keepalive:NO];
	NSMutableArray *results=[wrap results];
	[wrap startQuery];
	
	QSInterfaceController *controller=[[NSApp delegate]interfaceController];
	[controller showArray:results];
	return nil;
}



- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
		QSObject *textObject=[QSObject textProxyObjectWithDefaultValue:@""];
		return [NSArray arrayWithObject:textObject]; //[QSLibarrayForType:NSFilenamesPboardType];
}





-(void)runQueryInFinder:(NSString *)query name:(NSString *)name scope:(NSString *)scope{
	if (!name)name=query;
	NSMutableDictionary *dict=[NSMutableDictionary dictionary];
	[dict setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"ToolbarVisible"]
			 forKey:@"ViewOptions"];
	[dict setObject:[NSNumber numberWithInt:0]
			 forKey:@"CompatibleVersion"];
	[dict setObject:@"10.4"
			 forKey:@"version"];
	[dict setObject:query
			 forKey:@"RawQuery"];
	
	
	NSMutableDictionary *criteria=[NSMutableDictionary dictionary];
	{	
		[criteria setObject:name 								 forKey:@"AnyAttributeContains"];
	if (scope)	[criteria setObject:[NSArray arrayWithObject:scope]		 forKey:@"FXScopeArrayOfPaths"];
	}
	[dict setObject:criteria	forKey:@"SearchCriteria"];	
	
	NSMutableString *filename=[[name mutableCopy]autorelease];
	[filename replaceOccurrencesOfString:@"/" withString:@"_" options:nil range:NSMakeRange(0,[filename length])];
	if ([filename length]>242)
		filename=[filename substringToIndex:242];
	[filename appendString:@".savedSearch"];
	filename=[NSTemporaryDirectory() stringByAppendingPathComponent:filename];
	[dict writeToFile:filename atomically:NO];
	[[NSFileManager defaultManager]changeFileAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:
		NSFileExtensionHidden] atPath:filename];
	[[NSWorkspace sharedWorkspace]openTempFile:filename];
	
	usleep(500000);
//	[[NSFileManager defaultManager]removeFileAtPath:filename handler:nil];
}










/*

- (id)init {
    if (self = [super init]) {
        _query = [[NSMetadataQuery alloc] init];
        
        // To watch results send by the query, add an observer to the NSNotificationCenter
        NSNotificationCenter *nf = [NSNotificationCenter defaultCenter];
        [nf addObserver:self selector:@selector(queryNote:) name:nil object:_query];
        
        // We want the items in the query to automatically be sorted by the file system name; this way, we don't have to do any special sorting
        [_query setSortDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:(id)kMDItemPath ascending:YES] autorelease]]];
        // For the groups, we want the first grouping by the kind, and the second by the file size. 
        //[_query setGroupingAttributes:[NSArray arrayWithObjects:(id)kMDItemKind, (id)kMDItemFSSize, nil]];
        
        [_query setDelegate:self];
        
    }
    return self;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_query release];
    [_searchKey release];
    [super dealloc];
}

- (NSMetadataQuery *)query {
    return _query;
}

- (void)queryNote:(NSNotification *)note {
    // The NSMetadataQuery will send back a note when updates are happening. By looking at the [note name], we can tell what is happening
    if ([[note name] isEqualToString:NSMetadataQueryDidStartGatheringNotification]) {
        // The query has just started!
        NSLog(@"Started gathering");
    } else if ([[note name] isEqualToString:NSMetadataQueryDidFinishGatheringNotification]) {
        // At this point, the query will be done. You may recieve an update later on.
		
        NSLog(@"Finished gathering %d items:\r%@",[_query resultCount],[[[_query results]valueForKey:kMDItemPath]componentsJoinedByString:@"\r"]);
    } else if ([[note name] isEqualToString:NSMetadataQueryGatheringProgressNotification]) {
        // The query is still gatherint results...
        NSLog(@"Progressing...");
    } else if ([[note name] isEqualToString:NSMetadataQueryDidUpdateNotification]) {
        // An update will happen when Spotlight notices that a file as added, removed, or modified that affected the search results.
        NSLog(@"An update happened.");
    }
}

- (void)searchIn:(NSString *)path for:(NSString *)string{
//- (void)createSearchPredicate {
    // This demonstrates a few ways to create a search predicate.
    
    // The user can set the checkbox to include this in the search result, or not.
    NSPredicate *predicateToRun = nil;
    if (1) {
        // In the example below, we create a predicate with a given format string that simply replaces %@ with the string that is to be searched for. By using "like", the query will end up doing a regular expression search similar to *foo* when you are searching for the word "foo". By using the [c], the NSCaseInsensitivePredicateOption will be set in the created predicate. The particular item type to search for, kMDItemTextContent, is described in MDItem.h.
        NSString *predicateFormat = @"kMDItemPath beginswith %@";
        predicateToRun = [NSPredicate predicateWithFormat:predicateFormat, path];
    }
    
    // Create a compound predicate that searches for any keypath which has a value like the search key. This broadens the search results to include things such as the author, title, and other attributes not including the content. This is done in code for two reasons: 1. The predicate parser does not yet support "* = Foo" type of parsing, and 2. It is an example of creating a predicate in code, which is much "safer" than using a search string.
    unsigned options = (NSCaseInsensitivePredicateOption|NSDiacriticInsensitivePredicateOption);
    NSPredicate *compPred = [NSComparisonPredicate
                predicateWithLeftExpression:[NSExpression expressionForKeyPath:@"*"]
                            rightExpression:[NSExpression expressionForConstantValue:string]
                                   modifier:NSDirectPredicateModifier
                                       type:NSLikePredicateOperatorType
                                    options:options];
    
    // Combine the two predicates with an OR, if we are including the content as searchable
//    if (1) {
//        predicateToRun = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:compPred, predicateToRun, nil]];
//    } else {
//        // Since we aren't searching the content, just use the other predicate
//        predicateToRun = compPred;
//    }
    
    // Now, we don't want to include email messages in the result set, so add in an AND that excludes them
 //   NSPredicate *emailExclusionPredicate = [NSPredicate predicateWithFormat:@"(kMDItemContentType != 'com.apple.mail.emlx') && (kMDItemContentType != 'public.vcard')"];
   // predicateToRun = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicateToRun, emailExclusionPredicate, nil]];
    
	
	NSLog(@"Predicate %@",predicateToRun);
    // Set it to the query. If the query already is alive, it will update immediately
    [_query setPredicate:predicateToRun];           
    
    // In case the query hasn't yet started, start it.
    [_query startQuery]; 
}

- (BOOL)searchContent {
    return _searchContent;
}

- (void)setSearchContent:(BOOL)value {
    if (_searchContent != value) {
        _searchContent = value;
        [self createSearchPredicate];
    }
}

- (NSString *)searchKey {
    return [[_searchKey copy] autorelease];
}

- (void)setSearchKey:(NSString *) value {
    if (_searchKey != value) {
        [_searchKey release];
        _searchKey = [value copy];
        [self createSearchPredicate];
    }
}

*/
@end
