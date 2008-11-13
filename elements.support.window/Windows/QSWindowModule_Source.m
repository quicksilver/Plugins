//
//  QSWindowModule_Source.m
//  QSWindowModule
//
//  Created by Nicholas Jitkoff on 8/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSWindowModule_Source.h"
#import <QSCore/QSObject.h>
#import <QSFoundation/NSGeometry_BLTRExtensions.h>

#import "CGSPrivate.h"
#define kCGSNullConnectionID (CGSConnection)0
// GNU!



@implementation QSWindowObjectSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}
- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [[NSBundle bundleForClass:[self class]] imageNamed:@"Window"];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	CGSConnection cgs = _CGSDefaultConnection();
	int count=0;
	
		extern OSStatus CGSGetOnScreenWindowList(const CGSConnection cid, CGSConnection targetCID, 
												 int count, int* list, int* outCount);
	
	
	CGSWindow windows[count];
	if(!CGSGetOnScreenWindowList(cgs,NULL, count, &windows, &count)){
		int i;
		for(i=0;i<count;i++){
			newObject=[QSObject windowObjectWithWindowID:windows[i]];
			if (newObject)[objects addObject:newObject];
			NSLog(@"new %@",newObject);
		}
	}
	
	
	
	
	return objects;
}
@end
