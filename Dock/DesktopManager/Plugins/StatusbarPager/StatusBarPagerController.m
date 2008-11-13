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

#import "StatusBarPagerController.h"
#import "PagerView.h"

@implementation StatusBarPagerController

- (id) init {
    id myself = [super init];
    statusBarView = nil;
    return myself;
}

- (void) dealloc {
    if(statusItem) { [statusItem release]; }
	[super dealloc];
}

- (void) createStatusPager {
	[self createStatusPagerWithMenu: nil];
}

- (void) createStatusPagerWithMenu: (NSMenu*) menu {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    // Create the status bar menu item if required.
    [self destroyStatusPager];
    
    statusItem = [statusBar statusItemWithLength: NSVariableStatusItemLength];
    [statusItem retain];
    [statusItem setHighlightMode: NO];
    
    NSRect frame;
	if(statusBarView) { [statusBarView release]; }
    statusBarView = [PagerView alloc];
    frame.origin.x = 0; frame.origin.y = 0;
    frame.size.width = frame.size.height = 0;
    [statusBarView initWithFrame: frame ];
    [statusBarView retain];
    [statusBarView sizeToHeight: 22];
    [statusBarView syncWithController];
    [statusItem setView: statusBarView];
	[statusItem setHighlightMode: YES];
	if(menu) { [statusBarView setMenu: menu]; [menu retain]; }
}

- (void) destroyStatusPager {
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    
    if(statusBarView != nil) {
		NSMenu *menu;
		if(menu = [statusBarView menu]) { 
			[menu autorelease];
			[statusBarView setMenu: nil];
		}
        [statusBarView autorelease];
        statusBarView = nil;
    }
    
    if(statusItem != nil) {
        [statusBar removeStatusItem: statusItem];
        [statusItem release]; 
        statusItem = nil; 
    }
}

@end
