//
//  QSPatchPlugInSource.m
//  QSPatchPlugIn
//
//  Created by Nicholas Jitkoff on 5/16/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import "QSPatchPlugInSource.h"
#import <QSCore/QSObject.h>


@implementation QSPatchPlugInSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}


// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	newObject=[QSObject objectWithName:@"TestObject"];
	[newObject setObject:@"" forType:kQSPatchPlugInType];
	[newObject setPrimaryType:kQSPatchPlugInType];
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
    id data=[object objectForType:kQSPatchPlugInType];
	[object setIcon:nil];
    return YES;
}
*/
@end
