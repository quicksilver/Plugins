//
//  QSWebSearchPlugIn_Source.h
//  QSWebSearchPlugIn
//
//  Created by Nicholas Jitkoff on 11/24/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSWebSearchPlugInDefines.h"
#import "QSWebSearchPlugIn_Source.h"

@interface QSWebSearchSource : QSObjectSource{
	IBOutlet NSTableView *searchTable;
	IBOutlet NSPopUpButtonCell *encodingCell;
}

- (NSMenu *)encodingMenu;
- (void)setUrlArray:(id)array;
- (NSMutableArray *)urlArray;

@end

