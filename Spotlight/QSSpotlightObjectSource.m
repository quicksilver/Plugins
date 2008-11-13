//
//  QSSpotlightObjectSource.m
//  QSSpotlightPlugIn
//
//  Created by Nicholas Jitkoff on 3/26/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSSpotlightObjectSource.h"
#import "QSMDFindWrapper.h"
#import <QSCore/QSLibrarian.h>
@implementation QSSpotlightObjectSource
- (id) init {
	self = [super init];
	if (self != nil) {
		pending=[[NSMutableDictionary alloc]init];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(arrayLoaded:) name:@"QSSourceArrayFinished" object:nil];
	}
	return self;
}
- (void) arrayLoaded:(NSNotification *)notif{
	NSArray *array=[notif object];
	
	NSString *key=[[pending allKeysForObject:array]lastObject];
//	NSLog(@"%@ finished %d",key,[array count]);
	//[pending removeObjectForKey:key];
	//[self invalidateSelf];
	[[QSLib entryForID:key]scanForced:YES];
}
- (NSImage *) iconForEntry:(NSDictionary *)theEntry{
	return [QSResourceManager imageNamed:@"Spotlight"];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSArray *array=[pending objectForKey:[theEntry objectForKey:kItemID]];
//	NSLog(@"scan %@ %d items",theEntry, [array count]);
	//NSLog(@"%@");
	if ([array count]){
		return array;
	}else{
		NSString *query=[theEntry objectForKey:@"query"];
		QSMDFindWrapper *wrap=[QSMDFindWrapper findWrapperWithQuery:query path:nil keepalive:NO];
		NSMutableArray *results=[wrap results];
		[wrap performSelectorOnMainThread:@selector(startQuery) withObject:nil waitUntilDone:NO];
		//NSLog(@"started %@",wrap);
		[pending setObject:results forKey:[theEntry objectForKey:kItemID]];
	}
	return nil;
}
- (BOOL)isVisibleSource{
	return YES;
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	return NO;
}

- (NSView *) settingsView{
    if (![super settingsView]){
        [NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self];
	}
    return [super settingsView];
}
@end
