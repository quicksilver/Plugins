/* DesktopManager -- A virtual desktop provider for OS X
 *
 * Copyright (C) 2003, 2004 Richard J Wareham <richwareham@users.sourceforge.net>
 * This program is free software; you can redistribute it and/or modify it 
 * under the terms of the GNU General Public License as published by the Free 
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but 
 * WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
 * or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License 
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along 
 * with this program; if not, write to the Free Software Foundation, Inc., 675 
 * Mass Ave, Cambridge, MA 02139, USA.
 */

#import "DesktopManager.h"

#import <unistd.h>

static NSMutableDictionary *iconCache = nil;

static CGSValue kCGSWindowTitle = 0;
void _ensure_kCGSWindowTitle() {
	if(!kCGSWindowTitle) {
		kCGSWindowTitle = CGSCreateCStringNoCopy("kCGSWindowTitle");
	}
}


// These functions require use of the Dock extension.

void makeEvent(int event, AppleEvent *theEvent) {
    int sig = 'dock';
    OSErr err;
    AEAddressDesc targetDesc;
    
    err = AECreateDesc(
        typeApplSignature,
        &sig, sizeof(int),
        &targetDesc
    );
    if(err) { NSLog(@"Error creating descriptor: %i\n", err); }
    
    err = AECreateAppleEvent(
        kWindowControllerClass, event,
        &targetDesc,
        kAutoGenerateReturnID, kAnyTransactionID,
        theEvent
    );
    if(err) { NSLog(@"Error creating event: %i\n", err); }
    
    AEDisposeDesc(&targetDesc);
}

int getIntParam(const AppleEvent *theEvent, int keyword) {
    int value;
    OSErr err;
         
    // Get Parameter
    err = AEGetParamPtr(
        theEvent, keyword,
        typeSInt32, NULL, &value, sizeof(int),
        NULL
    );
    if(err) { NSLog(@"Error getting parameter: %i\n", err); }
    
    return value;
}

void addIntParm(int parm, int keyword, AppleEvent *theEvent) {
    OSErr err = AEPutParamPtr(
        theEvent, keyword,
        typeSInt32, &parm, sizeof(parm)
    );
    if(err) { NSLog(@"Error setting parameter: %i\n", err); }
}

void addDataParm(void *data, int length, int keyword, AppleEvent *theEvent) {
    OSErr err = AEPutParamPtr(
        theEvent, keyword,
        typeData, data, length
    );
    if(err) { NSLog(@"Error setting parameter: %i\n", err); }
}

void addFloatParm(float parm, int keyword, AppleEvent *theEvent) {
    OSErr err = AEPutParamPtr(
        theEvent, keyword,
        typeFloat, &parm, sizeof(parm)
    );
    if(err) { NSLog(@"Error setting parameter: %i\n", err); }
}

/* We await reply here since we wan't method calls using this
 * to appear like normal calls, i.e. once the method returns, the
 * action has been completed. */
void sendEvent(AppleEvent *theEvent) {
    OSErr err = AESend(
        theEvent, NULL, kAEWaitReply,
        kAENormalPriority, kNoTimeOut,
        NULL, NULL
    );
    if(err) { NSLog(@"Error sending: %i\n", err); }
}

void sendEventAsync(AppleEvent *theEvent) {
    OSErr err = AESend(
        theEvent, NULL, kAENoReply,
        kAENormalPriority, kNoTimeOut,
        NULL, NULL
    );
    if(err) { NSLog(@"Error sending: %i\n", err); }
}

int sendEventWithIntReply(AppleEvent *theEvent) {
	AppleEvent theReply;
	int retVal = 0;
    OSErr err = AESend(
        theEvent, &theReply, kAEWaitReply,
        kAENormalPriority, kNoTimeOut,
        NULL, NULL
    );
    if(err) { NSLog(@"Error sending: %i\n", err); }
	
	retVal = getIntParam(&theReply, 'retv');
	
	AEDisposeDesc(&theReply);
	
	return retVal;
}

