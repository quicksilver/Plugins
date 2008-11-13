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

#include "ControllerEventHandlers.h"

#include <stdio.h>
#include <syslog.h>
#include <stdarg.h>

#include "WindowController.h"
#include "couvert.h"

/* Utility functions for event handlers */
void putIntParam(AppleEvent *theEvent, int keyword, int value) {
    OSErr err;
         
    // Get Parameter
    err = AEPutParamPtr(
        theEvent, keyword,
        typeSInt32, &value, sizeof(int)
    );
    if(err) { syslog(LOG_ERR, "Error putting parameter: %i\n", err); }
}

int getParamSize(const AppleEvent *theEvent, int keyword) {
    Size value;
    OSErr err;
	DescType type;
         
    // Get Parameter
    err = AESizeOfParam(
        theEvent, keyword,
        &type, &value
	);
    if(err) { syslog(LOG_ERR, "Error getting parameter size: %i\n", err); }
    
    return value;
}

void getDataParam(const AppleEvent *theEvent, int keyword, void *value, int length) {
    OSErr err;
         
    // Get Parameter
    err = AEGetParamPtr(
        theEvent, keyword,
        typeData, NULL, value, length,
        NULL
    );
    if(err) { syslog(LOG_ERR, "Error getting parameter: %i\n", err); }
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
    if(err) { syslog(LOG_ERR, "Error getting parameter: %i\n", err); }
    
    return value;
}

/* Utility functions for event handlers */
int getFloatParam(const AppleEvent *theEvent, int keyword) {
    float value;
    OSErr err;
         
    // Get Parameter
    err = AEGetParamPtr(
        theEvent, keyword,
        typeFloat, NULL, &value, sizeof(int),
        NULL
    );
    if(err) { syslog(LOG_ERR, "Error getting parameter: %i\n", err); }
    
    return value;
}

/* These are the various AppleEvent handlers, they are used to
 * translate the events into calls to functions in WindowManipulation.c */
 
/* Fade a window */
OSErr fadeWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;
    
    wid = getIntParam(theEvent, 'wid ');
    fadeWindow(wid);
    
    return 0;
}

/* 'Unfade' a window. */
OSErr unFadeWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;
    
    wid = getIntParam(theEvent, 'wid ');
    unFadeWindow(wid);
    
    return 0;
}

/* Move a window. */
OSErr moveWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;
    float x,y;
    
    wid = getIntParam(theEvent, 'wid ');
    x = getFloatParam(theEvent, 'xpos');
    y = getFloatParam(theEvent, 'ypos');
    moveWindow(wid, x,y);
    
    return 0;
}

/* Order out a window. */
OSErr orderOutWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;
    
    wid = getIntParam(theEvent, 'wid ');
    orderOutWindow(wid);
    
    return 0;
}

/* order front a window. */
OSErr orderAboveWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid, above;
    
    wid = getIntParam(theEvent, 'wid ');
    above = getIntParam(theEvent, 'abve');
    orderAboveWindow(wid, above);
    
    return 0;
}

OSErr makeStickyHandler(const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;    
    wid = getIntParam(theEvent, 'wid ');
	makeSticky(wid);
		
	return 0;
}

OSErr makeUnStickyHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;    
    wid = getIntParam(theEvent, 'wid ');
	makeUnSticky(wid);
	
	return 0;
}

OSErr getTagsHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;    
    wid = getIntParam(theEvent, 'wid ');
	int tags = getTags(wid);
	putIntParam(reply, 'retv', tags);
	
	return 0;
}

OSErr getMaskHandler( const AppleEvent *theEvent,
					  AppleEvent *reply, SInt32 handlerRefcon) {
    int wid;    
    wid = getIntParam(theEvent, 'wid ');
	int mask = getMask(wid);
	putIntParam(reply, 'retv', mask);
	
	return 0;
}

OSErr setMaskHandler( const AppleEvent *theEvent,
						 AppleEvent *reply, SInt32 handlerRefcon) {
    int wid, mask;
	
	wid = getIntParam(theEvent, 'wid ');
	mask = getIntParam(theEvent, 'mask');
	setMask(wid, mask);
    
    return 0;
}

OSErr arrangeHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
	
	int numberLen = getParamSize(theEvent, 'wnar');
	void *numberArray = malloc(numberLen);
	getDataParam(theEvent, 'wnar', numberArray, numberLen);
	int targetLen = getParamSize(theEvent, 'tgar');
	void *targetArray = malloc(targetLen);
	getDataParam(theEvent, 'tgar', targetArray, targetLen);
	
	if(numberLen / sizeof(int) != targetLen / sizeof(CGAffineTransform)) {
		syslog(LOG_WARNING, "Someone passed stupidness to the Couvert handler");
		return 0;
	}
	
    arrangeWindows(numberArray, targetArray, numberLen / sizeof(int));
	
	free(numberArray);
	free(targetArray);

	return 0;
}

OSErr restoreHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    restoreWindows();
	
	return 0;
}

OSErr moveToWorkspaceHandler(const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon) {
    int wid, workspace;
    
    wid = getIntParam(theEvent, 'wid ');
    workspace = getIntParam(theEvent, 'wksp');
    moveToWorkspace(wid, workspace);
    
    return 0;
}