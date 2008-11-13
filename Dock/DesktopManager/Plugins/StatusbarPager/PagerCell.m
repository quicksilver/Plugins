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

#import "PagerCell.h"
#import "DesktopManager.h"

@implementation PagerCell

- (id) init {
    if([super init]) {
        associatedWorkspace = nil;
    }
    
    return self;
}

- (void) dealloc {
	if(associatedWorkspace) { [associatedWorkspace release]; }
	[super dealloc];
}

- (void) drawWithFrame: (NSRect) frame inView: (NSView*) controlView {
    frame.origin.x += 2;
    frame.origin.y += 2;
    frame.size.width -= 4;
    frame.size.height -= 5;
    
    [NSGraphicsContext saveGraphicsState];

    [[NSGraphicsContext currentContext] setShouldAntialias: NO];
    
    NSRect screenFrame = [[WorkspaceController defaultController] overallScreenFrame];
    float xScale = frame.size.width / screenFrame.size.width;
    float yScale = frame.size.height / screenFrame.size.height;
    float xOff = frame.origin.x - (screenFrame.origin.x * xScale);
    float yOff = frame.origin.y - (screenFrame.origin.y * yScale);
    
    if(associatedWorkspace) {
        [NSGraphicsContext saveGraphicsState];
        NSRectClip(frame);
        if([associatedWorkspace isSelected]) {
            [[NSColor selectedControlColor] set];
        } else {
            [[NSColor controlColor] set];
        }
        NSRectFill(frame);
 
        // Draw preview rects.
        int i;
        NSArray *windowList = [associatedWorkspace windowList];
        if(windowList && [windowList count]) {
            for(i=[windowList count]-1; i>=0; i--) {
                ForeignWindow *window = (ForeignWindow*) [windowList objectAtIndex: i];
                
				/*
				NSLog(@"Window workspace: %i (%i), title: %@", [window workspaceNumber],
					[[WorkspaceController defaultController] workspaceIndexForNumber: [window workspaceNumber]],
					[window title]);
				*/
				
                NSRect screenRect = [window screenRect];
                screenRect.origin.x *= xScale;   screenRect.origin.y *= yScale;
                screenRect.size.width *= xScale; screenRect.size.height *= yScale;
                screenRect.origin.x += xOff;     screenRect.origin.y += yOff;
            
                if([associatedWorkspace isSelected]) {
                    [[NSColor controlBackgroundColor] set];
                } else {
                    [[NSColor controlHighlightColor] set];
                }
                NSRectFill(NSIntegralRect(screenRect));
                [[NSColor blackColor] set];
                NSFrameRect(NSIntegralRect(screenRect));
            }
        }
        
        [NSGraphicsContext restoreGraphicsState];
        
        frame.origin.x -= 1; frame.origin.y -= 1;
        frame.size.width += 2; frame.size.height += 2;
        
        if([associatedWorkspace isSelected]) {
            NSSetFocusRingStyle(NSFocusRingOnly);
            NSRectFill(frame);
        }
    }

    [NSGraphicsContext restoreGraphicsState];

    [[NSColor blackColor] set];
    NSFrameRect(frame);
}

- (void) setAssociatedWorkspace: (Workspace*) workspace {
	if(associatedWorkspace) { [associatedWorkspace release]; }
    associatedWorkspace = [workspace retain];
}

- (Workspace*) associatedWorkspace {
    return associatedWorkspace;
}

@end
