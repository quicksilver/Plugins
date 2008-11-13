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

#import "DesktopNamesPreferences.h"
#import "DesktopManager.h"

#import <AvailabilityMacros.h>
#import <ApplicationServices/ApplicationServices.h>

static WorkspaceController *_defaultWSController = nil;

@implementation WorkspaceController

+ (WorkspaceController*) defaultController {
    if(!_defaultWSController) {
        _defaultWSController = [WorkspaceController
            controllerWithWorkspaceNames: [NSArray array]];
        [_defaultWSController retain];
    }
    
    return _defaultWSController;
}

+ (id) controllerWithWorkspaceNames: (NSArray*) names {
    id myself = [WorkspaceController alloc];
    if(myself) { [[myself initWithWorkspaceNames:names] autorelease]; }
    return myself;
}

- (id) initWithWorkspaceNames: (NSArray*) names {
    id myself = [self init];
    if(myself) { 
        [myself setWorkspaceNames: names];
    }
    return myself;
}

- (id) init {
    id myself = [super init];
    if(myself) {
        workspaceList = [[NSMutableArray alloc] init];
        [workspaceList retain];
        
        // Register an interest in workspace switch hotkeys
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(selectPreviousWorkspace)
            name: NOTIFICATION_PREVWORKSPACE
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(selectNextWorkspace)
            name: NOTIFICATION_NEXTWORKSPACE
            object: nil
        ];
        // Register an interest in window warp hotkeys
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(warpToPreviousWorkspace)
            name: NOTIFICATION_WARPTOPREVWORKSPACE
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(warpToNextWorkspace)
            name: NOTIFICATION_WARPTONEXTWORKSPACE
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(prefsChanged:)
            name: NOTIFICATION_PREFSCHANGED
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP1
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP2
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP3
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP4
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP5
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP6
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP7
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP8
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP9
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(switchToNumberedDesktop:)
            name: NOTIFICATION_DESKTOP10
            object: nil
        ];
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(fastDesktopCreate:)
            name: NOTIFICATION_FASTDESKTOP
            object: nil
        ];
       
        // Refresh timer
        [NSTimer scheduledTimerWithTimeInterval: 2.0
                target: self 
                selector: @selector(updateWindowList)
                userInfo: nil repeats: TRUE]; 
	}
    return myself;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

    if(workspaceList) {
        [workspaceList release];
    }
    [super dealloc];
}

- (void) updateWindowList {
	NSEnumerator *wsEnum = [workspaceList objectEnumerator];
	Workspace *ws;
	while(ws = [wsEnum nextObject]) {
		[ws updateWindowList];
	}
	
	// Tell any observers who are interesed in layout changes.
	[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_WINDOWLAYOUTUPDATED
		object: self];
}

- (void) prefsChanged: (id) sender {
    NSArray *names = [[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES];
    NSArray *oldNames = [self workspaceNames];
	
	if(![names isEqualToArray: oldNames]) {
		[self setWorkspaceNames: names];
		[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_DESKTOPNAMESCHANGED
			object: self ];
	}
}

/* Added by Christopher A. Watford 02/18/2004
 * Fast Desktop Create
 */
- (void) fastDesktopCreate: (NSNotification*) notification {
    NSMutableArray *namesArray = [NSMutableArray arrayWithArray:
            [[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES]
    ];
	
    [namesArray insertObject: @"Fast Desktop" atIndex: [namesArray count]];
    [[NSUserDefaults standardUserDefaults] setObject: namesArray forKey: PREF_DESKTOPNAMES];

    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_PREFSCHANGED
            object: self ];
}

- (void) switchToNumberedDesktop: (NSNotification*) notification {
	NSString *name = [notification name];
	int number = -1;
	
	if([name isEqualToString: NOTIFICATION_DESKTOP1]) {
		number = 1;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP2]) {
		number = 2;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP3]) {
		number = 3;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP4]) {
		number = 4;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP5]) {
		number = 5;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP6]) {
		number = 6;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP7]) {
		number = 7;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP8]) {
		number = 8;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP9]) {
		number = 9;
	} else if([name isEqualToString: NOTIFICATION_DESKTOP10]) {
		number = 10;
	}
	
	if(number == -1) {
		NSLog(@"Asked to switch to a desktop I've never heard of.");
	}
	
	number --;
	if([self workspaceAtIndex: number]) {
		[self selectWorkspace: number];
	}
}


