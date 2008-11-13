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

#import "StatusbarController.h"
#import "DesktopManager.h"

static WorkspaceController *_wsController;

@implementation StatusbarController

+ (WorkspaceController*) defaultController {
	return _wsController;
}

- (NSString*) name { return @"Statusbar Pager & Menu"; }
- (NSString*) description { return @"Statusbar-base pager/menu"; }
- (int) interfaceVersion { return 1; }
- (NSBundle*) preferencesBundle { 
	NSString *prefBundlePath = [myBundle pathForResource: @"StatusbarPrefPane" ofType: @"bundle"]; 
	
	if(!prefBundlePath) {
		NSLog(@"Error: Statusbar Pager couldn't find its preferences bundle.");
		return nil;
	}
	
	return [NSBundle bundleWithPath: prefBundlePath];
}

- (void) doStatusBarStuff {
	// Destroy any stuff we might have
    [sbMenuController destroyStatusMenuItem];
    [sbPagerController destroyStatusPager];
   	
	[sbMenuController fillMenu];
		
	menuOnLeft = [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWMENUONLEFT];
	statusPagerShown = [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWPAGER];
	statusMenuShown = [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWMENU];
	numberOfWorkspaces = [_wsController workspaceCount];
	
    if(menuOnLeft) {
        // Create status bar pager
        if(statusPagerShown) {
            [sbPagerController createStatusPagerWithMenu: [sbMenuController statusBarMenu]];
        }
        // Create status bar menu
        if(statusMenuShown) {
            [sbMenuController createStatusMenuItem];
            //[sbMenuController fillMenu];
        }
    } else {
        // Create status bar menu
        if(statusMenuShown) {
            [sbMenuController createStatusMenuItem];
            //[sbMenuController fillMenu];
        }
        // Create status bar pager
        if(statusPagerShown) {
            [sbPagerController createStatusPagerWithMenu: [sbMenuController statusBarMenu]];
        }
    }
}

- (void) pluginLoaded: (DMController*) controller withBundle: (NSBundle*) thisBundle {
	dmController = controller;
	myBundle = thisBundle;
	_wsController = [controller workspaceController];
	
	NSNib *myNib = [[NSNib alloc] initWithNibNamed: @"Statusbar" bundle: thisBundle];
	NSArray *tlobjs;
	[myNib instantiateNibWithOwner: self topLevelObjects: &tlobjs];
	
	menuOnLeft = [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWMENUONLEFT];
	statusPagerShown = [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWPAGER];
	statusMenuShown = [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWMENU];
	numberOfWorkspaces = -1;

    [self doStatusBarStuff];

    // Register out interest in preferences changes
    [[NSNotificationCenter defaultCenter] addObserver: self
        selector: @selector(prefsChanged)
        name: NOTIFICATION_PREFSCHANGED object: nil
    ];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	if(sbMenuController) { 
	    [sbMenuController destroyStatusMenuItem];
	}
	if(sbPagerController) { 
		[sbPagerController destroyStatusPager];
	}
	[super dealloc];
}

- (void) prefsChanged {
    // If nothing changed, ignore everything
	if((menuOnLeft == [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWMENUONLEFT]) &&
		(statusPagerShown == [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWPAGER]) &&
		(statusMenuShown == [[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWMENU]) &&
		(numberOfWorkspaces == [_wsController workspaceCount])) {
		return;
	}

    [self doStatusBarStuff];
}

- (void) showPreferences: (id) sender { [dmController showPreferences: sender]; }
- (void) nextDesktop: (id) sender { [dmController nextDesktop: sender]; }
- (void) previousDesktop: (id) sender { [dmController previousDesktop: sender]; }
- (void) runApplication: (id) sender { [dmController runApplication: sender]; }

- (void) quit: (id) sender { [NSApp terminate: sender]; }
- (void) showAboutBox: (id) sender { [NSApp orderFrontStandardAboutPanel: sender]; }

@end
