//
//  QSWindowHandlingPlugIn.m
//  QSWindowHandlingPlugIn
//
//  Created by Nicholas Jitkoff on 8/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSWindowHandlingPlugIn.h"
#import "QSWindowHandlingPlugIn_Prefix.pch"
//#import <QSInterface/CGSPrivate.h>
static CGSValue CGSWindowTitle = 0;
NSString *titleForWindowID(int windowid){
  CFStringRef title = nil;
	if(CGSGetWindowProperty(_CGSDefaultConnection(), windowid, CGSWindowTitle, &title)) return nil;
  return (NSString *)title;

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
	CGSWindowTitle = (int)CFStringCreateWithCStringNoCopy(kCFAllocatorDefault, "kCGSWindowTitle", kCFStringEncodingUTF8, kCFAllocatorNull); 
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
