//
//  HRToonManager.m
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Wed Oct 27 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "HRObjectManager.h"

@implementation HRObjectManager

//+ (HRObjectManager *)defaultManager;

+ (HRObjectManager *)defaultStrongBadEmailManager {
	HRObjectManager *manager;
	
	manager = [[[HRObjectManager alloc] initWithParser:[HREmailParser defaultParser]] autorelease];
	[manager setPreference:@"root.identifier" forKey:@"com.homestarrunner.sbemail"];
	[manager setPreference:@"root.type" forKey:@"com.homestarrunner.sbemail.list"];
	[manager setSources:[NSDictionary dictionaryWithObjectsAndKeys:
							@"http://www.hrwiki.org/index.php?title=Strong_Bad_Email&action=edit", @"com.homestarrunner.sbemail.list",
							@"http://www.hrwiki.org/index.php?title=*name*&action=edit", @"com.homestarrunner.sbemail.item"]];
	
	return manager;
}

//+ (HRObjectManager *)defaultToonManager;
//+ (HRObjectManager *)defaultCharacterManager;

- (NSDictionary *)objectsForEntry:(NSDictionary *)entry {
	NSString *key;
	NSMutableString *source;
	NSEnumerator *typeEnum = [_sources keyEnumerator], *keyEnum;
	
	while( key = [typeEnum nextObject] ) {
		if( [[entry objectForKey:@"type"] isEqualToString:key] ) {
			/* got the type, now get the source */
			source = [NSMutableString stringWithString:[_sources objectForKey:key]];
			keyEnum = [entry keyEnumerator];
			while( key = [keyEnum nextObject] ) {
				/* replace any instances of *key* in the source */
				source = [source replaceOccurrencesOfString : [NSString stringWithFormat:@"*%@*", key]
												 withString : [entry objectForKey:key]
													options : NSCaseInsensitiveSearch
													  range : NSMakeRange(0, [source length])];
			}
		}
	}
	
	/* download the URL referenced by 'source' and pass it to our parser */
	NSURL *url = [NSURL URLWithString:(NSString *)source];
	
	return [_parser objectsFromString:[NSString stringWithContentsOfURL:url orCache:[url cachePath] ifCreatedSinceNow:(-24*60*60)] ofType:[entry objectForKey:@"type"]];
}

- (NSDictionary *)rootEntry {
	return [NSDictionary dictionaryWithObjectsAndKeys:
				[_prefs objectForKey:@"root.identifier"], @"identifier",
				[_prefs objectForKey:@"root.type"], @"type"];
}

- (NSDictionary *)objectsForRoot {
	return [self objectsForEntry:[self rootEntry]];
}

- (id)initWithParser:(HRObjectParser *)parser {
	_parser = [parser retain];
}

- (void)dealloc {
	[_parser release];
	[_sources release];
	[super dealloc];
}

- (HRObjectParser *)parser {
	return _parser;
}

- (void)setParser:(HRObjectParser *)parser {
	[_parser autorelease];
	_parser = [parser retain];
}

- (NSMutableDictionary *)preferences {
	return _prefs;
}

- (void)setPreference:(id)object forKey:(NSString *)key {
	[_prefs setObject:object forKey:key];
}

- (NSDictionary *)sources {
	return _sources;
}

- (void)setSources:(NSDictionary *)sources {
	[_sources autorelease];
	_sources = [sources retain];
}

- (id)sourceForType:(NSString *)type {
	return [_sources objectForKey:type];
}

@end