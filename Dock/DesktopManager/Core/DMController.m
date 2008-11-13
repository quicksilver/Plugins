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
#import "NotificationView.h"
#import "../CodeInjection/CodeInjector.h"

#import <unistd.h>

@implementation DMController

- (WorkspaceController*) workspaceController {
	return [WorkspaceController defaultController];
}

- (void) loadPlugins {
	NSDirectoryEnumerator *bundleEnum;
	NSString *currBundlePath;
	NSString *searchPath = [[NSBundle mainBundle] builtInPlugInsPath];
	bundleEnum = [[NSFileManager defaultManager]
		enumeratorAtPath: searchPath];
	plugins = [[NSMutableArray array] retain];
		
	if(bundleEnum) {
		while(currBundlePath = [bundleEnum nextObject]) {
			if([[currBundlePath pathExtension] isEqualToString: @"bundle"]) {
				NSBundle* pluginBundle;
				
				pluginBundle = [NSBundle bundleWithPath: [searchPath 
					stringByAppendingPathComponent: currBundlePath]];
				if(pluginBundle) {
					Class principalClass = [pluginBundle principalClass];
					if([principalClass conformsToProtocol: @protocol(DesktopManagerPlugin)]) {
						// The plugin is valid, load it
						id<DesktopManagerPlugin> instance = [[[principalClass alloc] init] autorelease];
						
						if([instance interfaceVersion] != 1) {
							NSLog(@"Error lading '%@', incorrect interface version '%i'",
								currBundlePath, [instance interfaceVersion]);
						}
						
						[instance pluginLoaded: self withBundle: pluginBundle];
						
						// NSLog(@"Loaded plugin: %@", [instance name]);
						[plugins addObject: instance];
					}
				}
			}
		}
	}
}

- (void)awakeFromNib {
    lastSwitch = nil;
        
	// Inject our cunning code into the Dock
	// killDock(); sleep(6);
	injectCode();	
	
	[runApplicationBox setCompletes: YES];
	
    // Register default preferences
    RegisterDefaultPreferences();
			    
    // Create a workspace controller.
    wsController = [WorkspaceController defaultController];
    [wsController setWorkspaceNames: 
        [[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES]
    ];
        
    // Register some hotkey
    HotKeyController *hkController = [HotKeyController defaultController];
    [hkController loadFromDefaults];
    [hkController saveToDefaults];
    [hkController registerHotKeys];
	
	notificationWindow = nil;
     
    // Register our interest in workspace switches
    [[NSNotificationCenter defaultCenter] addObserver: self
        selector: @selector(workspaceSelected:)
        name: NOTIFICATION_WORKSPACEWILLSELECT object: nil
    ];
     
    // Register our interest in couvert
    [[NSNotificationCenter defaultCenter] addObserver: self
        selector: @selector(triggerCouvert)
        name: NOTIFICATION_STARTCOUVERT object: nil
    ];
    
    // Register our interest in Run Application
    [[NSNotificationCenter defaultCenter] addObserver: self
        selector: @selector(runApplication:)
        name: NOTIFICATION_RUNAPPLICATION object: nil
    ];
	
	// Register our interest in an Application becoming active by finding
	// out if the menu bar changes
	[[NSDistributedNotificationCenter defaultCenter] addObserver: self selector: @selector(newApplicationBecameActive:) name: @"com.apple.HIToolbox.menuBarShownNotification" object:nil];
	
	// Become the NSApplication delegate so we can reply
	// to termination signals.
	[NSApp setDelegate: self]; 
	
	// Load the plugins.
	[self loadPlugins];
	
	// Tell the preferences controller to load the preference pane.
	[prefController buildPreferencesToolbar: self];
	
	[StickyWindowController defaultController];
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	if(notificationWindow) {
		[notificationWindow release];
	}
    [wsController release];
	
	[plugins release];
	
    [super dealloc];
}

- (NSArray*) plugins {
	return plugins;
}

- (void)updateNotificationWindow 
{
    if(lastSwitch == nil) { return; }
	if(!notificationWindow) { return; }
    
    NSTimeInterval timeInterval = - [lastSwitch timeIntervalSinceNow];
    float callMeNextAt = 1.0 / 25.0;
	
	float waitTime = [[NSUserDefaults standardUserDefaults] floatForKey: PREF_NOTIFICATION_TIME];
    
    if(timeInterval < waitTime) {
        callMeNextAt = 0.1;
    } else if((timeInterval > waitTime) && (timeInterval < waitTime + 0.5)) {
        [notificationWindow setAlphaValue: 1.0 - 2.0 * (timeInterval - waitTime)];
    } else if(timeInterval > waitTime + 0.5) {
        [notificationWindow orderOut: self];
        [lastSwitch release];
        lastSwitch = nil;
		[notificationWindow autorelease]; 
		notificationWindow = nil;
    }
    
    [NSTimer scheduledTimerWithTimeInterval: callMeNextAt
        target: self 
        selector: @selector(updateNotificationWindow)
        userInfo: nil repeats: NO]; 
}

- (void) showPreferences: (id) sender {
    [prefController showPreferences];
}

- (void) newApplicationBecameActive: (NSNotification *) notification {
       ProcessSerialNumber processSN;
       OSErr retVal;
	   
	   // Only switch if shift is held down.
	   if(!(GetCurrentKeyModifiers() & (1 << 9))) {
		   return;
	   }

       retVal = GetFrontProcess( &processSN );
       if( retVal == noErr ) {
               [[WorkspaceController defaultController] switchToWorkspaceForApplication: processSN];
       } else {
               NSLog(@"New application is made active - error getting front most process serial number: %i", retVal);
       }
}

- (void) nextDesktop: (id) sender {
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_NEXTWORKSPACE
        object: self];
}

