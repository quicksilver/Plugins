//
//  QSUIAccessPlugIn.m
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSUIAccessPlugIn.h"

#import <ApplicationServices/ApplicationServices.h>


@implementation QSUIAccessPlugIn

+ (void)loadPlugIn{
	AXUIElementRef app=AXUIElementCreateApplication (8423);
	NSLog(@"MO",app);


	CFIndex count=-1;
	NSArray *children=nil;
	AXUIElementGetAttributeValueCount(app, kAXChildrenAttribute, &count);

	AXUIElementCopyAttributeValues(app, kAXChildrenAttribute, 0, count, &children);

	NSLog(@"children %d %@",count,children);

}
@end
