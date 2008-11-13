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

#import "DesktopWorkspaceNamesController.h"
#import "WorkspaceNameView.h"

@implementation DesktopWorkspaceNamesController
- (NSString*) name { return @"Desktop Name in Desktop"; }
- (NSString*) description { return @"Displays desktop oname on the desktop background"; }
- (int) interfaceVersion { return 1; }
- (NSBundle*) preferencesBundle {
	NSString *prefBundlePath = [myBundle pathForResource: @"WorkspaceNameDisplayPrefs" 
		ofType: @"bundle"]; 
	
	if(!prefBundlePath) {
		NSLog(@"Error: Desktop Pager couldn't find its preferences bundle.");
		return nil;
	}
	
	return [NSBundle bundleWithPath: prefBundlePath];
}

- (void) updateName {
	Workspace *ws = [_wsController currentWorkspace];
	[(WorkspaceNameView*)_nameView setName: [ws workspaceName]];
	[[_displayWindow contentView] setNeedsDisplay: YES];
}

- (void) readPrefs {
	if([[NSUserDefaults standardUserDefaults] boolForKey: PREF_DESKTOPNAME_SHOW]) {
		NSRect frameRect = [[NSScreen mainScreen] visibleFrame];
		if([[NSUserDefaults standardUserDefaults] boolForKey: PREF_DESKTOPNAME_TOPCORNER]) {
			// Nothing
			//NSLog(@"Top");
			frameRect.origin.y = frameRect.origin.y + frameRect.size.height - 60;
		} else {
			//NSLog(@"Bottom");
			frameRect.origin.y = 0;
		}
		frameRect.size.height = 60;
		[_displayWindow setFrame: frameRect display: NO];
		[_displayWindow orderFront: self];
		[_displayWindow setAlphaValue:
			[[NSUserDefaults standardUserDefaults] floatForKey: PREF_DESKTOPNAME_ALPHA]
		];
		[[_displayWindow contentView] setNeedsDisplay: YES];
	} else {
		[_displayWindow orderOut: self];
	}
}

- (void) pluginLoaded: (DMController*) controller withBundle: (NSBundle*) thisBundle {
	myBundle = thisBundle;
	_wsController = [controller workspaceController];

	// Register our own defaults	
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObjectsAndKeys: 
		PREF_DESKTOPNAME_LEFTCORNER_DEFAULT, PREF_DESKTOPNAME_LEFTCORNER,
		PREF_DESKTOPNAME_TOPCORNER_DEFAULT, PREF_DESKTOPNAME_TOPCORNER,
		PREF_DESKTOPNAME_SHOW_DEFAULT, PREF_DESKTOPNAME_SHOW,
		PREF_DESKTOPNAME_ALPHA_DEFAULT, PREF_DESKTOPNAME_ALPHA,
        nil
    ];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults: appDefaults];
		
	NSScreen *mainScreen = [NSScreen mainScreen];

	_displayWindow = [[NSWindow alloc] initWithContentRect: [mainScreen visibleFrame] 
		styleMask: NSBorderlessWindowMask backing: NSBackingStoreBuffered
		defer: YES];
	[_displayWindow setLevel: -5000];
	[_displayWindow setOpaque: NO];
	
	NSRect frameRect = [_displayWindow contentRectForFrameRect: [_displayWindow frame]];
	_nameView = [[WorkspaceNameView alloc] initWithFrame: frameRect];
	[_displayWindow setContentView: _nameView];
	[_displayWindow setIgnoresMouseEvents: YES];
	
	[self updateName];
	[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(updateName)
		name:NOTIFICATION_WORKSPACESELECTED object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self selector:@selector(readPrefs)
		name:NOTIFICATION_PREFSCHANGED object: nil];
		
	[self readPrefs];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	if(_displayWindow) { [_displayWindow release]; }
	if(_nameView) { [_nameView release]; }
	
	[super dealloc];
}

@end
