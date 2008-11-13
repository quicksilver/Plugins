//
//  QSSpotlightPlugIn_Source.m
//  QSSpotlightPlugIn
//
//  Created by Nicholas Jitkoff on 10/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSpotlightPlugIn_Source.h"
#import <QSCore/QSObject.h>


@implementation QSSpotlightPlugIn_Source
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	newObject=[QSObject objectWithName:@"TestObject"];
	[newObject setObject:@"" forType:QSSpotlightPlugInType];
	[newObject setPrimaryType:QSSpotlightPlugInType];
	[objects addObject:newObject];
  
    return objects;
    
}


// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:nil]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:QSSpotlightPlugInType];
	[object setIcon:nil];
    return YES;
}
*/
@end
