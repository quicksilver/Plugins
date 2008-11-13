//
//  QSSlideshowPlugInAction.h
//  QSSlideshowPlugIn
//
//  Created by Nicholas Jitkoff on 5/13/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>
#import "QSSlideshowPlugInAction.h"
#define QSSlideshowPlugInType @"QSSlideshowPlugIn_Type"
@interface QSSlideshowPlugInAction : QSActionProvider
{
	NSArray *images;
}
- (NSArray *)images;
- (void)setImages:(NSArray *)anImages;
- (void)runSlideshowForObjects:(NSArray *)objects;
@end

