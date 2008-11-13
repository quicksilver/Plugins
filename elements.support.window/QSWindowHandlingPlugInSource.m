//
//  QSWindowHandlingPlugInSource.m
//  QSWindowHandlingPlugIn
//
//  Created by Nicholas Jitkoff on 8/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSWindowHandlingPlugInSource.h"
#import "QSWindowHandlingPlugIn_Prefix.pch"

#import <Carbon/Carbon.h>
#define kCGSNullConnectionID (CGSConnection) 0



int QSGetFrontWindow() {
	int workspace;
	int count = 0;
	
	CGSConnection cgs = _CGSDefaultConnection();
	CGSGetWorkspace(cgs, &workspace);
	CGSGetWorkspaceWindowCount(cgs, workspace, &count);
	
	CGSWindow windows[count];
	if (!CGSGetWorkspaceWindowList(cgs, workspace, count, &windows, &count) ) {
		int i;
		int level;
		pid_t pid;
		CGSConnection wcid;
		for(i = 0; i<count; i++) {
			CGSGetWindowLevel(cgs, windows[i] , &level);
			CGSGetWindowOwner(cgs, windows[i] , &wcid);
			//
			//	NSLog(@"window id %d at %d - %d %d", windows[i] , level, cgs, wcid);
			
			//			CGSConnectionGetPID(cgs, &pid, const CGSConnection ownerCid);
			
			if (level<kCGDockWindowLevel && wcid != cgs)
				return windows[i];
		}
	}
}

CGPoint QSCGGlobalCursorPoint() {
	CGPoint point;
	Point      carbonPoint;
	GetGlobalMouse (&carbonPoint);
	return CGPointMake((float) carbonPoint.h, (float) carbonPoint.v);
}

int QSGetWindowUnderMouse() {
	int workspace;
	int count = 0;
	NSPoint mousePoint = [NSEvent mouseLocation];
	
	CGSConnection cgs = _CGSDefaultConnection();
	CGSGetWorkspace(cgs, &workspace);
	CGSGetWorkspaceWindowCount(cgs, workspace, &count);
	
	CGSWindow windows[count];
	
	if (!CGSGetWorkspaceWindowList(cgs, workspace, count, &windows, &count) ) {
		int i;
		int level;
		pid_t pid;
		CGSConnection wcid;
		CGPoint cursor = QSCGGlobalCursorPoint();
		for(i = 0; i<count; i++) {
			CGSGetWindowLevel(cgs, windows[i] , &level);
			CGSGetWindowOwner(cgs, windows[i] , &wcid);
			CGAffineTransform transform;
			CGSGetWindowTransform(cgs, windows[i] , &transform);  
			CGRect frame = CGRectZero; // = NSMakeRect(0, 0, 0, 0);
      
      CGSGetScreenRectForWindow(cgs, windows[i] , &frame);
      BOOL contains = CGRectContainsPoint(frame, cursor);
      
      if (!contains) continue;
      
      NSLog(@"window id %d at %d - %d %d contains %d", windows[i] , level, cgs, wcid, contains);
      //logRect(frame);
      NSLog(@"point %f, %f", cursor.x, cursor.y);
      
      //			CGSConnectionGetPID(cgs, &pid, const CGSConnection ownerCid);
      
      if (level<kCGDockWindowLevel && wcid != cgs)
        return windows[i];
		}
	}
}

NSArray *QSGetAllWindowsUnderMouse() {
	int workspace;
	int count = 0;
	NSPoint mousePoint = [NSEvent mouseLocation];
	
	CGSConnection cgs = _CGSDefaultConnection();
	CGSGetWorkspace(cgs, &workspace);
	CGSGetWorkspaceWindowCount(cgs, workspace, &count);
	
	CGSWindow windows[count];
	NSMutableArray *array = [NSMutableArray array];
	
	if (!CGSGetWorkspaceWindowList(cgs, workspace, count, &windows, &count) ) {
		int i;
		int level;
		pid_t pid;
		CGSConnection wcid;
		CGPoint cursor = QSCGGlobalCursorPoint();
		for(i = 0; i<count; i++) {
			CGSGetWindowLevel(cgs, windows[i] , &level);
			CGSGetWindowOwner(cgs, windows[i] , &wcid);
			CGAffineTransform transform;
			CGSGetWindowTransform(cgs, windows[i] , &transform);  
			CGRect frame = CGRectZero; // = NSMakeRect(0, 0, 0, 0);
      
      CGSGetScreenRectForWindow(cgs, windows[i] , &frame);
      BOOL contains = CGRectContainsPoint(frame, cursor);
      
      if (!contains) continue;
      
      NSLog(@"window id %d at %d - %d %d contains %d", windows[i] , level, cgs, wcid, contains);
      //logRect(frame);
      NSLog(@"point %f, %f", cursor.x, cursor.y);
      
      //			CGSConnectionGetPID(cgs, &pid, const CGSConnection ownerCid);
      
      if (level<kCGDockWindowLevel && wcid != cgs)
        [array addObject:[NSNumber numberWithInt:windows[i]]];
		}
	}
	return array;
}



@implementation QSWindowHandlingPlugInSource


