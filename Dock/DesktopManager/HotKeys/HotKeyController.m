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

#import "HotKeyController.h"
#import "DesktopManager.h"

static HotKeyController *_defaultHKController = nil;

#define KEYCODE_KEY     @"keycode"
#define MODIFIERS_KEY   @"modifiers"
#define NOTIFICATION_KEY   @"notification"

@implementation HotKeyController

- (NSMutableArray*) registerDefaults {
    NSMutableArray *defaultHotKeys;
    NSMutableArray *defaultHotKeyGroups = [NSMutableArray array];
	
	//
	// Navigation
	//
	
	defaultHotKeys = [NSMutableArray arrayWithObjects:
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: 124], KEYCODE_KEY,
            [NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_NEXTWORKSPACE, NOTIFICATION_KEY,
            nil
        ],
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: 123], KEYCODE_KEY,
            [NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_PREVWORKSPACE, NOTIFICATION_KEY,
            nil
        ],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 18], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP1, NOTIFICATION_KEY,
			nil
		],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 19], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP2, NOTIFICATION_KEY,
			nil
			],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 20], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP3, NOTIFICATION_KEY,
			nil
			],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 21], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP4, NOTIFICATION_KEY,
			nil
			],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 23], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP5, NOTIFICATION_KEY,
			nil
			],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 22], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP6, NOTIFICATION_KEY,
			nil
			],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 26], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP7, NOTIFICATION_KEY,
			nil
			],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 28], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP8, NOTIFICATION_KEY,
			nil
			],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 25], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_DESKTOP9, NOTIFICATION_KEY,
			nil
			],
		nil];
 	
	[defaultHotKeyGroups insertObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
			defaultHotKeys, @"HotKeys",
			@"DesktopNavigation", @"Name", nil]
		atIndex: 0];
	
	//
	// Window Manipulation
	//
	
	defaultHotKeys = [NSMutableArray arrayWithObjects:
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 124], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSControlKeyMask], MODIFIERS_KEY,
			NOTIFICATION_WARPTONEXTWORKSPACE, NOTIFICATION_KEY,
			nil
		],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 123], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSControlKeyMask], MODIFIERS_KEY,
			NOTIFICATION_WARPTOPREVWORKSPACE, NOTIFICATION_KEY,
			nil
		],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 31], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_OPERATIONS_MENU, NOTIFICATION_KEY,
			nil
		],
		nil];
 	
	[defaultHotKeyGroups insertObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
		defaultHotKeys, @"HotKeys",
		@"WindowManipulation", @"Name", nil]
							  atIndex: [defaultHotKeyGroups count]];
	
	
	//
	// Misc
	//
	
	defaultHotKeys = [NSMutableArray arrayWithObjects:
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 15], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_RUNAPPLICATION, NOTIFICATION_KEY,
			nil
		],
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 35], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_SHOWPREFS, NOTIFICATION_KEY,
			nil
		],/*
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 100], KEYCODE_KEY,
			[NSNumber numberWithInt: 0], MODIFIERS_KEY,
			NOTIFICATION_STARTCOUVERT, NOTIFICATION_KEY,
			nil
		],*/
		[NSMutableDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt: 49], KEYCODE_KEY,
			[NSNumber numberWithInt: NSCommandKeyMask | NSAlternateKeyMask], MODIFIERS_KEY,
			NOTIFICATION_FASTDESKTOP, NOTIFICATION_KEY,
			nil
		],
		nil];
 	
	[defaultHotKeyGroups insertObject: [NSMutableDictionary dictionaryWithObjectsAndKeys:
		defaultHotKeys, @"HotKeys",
		@"MiscOperations", @"Name", nil]
							  atIndex: [defaultHotKeyGroups count]];
	
	return defaultHotKeyGroups;
}

+ (HotKeyController*) defaultController {
    if(!_defaultHKController) {
        _defaultHKController = [[HotKeyController alloc] init];
    }
    
    return _defaultHKController;
}

- (id) init {
    id myself = [super init];
    if(myself) {
		// Register defaults with NSUserDefaults
        _groups = [myself registerDefaults];
		[_groups retain];
		
		_registeredHotKeys = [[NSMutableDictionary dictionary] retain];
		_registered = NO;
    }
    
    return myself;
}

