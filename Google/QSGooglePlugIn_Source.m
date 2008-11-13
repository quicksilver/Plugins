//
//  QSGooglePlugIn_Source.m
//  QSGooglePlugIn
//
//  Created by Nicholas Jitkoff on 1/1/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSGooglePlugIn_Source.h"
#import <QSCore/QSObject.h>


@implementation QSGooglePlugIn_Source
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
	[newObject setObject:@"" forType:QSGooglePlugInType];
	[newObject setPrimaryType:QSGooglePlugInType];
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
    id data=[object objectForType:QSGooglePlugInType];
	[object setIcon:nil];
    return YES;
}
*/
@end