void startCouvert() {
    AppleEvent theEvent;
	
	// Form an array containing workspace index -> number conversion
	int workspaceCount = [[WorkspaceController defaultController] workspaceCount];
	int *workspaceArray = malloc(workspaceCount * sizeof(int));
	CGAffineTransform *targetArray = malloc(workspaceCount * sizeof(CGAffineTransform));
    
	CGAffineTransform target = CGAffineTransformMakeScale(4.0, 4.0);
	int i; for(i=0; i<workspaceCount; i++) {
		workspaceArray[i] = [[[WorkspaceController defaultController] workspaceAtIndex:i] workspaceNumber];
		targetArray[i] = CGAffineTransformTranslate(target, -100 - ((i % 2) * 300),
			-100 - (floor((float)i / 2.0) * 300));
	}
	
    makeEvent(kWindowControllerArrange, &theEvent);
	addDataParm(workspaceArray, workspaceCount * sizeof(int), 'wnar', &theEvent);
	addDataParm(targetArray, workspaceCount * sizeof(CGAffineTransform), 'tgar', &theEvent);
    
    sendEventAsync(&theEvent);
	
	free(workspaceArray);
	free(targetArray);
}

void endCouvert() {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerRestore, &theEvent);
    
    sendEventAsync(&theEvent);
}

@implementation ForeignWindow

+ (id) windowWithWindowNumber: (CGSWindow) wId {
    ForeignWindow *myself = [ForeignWindow alloc];
    if(myself) {
        return [[myself initWithWindowNumber: wId] autorelease];
    }
    return nil;
}

+ (id) windowWithNSWindow: (NSWindow*) window {
    ForeignWindow *myself = [ForeignWindow alloc];
    if(myself) {
        return [[myself initWithNSWindow: window] autorelease];
    }
    return nil;
}

+ (bool) windowNumberValid: (CGSWindow) wId {
    CGSConnection connection = _CGSDefaultConnection();
    int level = -1;
    OSStatus retVal;
    
    if(retVal = CGSGetWindowLevel(connection, wId, &level)) {
        // error returned, assume window id not valid,
		return false;
    }	
	
	return true;
}

- (id) initWithWindowNumber: (CGSWindow) windowId {
    if([self init]) {
        // Initialisation
        wid = windowId;
		ownerName = nil;
		
		if(!iconCache) {
			iconCache = [[NSMutableDictionary dictionary] retain];
		}
    }
    return self;
}

- (id) initWithNSWindow: (NSWindow*) window {
	CGSWindow wId = 0;
	wId = [window windowNumber];
	//NSLog(@"WID: %x", wId);
	return [self initWithWindowNumber: wId];
}

- (id) key {
    return [NSString stringWithFormat: @"WID:%i", wid];
}

- (id) pidKey {
    return [NSString stringWithFormat: @"PID:%i", [self ownerPid]];
}

- (NSRect) screenRect {
    NSRect rect;
    OSStatus retVal;
    CGSConnection connection = _CGSDefaultConnection();
    
    retVal = CGSGetScreenRectForWindow(connection, wid, (CGRect*) &rect);
    if(retVal) {
        // NSLog(@"Error getting screen rect: %i", retVal);
		return NSMakeRect(0,0,0,0);
    }
                
    return rect;
}

- (int) level {
    CGSConnection connection = _CGSDefaultConnection();
    int level = -1;
    OSStatus retVal;
    
    if(retVal = CGSGetWindowLevel(connection, wid, &level)) {
        NSLog(@"Error getting window level: %i", retVal);
    }
    
    return level;
}

- (NSString*) title {
	CGSValue windowTitle = 0;
	OSStatus retVal;
    CGSConnection connection = _CGSDefaultConnection();

	_ensure_kCGSWindowTitle();

	if(retVal = CGSGetWindowProperty(connection, wid, 
				kCGSWindowTitle, &windowTitle)) {
		NSLog(@"Error getting window title for wid %i.", wid);
		return nil;
	}
	
	char *strVal = CGSCStringValue(windowTitle);
	if(strVal) {
		return [NSString stringWithUTF8String: strVal];
	}
	
	return nil; // Untitled window.
	//return [[NSBundle mainBundle] localizedStringForKey: @"Untitled"
	//	value: @"Error getting localised string" table: nil];
}

- (ForeignWindow*) movementParent {
	NSLog(@"Call to deprecated function");
	
	return nil;
}

- (int) workspaceNumber {
	int workspace = -1;
	OSStatus retVal;
    CGSConnection connection = _CGSDefaultConnection();
	
	if(retVal = CGSGetWindowWorkspace(connection, wid, &workspace)) {
		NSLog(@"Error getting workspace for window %i", wid);
		return -1;
	}
	
	return workspace;
}

- (void) moveToWorkspace: (Workspace*) ws {
	if(!ws) { return;}
		
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerMoveToWorkspace, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    addIntParm([ws workspaceNumber], 'wksp', &theEvent);
    
    sendEvent(&theEvent);
}

