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

#import "DMApplication.h"
#import <Carbon/Carbon.h>
#include "DesktopManager.h"

enum {
    // NSEvent subtypes for hotkey events (undocumented)
    kEventHotKeyPressedSubtype = 6,
    kEventHotKeyReleasedSubtype = 9,
};

@implementation DMApplication

- (void)sendEvent: (NSEvent*) theEvent {
    if(([theEvent type] == NSSystemDefined) && 
       ([theEvent subtype] == kEventHotKeyPressedSubtype)) {
        // Dispatch hotkey press notification.
        EventHotKeyRef hotKeyRef = (EventHotKeyRef) [theEvent data1];
        [[NSNotificationCenter defaultCenter]
          postNotificationName: NOTIFICATION_HOTKEYPRESS object: 
            [NSValue value: &hotKeyRef withObjCType: @encode(EventHotKeyRef)]];
    }

    [super sendEvent: theEvent];
}

@end
