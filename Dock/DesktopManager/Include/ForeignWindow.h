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
#import "Workspace.h"
#import "CGSPrivate.h"

void startCouvert();
void endCouvert();

@interface ForeignWindow : NSObject {
    CGSWindow wid;
	NSString *ownerName;
}

+ (id) windowWithWindowNumber: (CGSWindow) wId;
+ (id) windowWithNSWindow: (NSWindow*) window;

+ (bool) windowNumberValid: (CGSWindow) wId;

- (id) initWithWindowNumber: (CGSWindow) wId;
- (id) initWithNSWindow: (NSWindow*) window;

- (NSRect) screenRect;
- (int) level;
- (NSString*) title;
- (int) workspaceNumber;
- (CGSWindow) windowNumber;
- (ForeignWindow*) movementParent;
- (void) fade;
- (void) unFade;
- (void) move: (NSPoint) to;
- (void) orderOut;
- (void) orderFront;
- (void) orderAbove: (int) aboveWin;
- (void) moveToWorkspace: (Workspace*) ws;
- (NSString*) ownerName;
- (pid_t) ownerPid;
- (ProcessSerialNumber) ownerPSN;
- (void) focusOwner;
- (NSImage*) windowIcon;
- (void) makeSticky;
- (void) makeUnSticky;
- (int) tags;
- (uint32_t) eventMask;
- (void) setEventMask: (uint32_t) mask;

@end
