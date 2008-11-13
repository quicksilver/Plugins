//
//  NSColor_QSModifications.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Fri Mar 19 2004.
//  Copyright (c) 2004 Blacktree, Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDrawerFrame : NSView
@end
@interface NSDrawerFrame (QSMods)
- (id)contentFill;
@end



@interface NSColor (Contrast)
-(NSColor *)colorWithLighting:(float)light;
-(NSColor *)colorWithLighting:(float)light plasticity:(float)plastic;
	-(NSColor *)readableTextColor;	

+ (NSColor *)accentColor;
+ (void)setAccentColor:(NSColor *)color;
@end