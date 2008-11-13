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
#import "DesktopManager.h"

#define PREF_DESKTOPNAME_LEFTCORNER @"DesktopNameDisplayLeftCorner"
#define PREF_DESKTOPNAME_TOPCORNER @"DesktopNameDisplayTopCorner"
#define PREF_DESKTOPNAME_SHOW @"DesktopNameDisplayShow"
#define PREF_DESKTOPNAME_ALPHA @"DesktopNameDisplayAlpha"
#define PREF_DESKTOPNAME_LEFTCORNER_DEFAULT @"NO"
#define PREF_DESKTOPNAME_TOPCORNER_DEFAULT @"NO"
#define PREF_DESKTOPNAME_SHOW_DEFAULT @"YES"
#define PREF_DESKTOPNAME_ALPHA_DEFAULT @"0.80"

@interface DesktopWorkspaceNamesController : NSObject <DesktopManagerPlugin> {
	NSWindow *_displayWindow;
	NSView *_nameView;
	WorkspaceController *_wsController;
	NSBundle *myBundle;
}

@end
