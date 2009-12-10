//
//  QSRemoteDesktopPlugInAction.m
//  QSRemoteDesktopPlugIn
//
//  Created by Nicholas Jitkoff on 5/19/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import <QSCore/QSLibrarian.h>
#import "QSRemoteDesktopPlugInAction.h"
#import "QSRemoteDesktopDefines.h"



@implementation QSRemoteDesktopPlugInAction

#define kQSRemoteDesktopPlugInAction @"QSRemoteDesktopPlugInAction"
- (NSAppleScript *)script{
	NSString *scriptPath=[[NSBundle bundleForClass:[self class]]pathForResource:@"RemoteDesktop" ofType:@"scpt"];
	if (!scriptPath)return nil;
	NSAppleScript *script=[[NSAppleScript alloc]initWithContentsOfURL:[NSURL fileURLWithPath:scriptPath] error:nil];
	return script;
}
- (void)launchRDIfNeeded{
	if(!QSAppIsRunning(@"com.apple.RemoteDesktop")){
		
		[[NSWorkspace sharedWorkspace]launchAppWithBundleIdentifier:@"com.apple.RemoteDesktop"
															options:0
									 additionalEventParamDescriptor:nil
												   launchIdentifier:nil];
		sleep(5);
	}
}
- (QSObject *)copyFiles:(QSObject *)dObject toComputer:(QSObject *)iObject{
	NSString *uuid=[iObject objectForType:kQSRemoteDesktopPlugInType];
	[self launchRDIfNeeded];
	NSArray *filenames=[dObject validPaths];
	NSAppleEventDescriptor *aliases=[NSAppleEventDescriptor aliasListDescriptorWithArray:filenames];
	NSAppleEventDescriptor *ident=[[self script] executeSubroutine:@"copy_to_computer" arguments:[NSArray arrayWithObjects:uuid,aliases,nil] error:nil];
	return nil;
}

- (QSObject *)controlComputer:(QSObject *)dObject{
	NSString *uuid=[dObject objectForType:kQSRemoteDesktopPlugInType];
	[self launchRDIfNeeded];
	NSAppleEventDescriptor *ident=[[self script] executeSubroutine:@"control_computer" arguments:[NSArray arrayWithObjects:uuid,nil] error:nil];
	return nil;
}

- (QSObject *)observeComputer:(QSObject *)dObject{
	NSString *uuid=[dObject objectForType:kQSRemoteDesktopPlugInType];
	[self launchRDIfNeeded];
	NSAppleEventDescriptor *ident=[[self script] executeSubroutine:@"observe_computer" arguments:[NSArray arrayWithObjects:uuid,nil] error:nil];
	return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	return [QSLib arrayForType:kQSRemoteDesktopPlugInType];
}


@end
