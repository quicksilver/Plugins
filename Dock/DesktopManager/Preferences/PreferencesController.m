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
 
#import "PreferencesController.h"
#import "DesktopManager.h"
#import "PreferencePanes/NSPreferencePane.h"

#define MyPboardType @"DesktopsPrefsPboard"

@implementation PreferencesController

- (void) awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(showPreferences)
		name: NOTIFICATION_SHOWPREFS object: nil];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(prefsChanged)
		name: NOTIFICATION_PREFSCHANGED object: nil];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	if(panesArray) { [panesArray release]; }
	if(toolbar) { [toolbar release]; }
	if(toolbarItems) { [toolbarItems release]; }
	if(selectableIdentifiers) { [selectableIdentifiers release]; }
	if(defaultIdentifiers) { [defaultIdentifiers release]; }
	[super dealloc];
}

- (void) prefsChanged {
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) showPreferences {
    [prefsWindow orderOut: self];      
    [prefsWindow center];
    [prefsWindow makeKeyAndOrderFront: self];
    [NSApp activateIgnoringOtherApps: YES];
}

- (void) showPane: (NSPreferencePane*) pane animate: (BOOL) animate {
	NSView *mainView = [pane mainView];
	NSView *contentView = [prefsWindow contentView];
	NSView *oldView = nil;
	
	if([[contentView subviews] count]) {
		oldView = [[contentView subviews] objectAtIndex: 0];
	}
	
	if(oldView == mainView) { return; /* Nothing to do here */ }
	
	if(!mainView) { NSLog(@"Error getting main view."); return; }
	
	NSRect newFrame = [prefsWindow frame];
	float newHeight = [prefsWindow frameRectForContentRect: [mainView frame]].size.height;
	newFrame.origin.y += newFrame.size.height - newHeight;
	newFrame.size.height = newHeight;

	if(oldView) { [oldView removeFromSuperview]; }
	[prefsWindow setFrame: newFrame display: YES animate: animate];
	[pane willSelect];
	[contentView addSubview: mainView];
	[pane didSelect];
}

- (void) showPane: (NSPreferencePane*) pane {
	[self showPane: pane animate: YES];
}

- (NSString*) bundleIconLabel: (NSBundle*) prefBundle {
	NSDictionary *infoDictionary = [prefBundle infoDictionary];
		
	NSString *iconLabel = [infoDictionary objectForKey: @"NSPrefPaneIconLabel"];
	if(!iconLabel) {
		iconLabel = [infoDictionary objectForKey: @"CFBundleName"];
	}
	if(!iconLabel) {
		NSLog(@"Warning: Error getting icon label.");
		iconLabel = @"Unknown";
	}
	
	return iconLabel;
}

- (NSString*) bundleIconPath: (NSBundle*) prefBundle {
	NSDictionary *infoDictionary = [prefBundle infoDictionary];

	NSString *iconFile = [infoDictionary objectForKey: @"NSPrefPaneIconFile"];
	if(!iconFile) {
		iconFile = [infoDictionary objectForKey: @"CFBundleIconFile"];
	}
	if(!iconFile) {
		NSLog(@"Warning: Error getting icon file.");
		iconFile = @"";
	}
	
	NSString *iconPath = [prefBundle pathForImageResource: iconFile];

	return iconPath;
}