- (void) previousDesktop: (id) sender {
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTIFICATION_PREVWORKSPACE
        object: self];
}

- (void) showNotificationWindow {
	if(!notificationWindow) {
		// Create a notification window.
		NSRect rect;
		rect.origin.x = rect.origin.y = 0; rect.size.width = 215; rect.size.height = 215;

		notificationWindow = [[NSWindow alloc] initWithContentRect: rect
			styleMask: ( NSBorderlessWindowMask )
			backing: NSBackingStoreBuffered defer: TRUE];
		[notificationWindow setLevel: 21];
		[notificationWindow setBackgroundColor: [NSColor clearColor]];
		[notificationWindow setOpaque: NO];
		[notificationWindow setIgnoresMouseEvents: YES];
		//[[ForeignWindow windowWithNSWindow: notificationWindow] makeSticky];
		
		NotificationView *notificationView = [[[NotificationView alloc] 
			initWithFrame: rect] autorelease];
		[notificationWindow setContentView: notificationView];
		[notificationWindow setIgnoresMouseEvents: YES];
		
		[notificationView setWorkspaceName: [wsController currentWorkspaceName]];
	}

    NSRect frame = [notificationWindow frame];
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
    frame.origin.x = (int)(0.5 * (screenFrame.size.width - frame.size.height));
    frame.origin.y = (int)(0.5 * ((2.0/3.0) * screenFrame.size.height - frame.size.height));
    [notificationWindow setFrame: frame display: NO];
    
    [notificationWindow setAlphaValue: 1.0];
    [notificationWindow setLevel: kCGUtilityWindowLevel ];
   		
	[notificationWindow orderFrontRegardless];
	[[ForeignWindow windowWithNSWindow:notificationWindow] makeSticky];
	[NSTimer scheduledTimerWithTimeInterval:0.01 target:notificationWindow
		selector:@selector(orderFrontRegardless) userInfo:nil repeats:NO];

    lastSwitch = [[NSDate date] retain];
    
    [self updateNotificationWindow];
}

- (void) workspaceSelected: (NSNotification*) notification {
    // Show the notification Window
    if([[NSUserDefaults standardUserDefaults] boolForKey: PREF_SHOWNOTIFICATION]) {
        [self showNotificationWindow];
    }
}

// NSApplication termination delegate
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
	if([[NSUserDefaults standardUserDefaults] boolForKey: PREF_COLLECT_WINDOWS]) {
		[[WorkspaceController defaultController] collectWindows];
	}
	
	return NSTerminateNow;
}

- (void) allowToQuit: (NSTimer*) timer {
	[NSApp replyToApplicationShouldTerminate: YES];
}

- (void) runApplication: (id) sender {
	[NSApp activateIgnoringOtherApps: YES];
	[runApplicationBox setStringValue: @""];
	[runApplicationWindow center];
	[runApplicationWindow orderFrontRegardless];
	[runApplicationWindow makeKeyWindow];
}

- (void) runApplicationButtonClicked: (id) sender {
	NSString *appName = [runApplicationBox stringValue];
	
	// What should we do?
	
	// A few heuristics for detecting URLS.
	BOOL isURL = NO;
	if(([appName length] >= 7) && [[appName substringToIndex: 7] isEqualToString: @"http://"]) {
		isURL = YES;
	} else if(([appName length] >= 8) && [[appName substringToIndex: 8] isEqualToString: @"https://"]) {
		isURL = YES;
	} else if(([appName length] >= 4) && [[appName substringToIndex: 4] isEqualToString: @"www."]) {
		isURL = YES;
	} else if([appName rangeOfString: @".com"].length > 0) {
		isURL = YES;
	} else if([appName rangeOfString: @".org"].length > 0) {
		isURL = YES;
	} else if([appName rangeOfString: @".net"].length > 0) {
		isURL = YES;
	} else if([appName rangeOfString: @".co."].length > 0) {
		isURL = YES;
	}
	
	BOOL result = NO;
	if(isURL) {
		result = [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: appName]];
		if(!result) {
			// try pre-pending http://
			result = [[NSWorkspace sharedWorkspace] openURL: [NSURL URLWithString: 
				[NSString stringWithFormat: @"http://%@", appName]]];
		}
	} 
	
	if(!isURL || !result) {
		result = [[NSWorkspace sharedWorkspace] launchApplication: appName ];
	}
	
	[runApplicationBox setStringValue: @""];
	if(result) {
		if([runApplicationBox indexOfItemWithObjectValue: appName] == NSNotFound) {
			[runApplicationBox insertItemWithObjectValue: appName atIndex: 0];
		}
		[runApplicationWindow orderOut: self];
	} else {
		NSBundle *mainBundle = [NSBundle mainBundle];
		NSString *errStr = @"Error finding localised string";
		
		NSString *messageText = [mainBundle localizedStringForKey: @"RunApplicationMessage"
			value: errStr table: nil];
		NSString *defaultText = [mainBundle localizedStringForKey: @"RunApplicationDefault"
			value: errStr table: nil];
		NSString *informText  = [mainBundle localizedStringForKey: @"RunApplicationInfo"
			value: errStr table: nil];
		NSAlert *alert = [NSAlert alertWithMessageText: messageText defaultButton: defaultText
			alternateButton: nil otherButton: nil 
			informativeTextWithFormat: informText, appName ];
		[alert runModal];
	}
}

- (void) triggerCouvert {
	WorkspaceController *workspaceController = [WorkspaceController defaultController];
	int wsNum = [workspaceController currentWorkspaceIndex];
	wsNum ++;
	if(wsNum >= [workspaceController workspaceCount]) { wsNum = 0; }

	startCouvert();
	sleep(4);
	[[workspaceController workspaceAtIndex:wsNum] select];
	endCouvert();
}

@end
