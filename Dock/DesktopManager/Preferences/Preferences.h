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

#import <Cocoa/Cocoa.h>
#import "../HotKeys/HotKey.h"

#define PREF_SHOWPAGER          @"StatusBarPager"
#define PREF_SHOWMENU           @"StatusBarMenu"
#define PREF_SHOWMENUONLEFT     @"StatusBarMenuOnLeft"
#define PREF_SHOWNOTIFICATION   @"SwitchNotification"
#define PREF_NOTIFICATION_TIME   @"SwitchNotificationTime"
#define PREF_DESKTOPNAMES       @"DesktopNames"
#define PREF_HOTKEYS            @"HotKeys"
#define PREF_CENTREMOUSEPOINTER            @"CentreMousePointer"

#define PREF_SHOWPAGER_DEFAULT			@"YES"
#define PREF_SHOWMENU_DEFAULT           @"YES"
#define PREF_SHOWMENUONLEFT_DEFAULT     @"NO"
#define PREF_SHOWNOTIFICATION_DEFAULT   @"YES"
#define PREF_NOTIFICATION_TIME_DEFAULT   @"1.0"
#define PREF_CENTREMOUSEPOINTER_DEFAULT @"NO"

#define PREF_DESKTOPSWITCH_TRANSITION   @"DesktopSwitchTransition"
#define PREF_DESKTOPSWITCH_DURATION		@"DesktopSwitchDuration"
#define PREF_DESKTOPSWITCH_TRANSITION_DEFAULT   @"1"
#define PREF_DESKTOPSWITCH_DURATION_DEFAULT		@"0.3"

#define PREF_COLLECT_WINDOWS			@"CollectWindowsOnExit"
#define PREF_COLLECT_WINDOWS_DEFAULT	@"1"

void RegisterDefaultPreferences();
BOOL AreDefaultsRegistered();

