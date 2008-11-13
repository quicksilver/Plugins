//
//  QSImageAdjustController.m
//  QSImageManipulationPlugIn
//
//  Created by Nicholas Jitkoff on 8/8/06.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "QSImageAdjustController.h"


@implementation QSImageAdjustController
- (id) init {
	self = [super initWithWindowNibName:@"QSImageAdjustWindow"];
	if (self != nil) {
	}
	return self;
}

- (void)awakeFromNib{
	[imageView setImageWithURL:[NSURL fileURLWithPath:[@"~/Desktop/Picture 1.png" stringByStandardizingPath]]];
    [imageView setDoubleClickOpensImageEditPanel: YES];
    [imageView setCurrentToolMode: IKToolModeMove];
    [imageView zoomImageToFit: self];
    [imageView setDelegate: self];

}

@end
