//
//  QSFerdinandView.m
//  QSFlashlightInterface
//
//  Created by Nicholas Jitkoff on 7/7/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "QSFerdinandView.h"
#import <QSFoundation/QSFoundation.h>


@implementation QSFerdinandView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		background=nil;
		[self getSystemColor];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getSystemColor) name:NSControlTintDidChangeNotification object:NSApp];
		
	}
	return self;
}
- (void)getSystemColor{
	[background release];
	   // Initialization code here.
	if ([NSColor currentControlTint] == NSGraphiteControlTint) 
		background=[QSResourceManager imageNamed:@"SpotlightGraphiteBackground"];
	else
		background=[QSResourceManager imageNamed:@"SpotlightBlueBackground"];
	
	if(!background)
		background=[[NSBundle bundleForClass:[self class]]imageNamed:@"BarGradient"];
	[background retain];
	
	
}


- (void)drawRect:(NSRect)rect {
	[background drawInRect:[self frame] fromRect:rectFromSize([background size]) operation:NSCompositeSourceOver fraction:1.0];
	
}

@end
