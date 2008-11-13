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
 
#import "DesktopNamesPreferences.h"
#import "DesktopManager.h"

#define MyPboardType @"DesktopsPrefsPboard"

@implementation DesktopNamesPreferences

- (void) awakeFromNib {
    fromRow = -1;
	
    [desktopNamesTable setDataSource: self];

    [desktopNamesTable reloadData];
    [desktopNamesTable registerForDraggedTypes:
        [NSArray arrayWithObjects: MyPboardType, nil]];
}

- (IBAction) addDesktop: (id) sender {
	NSMutableArray *namesArray = [NSMutableArray arrayWithArray:
		[[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES]
	];
	
    [namesArray insertObject: @"New Desktop" atIndex: [namesArray count]];
    [[NSUserDefaults standardUserDefaults] setObject: namesArray forKey: PREF_DESKTOPNAMES];
    
    [desktopNamesTable reloadData];
    [desktopNamesTable selectRow: [desktopNamesTable numberOfRows] - 1 byExtendingSelection: NO];
}

- (IBAction) removeDesktop: (id) sender {
	NSMutableArray *namesArray = [NSMutableArray arrayWithArray:
		[[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES]
	];
    int selectedRow = [desktopNamesTable selectedRow];
    if((selectedRow != -1) && ([namesArray count] > 1)) {
        [namesArray removeObjectAtIndex: selectedRow];
        [[NSUserDefaults standardUserDefaults] setObject: namesArray forKey: PREF_DESKTOPNAMES];
        [desktopNamesTable reloadData];
        
        if(selectedRow >= [desktopNamesTable numberOfRows]) {
        } else {
            [desktopNamesTable selectRow: selectedRow byExtendingSelection: NO];
        }
    }
}

// TableView data source stuff.
- (int) numberOfRowsInTableView: (NSTableView*) tabView {
	NSArray *namesArray =[[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES];
    if(tabView == desktopNamesTable) {
        return [namesArray count];
    }
    
    return nil;
}

- (id) tableView: (NSTableView*) tabView 
    objectValueForTableColumn: (NSTableColumn*) column
    row: (int) row {
	NSArray *namesArray =[[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES];
    if(tabView == desktopNamesTable) {
        return [namesArray objectAtIndex: row];
    }
    
    return nil;
}

- (void) tableView: (NSTableView*) tabView
    setObjectValue: (id) object
    forTableColumn: (NSTableColumn*) column
    row: (int) row {
    if(tabView == desktopNamesTable) {
		NSMutableArray *namesArray = [NSMutableArray arrayWithArray:
			[[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES]
		];

        [namesArray replaceObjectAtIndex: row withObject: object];
        
        [[NSUserDefaults standardUserDefaults] setObject: namesArray forKey: PREF_DESKTOPNAMES];
    }
}

- (NSDragOperation) tableView: (NSTableView*) tabView
    validateDrop: (id <NSDraggingInfo>) info proposedRow: (int) row
    proposedDropOperation: (NSTableViewDropOperation) operation {
    if(tabView == desktopNamesTable) {    
        [tabView setDropRow: row dropOperation: NSTableViewDropAbove];
        return NSDragOperationMove;
    }
    
    return NSDragOperationNone;
}

- (BOOL) tableView: (NSTableView*)tabView 
    writeRows: (NSArray*) rows
    toPasteboard: (NSPasteboard*) pboard {
    if(tabView == desktopNamesTable) {    
		NSArray *namesArray =[[NSUserDefaults standardUserDefaults] 
			stringArrayForKey: PREF_DESKTOPNAMES];
        fromRow = [[rows objectAtIndex: 0] intValue];

        [pboard declareTypes:[NSArray arrayWithObjects: MyPboardType, 
            NSStringPboardType, nil] owner:self];
    
        [pboard setData: [NSData data] forType:MyPboardType]; 
    
        // Put string data on the pboard... notice you candrag into TextEdit!
        [pboard setString: [namesArray objectAtIndex: fromRow] 
            forType: NSStringPboardType];

        return YES;
    }
    
    return NO;
}

- (BOOL) tableView: (NSTableView*)tabView 
    acceptDrop: (id <NSDraggingInfo>) info row: (int) row
    dropOperation: (NSTableViewDropOperation) operation {
    if(tabView == desktopNamesTable) {    
        NSPasteboard *pboard = [info draggingPasteboard];
        NSString *string = [pboard stringForType: NSStringPboardType];
		NSMutableArray *namesArray = [NSMutableArray arrayWithArray:
			[[NSUserDefaults standardUserDefaults] stringArrayForKey: PREF_DESKTOPNAMES]
		];
		    
        [namesArray insertObject: string atIndex: row];
    
        if(fromRow > row) { fromRow ++; }
        [namesArray removeObjectAtIndex: fromRow];
        [tabView reloadData];

        [[NSUserDefaults standardUserDefaults] setObject: namesArray forKey: PREF_DESKTOPNAMES];

        return YES;
    }
    
    return NO;
}

@end
