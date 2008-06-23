//
//  NSStringAdditions.m
//  DictPlugin
//
//  Created by Kevin Ballard on 11/2/04.
//  Copyright 2004 Kevin Ballard. All rights reserved.
//

#import "NSMutableStringAdditions.h"

@implementation NSMutableString (NSMutableStringAdditions)
- (NSMutableString*)escapeCharactersInSet:(NSCharacterSet *)characterSet {
	[self escapeCharactersInSet:characterSet withString:@"\\"];
    return self;
}

- (NSMutableString*)escapeCharactersInSet:(NSCharacterSet *)characterSet withString:(NSString *)escape {
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
	[scanner setCaseSensitive:YES];
	int escapeLen = [escape length];
	[scanner scanUpToCharactersFromSet:characterSet intoString:nil];
	while (![scanner isAtEnd]) {
		[self insertString:escape atIndex:[scanner scanLocation]];
		[scanner setScanLocation:[scanner scanLocation] + escapeLen + 1];
		[scanner scanUpToCharactersFromSet:characterSet intoString:nil];
	}
    return self;
}
@end
