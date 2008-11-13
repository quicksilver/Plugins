//
//  QSExtendedAttributesPlugIn.m
//  QSExtendedAttributesPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSExtendedAttributesPlugIn.h"
#import "NSFileManager+ExtendedAttributes.h"

@implementation QSExtendedAttributesPlugIn

+(void)loadPlugIn{
	NSLog(@"load");	
	QSExtendedAttributes *attr=[[NSFileManager defaultManager]extendedAttributesAtPath:@"/Volumes/Lore/Desktop"];
	
	NSLog(@"attr %@",[attr allNames]);
	NSLog(@"attr %@",[attr valueForKey:@"test"]);
	
[attr setValue:@"hi!" forKey:@"test"];

NSLog(@"attr %@",[attr valueForKey:@"test"]);
NSLog(@"attr %p",[attr valueForKey:@"teest"]);
}
@end
