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

#include "WindowController.h"
#include "../../Include/CGSPrivate.h"

#include <unistd.h>
#include <syslog.h>

void fadeWindow(int wid) {
	float alpha = 0;
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
    //syslog(LOG_ERR, "Fading: %i", wid);
	
	for(alpha=1.0; alpha>=0.0; alpha-=0.05) {
      CGSSetWindowAlpha(cid, wid, alpha);
	  usleep(10000);
	}
	
	CGSSetWindowAlpha(cid, wid, 0.0);
}

void unFadeWindow(int wid) {
    CGSConnection cid;
    float alpha;
	
    cid = _CGSDefaultConnection();
	
	for(alpha=0.0; alpha<=1.0; alpha+=0.05) {
      CGSSetWindowAlpha(cid, wid, alpha);
	  usleep(10000);
	}
	
    CGSSetWindowAlpha(cid, wid, 1.0);
}


void moveWindow(int wid, float x, float y) {
    CGSConnection cid;
    CGPoint point;
	
    cid = _CGSDefaultConnection();
    point.x = x; point.y = y;
	
	CGSMoveWindow(cid, wid, &point);
}

void moveToWorkspace(int wid, int workspace) {
	CGSConnection cid;

	cid = _CGSDefaultConnection();
	CGSMoveWorkspaceWindowList(cid,&wid,1,workspace);
}

void orderOutWindow(int wid) {
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
    CGSOrderWindow(cid, wid, kCGSOrderOut, 0);
}

void orderAboveWindow(int wid, int above) {
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
    CGSOrderWindow(cid, wid, kCGSOrderAbove, above);
	CGSFlushWindow(cid, wid, 0);
}

int getTags(int wid) {
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
	CGSWindowTag tags[2];
	tags[0] = tags[1] = 0;
	CGSGetWindowTags(cid, wid, tags, 32);
	
	// syslog(LOG_WARNING, "Window %x, tags %x%x", wid, tags[1], tags[0]);
	
	return tags[0];
}

uint32_t getMask(int wid) {
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
	uint32_t mask = 0;
	CGSGetWindowEventMask(cid, wid, &mask);
		
	return mask;
}

void setMask(int wid, uint32_t mask) {
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
	syslog(LOG_WARNING, "RetVal: %i", CGSSetWindowEventMask(cid, wid, mask));
}

void makeSticky(int wid) {
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
	CGSWindowTag tags[2];
	tags[0] = tags[1] = 0;
	OSStatus retVal = CGSGetWindowTags(cid, wid, tags, 32);
	if(!retVal) {
		tags[0] = CGSTagSticky;
		retVal = CGSSetWindowTags(cid, wid, tags, 32);
	}
}

void makeUnSticky(int wid) {
    CGSConnection cid;
    
    cid = _CGSDefaultConnection();
	CGSWindowTag tags[2];
	tags[0] = tags[1] = 0;
	OSStatus retVal = CGSGetWindowTags(cid, wid, tags, 32);
	if(!retVal) {
		tags[0] = CGSTagSticky;
		retVal = CGSClearWindowTags(cid, wid, tags, 32);
	}
}
