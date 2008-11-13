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

#import <Foundation/Foundation.h>
#import "NSHidableWindow.h"
#import "../DMPlugins.h"

#define PREF_DESKTOPPAGER_SHOW				@"DesktopPagerShow"
#define PREF_DESKTOPPAGER_HEIGHT			@"DesktopPagerHeight"
#define PREF_DESKTOPPAGER_SKIN				@"DesktopPagerSkin"
#define PREF_DESKTOPPAGER_ROWS				@"DesktopPagerRows"
#define PREF_DESKTOPPAGER_AUTOHIDES			@"DesktopPagerAutohides"
#define PREF_DESKTOPPAGER_ICONS				@"DesktopPagerIcons"
#define PREF_DESKTOPPAGER_NAMES				@"DesktopPagerNames"
#define PREF_DESKTOPPAGER_LOCATION			@"DesktopPagerLocation"
#define PREF_DESKTOPPAGER_SHOW_DEFAULT		@"YES"
#define PREF_DESKTOPPAGER_HEIGHT_DEFAULT	@"40"
#define PREF_DESKTOPPAGER_SKIN_DEFAULT		@"default_skin"
#define PREF_DESKTOPPAGER_ROWS_DEFAULT		@"2"
#define PREF_DESKTOPPAGER_AUTOHIDES_DEFAULT @"NO"
#define PREF_DESKTOPPAGER_ICONS_DEFAULT		@"YES"
#define PREF_DESKTOPPAGER_NAMES_DEFAULT		@"NO"
#define PREF_DESKTOPPAGER_LOCATION_DEFAULT  @"0"

@interface DesktopPagerController : NSObject <DesktopManagerPlugin> {
	NSHidableWindow *pagerWindow;
	NSBundle *myBundle;
	DMController *dmController;
}

+ (WorkspaceController*) workspaceController;

- (void) readPreferences;
- (void) showPager;
- (void) hidePager;
- (void) orderPagerOut;

@end
