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

#import "OperationsMenuView.h"

@implementation OperationsMenuView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        associatedWindow = nil;
	}
    return self;
}

- (void) dealloc {
	if(associatedWindow) { [associatedWindow release ]; }
	
	[super dealloc];
}

- (void) setAssociatedWindow: (ForeignWindow*) window {
	if(associatedWindow) { [associatedWindow release]; }
	
	associatedWindow = [window retain];
}

- (ForeignWindow*) associatedWindow { return associatedWindow; }

- (void) drawRect:(NSRect)rect {
	NSRect windowRect;
	if(!associatedWindow) { return; }

	[[NSColor colorWithCalibratedWhite: 0.2 alpha: 0.5] set];
	NSRectFill([self bounds]);

    windowRect = [associatedWindow screenRect];
	// Need to flip windowRect.
	windowRect.origin.y = [self frame].size.height - windowRect.origin.y;
	windowRect.origin.y -= windowRect.size.height;
	
	NSColor *rectColor = [NSColor selectedControlColor];
	[[rectColor colorWithAlphaComponent: 0.5] set];
	NSRectFill(windowRect);
	
	NSString *title = [associatedWindow title];
	
	// Draw window title
    int fontSize = 16;
    NSPoint textPoint;
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSColor whiteColor], NSForegroundColorAttributeName,
        [NSFont boldSystemFontOfSize: fontSize], NSFontAttributeName,
        nil];
    
    NSSize textSize = [title sizeWithAttributes: attr];
    textPoint.x = windowRect.origin.x + 0.5 * (windowRect.size.width - textSize.width);
    textPoint.y = windowRect.origin.y + windowRect.size.height - 2.0*textSize.height;
	
	NSRect backRect;
	backRect.origin = textPoint; backRect.size = textSize;
	backRect.origin.x -= 5; backRect.origin.y -= 5;
	backRect.size.width += 10; backRect.size.height += 10;
	[[NSColor colorWithCalibratedWhite: 0.3 alpha: 0.75] set];
	NSRectFill(backRect);
	
    [title drawAtPoint: textPoint withAttributes: attr];
}

@end
