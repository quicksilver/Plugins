//
//  NSScreen_BLTRExtensions.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 12/19/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSScreen (BLTRExtensions)
-(int)screenNumber;
-(NSString *)deviceName;
+(NSScreen *)screenWithNumber:(int)number;
@end
