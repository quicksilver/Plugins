//
//  NSTask+BLTRExtensions.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 2/7/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSTask (BLTRExtensions)
+ (NSTask *)taskWithLaunchPath:(NSString *)path arguments:(NSArray *)arguments;
- (NSData *)launchAndReturnOutput;
@end
