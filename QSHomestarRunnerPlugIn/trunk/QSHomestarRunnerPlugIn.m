//
//  QSHomestarRunnerPlugIn.m
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Sun Oct 24 2004.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSTypes.h>
#import <QSCore/QSLibrarian.h>
#import "QSHomestarRunnerPlugIn.h"
#import "AGRegex.h"

@implementation NSString (QSAdditionsInformalProtocol)

- (NSString *)stringBetweenString:(NSString *)str1 andString:(NSString *)str2 {
	NSRange range1, range2;

	range1 = [self rangeOfString:str1 options:NSCaseInsensitiveSearch range:NSMakeRange(0, [self length])];
	if( range1.location == NSNotFound ) return nil;
	
	range2 = [self rangeOfString:str2 options:NSCaseInsensitiveSearch range:NSMakeRange(range1.location + range1.length, [self length] - range1.location - range1.length)];
	if( range2.location == NSNotFound ) return nil;
	
	return [self substringWithRange:NSMakeRange(range1.location + range1.length, range2.location - range1.location - range1.length)];
}

- (NSString *)stringForSingleLineDisplay {
	NSMutableString *formatted = [NSMutableString stringWithString:self];
	[formatted replaceOccurrencesOfString : @"\n"
							   withString : @" / "
								  options : 0 range : NSMakeRange( 0, [formatted length] )];
	[formatted replaceOccurrencesOfString : @"\r"
							   withString : @" / "
								  options : 0 range : NSMakeRange( 0, [formatted length] )];
	return formatted;
}

+ (NSString *)stringWithContentsOfURL:(NSURL *)url orCache:(NSString *)cachePath ifCreatedSinceNow:(NSTimeInterval)secs {
	return [NSString stringWithContentsOfURL:url orCache:cachePath ifCreatedAfter:[NSDate dateWithTimeIntervalSinceNow:secs]];
}

+ (NSString *)stringWithContentsOfURL:(NSURL *)url orCache:(NSString *)cachePath ifCreatedAfter:(NSDate *)date {
	//	NSLog( @"+loadContentsOfURL:\"%@\" orCache:\"%@\" ifCreatedAfter:\"%@\"", url, cachePath, date );
	
	NSString *contents;
	NSDictionary *attributes = [[NSFileManager defaultManager] fileAttributesAtPath:cachePath traverseLink:NO];
	
	if( attributes ) {
		//		NSLog( @"  cache found, time difference: %d", [date timeIntervalSinceDate:[attributes fileCreationDate]] );
		/* cache exists, is it fresh? */
		if( [date timeIntervalSinceDate:[attributes fileCreationDate]] < 0 ) {
			/* fresh enough, load it */
			//			NSLog( @"  loading from cache" );
			contents = [[[NSString alloc] initWithContentsOfFile:cachePath] autorelease];
		} else {
			//			NSLog( @"  too old, removing" );
			/* not fresh enough, remove it */
			attributes = nil;
			[[NSFileManager defaultManager] removeFileAtPath:cachePath handler:nil];
		}
	}
	
	if( !attributes ) {
		//		NSLog( @"  loading from web" );
		/* we need to load the file from the web */
		NSURLHandle *handle = [url URLHandleUsingCache:NO];
		
		[handle flushCachedData];
		NSData *responseData = [handle loadInForeground];
		contents = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] autorelease];
		[contents writeToFile:cachePath atomically:NO];
	}
	
	return contents;
}

@end

@implementation QSHomestarRunnerPlugIn

+ (QSObject *)objectForCharacter:(NSString *)character atURL:(NSURL *)url {
	NSDictionary *charIDs = [NSDictionary
								dictionaryWithObjectsAndKeys:
									HRHomestarRunner, HRIconHomestar, HRStrongBad, HRIconStrongBad,
									HRTheCheat, HRIconTheCheat, HRStrongMad, HRIconStrongMad, 
									HRStrongSad, HRIconStrongSad, HRMarzipan, HRIconMarzipan,
									HRCoachZ, HRIconCoachZ, HRPomPom, HRIconPomPom, 
									HRBubs, HRIconBubs, HRThePoopsmith, HRIconThePoopsmith, 
									HRTheKingOfTown, HRIconTheKingOfTown, HRHomsar, HRIconHomsar,
									HRTrogdor, HRIconTrogdor, HRStinkoman, HRIconStinkoman,
									HRMarshie, HRIconMarshie, HRPanPan, HRIconPanPan, nil];

	NSString *key, *objectID;
	NSEnumerator *charEnum = [charIDs keyEnumerator];
	
	while( key = [charEnum nextObject] ) {
//		NSLog( @"\"%@\" contains \"%@\"?", character, [charIDs objectForKey:key] );
		/* the character might be some 'alternate' version, which might contain the original name */
		if( [character rangeOfString:[charIDs objectForKey:key]].location != NSNotFound ) {
			objectID = key;
			break;
		}
	}
	
	if( !objectID ) return nil;
	
	QSObject *object = [QSObject makeObjectWithIdentifier:[NSString stringWithFormat:HRCharacterItemID, objectID]];
	[object setName:character];
	[object setIcon:[QSHomestarRunnerPlugIn iconForResourceFile:objectID]];
	[object setObject:[url absoluteString] forType:QSURLType];
	[object setPrimaryType:HRCharacterItem];
	return object;
}