- (void) switchToWorkspaceForApplication: (ProcessSerialNumber) frontPSN {
       ProcessSerialNumber windowProcessSN;
       Boolean processesEqual;
       OSErr retVal;

       int i=0;
       // Loop through all workspaces and grab their windows, start with
	   // the workspace after current one. This has the effect of cycling through
	   // all workspaces containing the app.
       for(i=0; i<[self workspaceCount]; i++) {
		   int j=0; int wsIndex = (i + [self currentWorkspaceIndex] + 1) % ([self workspaceCount]);
		   Workspace *ws = [self workspaceAtIndex: wsIndex];
		   // Get the windows in the current workspace we are looping through
		   NSArray *windowList = [ws windowList];
		   // For each window compare it's process SN to the front most applications process SN
		   for(j=0; j<[windowList count]; j++) {
			   ForeignWindow *window = [windowList objectAtIndex: j];
			   windowProcessSN = [window ownerPSN];
			   retVal = SameProcess( &windowProcessSN, &frontPSN, &processesEqual);
			   if ( retVal == noErr ) {
				   if ( processesEqual ) {
					   [self selectWorkspace: wsIndex];
					   // We'll return when we find the first matching window for process
					   return;
					}
			   } else {
				   NSLog(@"Error checking equality of processes: %i", retVal);
			   }
		   }
	   }
}


- (Workspace*) currentWorkspace {
    int i, currentWorkspace;
    
    currentWorkspace = [Workspace currentWorkspace];
    for(i=0; i<[self workspaceCount]; i++) {
        Workspace *ws = [workspaceList objectAtIndex:i];
        if([ws workspaceNumber] == currentWorkspace) {
            return ws;
        } 
    }
    
    return nil;
}

- (int) currentWorkspaceIndex {
    int i, currentWorkspace;
    
    currentWorkspace = [Workspace currentWorkspace];
    for(i=0; i<[self workspaceCount]; i++) {
        Workspace *ws = [workspaceList objectAtIndex:i];
        if([ws workspaceNumber] == currentWorkspace) {
            return i;
        } 
    }
    
    return -1;
}

- (NSString*) currentWorkspaceName {
    Workspace *ws = [self currentWorkspace];
    
    if(ws) {
        return [ws workspaceName];
    }
    
    return @"Unknown";
}

#define MAX_TRANSITION 8.0
+ (int) transitionNumber {
	int option = [[NSUserDefaults standardUserDefaults] 
		integerForKey: PREF_DESKTOPSWITCH_TRANSITION];
	
	if(option > MAX_TRANSITION) {
		option = round(((float)rand() * MAX_TRANSITION)/(float)RAND_MAX);
	}
		
	return option;
}

- (void) selectWorkspace: (int)workspace {
    if((workspace < 0) || (workspace >= [self workspaceCount])) {
        NSLog(@"Attempt to switch to invalid workspace %i", workspace);
        return;
    }
	
	if(workspace == [self currentWorkspaceIndex]) {
		// We're already here!
		return;
	}
	    
    Workspace *ws = [workspaceList objectAtIndex:workspace];

	CGSTransitionType transitionNumber = [WorkspaceController transitionNumber];
	CGSTransitionOption option = 0;
	float duration = 0;
    if(transitionNumber != CGSNone) {
        if(workspace > [self currentWorkspaceIndex]) {
            option = CGSLeft;
        } else {
            option = CGSRight;
        }
        
		if((workspace == [self workspaceCount]-1) && ([self currentWorkspaceIndex] == 0)) {
			option = CGSRight;
		}
		
		if(([self currentWorkspaceIndex] == [self workspaceCount]-1) && (workspace == 0)) {
			option = CGSLeft;
		}
		
        duration = [[NSUserDefaults standardUserDefaults] 
		floatForKey: PREF_DESKTOPSWITCH_DURATION];
    }

	[ws selectWithTransition: transitionNumber option: option duration: duration];
}

- (void) selectNextWorkspace {
    int cwsi = [self currentWorkspaceIndex];
    if(cwsi == -1) { return; }
    
    cwsi++;
    if(cwsi >= [self workspaceCount]) { cwsi = 0; }
    if(cwsi < 0) { cwsi = [self workspaceCount]-1; }
    
    [self selectWorkspace: cwsi];
}

- (void) selectPreviousWorkspace {
    int cwsi = [self currentWorkspaceIndex];
    if(cwsi == -1) { return; }
    
    cwsi--;
    if(cwsi >= [self workspaceCount]) { cwsi = 0; }
    if(cwsi < 0) { cwsi = [self workspaceCount]-1; }
    
    [self selectWorkspace: cwsi];
}

- (void) warpToNextWorkspace {
    int cwsi = [self currentWorkspaceIndex];
    if(cwsi == -1) { return; }
    
    cwsi++;
    if(cwsi >= [self workspaceCount]) { cwsi = 0; }
    if(cwsi < 0) { cwsi = [self workspaceCount]-1; }
    
    Workspace *nextWs = [self workspaceAtIndex: cwsi];
	ForeignWindow *window = [self windowUnderPointer];
	if(window && nextWs) {
		[window moveToWorkspace: nextWs];
		[nextWs selectWithDefaultTransition];
	}
}

- (void) warpToPreviousWorkspace {
    int cwsi = [self currentWorkspaceIndex];
    if(cwsi == -1) { return; }
    
    cwsi--;
    if(cwsi >= [self workspaceCount]) { cwsi = 0; }
    if(cwsi < 0) { cwsi = [self workspaceCount]-1; }
    
    Workspace *prevWs = [self workspaceAtIndex: cwsi];
	ForeignWindow *window = [self windowUnderPointer];
	if(window && prevWs) {
		[window moveToWorkspace: prevWs];
		[prevWs selectWithDefaultTransition];
	}
}

