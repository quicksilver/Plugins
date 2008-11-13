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

#import "NotificationView.h"
#import "DesktopManager.h"

@implementation NotificationView

const float kRoundedRadius = 25;

- (id)initWithFrame:(NSRect)frameRect
{
	[super initWithFrame:frameRect];
        
	[self setWorkspaceName: @""];
	
	// Register our interest in workspace change notifications
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(workspaceWillSelect:)
		name: NOTIFICATION_WORKSPACEWILLSELECT
		object: nil
	];
	
	[[NSNotificationCenter defaultCenter] addObserver: self
		selector: @selector(workspaceSelected:)
		name: NOTIFICATION_WORKSPACESELECTED
		object: nil
	];
        
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];

	[super dealloc];
}

- (void) workspaceWillSelect: (NSNotification*) notification {
    [self setWorkspaceName: @"..."];
	[self display];
}

- (void) workspaceSelected: (NSNotification*) notification {
    NSString *name = [(Workspace*)[notification object] workspaceName];
        
    [self setWorkspaceName: name];
	[self display];
}

- (void) setWorkspaceName: (NSString*) name 
{
    if(workspaceName != nil) { [workspaceName release]; }
    workspaceName = [[NSString stringWithString: name] retain];
    [self setNeedsDisplay: YES];
}

- (NSString*) workspaceName
{
    return workspaceName;
}

extern void *CGSReadObjectFromCString(char*);
extern char *CGSUniqueCString(char*);
extern void *CGSSetGStateAttribute(void*,char*,void*);
extern void *CGSReleaseGenericObj(void*);

- (void)drawRect:(NSRect)rect
{
    NSSize size = [self bounds].size;
    CGRect pageRect;
    CGContextRef context = 
        (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
 
    pageRect = CGRectMake(0, 0, rect.size.width, rect.size.height);

    CGContextBeginPage(context, &pageRect);

    //  Start with black translucent fill
    CGContextSetRGBFillColor(context, 0.2, 0.2, 0.2, 0.2);

    // Draw rounded rectangle.
    CGContextBeginPath(context);
    CGContextMoveToPoint(context,0,kRoundedRadius);
    CGContextAddArcToPoint(context, 0,0, kRoundedRadius,0, kRoundedRadius);
    CGContextAddLineToPoint(context, size.width - kRoundedRadius, 0);
    CGContextAddArcToPoint(context, size.width,0, 
        size.width,kRoundedRadius, kRoundedRadius);
    CGContextAddLineToPoint(context, size.width , size.height - kRoundedRadius);
    CGContextAddArcToPoint(context, size.width,size.height, 
        size.width - kRoundedRadius,size.height, kRoundedRadius);
    CGContextAddLineToPoint(context, kRoundedRadius,size.height);
    CGContextAddArcToPoint(context, 0,size.height, 
        0,size.height-kRoundedRadius, kRoundedRadius);
    CGContextClosePath(context);
    CGContextFillPath(context);
    
    // Setup shadow magic. This shadow magic uses undocumented
    // APIs from the web. This should be checked with each release
    // of OS X to make sure we still work. Many people don't hold
    // with all this hacky stuff. OTOH this entire app is a nice
    // GUI written round a hack.
    void *graphicsPort, *shadowValues;
    [NSGraphicsContext saveGraphicsState];
    NSString *shadowValuesString = [NSString stringWithFormat: 
        @"{ Style = Shadow; Height = %d; Radius = %d; Azimuth = %d; Ka = %f; }",
        1, 3, 90, 0.0];
    shadowValues = CGSReadObjectFromCString((char*) [shadowValuesString cString]);
    graphicsPort = [[NSGraphicsContext currentContext] graphicsPort];
    CGSSetGStateAttribute(graphicsPort, CGSUniqueCString("Style"), shadowValues);
    
    // Draw icon image
    NSImage *image = [NSImage imageNamed: @"screenicon"];
    NSPoint point;
    point.x = (size.width - [image size].width) / 2.0;
    point.y = 0.6 * size.height - [image size].height / 2.0;
    [image compositeToPoint: point operation: NSCompositeSourceOver];
    

    // Print workspace name
    int fontSize = 16;
    NSPoint textPoint;
    NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSColor whiteColor], NSForegroundColorAttributeName,
        [NSFont boldSystemFontOfSize: fontSize], NSFontAttributeName,
        nil];
    
    NSSize textSize = [workspaceName sizeWithAttributes: attr];
    textPoint.x = 0.5 * (size.width - textSize.width);
    textPoint.y = 0.5 * (point.y - textSize.height);
    [workspaceName drawAtPoint: textPoint withAttributes: attr];

    // Undo shadow magic
    [NSGraphicsContext restoreGraphicsState];
    CGSReleaseGenericObj(shadowValues);

    CGContextEndPage(context);

    CGContextFlush(context);
}

@end
