//
//  NSStringAdditions.m
//  FindModule
//
//  Created by Kevin Ballard on 8/5/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import "NSStringAdditions.h"


@implementation NSString (FindModuleStringAdditions)
- (NSString *) stringByEscapingCharactersFromSet:(NSCharacterSet *)charSet {
	NSMutableString *result = [NSMutableString stringWithCapacity:[self length]*1.5];
	NSScanner *scanner = [NSScanner scannerWithString:self];
	[scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
	while (![scanner isAtEnd]) {
		NSString *temp;
		[scanner scanUpToCharactersFromSet:charSet intoString:&temp];
		if (temp)
			[result appendString:temp];
		temp = nil;
		[scanner scanCharactersFromSet:charSet intoString:&temp];
		if (temp) {
			unsigned i;
			for (i = 0; i < [temp length]; i++) {
				NSString *c = [temp substringWithRange:NSMakeRange(i, 1)];
				[result appendFormat:@"\\%@", c];
			}
		}
	}
	return result;
}
@end
