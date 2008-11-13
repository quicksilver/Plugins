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

#import "MouseWatcher.h"
#import "DesktopManager.h"

/*
 *  The following comes from OSXVNC (http://sf.net/projects/osxvnc/)
 *  Created by Mihai Parparita on Sat Jun 15 2002.
 *  Copyright (c) 2002 Mihai Parparita. All rights reserved.
 */

extern CGError CGSGetCurrentCursorLocation(CGSConnection connection, CGPoint* point);
extern int CGSCurrentCursorSeed(void);

@implementation MouseWatcher

- (CGPoint) _currentCursorLocation {
	CGPoint loc;
	if(CGSGetCurrentCursorLocation(_CGSDefaultConnection(), &loc) != kCGErrorSuccess) {
		NSLog(@"Cannot get cursor location");
	}
	
	return loc;
}

- (void) awakeFromNib {
	lastCursorLoc = [self _currentCursorLocation];
	screenRect = [[WorkspaceController defaultController] overallScreenFrame];
	ForeignWindow *pointerWin = [[WorkspaceController defaultController] windowUnderPointer];
	lastWindowId = (pointerWin != nil) ? [pointerWin windowNumber] : -1;
	
	[NSTimer scheduledTimerWithTimeInterval: 0.5 target: self 
								   selector: @selector(updateMouse)
								   userInfo: nil repeats: YES];
}

- (MouseWatcherEdge) _edgeContainingPoint: (CGPoint) loc {
	if((loc.x >= screenRect.origin.x) && (loc.x <= screenRect.origin.x + 3)) {
		return LeftEdge;
	}
	if((loc.x <= screenRect.origin.x + screenRect.size.width) && 
	   (loc.x >= screenRect.origin.x + screenRect.size.width - 3)) {
		return RightEdge;
	}
	if((loc.y <= screenRect.origin.y + screenRect.size.height) && 
	   (loc.y >= screenRect.origin.y + screenRect.size.height - 3)) {
		return BottomEdge;
	}
	
	return None;
}

extern OSStatus CGSSetActiveWindow(const CGSConnection cid, int flag);
//extern OSStatus CGSSetMouseFocusWindow(const CGSConnection cid, int flag);

extern OSStatus CPSSetFrontProcess(ProcessSerialNumber *psn);

- (void) updateMouse {
	CGPoint loc = [self _currentCursorLocation];
	if(!CGPointEqualToPoint(lastCursorLoc, loc)) {
		ForeignWindow *pointerWin = [[WorkspaceController defaultController] windowUnderPointer];
		int windowId = (pointerWin != nil) ? [pointerWin windowNumber] : -1;

		if(windowId != lastWindowId) {
			// Changed window
			
			// The following is some experimental code to implement focus-follows mouse. It doesn't work.
#if 0
			if(windowId >= 0) {
				ForeignWindow *parent = [pointerWin movementParent];
				if(!parent && ([pointerWin level] == kCGNormalWindowLevel)) {
					[pointerWin focusOwner];
					
					// Only switch focus if it doesn't have a parent.
					//CGPostMouseEvent(loc, true, 1, true);
					//CGPostMouseEvent(loc, true, 1, false);
				}
			}
#endif

			lastWindowId = windowId;
		}
		
		MouseWatcherEdge lastEdge = [self _edgeContainingPoint: lastCursorLoc];
		MouseWatcherEdge edge = [self _edgeContainingPoint: loc];
		
		if((edge == None) && (lastEdge != None)) {
			//NSLog(@"Left: %i", lastEdge);
			// Left an edge
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool: NO], MouseWatcherMouseEnteredKey, nil
				];
			[userInfo setObject: [NSNumber numberWithInt: lastEdge] forKey: MouseWatcherEdgeKey];
			
			[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_MOUSEEDGEEVENT 
																object:self userInfo:userInfo];
		} else if((edge != None) && (lastEdge == None)) {
			//NSLog(@"Entered: %i", edge);
			// Entered an edge
			NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithBool: YES], MouseWatcherMouseEnteredKey, nil
				];
			[userInfo setObject: [NSNumber numberWithInt: edge] forKey: MouseWatcherEdgeKey];
		
			[[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_MOUSEEDGEEVENT 
																object:self userInfo:userInfo];
		}   
		lastCursorLoc = loc;
	}
}

@end
