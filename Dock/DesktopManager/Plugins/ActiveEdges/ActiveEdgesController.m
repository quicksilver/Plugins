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

#import "ActiveEdgesController.h"

@implementation ActiveEdgesController

- (NSString*) name { return @"Active Edges"; }
- (NSString*) description { return @"Initiate desktop switch on edges of the screen."; }
- (int) interfaceVersion { return 1; }

- (NSBundle*) preferencesBundle { 
	NSString *prefBundlePath = [myBundle pathForResource: @"ActiveEdgesPrefPane" ofType: @"bundle"]; 
	
	if(!prefBundlePath) {
		NSLog(@"Error: Active Edges couldn't find its preferences bundle.");
		return nil;
	}
	
	return [NSBundle bundleWithPath: prefBundlePath];
}

OSStatus CGSGetCurrentMouseButtonState(const CGSConnection cid, int *state);

- (void) timerTick: (NSTimer*) timer {	
 	NSPoint mouseLoc = [NSEvent mouseLocation];
	NSRect screenFrame = [wsController overallScreenFrame];
	CGPoint newLoc;

	if(edge == LeftEdge) {
		[wsController selectPreviousWorkspace];
		if([[NSUserDefaults standardUserDefaults] boolForKey:
			PREF_ACTIVEEDGES_WARPMOUSE]) {
			newLoc.x = screenFrame.origin.x + screenFrame.size.width - 5;
			newLoc.y = screenFrame.size.height - mouseLoc.y;
			CGWarpMouseCursorPosition(newLoc);
		}
	} else if(edge == RightEdge) {
		[wsController selectNextWorkspace];
		if([[NSUserDefaults standardUserDefaults] boolForKey:
			PREF_ACTIVEEDGES_WARPMOUSE]) {
			newLoc.x = screenFrame.origin.x + 5;
			newLoc.y = screenFrame.size.height - mouseLoc.y;
			CGWarpMouseCursorPosition(newLoc);
		}
	}
	
	waitingForExit = YES;
	switchTimer = nil;
}

- (void) readPreferences {
	waitThreshold = [[NSUserDefaults standardUserDefaults] integerForKey: PREF_ACTIVEEDGES_DELAY];
}

- (void) edgeEvent: (NSNotification*) notification {
	bool active = [[NSUserDefaults standardUserDefaults] boolForKey: PREF_ACTIVEEDGES_ENABLED];
	if(!active) { return; }

	NSNumber *edgeNum = [[notification userInfo] objectForKey: MouseWatcherEdgeKey];
	NSNumber *enteredNum = [[notification userInfo] objectForKey: MouseWatcherMouseEnteredKey];
	MouseWatcherEdge myedge = [edgeNum intValue];
	bool entered = [enteredNum boolValue];
	
	if(entered && !waitingForExit) {
		edge = myedge;
		switchTimer = [NSTimer scheduledTimerWithTimeInterval: 0.05 * (float)waitThreshold target: self
													 selector: @selector(timerTick:) userInfo: nil 
													 repeats: NO];
	} else if(!entered) {
		// We exited, be happy.
		waitingForExit = NO;
		if(switchTimer) {
			[switchTimer invalidate];
			switchTimer = nil;
		}
	}
}

- (void) pluginLoaded: (DMController*) controller withBundle: (NSBundle*) thisBundle {
	wsController = [controller workspaceController];
	myBundle = thisBundle;
	waitingForExit = NO;
	switchTimer = nil;
	
	// Register our own defaults	    
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObjectsAndKeys: 
        PREF_ACTIVEEDGES_ENABLED_DEFAULT, PREF_ACTIVEEDGES_ENABLED,
        PREF_ACTIVEEDGES_DELAY_DEFAULT, PREF_ACTIVEEDGES_DELAY,
        PREF_ACTIVEEDGES_WARPMOUSE_DEFAULT, PREF_ACTIVEEDGES_WARPMOUSE,
        nil
    ];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: appDefaults];
	
	// Register for preferences changed notifications
	[[NSNotificationCenter defaultCenter] addObserver: self
			selector: @selector(readPreferences) name: NOTIFICATION_PREFSCHANGED
			object: nil];
	// Register for edge notifications
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(edgeEvent:) name: NOTIFICATION_MOUSEEDGEEVENT object: nil];	
	[self readPreferences];
	
	//[NSTimer scheduledTimerWithTimeInterval: 0.05 target: self selector: @selector(timerTick:)
	//	userInfo: nil repeats: YES];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	[super dealloc];
}

@end
