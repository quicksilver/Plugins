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

#import "NSHidableWindow.h"
#import "DesktopManager.h"

@interface NSHidableWindow (Private)

- (void) frameChanged;
- (void) frameChanged: (BOOL) animateFlag;

@end

@implementation NSHidableWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)styleMask 
	backing:(NSBackingStoreType)backingType defer:(BOOL)flag {
	id mySelf = [super initWithContentRect:contentRect styleMask:styleMask
		backing:backingType defer:flag];
	if(mySelf) { 
		_hiding = NO;
		_autoHides = NO;		
		_wasAnimating = NO;
		_mouseTimer = nil;
		// Register for edge notifications
		[[NSNotificationCenter defaultCenter] addObserver: self
		    selector: @selector(edgeEvent:) name: NOTIFICATION_MOUSEEDGEEVENT
		    object: nil];	
		
		_location = BottomLeft;
		_screen = [[NSScreen mainScreen] retain];
		[self frameChanged: NO];
	}
	return mySelf;
}

- (void) dealloc {
	[_screen release];
	if(_mouseTimer != nil) {
		[_mouseTimer invalidate];
		_mouseTimer = nil;
	}
	[super dealloc];
}

- (void) edgeEvent: (NSNotification*) notification {
	NSNumber *edgeNum = [[notification userInfo] objectForKey: MouseWatcherEdgeKey];
	NSNumber *enteredNum = [[notification userInfo] objectForKey: MouseWatcherMouseEnteredKey];
	MouseWatcherEdge myedge = [edgeNum intValue];
	bool entered = [enteredNum boolValue];
	MouseWatcherEdge targetEdge = BottomEdge;
	
	switch(_location >> 2) {
		case 0:
			// Bottom
			targetEdge = BottomEdge;
			break;
		case 1:
			// Left
			targetEdge = LeftEdge;
			break;
		case 2:
			// Right
			targetEdge = RightEdge;
			break;
	}
	
	if(entered && (myedge == targetEdge)) {
		[self show];
	}
}

- (void) timerTick {
	// Called repeatedly whilst autohiding enabled and the window is being shown.
	NSRect frame = [self frame];
	NSPoint mouseLoc = [self mouseLocationOutsideOfEventStream];
	
	// Have we left the window position?
	switch(_location >> 2) {
		case 0:
			// Bottom
			if(mouseLoc.y > frame.size.height) {
				[self hide];
			}
			break;
		case 1:
			// Left
			if(mouseLoc.x > frame.size.width) {
				[self hide];
			}
			break;
		case 2:
			// Right
			if(mouseLoc.x < 0) {
				[self hide];
			}
			break;
	}
}

- (void) setAutohides: (BOOL) yesOrNo {
	if(yesOrNo == _autoHides) { return; }
	
	if(yesOrNo) {
		if(!_mouseTimer && !_hiding) {
			_mouseTimer = [NSTimer scheduledTimerWithTimeInterval: 0.25 target:self selector: @selector(timerTick) userInfo: nil repeats: YES];
		}
		_autoHides = YES;
	} else {
		if(_mouseTimer != nil) {
			[_mouseTimer invalidate];
			_mouseTimer = nil;
		}
		_autoHides = NO;
		[self show];
	}
}

- (BOOL) autohides {
	return _autoHides;
}
	
- (void) frameChanged: (BOOL) animateFlag {
	NSRect frame = [self frame];
	NSRect screenFrame = [[WorkspaceController defaultController] overallScreenFrame];
	NSRect screenVisFrame = [[WorkspaceController defaultController] overallVisibleScreenFrame];
	NSPoint targetOrigin = NSMakePoint(0,0);
	
	switch(_location >> 2) {
		case 0:
			// Bottom
			targetOrigin.y = screenFrame.origin.y;
			if(_hiding) {
				targetOrigin.y -= frame.size.height;
			}
			break;
		case 1:
			// Left
			targetOrigin.x = screenFrame.origin.x;
			if(_hiding) {
				targetOrigin.x -= frame.size.width;
			}
			break;
		case 2:
			// Right
			targetOrigin.x = screenFrame.origin.x + screenFrame.size.width;
			if(!_hiding) {
				targetOrigin.x -= frame.size.width;
			}
			break;
	}
	
	switch(_location & 3) {
		case 0:
			// Left/Top
			if(_location >> 2 == 0) {
				// Bottom, set x
				targetOrigin.x = screenFrame.origin.x;
			} else {
				// Left/Right, set y
				targetOrigin.y = screenVisFrame.origin.y + screenVisFrame.size.height - frame.size.height;
			}
			break;
		case 1:
			// Middle
			if(_location >> 2 == 0) {
				// Bottom, set x
				targetOrigin.x = screenFrame.origin.x;
				targetOrigin.x += (int) ((screenFrame.size.width - frame.size.width) / 2);
			} else {
				// Left/Right, set y
				targetOrigin.y = screenVisFrame.origin.y;
				targetOrigin.y += (int) ((screenVisFrame.size.height - frame.size.height) / 2);
			}
			break;
		case 2:
			// Right/Bottom
			if(_location >> 2 == 0) {
				// Bottom, set x
				targetOrigin.x = screenFrame.origin.x + screenFrame.size.width - frame.size.width;
			} else {
				// Left/Right, set y
				targetOrigin.y = screenFrame.origin.y;
			}
			break;
	}
	
	if(!_hiding) {
		if(!_mouseTimer && _autoHides) {
			_mouseTimer = [NSTimer scheduledTimerWithTimeInterval: 0.25 target:self selector: @selector(timerTick) userInfo: nil repeats: YES];
		}
	}
	
	if(!_wasAnimating && ((frame.origin.x != targetOrigin.x) || (frame.origin.y != targetOrigin.y))) {
		frame.origin = targetOrigin;
		_wasAnimating = YES;
		[super setFrame: frame display: NO animate: animateFlag];
	}
	
	if((frame.origin.x == targetOrigin.x) && (frame.origin.y == targetOrigin.y)) {
		_wasAnimating = NO;
	}
}

- (void) frameChanged {
	[self frameChanged: YES];
}

- (void) setFrame: (NSRect)frameRect display:(BOOL)flag {
	[super setFrame: frameRect display: flag];
	[self frameChanged];
}

- (void) setFrame:(NSRect)frameRect display:(BOOL)displayFlag animate:(BOOL)animationFlag {
	[super setFrame: frameRect display: displayFlag animate: animationFlag];
	[self frameChanged];
}

- (void)setFrameOrigin:(NSPoint)aPoint {
	[super setFrameOrigin: aPoint];
	[self frameChanged];
}

- (void)setFrameTopLeftPoint:(NSPoint)aPoint {
	[super setFrameTopLeftPoint: aPoint];
	[self frameChanged];	
}

- (void) show {
	_hiding = NO;
	[self frameChanged];
}

- (void) hide {
	_hiding = YES;
	// Stop mouse timer if it is running.
	if(_mouseTimer != nil) {
		[_mouseTimer invalidate];
		_mouseTimer = nil;
	}
	[self frameChanged];
}

- (void) setLocation: (NSHidableWindowLocation) location {
	_location = location;
	[self frameChanged: NO];
}
- (NSHidableWindowLocation) location {
	return _location;
}

@end