- (void) buildPreferencesToolbar: (id) controller {
	panesArray = [[NSMutableArray array] retain];
	toolbar = [[NSToolbar alloc] initWithIdentifier: @"PreferencesToolbar"];
	toolbarItems = [[NSMutableDictionary dictionary] retain];
	
	selectableIdentifiers = [[NSMutableArray array] retain];
	defaultIdentifiers = [[NSMutableArray array] retain];
	
	// Get list of plugins.
	NSArray *plugins = [(DMController*) controller plugins];
	NSMutableArray *prefBundles = [NSMutableArray array];
	
	if(plugins && [plugins count]) {
		NSEnumerator *pluginEnum = [plugins objectEnumerator];
		id <DesktopManagerPlugin> plugin;
		while(plugin = [pluginEnum nextObject]) {
			// Do we have a preferences bundle?
			NSBundle *prefBundle = [plugin preferencesBundle];
			if(prefBundle) { 
				[prefBundles addObject: prefBundle]; 
			}
		}
	}
	
	int paneIndex = 0;
	NSEnumerator *bundleEnum = [prefBundles objectEnumerator];
	NSBundle *prefBundle;
	while(prefBundle = [bundleEnum nextObject]) {
		NSString *iconLabel = [self bundleIconLabel: prefBundle];
		NSString *iconPath = [self bundleIconPath: prefBundle];
		
		Class principalClass = [prefBundle principalClass];
		if([principalClass isSubclassOfClass: [NSPreferencePane class]]) {
			NSPreferencePane *pane = [[principalClass alloc] initWithBundle: prefBundle];
			
			[panesArray insertObject: pane atIndex: paneIndex];
			
			[pane loadMainView];
			
			if(!iconPath) { 
				NSLog(@"Error loading icon: %@", iconPath);
			} else {
				NSImage *itemImage = [NSImage alloc];
				[itemImage initByReferencingFile: iconPath];
				
				if(!itemImage) { NSLog(@"Warning: Couldn't load image."); }
				
				NSToolbarItem *toolbarItem;
				toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: iconLabel];
				
				if(!toolbarItem) { NSLog(@"Warning: Could not create toolbar item."); }
				
				[toolbarItem setImage: itemImage];
				[toolbarItem setLabel: iconLabel];
				[toolbarItem setTag: paneIndex]; // The index of the appropriate pane.
				[toolbarItem setTarget: self];
				[toolbarItem setAction: @selector(toolbarButtonClicked:)];
				
				[toolbarItems setObject: toolbarItem forKey: iconLabel];
				
				[itemImage autorelease];
				[toolbarItem autorelease];
			}
			
			paneIndex ++;
		} else {
			NSLog(@"Error: Principal class is not a preference pane.");
		}
	}
	
	[selectableIdentifiers addObjectsFromArray: 
		[[toolbarItems allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)]
	];
	[defaultIdentifiers addObject: NSToolbarSeparatorItemIdentifier];
	[defaultIdentifiers addObjectsFromArray: 
		[[toolbarItems allKeys] sortedArrayUsingSelector: @selector(caseInsensitiveCompare:)]
	];
	
	// Load built-in plugins.
	NSArray *builtInBundles = [[NSBundle mainBundle] pathsForResourcesOfType: @"bundle"
		inDirectory: @"PreferencePanes"];
	if(builtInBundles && [builtInBundles count]) {
		NSString *bundlePath;
		NSEnumerator *bundleEnum = [builtInBundles objectEnumerator];
		while(bundlePath = [bundleEnum nextObject]) {
			NSBundle *prefBundle = [NSBundle bundleWithPath: bundlePath];
			
			NSString *iconLabel = [self bundleIconLabel: prefBundle];
			NSString *iconPath = [self bundleIconPath: prefBundle];
		
			Class principalClass = [prefBundle principalClass];
			if([principalClass isSubclassOfClass: [NSPreferencePane class]]) {
				NSPreferencePane *pane = [[principalClass alloc] initWithBundle: prefBundle];
				
				[panesArray insertObject: pane atIndex: paneIndex];
			
				[pane loadMainView];
			
				if(!iconPath) { 
					NSLog(@"Error loading icon: %@", iconPath);
				} else {
					NSImage *itemImage = [NSImage alloc];
					[itemImage initByReferencingFile: iconPath];
				
					if(!itemImage) { NSLog(@"Warning: Couldn't load image."); }
				
					NSToolbarItem *toolbarItem;
					toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier: iconLabel];
				
					if(!toolbarItem) { NSLog(@"Warning: Could not create toolbar item."); }
				
					[toolbarItem setImage: itemImage];
					[toolbarItem setLabel: iconLabel];
					[toolbarItem setTag: paneIndex]; // The index of the appropriate pane.
					[toolbarItem setTarget: self];
					[toolbarItem setAction: @selector(toolbarButtonClicked:)];
				
					[toolbarItems setObject: toolbarItem forKey: iconLabel];
				
					[itemImage autorelease];
					[toolbarItem autorelease];
					
					[selectableIdentifiers insertObject: iconLabel atIndex: 0];
					[defaultIdentifiers insertObject: iconLabel atIndex: 0];
				}
		
				paneIndex ++;
			} else {
				NSLog(@"Error: Principal class is not a preference pane.");
			}
		}
	}
	
	[toolbar setAutosavesConfiguration: NO];
	[toolbar setAllowsUserCustomization: NO];

	[toolbar setDelegate: self];
	[prefsWindow setToolbar: toolbar];
	
	if([selectableIdentifiers count]) {
		NSString *identifier = [selectableIdentifiers objectAtIndex: 0];
		NSToolbarItem *item = [toolbarItems objectForKey: identifier];
		NSPreferencePane *pane = [panesArray objectAtIndex: [item tag]];
		[toolbar setSelectedItemIdentifier: identifier];
		[self showPane: pane animate: NO];
	}
}

- (void) toolbarButtonClicked: (id) sender {
	NSPreferencePane *pane = [panesArray objectAtIndex: [(NSToolbarItem*) sender tag]];
	
	if(!pane) { NSLog(@"Error getting pane."); return; }

	[self showPane: pane];
}

// Toolbar delegate functions.
- (NSToolbarItem*) toolbar: (NSToolbar*) theToolbar
	itemForItemIdentifier: (NSString*) identifier willBeInsertedIntoToolbar: (BOOL) flag {
	NSToolbarItem *item = [toolbarItems objectForKey: identifier];
	if(!item) { return nil; }
	
	return item;
}

- (NSArray*) toolbarAllowedItemIdentifiers: (NSToolbar*) theToolbar {
	//NSLog(@"Allowed Items: %i", [[toolbarItems allKeys] count]);
	return defaultIdentifiers;
}

- (NSArray*) toolbarDefaultItemIdentifiers: (NSToolbar*) theToolbar {
	//NSLog(@"Default Items: %i", [[toolbarItems allKeys] count]);
	return defaultIdentifiers;
}

- (NSArray*) toolbarSelectableItemIdentifiers: (NSToolbar*) theToolbar {
	//NSLog(@"Default Items: %i", [[toolbarItems allKeys] count]);
	return selectableIdentifiers;
}

@end
