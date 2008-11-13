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

#import "OperationsMenuController.h"
#import "OperationsMenuView.h"
#import "DesktopManager.h"

#import <unistd.h>

@implementation OperationsMenuController

- (NSString*) name { return @"Operations Menu"; }
- (NSString*) description { return @"Hot-key triggered operations menu"; }
- (int) interfaceVersion { return 1; }
- (NSBundle*) preferencesBundle { return nil; }

- (void) _createWindow {
	// Create our overlay window
	NSRect contentRect = [wsController overallScreenFrame];
	overlayWin = [[NSWindow alloc] initWithContentRect: contentRect styleMask: NSBorderlessWindowMask 
		backing: NSBackingStoreBuffered defer:YES];
    [overlayWin setOpaque: NO]; 
    [overlayWin setHasShadow: NO];
	[overlayWin setLevel:NSFloatingWindowLevel];
    [overlayWin setBackgroundColor: [NSColor clearColor]]; 
	
	contentRect.origin.x = contentRect.origin.y = 0;
	_contentView = [[[OperationsMenuView alloc] initWithFrame: contentRect] autorelease];
	[overlayWin setContentView: _contentView];
	
	opsMenu = [[NSMenu alloc] initWithTitle: @""];
	[opsMenu setDelegate: self];
}

- (void) _releaseWindow {
	if(overlayWin) {
		[overlayWin autorelease];
		overlayWin = nil;
		_contentView = nil;
	}
	if(opsMenu) { [opsMenu autorelease]; opsMenu = nil; }
}

- (void) pluginLoaded: (DMController*) controller withBundle: (NSBundle*) thisBundle {
	wsController = [controller workspaceController];

	// Register for operations menu notification
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(showOperationsMenu) 
		name: NOTIFICATION_OPERATIONS_MENU object: nil];
		
	overlayWin = nil;
	_contentView = nil;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	if(overlayWin) { [overlayWin release]; }
	if(_contentView) { [_contentView release]; }
	if(opsMenu) { [opsMenu release]; }
	
	[super dealloc];
}

- (void) fillMenuForWindow: (ForeignWindow*) associatedWindow {
	if(!associatedWindow) { return; }
	
	[opsMenu setTitle: [associatedWindow title]];
	
	// Empty menu....
    while([opsMenu numberOfItems] > 0) {
        [opsMenu removeItemAtIndex: 0];
    }
	
	int j=0;
	NSString *formatStr = [[NSBundle mainBundle] 
		localizedStringForKey: @"SwitchToFormat"
		value: @"Error getting localized string" table: nil];
	for(j=0; j<[wsController workspaceCount]; j++) {
		NSMenuItem *switchItem = [opsMenu insertItemWithTitle: 
			[NSString stringWithFormat: formatStr, [[wsController workspaceAtIndex: j] workspaceName]]
			action: @selector(moveToWorkspaceRepresentedBy:) 
			keyEquivalent: (j < 10 ? [NSString stringWithFormat: @"%i", j+1] : @"") atIndex: j];
		[switchItem setTarget: associatedWindow];
		[switchItem setRepresentedObject: [wsController workspaceAtIndex: j]];
	}
	
	// Fixme
	BOOL sticky = [[StickyWindowController defaultController] isSticky: associatedWindow];
	
	if(sticky) {
		NSMenuItem *switchItem = [opsMenu insertItemWithTitle: [[NSBundle mainBundle] 
		localizedStringForKey: @"MakeUnSticky" value: @"Error getting localized string" table: nil] action: @selector(makeUnSticky) keyEquivalent: @"S" atIndex: j++];
		[switchItem setTarget: self];
	} else {
		NSMenuItem *switchItem = [opsMenu insertItemWithTitle: [[NSBundle mainBundle] 
		localizedStringForKey: @"MakeSticky" value: @"Error getting localized string" table: nil] action: @selector(makeSticky) keyEquivalent: @"S" atIndex: j++];
		[switchItem setTarget: self];	
	}
}

- (void) makeUnSticky {
	ForeignWindow *win = [_contentView associatedWindow];
	if(!win) {
		return;
	}
	
	[[StickyWindowController defaultController] removeWindowFromStickyList: win];
}

- (void) makeSticky {
	ForeignWindow *win = [_contentView associatedWindow];
	if(!win) {
		return;
	}
	
	[[StickyWindowController defaultController] addWindowToStickyList: win];
}

- (void) showOperationsMenu {
	if(!overlayWin) { [self _createWindow]; }

	// We firstly need to find the window under the mouse pointer.
	ForeignWindow *window = [wsController windowUnderPointer];
	
	if(!window) { 
		// Return if there is none.
		NSLog(@"No window under pointer");
			
		return;
	}
		
	// Move it to the front ready to show the menu.
	[window orderFront];
	
	[_contentView setAssociatedWindow: window];
	[_contentView setMenu: opsMenu];
	[_contentView setNeedsDisplay: YES];
	[overlayWin orderFrontRegardless];
	
	[self fillMenuForWindow: window];
	
	NSRect windowFrame = [window screenRect];
	NSPoint midpoint;
	midpoint.x = windowFrame.origin.x + (windowFrame.size.width / 2.0);
	midpoint.y = windowFrame.origin.y + 0.66 * (windowFrame.size.height / 2.0);
	
	// Convert to window co-ords
	midpoint.y = [_contentView frame].size.height - midpoint.y;

	// Nasty hack to show menu.
	NSEvent *mouseEvent = [NSEvent mouseEventWithType: NSLeftMouseDown 
		location: midpoint modifierFlags: NSControlKeyMask 
		timestamp: 0 windowNumber: [overlayWin windowNumber] 
		context: [NSGraphicsContext currentContext] 
		eventNumber: 0 clickCount: 1 pressure: 1.0];
	[overlayWin postEvent: mouseEvent atStart: YES];
	
	// Timer to tick immediately after the menu has hidden/been selected, etc.
	overlayTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self 
		selector: @selector(overlayTimerTick:) userInfo: nil repeats: NO];
}

- (void) overlayTimerTick: (NSTimer*) timer {
	if(overlayWin) {
		[overlayWin orderOut: nil];
		overlayTimer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self 
			selector: @selector(_releaseWindow) userInfo: nil repeats: NO];
	}
}

@end
