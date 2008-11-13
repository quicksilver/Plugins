/* WorkspaceController.h -- Interface for Workspace list manager class */

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

#import "Workspace.h"
#import "ForeignWindow.h"
#import "../Preferences/PreferencesController.h"

@interface WorkspaceController : NSObject {
    NSMutableArray *workspaceList;
}

+ (WorkspaceController*) defaultController;

+ (id) controllerWithWorkspaceNames: (NSArray*) names;
- (id) initWithWorkspaceNames: (NSArray*) names;

+ (int) transitionNumber;

- (NSString*) currentWorkspaceName;
- (NSArray*) workspaceNames;
- (void) selectWorkspace: (int) workspace;
- (void) selectNextWorkspace;
- (void) selectPreviousWorkspace;
- (int) workspaceCount;
- (void) switchToWorkspaceForApplication: (ProcessSerialNumber) frontPSN;
- (Workspace*) workspaceAtIndex: (int) index;
- (void) setWorkspaceNames: (NSArray*) names;
- (int) workspaceIndexForNumber: (int) num;
- (Workspace*) workspaceForNumber: (int) num;
- (Workspace*) currentWorkspace;
- (int) currentWorkspaceIndex;
- (NSArray*) workspaceNames;
- (ForeignWindow*) windowContainingPoint: (NSPoint) screenPoint;
- (ForeignWindow*) windowUnderPointer;
- (void) collectWindows;

// Return a NSRect that is the union of all the screenRects of attached screens.
- (NSRect) overallScreenFrame;
- (NSRect) overallVisibleScreenFrame;

@end
