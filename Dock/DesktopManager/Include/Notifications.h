/* Notifications.h -- List of common notifications */

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
 
#define NOTIFICATION_HOTKEYPRESS            @"DesktopManagerHotKeyPressed"
#define NOTIFICATION_WORKSPACEWILLSELECT	@"DesktopManagerWorkspaceWillSelect"
#define NOTIFICATION_WORKSPACESELECTED      @"DesktopManagerWorkspaceSelected"
#define NOTIFICATION_PREFSCHANGED           NSUserDefaultsDidChangeNotification
#define NOTIFICATION_DESKTOPNAMESCHANGED    @"DesktopManagerNamesChanged"
#define NOTIFICATION_WINDOWLAYOUTUPDATED    @"DesktopManagerWindowLayoutUpdated"

#define NOTIFICATION_NEXTWORKSPACE          @"SwitchToNextWorkspace"
#define NOTIFICATION_PREVWORKSPACE          @"SwitchToPrevWorkspace"
#define NOTIFICATION_WARPTONEXTWORKSPACE	@"WarpToNextWorkspace"
#define NOTIFICATION_WARPTOPREVWORKSPACE	@"WarpToPrevWorkspace"
#define NOTIFICATION_SHOWPREFS              @"ShowPreferences"
#define NOTIFICATION_DESKTOP1               @"SwitchToDesktop1"
#define NOTIFICATION_DESKTOP2               @"SwitchToDesktop2"
#define NOTIFICATION_DESKTOP3               @"SwitchToDesktop3"
#define NOTIFICATION_DESKTOP4               @"SwitchToDesktop4"
#define NOTIFICATION_DESKTOP5               @"SwitchToDesktop5"
#define NOTIFICATION_DESKTOP6               @"SwitchToDesktop6"
#define NOTIFICATION_DESKTOP7               @"SwitchToDesktop7"
#define NOTIFICATION_DESKTOP8               @"SwitchToDesktop8"
#define NOTIFICATION_DESKTOP9               @"SwitchToDesktop9"
#define NOTIFICATION_DESKTOP10              @"SwitchToDesktop10"

#define NOTIFICATION_OPERATIONS_MENU        @"ShowOperationsMenu"
#define NOTIFICATION_STARTCOUVERT			@"StartCouvert"
#define NOTIFICATION_RUNAPPLICATION			@"RunApplication"
#define NOTIFICATION_FASTDESKTOP            @"FastDesktopCreate"

#define NOTIFICATION_NEW_WINDOW				@"NewWindow"
#define NOTIFICATION_WINDOW_CLOSED			@"WindowClosed"

#define NOTIFICATION_MOUSEEDGEEVENT			@"MouseEdgeEvent"
