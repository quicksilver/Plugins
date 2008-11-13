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

#import "WorkspaceNameDisplayPrefs.h"
#import "DesktopWorkspaceNamesController.h"

@implementation WorkspaceNameDisplayPrefs

- (void) positionButtonClicked: (id) sender {
	int index = [_positionButton selectedTag];
	[[NSUserDefaults standardUserDefaults] setBool: (index & 0x1)  
		forKey: PREF_DESKTOPNAME_LEFTCORNER];
	[[NSUserDefaults standardUserDefaults] setBool: (index & 0x2)  
		forKey: PREF_DESKTOPNAME_TOPCORNER];
		
	//NSLog(@"Left:%i, Top:%i",
	//	[[NSUserDefaults standardUserDefaults] boolForKey: PREF_DESKTOPNAME_LEFTCORNER],
	//	[[NSUserDefaults standardUserDefaults] boolForKey: PREF_DESKTOPNAME_TOPCORNER]);
}

- (void) awakeFromNib {
	int index = 0;
	if([[NSUserDefaults standardUserDefaults] boolForKey: PREF_DESKTOPNAME_LEFTCORNER]) {
		index |= 0x1;
	}
	if([[NSUserDefaults standardUserDefaults] boolForKey: PREF_DESKTOPNAME_TOPCORNER]) {
		index |= 0x2;
	}
	[_positionButton selectItemAtIndex: index];
}

@end
