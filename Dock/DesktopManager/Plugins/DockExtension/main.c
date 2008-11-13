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

#include <mach/mach_init.h>
#include <mach/thread_act.h>

#include <Carbon/Carbon.h>

#include <stdio.h>
#include <syslog.h>
#include <stdarg.h>

#include "WindowController.h"
#include "../../Include/WindowControllerEvents.h"
#include "ControllerEventHandlers.h"

/* Entry point for injected code, this is how we get called. */
#define INJECT_ENTRY injectEntry

#define syslog my_syslog

void my_syslog(int level, char *str, ...) {
	// Nothing!
}

void INJECT_ENTRY (ptrdiff_t codeOffset, void *paramBlock, size_t paramSize);

/* This is the enty point for the bundle. When invoked it expects to
 * have been injected into a thread within the Dock. It attempts to be
 * as kind as possible... */
void INJECT_ENTRY( ptrdiff_t offset, void *paramBlock, size_t paramSize ) {
    OSErr err;
	
	syslog(LOG_ERR, "Hello");
    
	//NSLog(@"Boo");
	
    /* Install event handlers */
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerFadeWindow,
        NewAEEventHandlerUPP((&fadeWindowHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering fade handler: %i", err); }
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerUnFadeWindow,
        NewAEEventHandlerUPP((&unFadeWindowHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering un-fade handler: %i", err); }    
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerOrderOutWindow,
        NewAEEventHandlerUPP((&orderOutWindowHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering order out handler: %i", err); }    
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerOrderAboveWindow,
        NewAEEventHandlerUPP((&orderAboveWindowHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering order above handler: %i", err); }    
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerMoveWindow,
        NewAEEventHandlerUPP((&moveWindowHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering move handler: %i", err); }    
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerMakeSticky,
        NewAEEventHandlerUPP((&makeStickyHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering move handler: %i", err); }    
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerMakeUnSticky,
        NewAEEventHandlerUPP((&makeUnStickyHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering move handler: %i", err); }    
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerGetTags,
        NewAEEventHandlerUPP((&getTagsHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering move handler: %i", err); }    
	
    err = AEInstallEventHandler(
								kWindowControllerClass,
								kWindowControllerGetEventMask,
								NewAEEventHandlerUPP((&getMaskHandler) + offset),
								0, FALSE
								);
    if(err) { syslog(LOG_ERR, "Error registering mask handler: %i", err); }    
	
	err = AEInstallEventHandler(
								kWindowControllerClass,
								kWindowControllerSetEventMask,
								NewAEEventHandlerUPP((&setMaskHandler) + offset),
								0, FALSE
								);
    if(err) { syslog(LOG_ERR, "Error registering set mask handler: %i", err); }  
	
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerArrange,
        NewAEEventHandlerUPP((&arrangeHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering move handler: %i", err); }    
        
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerRestore,
        NewAEEventHandlerUPP((&restoreHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering move handler: %i", err); }    
     
    err = AEInstallEventHandler(
        kWindowControllerClass,
        kWindowControllerMoveToWorkspace,
        NewAEEventHandlerUPP((&moveToWorkspaceHandler) + offset),
        0, FALSE
    );
    if(err) { syslog(LOG_ERR, "Error registering move handler: %i", err); }    

    //syslog(LOG_WARNING, 
    //  "DesktopManager has installed a patch to the Dock, this might cause crashes.");

    /* And suspend the thread */
    thread_suspend( mach_thread_self() );
}