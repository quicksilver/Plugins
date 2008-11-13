//
//  QSPlatterInterface.h
//  QSPlatterInterface
//
//  Created by Nicholas Jitkoff on 8/8/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import <QSCore/QSObject.h>
#import <QSInterface/QSResizingInterfaceController.h>

#import <QuartzCore/QuartzCore.h>

@interface QSPlatterInterface : QSInterfaceController{
	NSRect positionC,positionL,positionR,positionO; //Center, left, right, out positions
	LKTextLayer *label;
}

- (void)updateSearchViewsForTarget:(NSView *)aResponder;
@end

@interface QSCIReflectionFilter : CIFilter{
	id inputImage;	
	CIFilter  *flipFilter;
	CIFilter    *blurFilter;
	CIFilter    *opacityFilter;	
	CIFilter    *gradientFilter;
	CIFilter    *blendFilter;	
}
@end
