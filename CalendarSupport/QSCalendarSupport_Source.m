//
//  QSCalendarSupport_Source.m
//  QSCalendarSupport
//
//  Created by Brian Donovan on 31/03/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSCalendarSupport_Source.h"
#import <QSCore/QSObject.h>


@implementation QSCalendarSupport_Source
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
	[newObject setObject:@"" forType:QSCalendarSupportType];
	[newObject setPrimaryType:QSCalendarSupportType];
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
    id data=[object objectForType:QSCalendarSupportType];
	[object setIcon:nil];
    return YES;
}
*/
@end
