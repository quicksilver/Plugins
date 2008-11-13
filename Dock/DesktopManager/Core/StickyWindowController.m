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

#import "DesktopManager.h"

static StickyWindowController *_defaultSWController = nil;

@implementation StickyWindowController

+ (StickyWindowController*) defaultController {
    if(!_defaultSWController) {
        _defaultSWController = [[[StickyWindowController alloc] init] retain];
    }
    
    return _defaultSWController;
}

- (void) windowCloseHandler: (NSNotification*) notification {
	NSNumber *widObj = (NSNumber*) [notification object];
	if(!widObj || !_stickyWindowDictionary) {
		return;
	}
	
	// Only remove if we're quite sure the window has gone.
	if([_stickyWindowDictionary objectForKey: widObj] && ![ForeignWindow windowNumberValid: [widObj intValue]]) {
		// NSLog(@"Really removing %@", widObj);
		[_stickyWindowDictionary removeObjectForKey: widObj];
	}
}

/* Don't care about new windows just yet.
- (void) newWindowHandler: (NSNotification*) notification {
	NSNumber *widObj = (NSNumber*) [notification object];
	
	NSLog(@"New %@", widObj);	
} */

- (id) init {
	id mySelf = [super init];
	if(mySelf) {
		_stickyWindowDictionary = [[NSMutableDictionary dictionary] retain];
		
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(windowCloseHandler:) name: NOTIFICATION_WINDOW_CLOSED object: nil];

		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(preSwitch:) name: NOTIFICATION_WORKSPACEWILLSELECT object: nil];
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(postSwitch:) name: NOTIFICATION_WORKSPACESELECTED object: nil];
		
		/*
		[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(newWindowHandler:) name: NOTIFICATION_NEW_WINDOW object: nil];
		 */
	}
	return mySelf;
}

- (void) dealloc {
	if(_stickyWindowDictionary) {
		[_stickyWindowDictionary release];
	}
	[super dealloc];
}

- (void) preSwitch: (NSNotification*) notification {
	NSEnumerator *enumerator = [[_stickyWindowDictionary allKeys] objectEnumerator];
	id key;
	while(key = [enumerator nextObject]) {
		ForeignWindow *win = (ForeignWindow*) [_stickyWindowDictionary objectForKey: key];
		if([ForeignWindow windowNumberValid: [win windowNumber]]) {
			// NSLog(@"Making %@ sticky", [win title]);
			[win makeSticky];
		} else {
			// NSLog(@"Removing %@", key);
			[_stickyWindowDictionary removeObjectForKey: key];
		}
	}
}

- (void) postSwitch: (NSNotification*) notification {
	NSEnumerator *enumerator = [[_stickyWindowDictionary allKeys] objectEnumerator];
	id key;
	while(key = [enumerator nextObject]) {
		ForeignWindow *win = (ForeignWindow*) [_stickyWindowDictionary objectForKey: key];
		if([ForeignWindow windowNumberValid: [win windowNumber]]) {
			// NSLog(@"Making %@ unsticky", [win title]);
			[win makeUnSticky];
		} else {
			// NSLog(@"Removing %@", key);
			[_stickyWindowDictionary removeObjectForKey: key];
		}
	}
}

- (void) addWindowToStickyList: (ForeignWindow*) win {
	[_stickyWindowDictionary setObject: win forKey: [NSNumber numberWithInt: [win windowNumber]]];
}

- (void) removeWindowFromStickyList: (ForeignWindow*) win {
	NSNumber *widObj = [NSNumber numberWithInt: [win windowNumber]];
	if([_stickyWindowDictionary objectForKey: widObj]) {
		[_stickyWindowDictionary removeObjectForKey: widObj];
	}
}

- (bool) isSticky: (ForeignWindow*) win {
	return [_stickyWindowDictionary objectForKey: [NSNumber numberWithInt: [win windowNumber]]] ? YES : NO;
}

@end
