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

#import "DesktopManager.h"
#import "DesktopPagerCell.h"
#import "DesktopPagerController.h"
	
@implementation DesktopPagerCell

- (id) init {
	id mySelf = [super init];
	if(mySelf) {
		targetHeight = 50;
	}
	return mySelf;
}

- (BOOL) isOpaque {
	return NO;
}

- (NSPoint) cellPointToScreenPoint: (NSPoint) cellPoint cellFrame: (NSRect) frame {
	WorkspaceController *wsController = [DesktopPagerController workspaceController];
	NSRect screenFrame = [wsController overallScreenFrame];
    float xScale = screenFrame.size.width / frame.size.width;
    float yScale = screenFrame.size.height / frame.size.height;
	
	cellPoint.x -= frame.origin.x;
	cellPoint.y -= frame.origin.y;
	cellPoint.x *= xScale;
	cellPoint.y *= yScale;
	cellPoint.x += screenFrame.origin.x;
	cellPoint.y += screenFrame.origin.y;
			
	return cellPoint;
}

- (NSRect) previewRectForScreenRect: (NSRect) screenRect cellFrame: (NSRect) frame {
	WorkspaceController *wsController = [DesktopPagerController workspaceController];
	NSRect screenFrame = [wsController overallScreenFrame];
    float xScale = frame.size.width / screenFrame.size.width;
    float yScale = frame.size.height / screenFrame.size.height;
    float xOff = frame.origin.x - (screenFrame.origin.x * xScale);
    float yOff = frame.origin.y - (screenFrame.origin.y * yScale);
	
	screenRect.origin.x *= xScale;   screenRect.origin.y *= yScale;
	screenRect.size.width *= xScale; screenRect.size.height *= yScale;
	screenRect.origin.x += xOff;     screenRect.origin.y += yOff;

	return screenRect;
}

- (void) drawWithFrame: (NSRect) frame inView: (NSView*) controlView {
	Workspace *associatedWorkspace = (Workspace*) [self representedObject];
	NSRectEdge mySides[] = {NSMaxYEdge, NSMaxXEdge, NSMinYEdge, NSMinXEdge};
	float myGrays[] = {NSDarkGray, NSDarkGray, NSWhite, NSWhite};	
	int edgesCount = 4;
	
    if(associatedWorkspace) {
        [NSGraphicsContext saveGraphicsState];
        NSRectClip(frame);
		
		// Draw preview rects.
        int i;
        NSArray *windowList = [associatedWorkspace windowList];
        if(windowList && [windowList count]) {
            for(i=[windowList count]-1; i>=0; i--) {
                ForeignWindow *window = (ForeignWindow*) [windowList objectAtIndex: i];
				
                NSRect screenRect;
				screenRect = [self previewRectForScreenRect: [window screenRect] cellFrame: frame];

				screenRect = NSDrawTiledRects(screenRect, screenRect, mySides, myGrays, edgesCount);
				if([associatedWorkspace isSelected]) {
					[[NSColor colorWithCalibratedWhite: 0.8 alpha: 1.0] set];
				} else {
					[[NSColor colorWithCalibratedWhite: 0.7 alpha: 1.0] set];
				}
				NSRectFill(screenRect);

				if([[NSUserDefaults standardUserDefaults] boolForKey:PREF_DESKTOPPAGER_ICONS]) {
					NSImage *icon = [window windowIcon];
					if(icon) {
						[NSGraphicsContext saveGraphicsState];
						NSRectClip(screenRect);
						
						NSRect srcRect;
						NSRect iconRect; 
						srcRect.origin.x = srcRect.origin.y = 0;
						srcRect.size = [icon size];

						iconRect.size = [icon size];
						iconRect.origin.y = screenRect.origin.y + (screenRect.size.height - iconRect.size.height)/2;
						iconRect.origin.x = screenRect.origin.x + (screenRect.size.width - iconRect.size.width)/2;
						
						[icon setFlipped: YES];
						[icon drawInRect: iconRect fromRect: srcRect
							operation: NSCompositeSourceOver fraction: 1.0];
							
						[NSGraphicsContext restoreGraphicsState];
					}
				}
            }
        }
        
        [NSGraphicsContext restoreGraphicsState];
		
		if([[NSUserDefaults standardUserDefaults] boolForKey:PREF_DESKTOPPAGER_NAMES]) {
			NSString *name = [associatedWorkspace workspaceName];
			NSShadow *shadow = [[[NSShadow alloc] init] autorelease];
			[shadow setShadowColor: [NSColor blackColor]];
			[shadow setShadowBlurRadius: 1.5];
			[shadow setShadowOffset:NSMakeSize(1,-1)];
			NSMutableParagraphStyle *style = [[[NSMutableParagraphStyle alloc] init] autorelease];
			[style setAlignment: NSCenterTextAlignment];
			//[style setLineBreakMode: NSLineBreakByTruncatingMiddle];
			[style setLineBreakMode: NSLineBreakByWordWrapping];
	
			NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSColor whiteColor], NSForegroundColorAttributeName,
				[NSFont boldSystemFontOfSize:targetHeight / 4.5], NSFontAttributeName,
				shadow, NSShadowAttributeName,
				style, NSParagraphStyleAttributeName,
			nil];
			
			//NSSize textSize = [name sizeWithAttributes: attrs];
			NSRect textRect = frame;
			//textRect.origin.y += 0.5 * (textRect.size.height - textSize.height);
			//textRect.size.height = textSize.height;
			textRect.origin.x += 3; textRect.size.width -= 6;
			textRect.origin.y += 3; textRect.size.height -= 6;
			
			[name drawInRect:textRect withAttributes: attrs];
		}

		if([associatedWorkspace isSelected]) {
			[[NSColor redColor] set];
		} else {
			[[NSColor colorWithCalibratedWhite: 1.0 alpha: 0.5] set];
		}
		NSFrameRectWithWidthUsingOperation(frame, 1.0, NSCompositeSourceOver);
	} else {
		[[NSColor colorWithCalibratedWhite: 0.5 alpha: 0.3] set];
		NSRectFill(frame);
		[[NSColor colorWithCalibratedWhite: 0.7 alpha: 0.5] set];
		NSFrameRect(frame);
	}
}

