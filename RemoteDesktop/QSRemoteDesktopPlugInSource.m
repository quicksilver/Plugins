//
//  QSRemoteDesktopPlugInSource.m
//  QSRemoteDesktopPlugIn
//
//  Created by Nicholas Jitkoff on 5/19/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSRemoteDesktopPlugInSource.h"
#import <QSCore/QSObject.h>


@implementation QSRemoteDesktopPlugInSource
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
	
	NSArray *computers = [(NSArray *) CFPreferencesCopyValue((CFStringRef) @"ComputerDatabase", (CFStringRef) @"com.apple.RemoteDesktop", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
	
	foreach(computer,computers){
		NSString *uuid=[computer objectForKey:@"uuid"];
		NSString *name=[computer objectForKey:@"name"];
		
		newObject=[QSObject objectWithName:name];
		[newObject setObject:uuid forType:kQSRemoteDesktopPlugInType];
		[newObject setPrimaryType:kQSRemoteDesktopPlugInType];
		[newObject setDetails:[[computer objectForKey:@"preferHostname"]boolValue]?[computer objectForKey:@"hostname"]:[computer objectForKey:@"networkAddress"]];
		
			
		[objects addObject:newObject];
	}
    return objects;
    
}


// Object Handler Methods

- (BOOL)loadChildrenForObject:(QSObject *)object{
	[object setChildren:[self objectsForEntry:nil]];	
}


- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.RemoteDesktop"]]; // An icon that is either already in memory or easy to load
}
/*
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:kQSRemoteDesktopPlugInType];
	[object setIcon:nil];
    return YES;
}
*/
@end
