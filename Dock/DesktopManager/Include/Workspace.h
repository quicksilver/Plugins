/* Workspace.h -- Interface for workspace management class */

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
#import <Carbon/Carbon.h>

@interface Workspace : NSObject
{
    int 	workspaceNumber;
    NSString*	name;
    NSMutableArray *foreignWindowList;
	NSMutableDictionary *windowMap;
	NSMutableData *windowList;
}

/* Return currently selected workspace number */
+ (int) currentWorkspace;

/* Allocator */
+ (id) workspaceWithWorkspaceNumber: (int)number;

/* Designated initialiser. 'number' is the OS X workspace number (1 indexed)
 * that this object manages */
- (id) initWithWorkspaceNumber: (int)number;

/* Returns the workspace number this workspace is associated with */
- (int) workspaceNumber;

/* Returns TRUE if this workspace is currently selected */
- (bool) isSelected;

/* Select this workspace */
- (void) select;

/* Select this workspace using the default transition. */
- (void) selectWithDefaultTransition;

/* Select this workspace using transition */
- (void) selectWithTransition: (CGSTransitionType) transition
	option: (CGSTransitionOption) option duration: (float) seconds;

/* Set the name associated with this workspace */
- (void) setWorkspaceName: (NSString*) n;

/* Return the name associated with this workspace */
- (NSString*) workspaceName;

/* Return an array of ForeignWindows representing the workspace contents */
- (NSArray*) windowList;

/* Called by the workspace controller to periodically update the layout cache */
- (void) updateWindowList;

@end