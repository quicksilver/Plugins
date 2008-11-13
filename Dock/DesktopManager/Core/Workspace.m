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

#import <Carbon/Carbon.h>
#import "DesktopManager.h"

#import <stdio.h>
#import <unistd.h>

@implementation Workspace

/* Allocator */
+ (id) workspaceWithWorkspaceNumber: (int)number {
    id mySelf = [Workspace alloc];
    
    if(mySelf) { 
        [[mySelf initWithWorkspaceNumber:number] autorelease];
    } 
    
    return mySelf;
}

extern OSStatus CGSGetWorkspaceWindowGroup(CGSConnection cid, int workspace, ...);
extern void *kCGSMovementGroup;

// Initialiser.
- (id) initWithWorkspaceNumber: (int)number {
    [super init];
    
    workspaceNumber = number;
    name = @"";
    foreignWindowList = [NSMutableArray array];
    [foreignWindowList retain];
	
	windowMap = [[NSMutableDictionary dictionary] retain];
	windowList = nil;

/*
	int group[300];
	int retVal = CGSGetWorkspaceWindowGroup(_CGSDefaultConnection(), number,
		group, 0);
	NSLog(@"%i", retVal);
	NSLog(@"Group: %i", group[0]);
*/
				         
    return self;
}

// Destructor
- (void) dealloc {
    [foreignWindowList release];
	if(windowList){
		[windowList release];
	}
	[windowMap release];
    [super dealloc];
}

/* Return currently selected workspace number */
+ (int) currentWorkspace {
    CGSConnection Connection = _CGSDefaultConnection();
    int currentWorkspace = -1;
    
    CGSGetWorkspace(Connection, &currentWorkspace);
    // NSLog(@"Current Workspace: %i", currentWorkspace);
        
    return currentWorkspace;
}

- (bool) isSelected {
    return ([Workspace currentWorkspace] == workspaceNumber);
}
	
- (void) selectWithDefaultTransition {
    CGSTransitionType transitionNumber = [WorkspaceController transitionNumber];
	CGSTransitionOption option = CGSLeft;
    float duration = 0;
    if(transitionNumber != CGSNone) {
        if(workspaceNumber > [Workspace currentWorkspace]) {
            option = CGSLeft;
        } else {
            option = CGSRight;
        }
        
        duration = [[NSUserDefaults standardUserDefaults] 
		floatForKey: PREF_DESKTOPSWITCH_DURATION];
    }
	[self selectWithTransition: transitionNumber option: option duration: duration];
}
	
- (void) select {
	[self selectWithTransition: CGSNone option: CGSLeft duration: 0];
}

- (void) selectWithTransition: (CGSTransitionType) transitionNumber
	option: (CGSTransitionOption) transitionOption duration: (float) seconds {
         
    // Post will select notification
    [[NSNotificationCenter defaultCenter]
        postNotificationName: NOTIFICATION_WORKSPACEWILLSELECT
        object: self];
	
    CGSConnection cid = _CGSDefaultConnection();
	CGSTransitionSpec transSpec;
	int transNo = -1;
	
	transSpec.type = transitionNumber;
	transSpec.option = transitionOption;
	transSpec.wid = 0;
	transSpec.backColour = 0;
	
	CGSNewTransition(cid, &transSpec, &transNo);
    OSStatus retVal = CGSSetWorkspace(cid, workspaceNumber);
	usleep(10000);
	CGSInvokeTransition(cid, transNo, seconds);
	
	if(retVal) {
		NSLog(@"Error setting workspace: %i", retVal);
	}
	
	// Warp pointer
	if([[NSUserDefaults standardUserDefaults] boolForKey: PREF_CENTREMOUSEPOINTER]) {
		CGPoint newLoc;
		NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
		newLoc.x = screenFrame.origin.x + (0.5 * screenFrame.size.width);
		newLoc.y = screenFrame.origin.y + (0.5 * screenFrame.size.height);
		CGWarpMouseCursorPosition(newLoc);
	}
	
	// Post selected notification
    [[NSNotificationCenter defaultCenter]
        postNotificationName: NOTIFICATION_WORKSPACESELECTED
        object: self];
}

- (void) setWorkspaceName: (NSString*) n 
{
    if(name) { [name release]; }
    name = [[NSString stringWithString: n] retain];
}

- (NSString*) workspaceName 
{
    return name;
}

- (int) workspaceNumber 
{
    return workspaceNumber;
}

extern OSStatus CGSSetActiveWindow(CGSConnection cid, ...);
extern OSStatus CGSSetWorkspaceForWindow(CGSConnection cid, ...);

- (void) updateWindowList {
    CGSConnection connection = _CGSDefaultConnection();
    OSStatus retVal;

    [foreignWindowList removeAllObjects];		
    int windowCount = -1;
	
	retVal = CGSGetWorkspaceWindowCount(connection, workspaceNumber, &windowCount);
    
    if(retVal) {
        NSLog(@"Error getting window list for %@: %i-a", name, retVal);
        return;
    }
    
    if(windowCount == 0) {
        // No windows, return
		[windowMap removeAllObjects];
        return;
    }
    
	if(windowList) {
		[windowList autorelease];
	}
	windowList = [[NSMutableData dataWithCapacity: windowCount * sizeof(int)] retain];
	
	retVal = CGSGetWorkspaceWindowList(connection, workspaceNumber, windowCount, 
		[windowList mutableBytes], &windowCount);
	if(retVal) {
        NSLog(@"Error getting window list for %@: %i", name, retVal);
        return;
    }
	
	// For each window in the window map, check it is valid and remove it if not.
	NSEnumerator *mapEnum = [[windowMap allKeys] objectEnumerator];
	NSNumber *widObj;
	while(widObj = [mapEnum nextObject]) {
		int i = 0;
		bool found = NO;
		while(!found && (i<windowCount)) {
			CGSWindow wId = ((int*)[windowList mutableBytes])[i];
			if(wId == [widObj intValue]) {
				found = YES;
			}
			i++;
		}
		
		if(!found) {
			//NSLog(@"Removing %@", widObj);
			[windowMap removeObjectForKey: widObj];
			[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_WINDOW_CLOSED object: widObj];
		}
	}
	
	// Go through each window in the window list, inserting it in the 
	// map if its not already there.
	int i;
    for(i=0; i<windowCount; i++) {
        CGSWindow wId = ((int*)[windowList mutableBytes])[i];
		
		[foreignWindowList insertObject: [NSNumber numberWithInt: wId] atIndex: 0];
		
		ForeignWindow *window = (ForeignWindow*) [windowMap objectForKey: [NSNumber numberWithInt: wId]];
		if(!window) {
			window = [ForeignWindow windowWithWindowNumber: wId];
			
			if(([window level] != kCGNormalWindowLevel)) {
				// If this is a non-normal level window and it has no movement parent
				// then make it sticky. Note that this effectively removes it from the
				// window list returned by CGSGet*WindowList().
				[window makeSticky];
			}			
			
			//NSLog(@"Adding %i", wId);
			[windowMap setObject: window forKey: [NSNumber numberWithInt: wId]];
			
			[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_NEW_WINDOW object: [NSNumber numberWithInt: wId]];
		}
	}
}

- (NSArray*) windowList {
	NSMutableArray *list = [NSMutableArray array];
	
	// Work through the current window list and append
	// the appropariate foreign window representation.
	NSEnumerator *enumerator = [foreignWindowList objectEnumerator];
	NSNumber *widObj;
	while(widObj = (NSNumber*) [enumerator nextObject]) {
		[list insertObject: [windowMap objectForKey: widObj] atIndex: 0];
	}
	
    return list;
}

@end