- (void) moveToWorkspaceRepresentedBy: (id) represent {
	Workspace *ws = [represent representedObject];
	
	[self moveToWorkspace: ws];
}

- (void) move: (NSPoint) point {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerMoveWindow, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    addFloatParm(point.x, 'xpos', &theEvent);
    addFloatParm(point.y, 'ypos', &theEvent);
    
    sendEvent(&theEvent);
}

- (void) fade {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerFadeWindow, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    sendEvent(&theEvent);
}

- (void) unFade {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerUnFadeWindow, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    sendEvent(&theEvent);
}

- (int) tags {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerGetTags, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    return sendEventWithIntReply(&theEvent);	
}

- (uint32_t) eventMask {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerGetEventMask, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    return sendEventWithIntReply(&theEvent);	
}

- (void) setEventMask: (uint32_t) mask {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerSetEventMask, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    addIntParm(mask, 'mask', &theEvent);
    
    sendEvent(&theEvent);	
}

- (void) makeSticky {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerMakeSticky, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    sendEvent(&theEvent);
}

- (void) makeUnSticky {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerMakeUnSticky, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    sendEvent(&theEvent);
}

- (void) orderOut {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerOrderOutWindow, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    
    sendEvent(&theEvent);
}

- (void) orderAbove: (int) above {
    AppleEvent theEvent;
    
    makeEvent(kWindowControllerOrderAboveWindow, &theEvent);
    addIntParm(wid, 'wid ', &theEvent);
    addIntParm(above, 'abve', &theEvent);
    
    sendEvent(&theEvent);
}

- (CGSWindow) windowNumber {
	return wid;
}

- (void) orderFront {
	Workspace *currentWorkspace = [[WorkspaceController defaultController] currentWorkspace];
	if(currentWorkspace) {
		NSArray *windowList = [currentWorkspace windowList];
		if(windowList && [windowList count]) {
			ForeignWindow *window = (ForeignWindow*) [windowList objectAtIndex: 0];
			if(window) {
				[self orderAbove: [window windowNumber]];				
				return;
			}
		}
	}
	
	// If we can't fint the topmost window, do the best we can.
	[self orderAbove: 0];
}


- (ProcessSerialNumber) ownerPSN {
    ProcessSerialNumber psn;

    int retVal;
    if(retVal = GetProcessForPID([self ownerPid], &psn)) {
        NSLog(@"Error getting PSN from PID: %i\n", retVal);
    }

    return psn;
}

- (void) focusOwner
{
    OSStatus retVal;
    ProcessSerialNumber psn = [self ownerPSN];
    if(retVal = SetFrontProcess(&psn)) {
        NSLog(@"Error focusing owner: %i\n", (int)retVal);
    }
}


- (NSImage*) windowIcon {
    NSImage *icon = nil;
    
    if(iconCache != nil) {
        // printf("Fetching...\n");
        icon = [iconCache objectForKey: [self key]];
		
		if(icon) { return icon; }
    }
        
    if(icon == nil) {
        int retVal;
        FSRef fsRef;
        ProcessSerialNumber psn = [self ownerPSN];
        
        if(retVal = GetProcessBundleLocation(&psn, &fsRef)) {
            NSLog(@"Error getting process bundle location: %i\n", retVal);
            return nil;
        }
    
        unsigned char string[512];
        FSRefMakePath(&fsRef, string, 512);
        // printf("Bundle path: %s\n", string);
    
        icon = [[NSWorkspace sharedWorkspace] iconForFile: [NSString stringWithCString: (char*) string]];
        [iconCache setObject: icon forKey: [self key]];
    }
    
    return icon;
}

- (pid_t) ownerPid {
	OSStatus retVal;
	CGSConnection connection = _CGSDefaultConnection();
	CGSConnection ownerCID;
	
	if(retVal = CGSGetWindowOwner(connection, wid, &ownerCID)) {
		NSLog(@"Error getting window owner: %i\n", retVal);
		return 0;
	}

	pid_t pid = 0;
	if(retVal = CGSConnectionGetPID(ownerCID, &pid, ownerCID)) {
		NSLog(@"Error getting connection PID: %i\n", retVal);
	}
	
	return pid;
}

- (NSString*) ownerName {
    if(ownerName == nil) {
        CFStringRef strProcessName;
        ProcessSerialNumber psn = [self ownerPSN];
        int retVal;
    
        if(retVal = CopyProcessName(&psn, &strProcessName)) {
            NSLog(@"Error getting process name: %i\n", retVal);
        }
        
        ownerName = (NSString*) strProcessName;
    }
        
    return ownerName;
}



@end