- (Workspace*) workspaceAtIndex: (int) index {
    if((index < 0) || (index >= [self workspaceCount])) { return nil; }
    
    return (Workspace*) [workspaceList objectAtIndex: index];
}

- (int) workspaceIndexForNumber: (int) num {
	int i=0;
	for(i=0; i<[workspaceList count]; i++) {
		Workspace *ws = (Workspace*) [workspaceList objectAtIndex: i];
		if([ws workspaceNumber] == num) {
			return i;
		}
	}
	
	return -1;
}

- (Workspace*) workspaceForNumber: (int) num {
	return [self workspaceAtIndex: [self workspaceIndexForNumber: num]];
}

- (int) workspaceCount {
    return [workspaceList count];
}

- (NSArray*) workspaceNames {
	NSMutableArray *namesArray = [NSMutableArray array];
	int i=0;
	
	for(i=0; i<[workspaceList count]; i++) {
		Workspace *ws = [self workspaceAtIndex: i];
		[namesArray insertObject: [ws workspaceName] atIndex: i];
	}
	
	return namesArray;
}

- (void) setWorkspaceNames: (NSArray*) names {
    if(!names) {
        NSLog(@"Passed a null array to setWorkspaceNames");
    }

    // Remove any entries in list already.
    [workspaceList removeAllObjects];
    
    // For each new name, create a new workspace for it.
    int i;
    for(i=0; i<[names count]; i++) {
        NSString *name = [names objectAtIndex:i];

		/* Check which version we are compiling for and
		 * perform worksarpund for different indexing between
		 * OS X 10.3 and 10.2. */
#if (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_3)
        Workspace *workspace = [Workspace workspaceWithWorkspaceNumber: i+1];
#else
        Workspace *workspace = [Workspace workspaceWithWorkspaceNumber: i];
#endif

        [workspace setWorkspaceName:name];
        // NSLog(@"Set workspace number %i to %@", i, name);
        [workspaceList insertObject:workspace atIndex:i];
    }
}

- (ForeignWindow*) windowContainingPoint: (NSPoint) mouseLoc {

	
	// NSLog(@"Mouse at (%f,%f)", mouseLoc.x, mouseLoc.y);
	
	// Start walking trough the window list from top to bottom
	// and return if we find a window.
	int i=0; NSArray *windowList = [[self currentWorkspace] windowList];
	for(i=0; i<[windowList count]; i++) {
		ForeignWindow *window = (ForeignWindow*) [windowList objectAtIndex: i];
		NSRect screenRect = [window screenRect];
		//NSLog(@"(%f,%f) +(%f,%f) - %@", screenRect.origin.x, screenRect.origin.y,
	    //		screenRect.size.width, screenRect.size.height, [window title]);
		
		if(NSMouseInRect(mouseLoc, screenRect, NO)) {
			return window;
		}
	}
	
	return nil;
}

- (ForeignWindow*) windowUnderPointer {
	// find mouse poisition on screen.
	NSPoint mouseLoc = [NSEvent mouseLocation];
	NSSize screenSize = [[NSScreen mainScreen] frame].size;
	// NSLog(@"Screen size %f x %f", screenSize.width, screenSize.height);
	
	// Convert mouse co-oirdinates to screen co-ords
	mouseLoc.y = screenSize.height - mouseLoc.y;
	return [self windowContainingPoint: mouseLoc];
}

- (void) collectWindows {
	// Move all windows to first workspace.
	if(!workspaceList && ![workspaceList count]) { return; }
	
	Workspace *firstWorkspace = [self workspaceAtIndex: 0];
	
	int i=0;
	for(i=1; i<[self workspaceCount]; i++) {
		int j=0;
		Workspace *ws = [self workspaceAtIndex: i];
		NSArray *windowList = [ws windowList];
		for(j=0; j<[windowList count]; j++) {
			ForeignWindow *window = [windowList objectAtIndex: j];
			[window moveToWorkspace: firstWorkspace];
		}
	}
}

- (NSRect) overallScreenFrame {
	NSArray *screens = [NSScreen screens];
	NSRect overallRect = [[NSScreen mainScreen] frame];
	
	NSEnumerator *enumerator = [screens objectEnumerator];
	NSScreen *screen;
	while (screen = [enumerator nextObject]) {
		overallRect = NSUnionRect(overallRect, [screen frame]);
	}
	
	return overallRect;
}

- (NSRect) overallVisibleScreenFrame {
	NSArray *screens = [NSScreen screens];
	NSRect overallRect = [[NSScreen mainScreen] visibleFrame];
	
	NSEnumerator *enumerator = [screens objectEnumerator];
	NSScreen *screen;
	while (screen = [enumerator nextObject]) {
		overallRect = NSUnionRect(overallRect, [screen visibleFrame]);
	}
	
	return overallRect;
}

@end
