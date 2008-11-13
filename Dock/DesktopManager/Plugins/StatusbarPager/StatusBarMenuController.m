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

#import "StatusBarMenuController.h"
#import "StatusBarController.h"
#import "DesktopManager.h"

@implementation StatusBarMenuController

- (void) fillMenu {
    int i;
    WorkspaceController *wsController = [StatusbarController defaultController];
    
    NSMenu *desktopsMenu = [desktopsMenuItem submenu];
    
    // Empty Desktops menu....
    while([desktopsMenu numberOfItems] > 0) {
        [desktopsMenu removeItemAtIndex: 0];
    }
    
    for(i=0; i<[wsController workspaceCount]; i++) {
        Workspace *ws = [wsController workspaceAtIndex:i];
        NSMenuItem *item;
        item = (NSMenuItem*) [desktopsMenu 
            insertItemWithTitle: [ws workspaceName]
            action: @selector(select) keyEquivalent: @"" atIndex: i];
        [item setTarget: ws];
    }
	
	[currentDesktopMenu setDelegate: self];
}

- (NSMenu*) statusBarMenu {
	return statusMenu;
}

- (void) createStatusMenuItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    // Create the status bar menu item if required.
    [self destroyStatusMenuItem];
    
    statusMenuItem = [statusBar statusItemWithLength:NSSquareStatusItemLength];
    [statusMenuItem retain];
    [statusMenuItem setHighlightMode: YES];
    [statusMenuItem setImage: [NSImage imageNamed: @"DesktopStatusIcon"]];
    [statusMenuItem setAlternateImage: [NSImage imageNamed: @"DesktopStatusIconHighlight"]];
    [statusMenuItem setMenu: statusMenu];
}

- (void) destroyStatusMenuItem {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    if(statusMenuItem != nil) {
        [statusBar removeStatusItem: statusMenuItem];
        [statusMenuItem release]; 
        statusMenuItem = nil; 
    }
}

- (void) dealloc {
    if(statusMenuItem) { [statusMenuItem release]; }
	[super dealloc];
}

- (id) init {
    id myself = [super init];
    statusMenuItem = nil;
    return myself;
}

// Delegate methods
- (void) menuNeedsUpdate: (NSMenu*) menu {
	if(menu != currentDesktopMenu) { return; }
	
	int i = 0;
	
	// Update the menu with the current workspace's windows.
	while([currentDesktopMenu numberOfItems]) {
		[currentDesktopMenu removeItemAtIndex: 0];
	}
	
	WorkspaceController *wsController = [StatusbarController defaultController];
	NSArray *windowList = [[wsController currentWorkspace] windowList];
	if(windowList && [windowList count]) {
		for(i=[windowList count]-1; i>=0; i--) {
			ForeignWindow *window = (ForeignWindow*) [windowList objectAtIndex: i];
			NSString *title = [window title];
			
			if(title) {
				int max_length = 25;
				if([title length] > max_length) {
					title = [NSString stringWithFormat: @"%@...%@",
						[title substringToIndex: (max_length/2)-1],
						[title substringFromIndex: [title length]-1-(max_length/2)+2] ];
				}
				
				NSMenuItem *item = [currentDesktopMenu 
					insertItemWithTitle: title
					action: nil keyEquivalent: @"" atIndex: 0];		
					
				NSMenu* subMenu = [[NSMenu alloc] init];
				[subMenu autorelease];
				
				[item setRepresentedObject: window];
				[item setSubmenu: subMenu];
				
				int j=0;
				NSString *formatStr = [[NSBundle mainBundle] 
						localizedStringForKey: @"SwitchToFormat"
						value: @"Error getting localized string" table: nil];
				for(j=0; j<[wsController workspaceCount]; j++) {
					NSMenuItem *switchItem = [subMenu insertItemWithTitle: 
					   [NSString stringWithFormat: formatStr, [[wsController workspaceAtIndex: j] workspaceName]]
					   action: @selector(moveToWorkspaceRepresentedBy:) keyEquivalent: @"" atIndex: j];
					[switchItem setTarget: window];
					[switchItem setRepresentedObject: [wsController workspaceAtIndex: j]];
				}
			}
		}
	} else {
		NSMenuItem *item = [currentDesktopMenu 
				insertItemWithTitle: [[NSBundle mainBundle] 
					localizedStringForKey: @"NoWindowsOnDesktop"
					value: @"Error getting localized string" table: nil]
				action: nil keyEquivalent: @"" atIndex: 0];
		[item setEnabled: NO];
	}
}

@end
