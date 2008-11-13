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
#import "../DMPlugins.h"
 
#import "DesktopPagerController.h"
#import "DesktopPagerView.h"

static WorkspaceController *_wsController = nil;

@implementation DesktopPagerController

- (NSString*) name { return @"Desktop Pager"; }
- (NSString*) description { return @"A Pager within a floating window."; }
- (int) interfaceVersion { return 1; }
- (NSBundle*) preferencesBundle { 
	NSString *prefBundlePath = [myBundle pathForResource: @"DesktopPagerPrefPane" ofType: @"bundle"]; 
	
	if(!prefBundlePath) {
		NSLog(@"Error: Desktop Pager couldn't find its preferences bundle.");
		return nil;
	}
	
	return [NSBundle bundleWithPath: prefBundlePath];
}

+ (WorkspaceController*) workspaceController { return _wsController; }

- (void) pluginLoaded: (DMController*) controller withBundle: (NSBundle*) thisBundle {
	myBundle = thisBundle;
	dmController = controller;
	_wsController = [controller workspaceController];
	
	// Register our own defaults	
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObjectsAndKeys: 
        PREF_DESKTOPPAGER_SHOW_DEFAULT, PREF_DESKTOPPAGER_SHOW,
        PREF_DESKTOPPAGER_HEIGHT_DEFAULT, PREF_DESKTOPPAGER_HEIGHT,
        PREF_DESKTOPPAGER_ROWS_DEFAULT, PREF_DESKTOPPAGER_ROWS,
        PREF_DESKTOPPAGER_AUTOHIDES_DEFAULT, PREF_DESKTOPPAGER_AUTOHIDES,
        PREF_DESKTOPPAGER_SKIN_DEFAULT, PREF_DESKTOPPAGER_SKIN,
        PREF_DESKTOPPAGER_ICONS_DEFAULT, PREF_DESKTOPPAGER_ICONS,
        PREF_DESKTOPPAGER_NAMES_DEFAULT, PREF_DESKTOPPAGER_NAMES,
        PREF_DESKTOPPAGER_LOCATION_DEFAULT, PREF_DESKTOPPAGER_LOCATION,
        nil
    ];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: appDefaults];

	// Register for switch notifications
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(workspaceSelected) name: NOTIFICATION_WORKSPACESELECTED
		object: nil];
		
	NSRect contentRect;
	
	contentRect.size.width = 300;
	contentRect.size.height = 100;
	contentRect.origin.x = 0;
	contentRect.origin.y = 0;
	
	pagerWindow = [[NSHidableWindow alloc]	initWithContentRect: contentRect
		styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered
		defer: YES ];
	[pagerWindow setBackgroundColor: [NSColor clearColor]];
	[pagerWindow setOpaque: NO];
	[pagerWindow setLevel: NSDockWindowLevel];
	[pagerWindow setHasShadow: NO];
	[pagerWindow hide]; [pagerWindow show];
	
	DesktopPagerView *pagerView = [[DesktopPagerView alloc] initWithFrame: contentRect
		controller: [controller workspaceController]];
	[pagerWindow setContentView: pagerView];
	[pagerView setAutoresizingMask: NSViewWidthSizable | NSViewHeightSizable ];
	
	[pagerView setCloseTarget: self];
	[pagerView setCloseAction: @selector(closeAction:) ];
	[pagerView setPrefTarget: self];
	[pagerView setPrefAction: @selector(prefAction:) ];
	
	// [[ForeignWindow windowWithNSWindow: pagerWindow] makeSticky];

	// Register for preferences changed notifications
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(readPreferences) name: NOTIFICATION_PREFSCHANGED
		object: nil];
		
	[self readPreferences];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	if(pagerWindow) { 
		[[pagerWindow contentView] release];
		[pagerWindow release];
	}
	
	[super dealloc];
}

- (void) closeAction: (id) sender {
	[NSApp terminate: self];
}

- (void) prefAction: (id) sender {
	[dmController showPreferences: self];
}

- (void) showPager {
	if(!pagerWindow) { return; }
	
	[(DesktopPagerView*) [pagerWindow contentView] setTargetHeight:
		[[NSUserDefaults standardUserDefaults] integerForKey: PREF_DESKTOPPAGER_HEIGHT]];
		
	[pagerWindow orderFront: self];
}

- (void) hidePager {
	if(!pagerWindow) { return; }
}

- (void) orderPagerOut {
	if(!pagerWindow) { return; }
	
	[pagerWindow orderOut: self];
}

- (void) readPreferences {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if([defaults boolForKey: PREF_DESKTOPPAGER_SHOW]) {
		[self showPager];
	} else {
		[self orderPagerOut];
	}
	
	NSHidableWindowLocation location = [defaults integerForKey: PREF_DESKTOPPAGER_LOCATION];
	if([pagerWindow location] != location) {
		[pagerWindow setLocation: location];
	} 
	
	BOOL autohides = [defaults boolForKey: PREF_DESKTOPPAGER_AUTOHIDES];
	if([pagerWindow autohides] != autohides) {
		[(NSHidableWindow*) pagerWindow setAutohides: autohides];
	}
}

- (void) workspaceSelected {
	if([pagerWindow isVisible]) {
		// [pagerWindow orderOut: self];
		[pagerWindow orderFront: self];
	}
}

@end
