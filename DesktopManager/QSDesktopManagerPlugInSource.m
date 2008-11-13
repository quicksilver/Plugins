//
//  QSDesktopManagerPlugInSource.m
//  QSDesktopManagerPlugIn
//
//  Created by Nicholas Jitkoff on 8/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSDesktopManagerPlugInSource.h"
#import <QSCore/QSObject.h>
#define kQSWorkspaceType @"qs.workspaceid"

@implementation QSDesktopManagerPlugInSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}
- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [[NSBundle bundleForClass:[self class]] imageNamed:@"de.berlios.desktopmanager"];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{

//	NSArray *desktops= (NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)@"DesktopNames",(CFStringRef) @"de.berlios.desktopmanager");
  //  [desktops autorelease];
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	NSDictionary *thisDesktop;
	int i=0;
	for (i=0;;i++){
		thisDesktop=(NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)[NSString stringWithFormat:@"Workspace%dInfo",i+1],(CFStringRef) @"de.berlios.desktopmanager");
		if (!thisDesktop)break;
		NSLog(@"thisDesktop %@",thisDesktop);
		//[desktops autorelease];
		
		newObject=[QSObject objectWithName:[thisDesktop objectForKey:@"name"]];
		[newObject setObject:[NSNumber numberWithInt:i+1] forType:kQSWorkspaceType];
		[newObject setPrimaryType:kQSWorkspaceType];
		[objects addObject:newObject];
		[thisDesktop release];
	}
    return objects;
}
//- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
//	NSArray *desktops= (NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)@"DesktopNames",(CFStringRef) @"net.sf.wsmanager.desktopmanager");
//    [desktops autorelease];
//	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
//    QSObject *newObject;
//	
//	int i=0;
//	for (i=0;i<[desktops count];i++){
//		newObject=[QSObject objectWithName:[desktops objectAtIndex:i]];
//		[newObject setObject:[NSNumber numberWithInt:i+1] forType:kQSWorkspaceType];
//		[newObject setPrimaryType:kQSWorkspaceType];
//		[objects addObject:newObject];
//	}
//    return objects;
//}

- (BOOL)loadChildrenForObject:(QSObject *)object{
	[object setChildren:[self objectsForEntry:nil]];
	return YES;
}

@end
