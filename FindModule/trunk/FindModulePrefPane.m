//
//  FindModulePrefPane.m
//  FindModule
//
//  Created by Kevin Ballard on 8/5/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import "FindModulePrefPane.h"

NSString *FindModuleComplexityPref = @"Find Action Complexity";

@implementation FindModulePrefPane
- (id) init {
	if ((self = [super initWithBundle:[NSBundle bundleForClass:[self class]]])) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:
			[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0]
										forKey:FindModuleComplexityPref]];
		findImage = [[QSResourceManager imageNamed:@"Find"] copy];
	}
	return self;
}

- (void) dealloc {
	[findImage release];
	[super dealloc];
}

- (NSString *) mainNibName {
	return @"FindModulePrefPane";
}

- (NSImage *) icon {
	return findImage;
}
@end