- (void) dealloc {
	if(_groups) {
		[_groups autorelease];
	}
	if(_registeredHotKeys) {
		[_registeredHotKeys autorelease];
	}
    [super dealloc];
}

- (void) loadFromDefaults {
    NSDictionary *hotKeyDefaults = 
        [[NSUserDefaults standardUserDefaults] dictionaryForKey: PREF_HOTKEYS];
	if(!hotKeyDefaults) {
		return;
	}
    
	int i,j;
	for(j=0; j<[_groups count]; j++) {
		NSDictionary *groupDict = [_groups objectAtIndex: j];
		NSMutableArray *groupArray = [groupDict objectForKey: @"HotKeys"];
		for(i=0; i<[groupArray count]; i++) {
			NSMutableDictionary *hotKeyDict = (NSMutableDictionary*) [groupArray objectAtIndex: i];
			NSString *key = [hotKeyDict objectForKey: NOTIFICATION_KEY];
			NSDictionary *hotKeyDesc = (NSDictionary*) [hotKeyDefaults objectForKey: key];
			if(hotKeyDesc) {
				int keycode = [(NSNumber*)[hotKeyDesc objectForKey: KEYCODE_KEY] intValue];
				int modifiers = [(NSNumber*)[hotKeyDesc objectForKey: MODIFIERS_KEY] intValue];
        
				[hotKeyDict setObject: [NSNumber numberWithInt: keycode] forKey: KEYCODE_KEY];
				[hotKeyDict setObject: [NSNumber numberWithInt: modifiers] forKey: MODIFIERS_KEY];
			}
		}
    }
}

- (void) saveToDefaults {
    NSMutableDictionary *hotKeyDictionary = [NSMutableDictionary dictionary];
	
	int i,j;
	for(i=0; i<[_groups count]; i++) {
		NSDictionary *groupDict = [_groups objectAtIndex: i];
		NSArray *hotKeyArray = (NSArray*) [groupDict objectForKey: @"HotKeys"];
		for(j=0; j<[hotKeyArray count]; j++) {
			NSDictionary *hotKey = (NSDictionary*) [hotKeyArray objectAtIndex: j];
			[hotKeyDictionary setObject: 
				[NSDictionary dictionaryWithObjectsAndKeys:
					[hotKey objectForKey: KEYCODE_KEY], KEYCODE_KEY, 
					[hotKey objectForKey: MODIFIERS_KEY], MODIFIERS_KEY,
					nil
				]
				forKey: [hotKey objectForKey: NOTIFICATION_KEY] ];
		}
	}
	    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject: hotKeyDictionary forKey: PREF_HOTKEYS];
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] 
        postNotificationName: NOTIFICATION_PREFSCHANGED object: self];
}

- (void) registerHotKeys {
	if([_registeredHotKeys count]) {
		[self unregisterHotKeys];
	}
	
	int i,j;
	for(i=0; i<[_groups count]; i++) {
		NSDictionary *groupDict = [_groups objectAtIndex: i];
		NSArray *hotKeyArray = (NSArray*) [groupDict objectForKey: @"HotKeys"];
		for(j=0; j<[hotKeyArray count]; j++) {
			NSDictionary *hotKey = (NSDictionary*) [hotKeyArray objectAtIndex: j];
			NSNumber *keycodeNum = [hotKey objectForKey: KEYCODE_KEY];
			NSNumber *modifiersNum = [hotKey objectForKey: MODIFIERS_KEY];
			NSString *notificationName = [hotKey objectForKey: NOTIFICATION_KEY];
			HotKey *hk = [HotKey hotKeyWithKeycode: [keycodeNum intValue] modifiers: [modifiersNum intValue] notification: notificationName];
			[hk setEnabled: ([hk keycode] != -1)];
			if([hk enabled]) {
				[hk registerHotKey];
			}
			[_registeredHotKeys setObject: hk forKey: notificationName];
		}
	}
	
	_registered = YES;
}

