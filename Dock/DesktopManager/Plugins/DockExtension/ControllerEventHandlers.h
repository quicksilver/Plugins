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

#include <Carbon/Carbon.h>

OSErr fadeWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr unFadeWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr moveWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr orderOutWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr orderAboveWindowHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr makeStickyHandler(const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr makeUnStickyHandler( const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr getTagsHandler(const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr getMaskHandler(const AppleEvent *theEvent,
					 AppleEvent *reply, SInt32 handlerRefcon);
OSErr setMaskHandler( const AppleEvent *theEvent,
						 AppleEvent *reply, SInt32 handlerRefcon);
OSErr arrangeHandler(const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr restoreHandler(const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);
OSErr moveToWorkspaceHandler(const AppleEvent *theEvent,
    AppleEvent *reply, SInt32 handlerRefcon);