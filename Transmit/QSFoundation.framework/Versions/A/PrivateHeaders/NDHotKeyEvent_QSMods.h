//
//  NDHotKeyEvent_QSMods.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 8/16/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "NDHotKeyEvent.h"

@interface QSHotKeyEvent : NDHotKeyEvent{
	NSString *identifier;
}
- (NSString *)identifier;
- (void)setIdentifier:(NSString *)anIdentifier;
+ (QSHotKeyEvent *)hotKeyWithIdentifier:(NSString *)identifier;
@end

@interface NDHotKeyEvent (QSMods)
+ (NDHotKeyEvent *)getHotKeyForKeyCode:(unsigned short)aKeyCode character:(unichar)aChar safeModifierFlags:(unsigned int)aModifierFlags;
@end