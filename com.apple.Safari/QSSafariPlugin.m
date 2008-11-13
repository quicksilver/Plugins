

#import "QSSafariPlugin.h"
//#import <QSCore/QSCore.h>
//
//#import <QSCore/QSObject_FileHandling.h>
//#import <QSCore/QSObject_URLHandling.h>
//
//#import <QSCore/QSLibrarian.h>
//#import <QSCore/QSTypes.h>
//#import <QSCore/QSMacros.h>
@implementation QSSafariObjectHandler

- (void)performJavaScript:(NSString *)jScript {
	//NSLog(@"JAVASCRIPT perform: %@", jScript);
	NSDictionary *errorDict = nil;
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Safari\" to do JavaScript \"%@\" in document 1", jScript]]autorelease];
	if (errorDict) NSLog(@"Load Script: %@", [errorDict objectForKey:@"NSAppleScriptErrorMessage"]);
	else [script executeAndReturnError:&errorDict];
	if (errorDict) NSLog(@"Run Script: %@", [errorDict objectForKey:@"NSAppleScriptErrorMessage"]);
}



- (id)resolveProxyObject:(id)proxy {	
	if (!QSAppIsRunning(@"com.apple.Safari") ) return nil;
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:@"tell application \"Safari\" to if (count documents) > 0 then URL of front document"] autorelease]; 	
	NSString *url = [[script executeAndReturnError:nil] stringValue];
	if (url)
		return [QSObject URLObjectWithURL:url title:nil];
	return nil;
}



- (BOOL)loadChildrenForObject:(QSObject *)object {
	if ([[object primaryType] isEqualToString:NSFilenamesPboardType]) {
		[object setChildren:[self safariChildren]];
		return YES; 	
	}
	NSDictionary *dict = [object objectForType:@"qs.safari.bookmarkGroup"];
	NSString *type = [dict objectForKey:@"WebBookmarkType"];
	NSString *ident = [dict objectForKey:@"WebBookmarkIdentifier"];
	
	NSArray *children = nil;
	
	if (![type isEqualToString:@"WebBookmarkTypeProxy"]) {
		id parser = [[[QSSafariBookmarksParser alloc] init] autorelease];
		children = [parser safariBookmarksForDict:dict deep:NO includeProxies:YES];
		
	} else if ([ident isEqualToString:@"History Bookmark Proxy Identifier"]) {
		QSCatalogEntry *theEntry = [QSLib entryForID:@"QSPresetSafariHistory"];
		children = [theEntry contentsScanIfNeeded:YES];
	} else if ([ident isEqualToString:@"Bonjour Bookmark Proxy Identifier"]) {
		return NO;
	} else if ([ident isEqualToString:@"Address Book Bookmark Proxy Identifier"]) {
		children = [[QSReg getClassInstance:@"QSAddressBookObjectSource"] performSelector:@selector(contactWebPages)];
	}
	
	if (children) {
		[object setChildren:children];
		return YES;  
	}
	return NO;
}

- (BOOL)objectHasChildren:(id <QSObject>)object {
	return YES;
}

- (NSString *)detailsOfObject:(QSObject *)object {
	
	NSDictionary *dict = [object objectForType:@"qs.safari.bookmarkGroup"];
	
	NSString *type = [dict objectForKey:@"WebBookmarkType"];
	NSString *ident = [dict objectForKey:@"WebBookmarkIdentifier"];
	
	if (![type isEqualToString:@"WebBookmarkTypeProxy"]) {
		
		int count = [[dict objectForKey:@"Children"] count];
		return [NSString stringWithFormat:@"%d item%@", count, ESS(count)];
	}
	return nil;
}

- (NSArray *)safariChildren {
	id parser = [[[QSSafariBookmarksParser alloc] init] autorelease];
	
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [@"~/Library/Safari/Bookmarks.plist" stringByStandardizingPath]];
	
	NSArray *children = [parser safariBookmarksForDict:dict deep:NO includeProxies:YES];
	return children;
}

// Object Handler Methods
- (void)setQuickIconForObject:(QSObject *)object {
    [object setIcon:[QSResourceManager imageNamed:@"GenericFolderIcon"]];
}

- (BOOL)loadIconForObject:(QSObject *)object {
	NSDictionary *dict = [object objectForType:@"qs.safari.bookmarkGroup"];
	NSString *uuid = [dict objectForKey:@"WebBookmarkUUID"];
	
	if ([uuid isEqualToString:@"Bookmarks Menu ID"]) {
		[object setIcon:[QSResourceManager imageNamed:@"SafariBookmarkMenuIcon"]]; 	
		return YES;
	}
	if ([uuid isEqualToString:@"Bookmarks Bar ID"]) {
		[object setIcon:[QSResourceManager imageNamed:@"SafariBookmarkBarIcon"]]; 	
		return YES;
	}
	
	NSString *ident = [dict objectForKey:@"WebBookmarkIdentifier"];
	if ([ident isEqualToString:@"History Bookmark Proxy Identifier"]) {
		[object setIcon:[QSResourceManager imageNamed:@"Recent"]]; 	
		return YES;
	}
	if ([ident isEqualToString:@"Bonjour Bookmark Proxy Identifier"]) {
		[object setIcon:[QSResourceManager imageNamed:@"Bonjour"]]; 	
		return YES;
	}
	if ([ident isEqualToString:@"Address Book Bookmark Proxy Identifier"]) {
		[object setIcon:[QSResourceManager imageNamed:@"com.apple.AddressBook"]]; 	
		return YES;
	}
	
	return NO;
}


