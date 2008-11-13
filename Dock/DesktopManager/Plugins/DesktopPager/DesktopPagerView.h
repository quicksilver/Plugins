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

#import <AppKit/AppKit.h>
#import "DesktopManager.h"

@interface DesktopPagerView : NSView {
	NSImage *blImage;
	NSImage *brImage;
	NSImage *tlImage;
	NSImage *trImage;
	NSImage *tcImage;
	NSImage *bcImage;
	NSImage *lsImage;
	NSImage *rsImage;
	NSImage *bgImage;
	NSImage *closeImage;
	NSImage *prefImage;
	
	NSButton *closeButton;
	NSButton *prefButton;
	
	NSMatrix *pagerMatrix;
	
	int targetHeight;
	NSString *loadedSkin;
	
	WorkspaceController *defaultController;
}

- (id)initWithFrame:(NSRect)frame controller: (WorkspaceController*) controller;

- (void) readPreferences;
- (BOOL) loadSkin: (NSString*) skinFile;

- (void) setCloseTarget: (id) target;
- (void) setCloseAction: (SEL) action;

- (void) setPrefTarget: (id) target;
- (void) setPrefAction: (SEL) action;

- (void) setTargetHeight: (int) height;
- (int) targetHeight;

@end