- (void) setHotKey: (HotKey*) hotKey forNotification: (NSString*) notificationName {
	HotKey *hk = [_registeredHotKeys objectForKey: notificationName];
	if(hk) {
		[hk setKeycode: [hotKey keycode]];
		[hk setModifiers: [hotKey modifiers]];
		[hk setEnabled: [hotKey enabled]];
		[hk registerHotKey];
	}
	
	int i,j;
	for(j=0; j<[_groups count]; j++) {
		NSDictionary *groupDict = [_groups objectAtIndex: j];
		NSMutableArray *groupArray = [groupDict objectForKey: @"HotKeys"];
		for(i=0; i<[groupArray count]; i++) {
			NSMutableDictionary *hotKeyDict = (NSMutableDictionary*) [groupArray objectAtIndex: i];
			NSString *key = [hotKeyDict objectForKey: NOTIFICATION_KEY];
			if([key isEqualToString: notificationName]) {
				int keycode = [hotKey enabled] ? [hotKey keycode] : -1;
				int modifiers = [hotKey modifiers];
				
				[hotKeyDict setObject: [NSNumber numberWithInt: keycode] forKey: KEYCODE_KEY];
				[hotKeyDict setObject: [NSNumber numberWithInt: modifiers] forKey: MODIFIERS_KEY];
			}
		}
    }
	
	[self saveToDefaults];
}

- (void) unregisterHotKeys {
	NSEnumerator *hkEnum = [_registeredHotKeys objectEnumerator];
	HotKey *hk;
	while(hk = [hkEnum nextObject]) {
		[hk unregisterHotKey];
	}
	
	[_registeredHotKeys removeAllObjects];
	_registered = NO;
}

- (NSArray*) groups {
	return _groups;
}

//
// Outline view data source methods
//

- (id)outlineView:(NSOutlineView *)outlineView child:(int)index ofItem:(id)item {
//	NSLog(@"outlineView: child: %i ofItem: %x", index, item);
	
	if(item == nil) {
		return [_groups objectAtIndex: index];
	}
	
	if([item isKindOfClass: [NSDictionary class]]) {
		NSDictionary *itemDict = (NSDictionary*) item;
		if([itemDict objectForKey: @"HotKeys"]) {
			return [(NSArray*) [itemDict objectForKey: @"HotKeys"] objectAtIndex: index];
		} 
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
	if(item == nil) {
		return YES;
	}
	
	if([item isKindOfClass: [NSDictionary class]]) {
		NSDictionary *itemDict = (NSDictionary*) item;
		if([itemDict objectForKey: @"HotKeys"]) {
			return YES;
		}
	}
	
	return NO;
}

- (int)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
//	NSLog(@"outlineView: numberOfChildrenOfItem: %x", item);
	
	if(item == nil) {
		return [_groups count];
	}

	if([item isKindOfClass: [NSDictionary class]]) {
		NSDictionary *itemDict = (NSDictionary*) item;
		if([itemDict objectForKey: @"HotKeys"]) {
			return [(NSArray*) [itemDict objectForKey: @"HotKeys"] count];
		}
	}
	
	return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
//	NSLog(@"outlineView: objectValueForTablecolumne: %x byItem:", tableColumn, item);
	
	if(item == nil) {
		return nil;
	}
	
	if([item isKindOfClass: [NSDictionary class]]) {
		NSDictionary *itemDict = (NSDictionary*) item;
		if([itemDict objectForKey: @"HotKeys"]) {
			if([[tableColumn identifier] isEqualToString: @"action"]) {
				NSString *key = [itemDict objectForKey: @"Name"];
				return [[NSBundle mainBundle] localizedStringForKey: key value: key table: nil];
			} else {
				return nil;
			}
		} else {
			if([[tableColumn identifier] isEqualToString: @"action"]) {
				NSString *key = [itemDict objectForKey: NOTIFICATION_KEY];
				return [[NSBundle mainBundle] localizedStringForKey: key value: key table: nil];
			} else if([[tableColumn identifier] isEqualToString: @"hotkey"]) {
				return [_registeredHotKeys objectForKey: [itemDict objectForKey: NOTIFICATION_KEY]];
			}
		}
	}
	
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item {
	return ((item != nil) && [[tableColumn identifier] isEqualToString: @"hotkey"]) ? YES : NO;
}

@end
