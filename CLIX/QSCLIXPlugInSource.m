//
//  QSCLIXPlugInSource.m
//  QSCLIXPlugIn
//
//  Created by Nicholas Jitkoff on 5/16/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSCLIXPlugInSource.h"
#import <QSCore/QSObject.h>


@implementation QSCLIXPlugInSource
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
	[newObject setObject:@"" forType:QSCLIXPlugInType];
	[newObject setPrimaryType:QSCLIXPlugInType];
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
    id data=[object objectForType:QSCLIXPlugInType];
	[object setIcon:nil];
    return YES;
}
*/
@end