- (id)resolveProxyObject:(id)proxy {
	if ([[proxy identifier] isEqualToString:@"QSKeyWindowProxy"]) {
		int window = QSGetFrontWindow();
		return [QSObject windowObjectWithWindowID:window];
		
		
	} else if ([[proxy identifier] isEqualToString:@"QSAllWindowsUnderMouseProxy"]) {
		
		NSArray *wids = QSGetAllWindowsUnderMouse();
		NSMutableArray *array = [NSMutableArray array];
		foreach(wid, wids) {
			[array addObject:[QSObject windowObjectWithWindowID:[wid intValue]]];
		}
		return [QSObject objectByMergingObjects:array];
		
		return ;
	} else if ([[proxy identifier] isEqualToString:@"QSWindowUnderMouseProxy"]) {
		int window = QSGetWindowUnderMouse();
		return [QSObject windowObjectWithWindowID:window];
	}
	return nil;
}

- (NSTimeInterval) cacheTimeForProxy:(id)proxy {
	return 0.0f; 	
}


- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
  return NO;
}

- (NSImage *)iconForEntry:(NSDictionary *)dict {
  return [[NSBundle bundleForClass:[self class]]imageNamed:@"Window"];
}

- (NSString *)identifierForObject:(id <QSObject>)object {
  return [NSString stringWithFormat:@"[WindowID] :%@", [object objectForType:QSWindowIDType]];
} 	
- (NSString *)detailsOfObject:(id <QSObject>)object {
	int windowid = [[object objectForType:QSWindowIDType] intValue];
	int workspace;
	CGSGetWindowWorkspace(_CGSDefaultConnection(), windowid, &workspace);
	NSString *owner = [[NSWorkspace sharedWorkspace] nameForPID:pidForWindowID(windowid)];
  return [NSString stringWithFormat:@"%@ %d", owner, workspace];
} 	

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
  NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
  QSObject *newObject;
	
	CGSConnection cgs = _CGSDefaultConnection();
	int count;
	
	//windowList = [[NSMutableData dataWithCapacity: windowCount * sizeof(int)] retain];
	count = 0;
  CGSGetWindowCount(cgs, kCGSNullConnectionID, &count);
	//NSLog(@" %d windows", count);
  
  int windows[count];
  if (!CGSGetWindowList(cgs, kCGSNullConnectionID, count, &windows, &count) ) {
    int i;
    for(i = 0; i<count; i++) {
      newObject = [QSObject windowObjectWithWindowID:windows[i]];
      if (newObject) [objects addObject:newObject];
    }
  } else {
    NSLog(@"err"); 	
  }
  
  //NSLog(@"%d", [objects count]);
  return objects;
  
}



// Object Handler Methods

- (void)setQuickIconForObject:(QSObject *)object {
	[object setIcon:[[NSBundle bundleForClass:[self class]]imageNamed:@"Window"]]; // An icon that is either already in memory or easy to load
}

- (BOOL)drawIconForObject:(QSObject *)object inRect:(NSRect)rect flipped:(BOOL)flipped {
	if (NSWidth(rect) <= 32) return NO;
  int windowid = [[object objectForType:QSWindowIDType] intValue];
  CGSOrderWindow(_CGSDefaultConnection(), windowid, kCGSOrderAbove, 0);
  CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, windowid, 0);
  NSRect imageRect = NSMakeRect(0, 0, CGImageGetWidth(windowImage), CGImageGetHeight(windowImage) );
  CGContextDrawImage([[NSGraphicsContext currentContext] graphicsPort] , NSRectToCGRect(fitRectInRect(imageRect, rect, NO) ), windowImage);
  CGImageRelease(windowImage);
  return;
  NSImage *image = [object icon];
	
  [image setSize:[[image bestRepresentationForSize:rect.size] size]];
	//[image adjustSizeToDrawAtSize:rect.size];
	[image setFlipped:flipped];
	[image drawInRect:rect fromRect:rectFromSize([image size]) operation:NSCompositeSourceOver fraction:1.0];
	
	
  
  
  
	NSString *path = [[NSWorkspace sharedWorkspace] pathForPID:pidForWindowID(windowid)];
	
	//NSLog(@"path %@", path);
	
	
	NSImage *cornerBadge = [[NSWorkspace sharedWorkspace] iconForFile:path];
	if (cornerBadge != image) {
		[cornerBadge setFlipped:flipped];  
		NSImageRep *bestBadgeRep = [cornerBadge bestRepresentationForSize:rect.size];  
		[cornerBadge setSize:[bestBadgeRep size]];
		NSRect badgeRect = NSMakeRect(0, 0, NSHeight(rect) * 2/3, NSWidth(rect) *2/3);
		
		//NSPoint offset = rectOffset(badgeRect, rect, 2);
		badgeRect = centerRectInRect(badgeRect, rect);
		badgeRect = NSOffsetRect(badgeRect, 0, -NSHeight(rect) /16);
		
		[[NSColor colorWithDeviceWhite:1.0 alpha:0.8] set];
		//NSRectFillUsingOperation(NSInsetRect(badgeRect, -3, -3), NSCompositeSourceOver);
		[[NSColor colorWithDeviceWhite:0.75 alpha:1.0] set];
		//NSFrameRectWithWidth(NSInsetRect(badgeRect, -5, -5), 2);
		[cornerBadge drawInRect:badgeRect fromRect:rectFromSize([cornerBadge size]) operation:NSCompositeSourceOver fraction:1.0];
	}
	
	return YES;
}

/*
 - (BOOL)loadIconForObject:(QSObject *)object {
 return NO;
 id data = [object objectForType:QSWindowModuleType];
 [object setIcon:nil];
 return YES;
 }
 */@end