- (NSSize) cellSize {
	NSSize size, screenSize;
	
	WorkspaceController *wsController = [DesktopPagerController workspaceController];
	screenSize = [wsController overallScreenFrame].size;
	
	size.width = (screenSize.width / screenSize.height) * (float)targetHeight;
	size.height = targetHeight;
	
	return size;
}

- (void) setTargetHeight: (int) height {
	targetHeight = height;
}

- (int) targetHeight {
	return targetHeight;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame
	ofView:(NSView*)controlView untilMouseUp:(BOOL)untilMouseUp {
	
	lastCellFrame = cellFrame;
	dragging = NO;
	
	return [super trackMouse: theEvent inRect: cellFrame
		ofView: controlView untilMouseUp: untilMouseUp];
}


- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView {
	WorkspaceController *wsController = [DesktopPagerController workspaceController];
	Workspace *ws = [self representedObject];
	
	if(!ws) { return NO; }
	
	if(ws && ![ws isSelected]) { [ws selectWithDefaultTransition]; }
	
	startPoint = [self cellPointToScreenPoint: startPoint cellFrame: lastCellFrame];
	draggingWindow = [wsController windowContainingPoint: startPoint];
	
	if(!draggingWindow) { return nil; }
	
	delta.x = [draggingWindow screenRect].origin.x - startPoint.x;
	delta.y = [draggingWindow screenRect].origin.y - startPoint.y;
	[draggingWindow retain];
	dragging = YES;
	
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView*)controlView {
	if(!dragging) { return NO; }
	
	if(!NSPointInRect(currentPoint, lastCellFrame)) {
		// Don't move windows out of the screen but
		// keep tracking...
		return YES;
	}
	
	currentPoint = [self cellPointToScreenPoint: currentPoint cellFrame: lastCellFrame];
	
	NSPoint newPoint;
	newPoint.x = currentPoint.x + delta.x;
	newPoint.y = currentPoint.y + delta.y;
	
	[draggingWindow move: newPoint];
	[[self controlView] setNeedsDisplay: YES];
	
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag {
	dragging = NO;
	
	[draggingWindow release];
}

+ (BOOL)prefersTrackingUntilMouseUp { return YES; }

@end
