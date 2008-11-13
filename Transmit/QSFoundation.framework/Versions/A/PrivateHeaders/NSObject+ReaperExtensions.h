//
//  NSObject+ReaperExtensions.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 9/13/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define QSDefaultReapInterval 600.0f

@interface NSObject (ReaperExtensions)
- (void)doomSelector:(SEL)selector delay:(NSTimeInterval)delay extend:(BOOL)extend;
@end
