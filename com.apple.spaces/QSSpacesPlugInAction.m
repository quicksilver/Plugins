//
//  QSSpacesPlugInAction.m
//  QSSpacesPlugIn
//
//  Created by Nicholas Jitkoff on 8/30/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSSpacesPlugInAction.h"
//#import "WindowControllerEvents.h"
#import "QXCGSWindow.h"
#import "QXCGSWindowManager.h"
#define kQSWorkspaceType @"qs.workspaceid"
#define kQSWindowIDType @"qs.windowid"

#define kQSWorkspaceSelectAction @"QSWorkspaceSelectAction"
#define kQSMoveWindowToWorkspaceAction @"QSMoveWindowToWorkspaceAction"

@implementation QSSpacesPlugInAction


- (NSArray *) validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	return [QSLib arrayForType:kQSWorkspaceType];
}

- (QSObject *)selectWorkspace:(QSObject *)dObject{
	
	int workspaceID=[[dObject objectForType:kQSWorkspaceType]intValue];
	
	//NSLog(@"switch to: %d",workspaceID);
	CGSConnection cgs = _CGSDefaultConnection();
	
	int currentID;
	CGSGetWorkspace(cgs, &currentID);
	int i;
//	OSStatus err=CGSSetWorkspace(cgs, workspaceID);
//	for(i=currentID;i!=workspaceID;i=(i%4)+1){
//		NSLog(@"%d",i);
//		CGSSetWorkspaceWithTransition(cgs, i+1, CGSCube, CGSLeft, 0.25);
//		usleep(750000);
//	}
//	NSLog(@">%d",workspaceID);
	 OSStatus err = CGSSetWorkspaceWithTransition(cgs, workspaceID, 9, CGSLeft, 0);
	//NSLog(@"switch toerr : %d",err);
	


	return nil;
}
//- (NSAppleEventDescriptor *)windowControlEventWithID:(OSType)eventID{
//	NSAppleEventDescriptor *dockTarget=[NSAppleEventDescriptor targetDescriptorWithTypeSignature:'dock'];
//	return [NSAppleEventDescriptor appleEventWithEventClass:kWindowControllerClass eventID:eventID targetDescriptor:dockTarget returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
//	
//}
- (QSObject *)moveWindow:(QSObject *)dObject toWorkspace:(QSObject *)iObject{
	
	int workspaceID=[[iObject objectForType:kQSWorkspaceType]intValue];
	if (!workspaceID)return nil;
	
	NSEnumerator *e=[dObject enumeratorForType:kQSWindowIDType];
	int windowID;
	while (windowID=[[e nextObject]intValue])
		[self moveWindowID:windowID toWorkspaceID:workspaceID];
	
	[self selectWorkspace:iObject];
	return nil;
}


- (id <QXCGSWindowManager>) remoteWindowManager {
  id proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"RemoteWindowConnection" host:nil];  
  if (proxy) {
		[proxy setProtocolForProxy:@protocol(QXCGSWindowManager)];
  }
  return proxy;  
}

- (id <QXCGSWindow>) remoteWindowWithID:(int)wid {
  return [[self remoteWindowManager] windowWithID:wid];
}



- (void)moveWindowID:(int)windowID toWorkspaceID:(int)workspaceID{
  [[self remoteWindowWithID:windowID] moveToWorkspace:workspaceID];
}

@end
