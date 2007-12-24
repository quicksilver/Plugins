//
//  HREmailParser.m
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Wed Oct 27 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "HREmailParser.h"


@implementation HREmailParser

+ (HREmailParser *)defaultParser {
	return [[[HREmailParser alloc] init] autorelease];
}

- (BOOL)canHandleType:(NSString *)type {
	return [type hasPrefix:@"com.homestarrunner.sbemail"];
}

- (NSDictionary *)objectsFromString:(NSString *)data ofType:(NSString *)type {
	AGRegex *regex;
	AGRegexMatch *match;
	NSEnumerator *enumerator;
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	
	if( [type isEqualToString:@"com.homestarrunner.sbemail.list"] ) {
		/* list of emails - data will be the wiki text */
		regex = [AGRegex regexWithPattern:HREmailListItemPattern options:AGRegexCaseInsensitive];
		enumerator = [regex findEnumeratorInString:data];
		
		while( match = [enumerator nextObject] ) {
			[dict insertValue:[match dictionary] inPropertyWithKey:[match groupNamed:@"name"]];
		}
		
		return [NSDictionary dictionaryWithDictionary:dict];
	} else {
		return nil;
	}
}

- (NSDictionary *)objectFromString:(NSString *)data ofType:(NSString *)type {
	AGRegex *regex;
	AGRegexMatch *match;
	NSEnumerator *enumerator;
	NSMutableDictionary *dict;
	
	if( [type isEqualToString:@"com.homestarrunner.sbemail.item"] ) {
		/* email item - data will be the wiki text */
		regex = [AGRegex regexWithPattern:HREmailCastPattern options:AGRegexCaseInsensitive];
		match = [regex findInString:data];
		
		/* get more than just the cast */
		
		return dict = [match dictionary];
	}
	
	return nil;
}

@end
