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

#include "CodeInjector.h"

#include <signal.h>

#include <mach/thread_act.h>
#include <mach/mach_init.h>
#include "mach_inject.h"

OSErr FindProcessBySignature( OSType type, OSType creator, ProcessSerialNumber *psn );

// Mac to Mach error morphing.
#define err_mac			err_system(0xf)	/* Mac (Carbon) errors */
static mach_error_t	_mac_err( OSErr err ) {
	return err ? (err_mac|err) : err_none;
}
#define	mac_err( CODE )	_mac_err( (CODE) );

#define	err_couldnt_load_main_bundle			(err_local|1)
#define	err_couldnt_find_injection_bundle		(err_local|2)
#define	err_couldnt_load_injection_bundle		(err_local|3)
#define	err_couldnt_find_injectedThread_symbol	(err_local|4)

OSErr injectCode() {
    mach_error_t err = err_none;
    
    //printf("Attempting to install Dock patch...\n");
    
    // Get the main bundle for the app.
    CFBundleRef mainBundle = NULL;
    if(!err) {
        mainBundle = CFBundleGetMainBundle();
    if( !mainBundle )
                    err = err_couldnt_load_main_bundle;
    }
    
    // Find our injection bundle by name.
    CFURLRef injectionURL = NULL;
    if( !err ) {
        injectionURL = CFBundleCopyResourceURL( mainBundle,
            CFSTR("DockExtension.bundle"), NULL, NULL );
        if( !injectionURL )
            err = err_couldnt_find_injection_bundle;
    }
	
    //	Create injection bundle instance.
    CFBundleRef injectionBundle = NULL;
    if( !err ) {
        injectionBundle = CFBundleCreate( kCFAllocatorDefault, injectionURL );
        if( !injectionBundle )
            err = err_couldnt_load_injection_bundle;
    }
	
    //	Load the thread code injection.
    void *injectionCode = NULL;
    if( !err ) {
        injectionCode = CFBundleGetFunctionPointerForName( injectionBundle, 
        CFSTR( INJECT_ENTRY_SYMBOL ));
        if( injectionCode == NULL )
            err = err_couldnt_find_injectedThread_symbol;
    }
		
    //	Find target by signature.
    ProcessSerialNumber psn;
    if( !err )
        err = mac_err( FindProcessBySignature( 'APPL', 'dock', &psn ));
	
    //	Convert PSN to PID.
    pid_t dockpid;
    if( !err )
        err = mac_err( GetProcessPID( &psn, &dockpid ));
    //if( !err )
    //    printf( "pid: %ld\n", (long) dockpid );
	
    //	Inject the code.
    if( !err )
        err = mach_inject( injectionCode, NULL, 0, dockpid, 32 * 1024 );
	
    if(err) {
        printf("Failed!\n");
    }
        
    //	Clean up.
    if( injectionBundle )
        CFRelease( injectionBundle );
    if( injectionURL )
        CFRelease( injectionURL );
    if( mainBundle )
        CFRelease( mainBundle );

    return err;
}

void killDock() {
    mach_error_t err = 0;
    
    //	Find target by signature.
    ProcessSerialNumber psn;
    if( !err )
        err = mac_err( FindProcessBySignature( 'APPL', 'dock', &psn ));
	
    //	Convert PSN to PID.
    pid_t dockpid;
    if( !err )
        err = mac_err( GetProcessPID( &psn, &dockpid ));
    if( !err )
        printf( "pid: %ld\n", (long) dockpid );
    
    kill(dockpid, SIGKILL);
}

OSErr FindProcessBySignature( OSType type, OSType creator, ProcessSerialNumber *psn ) {
    ProcessSerialNumber tempPSN = { 0, kNoProcess };
    ProcessInfoRec procInfo;
    OSErr err = noErr;
    
    procInfo.processInfoLength = sizeof( ProcessInfoRec );
    procInfo.processName = nil;
    procInfo.processAppSpec = nil;
    
    while( !err ) {
      err = GetNextProcess( &tempPSN );
      if( !err ) { err = GetProcessInformation( &tempPSN, &procInfo ); }
      if( !err && procInfo.processType == type
               && procInfo.processSignature == creator ) {
        *psn = tempPSN;
        return noErr;
      }
    }
    
    return err;
}