//
//  QSSpacesPlugInSource.m
//  QSSpacesPlugIn
//
//  Created by Nicholas Jitkoff on 8/30/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSSpacesPlugInSource.h"
#define kQSWorkspaceType @"qs.workspaceid"
@implementation QSSpacesPlugInSource

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
    return NO;
}

- (NSImage *)iconForEntry:(NSDictionary *)dict {
    return [[NSBundle bundleForClass:[self class]] imageNamed:@"com.apple.spaceslauncher"];
}
- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
  
  
  
  NSNumber *cols = (NSNumber *)[CFPreferencesCopyAppValue((CFStringRef)@"workspaces-cols", (CFStringRef) @"com.apple.dock") autorelease];
  NSNumber *rows = (NSNumber *)[CFPreferencesCopyAppValue((CFStringRef)@"workspaces-rows", (CFStringRef) @"com.apple.dock") autorelease];
  NSArray *spaces = (NSArray *)[CFPreferencesCopyAppValue((CFStringRef)@"spaces", (CFStringRef) @"com.thecocoabots.Hyperspaces") autorelease];
  
  
  
  int spacesCount = [cols intValue] * [rows intValue];
  //NSArray *desktops = (NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)@"DesktopNames", (CFStringRef) @"com.apple.dock.plist");
  //  [desktops autorelease];
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	int i = 0;
	for (i = 0; i < spacesCount; i++) {
	//	thisDesktop = (NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)[NSString stringWithFormat:@"Workspace%dInfo", i+1] , (CFStringRef) @"de.berlios.desktopmanager");
	//	if (!thisDesktop) break;
		//[desktops autorelease];
    NSDictionary *thisDesktop = [spaces objectAtIndex:i];
		
		newObject = [QSObject objectWithName:[NSString stringWithFormat:@"Space %d", i+1]];
    
    [newObject setLabel:[thisDesktop objectForKey:@"name"]];
		[newObject setObject:[NSNumber numberWithInt:i+1] forType:kQSWorkspaceType];
		[newObject setPrimaryType:kQSWorkspaceType];
		[objects addObject:newObject];
	//	[thisDesktop release];
	}
    return objects;
}
//- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
//	NSArray *desktops = (NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)@"DesktopNames", (CFStringRef) @"net.sf.wsmanager.desktopmanager");
//    [desktops autorelease];
//	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
//    QSObject *newObject;
//	
//	int i = 0;
//	for (i = 0; i<[desktops count]; i++) {
//		newObject = [QSObject objectWithName:[desktops objectAtIndex:i]];
//		[newObject setObject:[NSNumber numberWithInt:i+1] forType:kQSWorkspaceType];
//		[newObject setPrimaryType:kQSWorkspaceType];
//		[objects addObject:newObject];
//	}
//    return objects;
//}

















- (NSString *)identifierForObject:(id <QSObject>)object {
    return [NSString stringWithFormat:@"%@", [object objectForType:kQSWorkspaceType]];
}



// Object Handler Methods



- (BOOL)loadChildrenForObject:(QSObject *)object {
	if ([[object primaryType] isEqualToString:kQSWorkspaceType]) {
		int workspaceID = [[object objectForType:kQSWorkspaceType] intValue];
		
		NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
		QSObject *newObject;
		
		CGSConnection cgs = _CGSDefaultConnection();
		int count = 0;
		
		//windowList = [[NSMutableData dataWithCapacity: windowCount * sizeof(int)] retain];
		
		CGSGetWorkspaceWindowCount(cgs, workspaceID, &count);
		
		CGSWindow windows[count];
		if (!CGSGetWorkspaceWindowList(cgs, workspaceID, count, &windows, &count) ) {
			int i;
			for(i = 0; i<count; i++) {
				newObject = [QSObject windowObjectWithWindowID:windows[i]];
				if (newObject) [objects addObject:newObject];
			}
			[object setChildren:objects];
			return YES;
			
		}
    return NO;
		
		
		
	}

	[object setChildren:[self objectsForEntry:nil]];
	return YES;

}


- (NSString *)detailsOfObject:(QSObject *)object {
	return @""; //[NSString stringWithFormat:@"Space %@", [object objectForType:kQSWorkspaceType]];
}

- (void)setQuickIconForObject:(QSObject *)object {
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.spaceslauncher"]]; // An icon that is either already in memory or easy to load
}

/*
 - (BOOL)loadIconForObject:(QSObject *)object {
	 return NO;
	 id data = [object objectForType:QSDesktopManagerModuleType];
	 [object setIcon:nil];
	 return YES;
 }
 */
@end
