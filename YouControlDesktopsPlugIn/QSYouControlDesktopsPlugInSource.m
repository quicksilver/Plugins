//
//  QSYouControlDesktopsPlugInSource.m
//  QSYouControlDesktopsPlugIn
//
//  Created by Nicholas Jitkoff on 8/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSYouControlDesktopsPlugInSource.h"
#import <QSCore/QSObject.h>
#define kQSWorkspaceType @"qs.workspaceid"

@implementation QSYouControlDesktopsPlugInSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}
- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [[NSBundle bundleForClass:[self class]] imageNamed:@"com.yousoftware.youcontroldesktops"];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSArray *desktops= (NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)@"Workspaces",(CFStringRef) @"com.yousoftware.desktops");
    [desktops autorelease];
	desktops=[desktops valueForKey:@"name"];
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	int i=0;
	for (i=0;i<[desktops count];i++){
		newObject=[QSObject objectWithName:[desktops objectAtIndex:i]];
		[newObject setObject:[NSNumber numberWithInt:i+1] forType:kQSWorkspaceType];
		[newObject setPrimaryType:kQSWorkspaceType];
		[objects addObject:newObject];
	}
    return objects;
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
	[object setChildren:[self objectsForEntry:nil]];
	return YES;
}

@end
