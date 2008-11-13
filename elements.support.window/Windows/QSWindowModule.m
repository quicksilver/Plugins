//
//  QSWindowModule.m
//  QSWindowModule
//
//  Created by Nicholas Jitkoff on 8/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSWindowModule.h"

#import "CGSPrivate.h"
static int CGSWindowTitle = 0;
NSString *titleForWindowID(int windowid){
	int titleValue = NULL;
	//if (!CGSWindowTitle)
	
	//CGSWindowTitle = CGSCreateCStringNoCopy(@"kCGSWindowTitle");
	if(CGSGetWindowProperty(_CGSDefaultConnection(),windowid,CGSWindowTitle, &titleValue))return nil;
	char *title = (char *)CGSCStringValue(titleValue);
	if(title) return [NSString stringWithUTF8String: title];
	
	return nil;
}

int pidForWindowID(int windowid){
	int pid = 0;
	CGSConnection winConnection;
	if(!CGSGetWindowOwner(_CGSDefaultConnection(), windowid, &winConnection)){
		if (!CGSConnectionGetPID(winConnection, &pid, winConnection))
			return pid;
	}
	return 0;
}

@implementation QSObject (WindowModule)
+ (void)load{
	CGSWindowTitle = CGSCreateCStringNoCopy("kCGSWindowTitle");
}


+ (QSObject *)windowObjectWithWindowID:(int)wid{
		if(!CGSGetWindowLevel(_CGSDefaultConnection(), wid, NULL))return nil;

	QSObject *object;
	int workspace;
	CGSGetWindowWorkspace(_CGSDefaultConnection(), wid, &workspace);
				
	NSString *title=titleForWindowID(wid);
	if (workspace && [title length]){
		object=[QSObject objectWithName:[NSString stringWithFormat:@"%@ Window",title]];
		[object setObject:[NSNumber numberWithInt:wid] forType:QSWindowIDType];
		[object setPrimaryType:QSWindowIDType];
			//NSLog(@"wid %@",object);
		return object;
	}
	return nil;
}
@end