+ (NSArray *)castForObject:(QSObject *)object {
	NSLog( @"+castForObject: %@", [object identifier] );
	NSString *page = [NSString stringWithContentsOfURL:[NSURL URLWithString:[object objectForType:QSURLType]] orCache:[NSString stringWithFormat:HRTempItem, [object objectForType:HRCharacterList]] ifCreatedSinceNow:(-kHRTimeoutEmailItem)];
	NSMutableArray *cast;
	NSRange castRange = [page rangeOfString:HRWikiCastStart options:NSCaseInsensitiveSearch];
	
	/* found cast? */
	if( !castRange.length ) return nil;
	
	castRange = NSMakeRange(castRange.location, [page rangeOfString:HRWikiCastEnd options:NSCaseInsensitiveSearch range:NSMakeRange(castRange.location,[page length] - castRange.location)].location - castRange.location);
	
	AGRegexMatch *member;
	AGRegex *regCastMember = [AGRegex regexWithPattern:HRWikiLinkPat options:AGRegexCaseInsensitive | AGRegexMultiline];
	NSEnumerator *castEnumerator = [regCastMember findEnumeratorInString:[page substringWithRange:castRange]];
	
	cast = [NSMutableArray array];
	while( member = [castEnumerator nextObject] ) {
		[cast addObject:[QSHomestarRunnerPlugIn objectForCharacter:[member groupAtIndex:kHRLinkGroupName] atURL:[NSURL URLWithString:[member groupAtIndex:kHRLinkGroupURL] relativeToURL:URL(HRWikiBase)]]];
	}
	
	return cast;
}

+ (NSArray *)fixQSObjectArray:(NSArray *)array {
	if( !array ) return nil;
	
	array = [QSLib scoredArrayForString:nil inSet:array];
	return [array count] ? array : nil;
}

- (void)invalidateSelf {
	/* todo */
	[super invalidateSelf];
}

+ (NSImage *)iconForResourceFile:(NSString *)file {
	return [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:file ofType:@"icns"]] autorelease];	
}

+ (NSImage *)iconForEntryType:(NSString *)type {
//	NSLog( @"+iconForEntry: %@", type );
	
	NSString *objectIcon = nil;
	
	if( [type isEqualToString:HRSBEmailList] ) {
		objectIcon = HRIconSBHead;
	} else if( [type isEqualToString:HRSBEmailItem] ) {
		objectIcon = HRIconEmail;
	}
	
	if( objectIcon ) {
		return [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:objectIcon ofType:@"icns"]] autorelease];
	}
	
	return nil;		
}

- (NSImage *)iconForEntry:(NSDictionary *)theEntry {
	NSLog( @"-iconForEntry: %@", [theEntry description] );
	
	return [QSHomestarRunnerPlugIn iconForEntryType:[theEntry objectForKey:@"ID"]];
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
	NSLog( @"-objectsForEntry: %@", [theEntry description] );
	
	NSArray *children = nil;
	NSString *objectID = [theEntry objectForKey:@"ID"];
	
	if( [objectID isEqualToString:HRMediaRoot] ) {
		/* load child items */
		QSObject *object;
		
		object = [QSObject makeObjectWithIdentifier:HRSBEmailListID];		
		[object setName:@"Strong Bad Emails"];
		[object setPrimaryType:HRSBEmailList];
		NSLog( @"%@", HRSBEmailList );
		[object setIcon:[self iconForEntry:[NSDictionary dictionaryWithObject:[object identifier] forKey:@"ID"]]];
		
		children = [NSArray arrayWithObject:object];
	}
	
	return [QSHomestarRunnerPlugIn fixQSObjectArray:children];	
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
	/* todo */
	return NO;
}

- (void)populateFields {
	/* todo */
	[super populateFields];
}

- (NSMutableDictionary *)currentEntry {
	/* todo */
	return [super currentEntry];
}

- (void)setCurrentEntry:(NSMutableDictionary *)newCurrentEntry {
	/* todo */
	[super setCurrentEntry:newCurrentEntry];
}

- (NSView *)settingsView {
	/* todo */
	return [super settingsView];
}

- (void)setSettingsView:(NSView *)newSettingsView {
	/* todo */
	[super setSettingsView:newSettingsView];
}

@end

@implementation NSURL (QSAdditionsInformalProtocol)

- (NSString *)cachePath {
	AGRegex *regexHRWiki = [AGRegex regexWithPattern:@"index\\.php(/(?<title>.*)|\\?title=(?<title>[^&]*))" options:AGRegexCaseInsensitive];
	AGRegexMatch *match = [regexHRWiki findInString:[self absoluteString]];
	
	if( [match range].location != NSNotFound ) {
		return [[[NSString stringWithString:@"~/Library/Caches/Quicksilver/HRWiki/"] stringByAppendingPathComponent:[match groupNamed:@"title"]] stringByExpandingTildeInPath];
	}
	return nil;
}

@end