@end

@implementation QSSafariBookmarksParser
- (BOOL)validParserForPath:(NSString *)path {
    return [[path lastPathComponent] isEqualToString:@"Bookmarks.plist"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    return [self safariBookmarksForDict:dict deep:YES includeProxies:NO];
}
- (NSArray *)safariBookmarksForDict:(NSDictionary *)dict deep:(BOOL)deep includeProxies:(BOOL)proxies {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
	NSString *title = [dict objectForKey:@"Title"];
	if ([title isEqualToString:@"Archive"]) return nil; //***Skip Archive Folder
	
	
	NSEnumerator *childEnum = [[dict objectForKey:@"Children"] objectEnumerator];
	NSDictionary *child;
	while (child = [childEnum nextObject]) {
		NSString *type = [child objectForKey:@"WebBookmarkType"];
		QSObject *object = nil;
		if ([type isEqualToString:@"WebBookmarkTypeLeaf"]) {
			//if ([ident isEqualToString:@"Address Book Bookmark Proxy Identifier"]) 			
			if (object = [self bookmarkLeafObjectForDict:child])
				[array addObject:object];
		} else if ([type isEqualToString:@"WebBookmarkTypeList"]) {
			if (deep)
				[array addObjectsFromArray:[self safariBookmarksForDict:child deep:YES includeProxies:proxies]];
			if (object = [self bookmarkGroupObjectForDict:child])
				[array addObject:object]; 			
		} else if ([type isEqualToString:@"WebBookmarkTypeProxy"] && proxies) {
			NSString *ident = [child objectForKey:@"WebBookmarkIdentifier"];
			if ([ident isEqualToString:@"Bonjour Bookmark Proxy Identifier"])
				continue;
		
			//if ([ident isEqualToString:@"Address Book Bookmark Proxy Identifier"])
			QSObject *object = [self bookmarkGroupObjectForDict:child];
		
			if (object)
				[array addObject:object];
			//else NSLog(@"child %@", child);
		}
	}
	return  array;
}

- (NSString *)safariLocalizedString:(NSString *)string {
	NSBundle *bundle = [NSBundle bundleWithPath:[[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:@"com.apple.Safari"]]; 	
	return [bundle localizedStringForKey:string value:string table:@"Localizable"];
}

- (QSObject *)bookmarkGroupObjectForDict:(NSDictionary *)dict {

	NSString *title = [dict objectForKey:@"Title"];
	NSString *identifier = [dict objectForKey:@"WebBookmarkUUID"];
	
	if ([identifier isEqualToString:@"Bookmarks Bar ID"])  title = [self safariLocalizedString:@"Bookmarks Bar"];
	if ([identifier isEqualToString:@"Bookmarks Menu ID"]) title = [self safariLocalizedString:@"Bookmarks Menu"];
	QSObject *group = [QSObject objectWithName:title];
	//NSLog(@"title %@", title);
	[group setIdentifier:identifier];
	[group setObject:dict forType:@"qs.safari.bookmarkGroup"];
	[group setPrimaryType:@"qs.safari.bookmarkGroup"];
	[group setObject:@"" forMeta:kQSObjectDefaultAction];
	
	//	if ([dict objectForKey:@"WebBookmarkAutoTab"])
	
	NSMutableArray *urls = [[[[dict objectForKey:@"Children"] valueForKey:@"URLString"] mutableCopy] autorelease];
	[urls removeObject:[NSNull null]];
	//NSLog(@"urls %@", urls);
	[group setObject:urls forType:QSURLType];
	//[group setObject:@"GenericFolderIcon" forMeta:kQSObjectDefaultAction];
	//NSLog(@"dict %@", urls);
	
	return group;
}
- (QSObject *)bookmarkLeafObjectForDict:(NSDictionary *)dict {
	NSString *url = [dict objectForKey:@"URLString"];
	NSString *title = [[dict objectForKey:@"URIDictionary"] objectForKey:@"title"];
	QSObject *leaf = [QSObject URLObjectWithURL:url title:title];
	return leaf;
}



@end

@implementation QSSafariHistoryParser

- (BOOL)validParserForPath:(NSString *)path {
    return [[path lastPathComponent] isEqualToString:@"History.plist"];
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings {
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    NSArray *history = [dict objectForKey:@"WebHistoryDates"];
    
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:1];
    
    NSEnumerator *childEnum = [history objectEnumerator];
    NSDictionary *child;
    while (child = [childEnum nextObject]) {
        NSString *url = [child objectForKey:@""];
        NSString *title = [child objectForKey:@"title"];
        QSObject *object = [QSObject URLObjectWithURL:url title:title];
        if (object) [array addObject:object];
    }
    return  array;
    
}

@end

