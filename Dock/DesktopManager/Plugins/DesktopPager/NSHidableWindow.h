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

// Bits 0-1 - Position: 0 - Left/Top, 1 - Middle, 2 - Right/Bottom
// Bits 2-3 - Edge:     0 - Bottom, 1 - Left, 2 - Right
typedef enum {
	BottomLeft		= 0x0,
	BottomMiddle	= 0x1,
	BottomRight		= 0x2,
	LeftTop			= 0x4,
	LeftMiddle		= 0x5,
	LeftBottom		= 0x6,
	RightTop		= 0x8,
	RightMiddle		= 0x9,
	RightBottom		= 0xa,
} NSHidableWindowLocation;

@interface NSHidableWindow : NSWindow {
	BOOL _autoHides;	
	BOOL _wasAnimating;
	BOOL _hiding;
	NSTimer *_mouseTimer;
	NSHidableWindowLocation _location;
	NSScreen *_screen;
}

- (void) setAutohides: (BOOL) yesOrNo;
- (BOOL) autohides;

- (void) setLocation: (NSHidableWindowLocation) location;
- (NSHidableWindowLocation) location;

- (void) hide;
- (void) show;

@end
