//
//  QSMouseTriggerDescriptionView.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 9/29/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "QSMouseTriggerDescriptionView.h"


@implementation QSMouseTriggerDescriptionView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    
    NSColor *highlight=[NSColor alternateSelectedControlColor];
	[highlight setStroke];
	[[NSColor blackColor]setFill];
	NSRectFill(rect);
	NSFrameRect(rect);
}


@end
