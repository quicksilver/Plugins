//
//  QSBasicEventTriggers.m
//  QSEventTriggersPlugIn
//
//  Created by Nicholas Jitkoff on 1/22/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSBasicEventTriggers.h"

#import <QSCore/QSObject.h>
#import <QSCore/QSObject_FileHandling.h>
#import "QSEventTriggerManager.h"
@implementation QSBasicEventTriggers
-(id)init{
	if (self=[super init]){
		NSNotificationCenter *wc=[[NSWorkspace sharedWorkspace]notificationCenter];
		NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
		NSDistributedNotificationCenter *dc=[NSDistributedNotificationCenter defaultCenter];
		
		
		[wc addObserver:self selector:@selector(handleWorkspaceNotification:) name:NSWorkspaceWillSleepNotification object:nil];
		[wc addObserver:self selector:@selector(handleWorkspaceNotification:) name:NSWorkspaceDidWakeNotification object:nil];
		[wc addObserver:self selector:@selector(handleWorkspaceNotification:) name:NSWorkspaceWillPowerOffNotification object:nil];
		[wc addObserver:self selector:@selector(handleWorkspaceNotification:) name:NSWorkspaceSessionDidResignActiveNotification object:nil];
		[wc addObserver:self selector:@selector(handleWorkspaceNotification:) name:NSWorkspaceSessionDidBecomeActiveNotification object:nil];
	
		[wc addObserver:self selector:@selector(handleWorkspaceMountNotification:) name:NSWorkspaceDidMountNotification object:nil];
		[wc addObserver:self selector:@selector(handleWorkspaceMountNotification:) name:NSWorkspaceDidUnmountNotification object:nil];
		[wc addObserver:self selector:@selector(handleWorkspaceMountNotification:) name:NSWorkspaceWillUnmountNotification object:nil];
		
		//[dc addObserver:self selector:@selector(handleScreenSaverNotification:) name:@"com.apple.screensaver.action" object:nil];
		[dc addObserver:self selector:@selector(handleScreenSaverNotification:) name:@"com.apple.screensaver.didstart" object:nil];
		//		[dc addObserver:self selector:@selector(handleScreenSaverNotification:) name:@"com.apple.screensaver.willstop" object:nil];
		[dc addObserver:self selector:@selector(handleScreenSaverNotification:) name:@"com.apple.screensaver.didstop" object:nil];
		
	}
	return self;
}

-(void)handleScreenSaverNotification:(NSNotification *)notif{
	if (VERBOSE)NSLog(@"screensavernotif:%@",notif);
	NSString *name=[notif name];
	if ([name isEqualToString:@"com.apple.screensaver.didstart"]){
		name=@"QSScreensaverStartedEvent";
	}else if ([name isEqualToString:@"com.apple.screensaver.didstop"]){
		name=@"QSScreensaverStoppedEvent";
	} else{
		return;
	}
	[[QSEventTriggerManager sharedInstance]handleTriggerEvent:name withObject:nil];
}


-(void)handleWorkspaceNotification:(NSNotification *)notif{
	NSString *name=[notif name];
	if ([name isEqualToString:NSWorkspaceWillSleepNotification]){
		name=@"QSWorkspaceWillSleepEvent";
	}else if ([name isEqualToString:NSWorkspaceDidWakeNotification]){
		name=@"QSWorkspaceDidWakeEvent";
	}else if ([name isEqualToString:NSWorkspaceWillPowerOffNotification]){
		name=@"QSWorkspaceWillPowerOffEvent";
	}else if ([name isEqualToString:NSWorkspaceSessionDidResignActiveNotification]){
		name=@"QSWorkspaceSessionDidResignActiveEvent";
	}else if ([name isEqualToString:NSWorkspaceSessionDidBecomeActiveNotification]){
		name=@"QSWorkspaceSessionDidBecomeActiveEvent";
	} else{
		return;
	}
	[[QSEventTriggerManager sharedInstance]handleTriggerEvent:name withObject:nil];
}
-(void)handleWorkspaceMountNotification:(NSNotification *)notif{
	NSString *name=[notif name];
	NSString *path=[[notif userInfo]objectForKey:@"NSDevicePath"];
	
	if ([path isEqualToString:@"/Network"])return;
	QSObject *drive=[QSObject fileObjectWithPath:path];

	if ([name isEqualToString:NSWorkspaceDidMountNotification]){
		name=@"QSWorkspaceDidMountEvent";
	}else if ([name isEqualToString:NSWorkspaceWillUnmountNotification]){
		name=@"QSWorkspaceWillUnmountEvent";
	}else if ([name isEqualToString:NSWorkspaceDidUnmountNotification]){
		name=@"QSWorkspaceDidUnmountEvent";
	}else{
		return;
	}

	[[QSEventTriggerManager sharedInstance]handleTriggerEvent:name withObject:drive];

}
@end
