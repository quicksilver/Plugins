//
//  QSPhoneDialer.m
//  QSPhonePlugIn
//
//  Created by Nicholas Jitkoff on 3/30/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSPhoneDialer.h"


@implementation QSAppleScriptPhoneDialer
- (id)initWithSettings:(NSDictionary *)def{
	self = [super init];
	if (self != nil) {
		//			script=[def object
		}
	return self;
	
}
- (BOOL)dialString:(NSString *)string{
	NSLog(@"dial %@",string);	
}
@end
