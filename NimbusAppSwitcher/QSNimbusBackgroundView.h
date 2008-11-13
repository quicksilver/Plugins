//
//  QSNimbusBackgroundView.h
//  QSNimbusSwitcherPlugIn
//
//  Created by Nicholas Jitkoff on 9/17/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <QSInterface/QSBezelBackgroundView.h>


@interface QSNimbusBackgroundView : QSBezelBackgroundView {
	float innerRadius;
	NSColor *innerColor;
}
- (float)innerRadius;
- (void)setInnerRadius:(float)value;
- (NSColor *)innerColor;
- (void)setInnerColor:(NSColor *)value;
@end
