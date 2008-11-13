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
 
#import "Preferences.h"
#import "DesktopManager.h"

static BOOL _defaultsRegistered = NO;

void RegisterDefaultPreferences() {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSArray *desktopNames = [NSArray arrayWithObjects:
        @"Main Desktop",
        @"Web-browsing",
        @"E-mail",
        @"Work",
		nil
    ];
    
    NSDictionary *appDefaults = [NSDictionary
        dictionaryWithObjectsAndKeys: 
        PREF_SHOWMENU_DEFAULT, PREF_SHOWMENU,
        PREF_SHOWMENUONLEFT_DEFAULT, PREF_SHOWMENUONLEFT,
        PREF_SHOWNOTIFICATION_DEFAULT, PREF_SHOWNOTIFICATION,
        PREF_NOTIFICATION_TIME_DEFAULT, PREF_NOTIFICATION_TIME,
        PREF_SHOWPAGER_DEFAULT, PREF_SHOWPAGER,
        PREF_CENTREMOUSEPOINTER_DEFAULT, PREF_CENTREMOUSEPOINTER,
        PREF_DESKTOPSWITCH_TRANSITION_DEFAULT, PREF_DESKTOPSWITCH_TRANSITION,
        PREF_DESKTOPSWITCH_DURATION_DEFAULT, PREF_DESKTOPSWITCH_DURATION,
        PREF_COLLECT_WINDOWS_DEFAULT, PREF_COLLECT_WINDOWS,
        desktopNames, PREF_DESKTOPNAMES,
        nil
    ];
    
    [defaults registerDefaults: appDefaults];
	[[NSNotificationCenter defaultCenter] 
        postNotificationName: NOTIFICATION_PREFSCHANGED
        object: nil];
	_defaultsRegistered = YES;
}

BOOL AreDefaultsRegistered() {
	return _defaultsRegistered;
}
