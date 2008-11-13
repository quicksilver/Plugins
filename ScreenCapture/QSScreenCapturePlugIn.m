//
//  QSScreenCapturePlugIn.m
//  QSScreenCapturePlugIn
//
//  Created by Nicholas Jitkoff on 11/26/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSScreenCapturePlugIn.h"
#define SCTOOL @"/usr/sbin/screencapture"

//usage: screencapture [-icmwsWx] [files]
//-i         capture screen interactively, by selection or window
//	control key - causes screen shot to go to clipboard
//	space key   - toggle between mouse selection and
//	window selection modes
//	escape key  - cancels interactive screen shot
//-c         force screen capture to go to the clipboard
//-m         only capture the main monitor, undefined if -i is set
//-w         only allow window selection mode
//-s         only allow mouse selection mode
//-W         start interaction in window selection mode
//-x         do not play sounds
//-S         in window capture mode, capture the screen not the window
//-C         capture the cursor as well as the screen. only in non-interactive modes
//-t<format> image format to create, default is png
//	files   where to save the screen capture, 1 file per screen

@implementation QSScreenCapturePlugIn

- (QSObject *)captureScreen:(QSObject *)dObject{
	NSString *destinationPath=[@"~/Desktop/Picture.png" stringByStandardizingPath];
	destinationPath=[destinationPath firstUnusedFilePath];
	NSTask *task=[NSTask launchedTaskWithLaunchPath:SCTOOL arguments:[NSArray arrayWithObject:destinationPath]];
	[task waitUntilExit];
	[[QSReg preferredCommandInterface]selectObject:[QSObject fileObjectWithPath:destinationPath]];
	[[QSReg preferredCommandInterface]actionActivate:nil];
	return nil;
}

- (QSObject *)captureRegion:(QSObject *)dObject{
	NSString *destinationPath=[@"~/Desktop/Picture.png" stringByStandardizingPath];
	destinationPath=[destinationPath firstUnusedFilePath];
	NSTask *task=[NSTask launchedTaskWithLaunchPath:SCTOOL arguments:[NSArray arrayWithObjects:@"-is",destinationPath,nil]];
	[task waitUntilExit];
	[[QSReg preferredCommandInterface]selectObject:[QSObject fileObjectWithPath:destinationPath]];
	[[QSReg preferredCommandInterface]actionActivate:nil];
	return nil;
}

- (QSObject *)captureWindow:(QSObject *)dObject{
	NSString *destinationPath=[@"~/Desktop/Picture.png" stringByStandardizingPath];
	destinationPath=[destinationPath firstUnusedFilePath];
	NSTask *task=[NSTask launchedTaskWithLaunchPath:SCTOOL arguments:[NSArray arrayWithObjects:@"-iW",destinationPath,nil]];
	[task waitUntilExit];
	[[QSReg preferredCommandInterface]selectObject:[QSObject fileObjectWithPath:destinationPath]];
	[[QSReg preferredCommandInterface]actionActivate:nil];
	return nil;
}
@end
