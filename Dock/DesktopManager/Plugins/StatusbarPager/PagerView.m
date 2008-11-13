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

#import "PagerView.h"
#import "PagerCell.h"
#import "DesktopManager.h"
#import "StatusbarController.h"

@implementation PagerView

- (void) syncWithController {
    WorkspaceController *wsController = [StatusbarController defaultController];
    [self renewRows: 1 columns: [wsController workspaceCount]];
    
    [cellArray removeAllObjects];
    int i;
    for(i=0; i<[wsController workspaceCount]; i++) {
        PagerCell *cell = [self cellAtRow: 0 column: i];
        [cellArray insertObject: cell atIndex: i];
        
        [cell setAssociatedWorkspace: [wsController workspaceAtIndex: i]];
        [cell setTarget: [wsController workspaceAtIndex: i]];
        [cell setAction: @selector(selectWithDefaultTransition)];
    }
    
    [self sizeToCells];
    [self setNeedsDisplay];
}

- (id)initWithFrame:(NSRect)frame {
    [super initWithFrame:frame];
    
    if (self) {
        NSSize size;
        size.width = size.height = 0;
        [self setCellSize: size];
        [self setCellBackgroundColor: [NSColor clearColor]];
        [self setBackgroundColor: [NSColor clearColor]];
        [self setCellClass: NSClassFromString(@"PagerCell")];
        size.width = size.height = 0;
        [self setIntercellSpacing: size];
        [self setMode: NSRadioModeMatrix];
        
        [self sizeToCells];
        
        cellArray = [NSMutableArray array];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(setNeedsDisplay)
            name: NOTIFICATION_WORKSPACESELECTED
            object: nil
        ];
        
        [[NSNotificationCenter defaultCenter] addObserver: self
            selector: @selector(setNeedsDisplay)
            name: NOTIFICATION_WINDOWLAYOUTUPDATED
            object: nil
        ];
                    
        [self syncWithController];
    }
    return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	[super dealloc];
}

- (void) sizeToHeight: (float) height {
    NSSize size;
    float aspectRatio;
  
    size.height = height;
    NSRect mainScreenFrame = [[WorkspaceController defaultController] overallScreenFrame];
    aspectRatio = mainScreenFrame.size.width / mainScreenFrame.size.height;
    size.width = (int)(aspectRatio * size.height);

    [self setCellSize: size];
    [self sizeToCells];
}

@end
