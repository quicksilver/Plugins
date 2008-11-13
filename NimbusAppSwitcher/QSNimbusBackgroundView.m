//
//  QSNimbusBackgroundView.m
//  QSNimbusSwitcherPlugIn
//
//  Created by Nicholas Jitkoff on 9/17/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSNimbusBackgroundView.h"


@implementation QSNimbusBackgroundView
//- (BOOL)isOpaque{return YES;}
- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		innerRadius=128*sqrtf(2.0f);
	[self setGlassStyle:QSGlossUpArc];
		[self setRadius:-1];
    }
    return self;
}
- (float)innerRadius {
    return innerRadius;
}

- (void)setInnerRadius:(float)value {
    if (innerRadius != value) {
        innerRadius = value;
		
		//NSLog(@"radius %f",innerRadius);
		[self setNeedsDisplay:YES];
    }
}


- (void)drawRect:(NSRect)rect {
	
	[NSGraphicsContext saveGraphicsState];
	[super drawRect:rect];
	[NSGraphicsContext restoreGraphicsState];
	
	
	//innerRadius=NSWidth([self bounds])-128*sqrtf(2.0f);
	
	[[self innerColor]set];
//	NSRectFill(rect);
	float inset=(NSWidth([self bounds])-innerRadius)/4;
	inset=inset/2;
	//NSLog(@"inset %f %f %f",inset, NSWidth([self bounds]),innerRadius);
	[[NSBezierPath bezierPathWithOvalInRect:NSInsetRect([self bounds],inset,inset)]fill];
	
	
	[[[self innerColor] colorWithAlphaComponent:[[self innerColor]alphaComponent]*2]set];
	
	[[NSBezierPath bezierPathWithOvalInRect:NSInsetRect([self bounds],inset,inset)]stroke];
}

- (NSColor *)innerColor {
    return [[innerColor retain] autorelease];
}

- (void)setInnerColor:(NSColor *)value {
    if (innerColor != value) {
        [innerColor release];
        innerColor = [value copy];
		[self setNeedsDisplay:YES];
    }
}


@end
