//
//  NDProcess+QSMods.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 9/3/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NDProcess.h"

@interface NDProcess (QSMods)
- (pid_t)pid;
- (NSDictionary *)processInfo;
- (BOOL)isBackground;
- (BOOL)isCarbon;

@end
