//
//  QSProcessObjectView.m
//  QSNimbusSwitcherPlugIn
//
//  Created by Nicholas Jitkoff on 9/17/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSProcessObjectView.h"
#import <QSCore/QSLibrarian.h>

@implementation QSProcessObjectView
- (void)viewDidMoveToWindow{
	[self updateTrackingRect];
}

- (void)setFrame:(NSRect)frame{
	[super setFrame:frame];
	//[self updateTrackingRect];
}
- (void)updateTrackingRect{
	if (trackingRect)[self removeTrackingRect:trackingRect];
	trackingRect=[self addTrackingRect:rectFromSize([self frame].size) owner:self userData:self assumeInside:NO];	
}
- (void)mouseMoved:(NSEvent *)theEvent{
	//	NSLog(@"moved %@",self);
}
- (void)drawRect:(NSRect)rect{
	
	BOOL isFirstResponder=[[self window]firstResponder]==self;
	if (isFirstResponder){
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.3]set];
		[[NSBezierPath bezierPathWithOvalInRect:NSInsetRect([self bounds],3,3)]fill];
		
		[[NSColor whiteColor]set];
	//	NSFrameRect([self bounds]);
		[[NSBezierPath bezierPathWithOvalInRect:NSInsetRect([self bounds],1,1)]stroke];
	}
	[super drawRect:rect];	
}
- (void)rightMouseDown:(NSEvent *)theEvent{
	//NSLog(@"right");
}

- (void)insertTab:(id)sender{
//	NSLog(@"nexttab");
}
///- (void)key

 
- (void)mouseEntered:(NSEvent *)theEvent{
	//	 NSLog(@"enter %@",theEvent);
	// [[self window]makeFirstResponder:[theEvent userData]];
	[[self window]makeFirstResponder:self];
}
- (void)drag:(NSEvent *)theEvent{
	//	 NSLog(@"enter %@",theEvent);
	// [[self window]makeFirstResponder:[theEvent userData]];
	[[self window]makeFirstResponder:self];
}
- (void)mouseExited:(NSEvent *)theEvent{
}
- (void)mouseClicked:(NSEvent *)theEvent{
	QSObject *selectedObject=[self objectValue];
	// [self deactivate:self];	
    [[QSLib actionForIdentifier:@"FileOpenAction"]performOnDirectObject:selectedObject indirectObject:nil];		
}


@end


