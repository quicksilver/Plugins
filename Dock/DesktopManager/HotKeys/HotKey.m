/* DesktopManager -- A virtual desktop provider for OS X
 *
 * Copyright (C) 2003, 2004 Richard J Wareham <richwareham@users.sourceforge.net>
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 675 
 * Mass Ave, Cambridge, MA 02139, USA.
 */

#import "HotKey.h"

#import <Carbon/Carbon.h>
#include "DesktopManager.h"

@implementation HotKey

+ (id) hotKeyWithKeycode: (int) kcode modifiers: (int) mfier
    notification: (NSString*) nName;
{
    return [[[HotKey alloc] initWithKeycode: kcode modifiers: mfier
        notification: nName] autorelease];
}

- (id) initWithKeycode: (int) kcode modifiers: (int) mdfer 
    notification: (NSString*) nName;
{
    id retVal = [super init];
    [retVal init];
    
    keycode = kcode;
    modifiers = mdfer;
    notificationName = [[NSString stringWithString: nName] retain];
    registered = FALSE;
	_wasRegistered = NO;
	_enabled = YES;
    
    return retVal;
}

- (id) initWithHotKey: (HotKey*) key
{
    id retVal = [super init];
    [retVal init];
    
    keycode = [key keycode];
    modifiers = [key modifiers];
    notificationName = [NSString stringWithString: [key notificationName]];
    [notificationName retain];
    registered = FALSE;
	_wasRegistered = NO;
	_enabled = YES;
    
    return retVal;
}

- (id) init
{
    id retVal = [super init];
    
    keycode = modifiers = 0;
    notificationName = nil;
    registered = FALSE;
	_enabled = YES;
	_wasRegistered = NO;
    
    // Register our interest in hotkey notifications
    [[NSNotificationCenter defaultCenter] addObserver: self
        selector: @selector(hotKeyPressedNotification:)
        name: NOTIFICATION_HOTKEYPRESS object: nil
    ];
    
    return retVal;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

    if([self isRegistered]) { [self unregisterHotKey]; }
    if(notificationName) { [notificationName release]; }
    [super dealloc];
}

- (BOOL) enabled {
	return _enabled;
}

- (void) setEnabled: (BOOL) enabled {
	if(enabled == _enabled) {
		return;
	}
	
	_enabled = enabled;
	if(!_enabled && registered) {
		_wasRegistered = YES;
		[self unregisterHotKey];
	}
	
	if(_enabled && _wasRegistered) {
		_wasRegistered = NO;
		[self registerHotKey];
	}
}

- (void) hotKeyPressedNotification: (NSNotification*) notification {
    NSValue *value = [notification object];
    EventHotKeyRef hotKeyRef;
    [value getValue: &hotKeyRef];
    if(hotKeyRef == myRef) {
        // NSLog(@"Hot key received, posting %@ notification", notificationName);
        [[NSNotificationCenter defaultCenter] postNotificationName: notificationName
            object: self];
    }
}

- (BOOL) isRegistered { return registered; }

- (void) registerHotKey {
	if(!_enabled) {
		return;
	}
    if(registered) { return; }
    EventHotKeyID hotKeyID;
    EventHotKeyRef hotkeyRef;
    hotKeyID.id = (int)self; 
    OSStatus retVal = RegisterEventHotKey([self keycode], [self carbonModifiers], hotKeyID,
        GetApplicationEventTarget(), 0, &hotkeyRef);
    if(retVal) { NSLog(@"Error registering hot key"); }
        
    myRef = hotkeyRef;
    registered = YES;
}

- (void) unregisterHotKey {
    if(!registered) { return; }
    UnregisterEventHotKey(myRef);
    registered = NO;
}

- (int) keycode
{
    return keycode;
}

- (int) modifiers
{
    return modifiers;
}

- (NSString*) notificationName {
    return notificationName;
}

- (int) carbonModifiers
{
    int cmod = 0;
    if(modifiers & NSCommandKeyMask) { cmod |= cmdKey; }
    if(modifiers & NSAlternateKeyMask) { cmod |= optionKey; }
    if(modifiers & NSShiftKeyMask) { cmod |= shiftKey; }
    if(modifiers & NSControlKeyMask) { cmod |= controlKey; }
    
    return cmod;
}

- (void) setKeycode: (int) _keycode
{
    keycode = _keycode;
    if([self isRegistered]) { 
        [self unregisterHotKey];
        [self registerHotKey];
    }
}

- (void) setModifiers: (int) _modifiers
{
    modifiers = _modifiers;
    if([self isRegistered]) { 
        [self unregisterHotKey];
        [self registerHotKey];
    }
}

NSString *C2S(unichar ch) {
	return [NSString stringWithCharacters: &ch length: 1];	
}

NSString *_charCodeToString(unichar charCode, int keyCode) {
	switch(charCode) {
		case kFunctionKeyCharCode:
			switch(keyCode) {
				case 122:
					return @"F1";
					break;
				case 120:
					return @"F2";
					break;
				case 99:
					return @"F3";
					break;
				case 118:
					return @"F4";
					break;
				case 96:
					return @"F5";
					break;
				// No F6
				case 98:
					return @"F7";
					break;
				case 100:
					return @"F8";
					break;
				case 101:
					return @"F9";
					break;
				case 109:
					return @"F10";
					break;
				case 103:
					return @"F11";
					break;
				case 111:
					return @"F12";
					break;
				case 105:
					return @"F13";
					break;
			}
			break;
		case kRightArrowCharCode:
			return C2S(0x2192);
			break;
		case kLeftArrowCharCode:
			return C2S(0x2190);
			break;
		case kUpArrowCharCode:
			return C2S(0x2191);
			break;
		case kDownArrowCharCode:
			return C2S(0x2193);
			break;
		case kBackspaceCharCode:
			return C2S(0x232b);
			break;
		case kHomeCharCode:
			return C2S(0x2196);
			break;
		case kSpaceCharCode:
			return @"<Spc>";
			break;
		case kReturnCharCode:
			return C2S(0x23CE);
			break;	
		case kEscapeCharCode:
			return C2S(0x238B);
			break;	
	}
	
	// NSLog(@"CharCode: %i", charCode);
	
	return [C2S(charCode) uppercaseString];
}

- (NSString*) stringRepresentation {
	if(!_enabled) {
		 return @"";
	}
	
	KeyboardLayoutRef kbdLayout;
	Handle kchrHandle;
	
	KLGetCurrentKeyboardLayout(&kbdLayout);
	KLGetKeyboardLayoutProperty(kbdLayout, kKLKCHRData, (const void**) &kchrHandle);
		
	if(kchrHandle) {
		UInt32 state = 0;
		UInt32 charCode = KeyTranslate(kchrHandle, keycode, &state);
				
		NSMutableString *string = [NSMutableString string];
		
		if(modifiers & NSControlKeyMask) {
			[string appendString: @"Ctrl-"];
		}
		if(modifiers & NSShiftKeyMask) {
			[string appendString: C2S(0x21E7)];
		}
		if(modifiers & NSAlternateKeyMask) {
			[string appendString: C2S(0x2325)];
		}
		if(modifiers & NSCommandKeyMask) {
			[string appendString: C2S(0x2318)];
		}

		[string appendString: _charCodeToString(charCode, keycode)];
		
		return string;
	}
	
	return @"Error";
}

- (id) copyWithZone: (NSZone*) zone
{
    HotKey *hk= [[[HotKey allocWithZone: zone] initWithKeycode: keycode modifiers: modifiers 
        notification: notificationName] autorelease];
	[hk setEnabled: [self enabled]];
	return hk;
}
@end
