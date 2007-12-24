//
//  TSActions.m
//  TSActionsPlugin
//
//  Created by Kevin Ballard on 6/23/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import "TSActions.h"

#import <QSCore/QSObject.h>
#import <QSCore/QSResourceManager.h>
#import <QSCore/QSTypes.h>

#define TSGoogleCacheAction @"TSGoogleCacheAction"
#define TSWaybackArchiveAction @"TSWaybackArchiveAction"
#define TSBugMeNotAction @"TSBugMeNotAction"

@implementation TSActions
- (id) init {
	if (self = [super init]) {
		NSBundle *plugin = [NSBundle bundleForClass:[self class]];
		bugMeNotImage = [[NSImage alloc] initByReferencingFile:
			[plugin pathForResource:@"bugmenot" ofType:@"gif"]];
	}
	return self;
}

- (void) dealloc {
	[bugMeNotImage release];
	[super dealloc];
}

- (NSArray *) types {
	return [NSArray arrayWithObjects:QSURLType, nil];
}

- (NSArray *) actions {
	NSBundle *plugin = [NSBundle bundleForClass:[TSActions class]];
	NSMutableArray *actionArray = [NSMutableArray array];
	QSAction *action = [QSAction actionWithIdentifier:TSGoogleCacheAction bundle:plugin];
	[action setIcon:[QSResourceManager imageNamed:@"DefaultBookmarkIcon"]];
	[action setProvider:self];
	[action setAction:@selector(viewGoogleCache:)];
	[action setArgumentCount:1];
	[action setDetails:@"View the Google cache for this page"];
	[actionArray addObject:action];
	
	action = [QSAction actionWithIdentifier:TSWaybackArchiveAction bundle:plugin];
	[action setIcon:[QSResourceManager imageNamed:@"DefaultBookmarkIcon"]];
	[action setProvider:self];
	[action setAction:@selector(viewWaybackArchive:)];
	[action setArgumentCount:1];
	[action setDetails:@"View the Wayback archive for this page"];
	[actionArray addObject:action];
	
	action = [QSAction actionWithIdentifier:TSBugMeNotAction bundle:plugin];
	[action setIcon:bugMeNotImage];
	[action setProvider:self];
	[action setAction:@selector(viewBugMeNotLogins:)];
	[action setArgumentCount:1];
	[action setDetails:@"View the BugMeNot logins for this site"];
	[actionArray addObject:action];
	
	return actionArray;
}

- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	NSMutableArray *actionArray = [NSMutableArray array];
	NSString *url = nil;
	if ((url = [dObject objectForType:QSURLType]) != nil &&
		[url hasPrefix:@"http://"]) {
		[actionArray addObject:TSGoogleCacheAction];
		[actionArray addObject:TSWaybackArchiveAction];
		[actionArray addObject:TSBugMeNotAction];
	}
	
	return actionArray;
}

- (QSObject *) viewGoogleCache:(QSObject *)dObject {
	NSString *origURL = [dObject objectForType:QSURLType];
	NSString *encodedURL = [origURL stringByEscapingURLChars];
	NSURL *cacheURL = [NSURL URLWithString:
		[NSString stringWithFormat:@"http://www.google.com/search?q=cache:%@&ie=UTF-8&oe=UTF-8",
			encodedURL]];
	[[NSWorkspace sharedWorkspace] openURL:cacheURL];
	
	return nil;
}

- (QSObject *) viewWaybackArchive:(QSObject *)dObject {
	NSString *origURL = [dObject objectForType:QSURLType];
	NSString *encodedURL = [origURL stringByEscapingURLChars];
	NSURL *cacheURL = [NSURL URLWithString:
		[NSString stringWithFormat:@"http://web.archive.org/web/*/%@", encodedURL]];
	[[NSWorkspace sharedWorkspace] openURL:cacheURL];
	
	return nil;
}

- (QSObject *) viewBugMeNotLogins:(QSObject *)dObject {
	NSString *origURL = [dObject objectForType:QSURLType];
	NSString *encodedURL = [origURL stringByEscapingURLChars];
	NSURL *cacheURL = [NSURL URLWithString:
		[NSString stringWithFormat:@"http://www.bugmenot.com/view.php?url=%@", encodedURL]];
	[[NSWorkspace sharedWorkspace] openURL:cacheURL];
	
	return nil;
}
@end

@implementation NSString (TSActionsStringExtensions)
- (NSString *) stringByEscapingURLChars {
	NSCharacterSet *invalidChars = [NSCharacterSet characterSetWithCharactersInString:@"#%^&[]{}\\|\"<>?"];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
	NSString *output = nil;
	NSMutableString *result = [NSMutableString string];
	while (![scanner isAtEnd]) {
		if ([scanner scanUpToCharactersFromSet:invalidChars intoString:&output])
			[result appendString:output];
		if ([scanner scanCharactersFromSet:invalidChars intoString:&output]) {
			// encode each character
			int i;
			for (i = 0; i < [output length]; i++) {
				[result appendFormat:@"%%%.2X", [output characterAtIndex:i]];
			}
		}
	}
	
	return result;
}
@end
