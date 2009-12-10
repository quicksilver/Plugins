
#import "QSPasteboardMonitor.h"
#import "QSPasteboardController.h"
#import <QSInterface/QSDockingWindow.h>
//#import <QSBase/NDHotKeyEvent.h>
//#import <QSBase/NDHotKeyEvent_QSMods.h>
//#import <QSInterface/QSInterface.h>
//
#import <QSCore/QSNullObject.h>
//#import <QSCore/QSLibrarian.h>
//
#import "QSPasteboardAccessoryCell.h"
//
#import <QSInterface/QSObjectCell.h>
//

@implementation QSPasteboardController

+ (void)initialize {
	NSMenu *modulesMenu = [[[NSApp mainMenu] itemWithTag:128] submenu];
	NSMenuItem *modMenuItem = [modulesMenu addItemWithTitle:@"Clipboard History" action:@selector(showClipboard:) keyEquivalent:@"l"];
	[modMenuItem setTarget:self];
	
	[QSPasteboardMonitor sharedInstance];
	if ([[NSUserDefaults standardUserDefaults] boolForKey:kCapturePasteboardHistory])
		[QSPasteboardController sharedInstance];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:@"QSPasteboardHistoryIsVisible"]) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showClipboardHidden:) name:@"QSApplicationDidFinishLaunchingNotification" object:NSApp];
	} 	
	NSImage *image = [[NSImage alloc] initByReferencingFile:
                  [[NSBundle bundleForClass:[QSPasteboardController class]]pathForImageResource:@"Clipboard"]];
	[image shrinkToSize:QSSize16];
	[modMenuItem setImage:image];
	return ; 	
}

+ (BOOL)validateMenuItem:(NSMenuItem*)anItem {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([anItem action] == @selector(showClipboards:) ) {
		[defaults boolForKey:kCapturePasteboardHistory];
	}
	return YES;
}

+ (void)showClipboardHidden:(id)sender {
	[(QSDockingWindow *)[[self sharedInstance] window] orderFrontHidden:sender];
}

+ (void)showClipboard:(id)sender {
	[(QSDockingWindow *)[[self sharedInstance] window] toggle:sender];
	
}

+ (id)sharedInstance {
  static id _sharedInstance;
  if (!_sharedInstance) _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
  return _sharedInstance;
}


- (id)clearStore {
	[pasteboardStoreArray removeAllObjects];
	for (int i = 0; i<10; i++) [pasteboardStoreArray addObject:[QSNullObject nullObject]];
}
- (id)init {
  if (self = [super initWithWindowNibName:@"Pasteboard" owner:self]) {
		
		pasteboardHistoryArray = nil;
		pasteboardHistoryArray = [[QSLibrarian sharedInstance] shelfNamed:@"QSPasteboardHistory"]; //[[NSMutableArray alloc] initWithCapacity:1];
		
		currentArray = pasteboardHistoryArray;
		mode = QSPasteboardHistoryMode;
		pasteboardStoreArray = [[NSMutableArray alloc] init];
		[self clearStore];
		pasteboardCacheArray = [[NSMutableArray alloc] init];
		
		// ***warning   * if pasteboard is empty, put last copyied item onto it
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pasteboardChanged:) name:QSPasteboardDidChangeNotification object:nil];
		
		
		if (defaultBool(@"QSClipboardModule/EnableHotKeys") ) {
			QSHotKeyEvent *hotKey;
			
			hotKey = [QSHotKeyEvent getHotKeyForKeyCode:37 character:@"L"
                                            modifierFlags:NSCommandKeyMask | NSControlKeyMask];
			[hotKey setTarget:self selector:@selector(showHistory:)];
			[hotKey setEnabled:YES];
			
			hotKey = [QSHotKeyEvent getHotKeyForKeyCode:37 character:@"L"
                                            modifierFlags:NSCommandKeyMask | NSShiftKeyMask | NSAlternateKeyMask];
			[hotKey setTarget:self selector:@selector(showStore:)];
			[hotKey setEnabled:YES];
			
			hotKey = [QSHotKeyEvent getHotKeyForKeyCode:37 character:@"L"
                                            modifierFlags:NSCommandKeyMask | NSControlKeyMask | NSAlternateKeyMask];
			[hotKey setTarget:self selector:@selector(showQueue:)];
			[hotKey setEnabled:YES];
			
			hotKey = [QSHotKeyEvent getHotKeyForKeyCode:37 character:@"L"
                                            modifierFlags:NSCommandKeyMask | NSControlKeyMask | NSShiftKeyMask];
			[hotKey setTarget:self selector:@selector(showStack:)];
			[hotKey setEnabled:YES];
			
			hotKey = [QSHotKeyEvent getHotKeyForKeyCode:9 character:@"V"
                                            modifierFlags:NSCommandKeyMask | NSControlKeyMask];
			[hotKey setTarget:self selector:@selector(qsPaste:)];
			[hotKey setEnabled:YES];
		}
		
	}
	return self;
}

- (IBAction)showHistory:(id)sender {
	[self switchToMode:QSPasteboardHistoryMode];
	[[self window] show:sender];
}

- (IBAction)showStore:(id)sender {
	[self switchToMode:QSPasteboardStoreMode]; 	
	[[self window] show:sender];
}

- (IBAction)showQueue:(id)sender {
	[self switchToMode:QSPasteboardQueueMode];
	[[self window] show:sender];
}

- (IBAction)showStack:(id)sender {
	[self switchToMode:QSPasteboardStackMode];
	[[self window] show:sender];
}


- (void)pasteItem:(id)sender {
  //  activateFrontWindowOfApplication
  //supressCapture = YES;
  //[[NSWorkspace sharedWorkspace] activateFrontWindowOfApplication:
  //  [[NSWorkspace sharedWorkspace] activeApplication]];
  //[[NSApp keyWindow] orderOut:self];
  [(QSDockingWindow *)[self window] resignKeyWindowNow];
  //[NSApp deactivate];
	[self qsPaste:nil];
	
	[self hideWindow:sender];
  
  [[[NSApp delegate] interfaceController] hideWindows:self];
  
  
	// ***warning   * the clipboard should be restored
}


- (IBAction)qsPaste:(id)sender {
	switch (mode) {
		case QSPasteboardHistoryMode:
		case QSPasteboardStoreMode:
			[self copy:sender];
			QSForcePaste();
			break;
		case QSPasteboardQueueMode:
		case QSPasteboardStackMode:
			if ([pasteboardCacheArray count]) {
				
				id object = (sender?[pasteboardCacheArray objectAtIndex:0] :[self selectedObject]);
				supressCapture = YES;
				[object putOnPasteboard:[NSPasteboard generalPasteboard] includeDataForTypes:nil];
				QSForcePaste();
				if (sender) {
					[pasteboardCacheArray removeObjectAtIndex:0];
					[pasteboardHistoryTable reloadData];
				}
			} else {
				NSBeep(); 	
				
			}
			break;
		default:
			break;
	}
	
}


- (void)awakeFromNib {
  
	[[self window] addInternalWidgetsForStyleMask:NSUtilityWindowMask closeOnly:NO];
  [pasteboardHistoryTable registerForDraggedTypes:standardPasteboardTypes];
  [[self window] setLevel:27];
  [[self window] setHidesOnDeactivate:NO];
  [pasteboardHistoryArray makeObjectsPerformSelector:@selector(loadIcon)];
  
  [(QSDockingWindow *)[self window] setAutosaveName:@"QSPasteboardHistoryWindow"]; // should use the real methods to do this
  NSCell *newCell = nil;
  
  //NSImageCell *imageCell = nil;
  [pasteboardHistoryTable setVerticalMotionCanBeginDrag: TRUE];
	
	NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
	
	float rowHeight = [def floatForKey:@"QSPasteboardRowHeight"];
	adjustRowsToFit = [def boolForKey:@"QSPasteboardAdjustRowHeight"];
  [pasteboardHistoryTable setRowHeight:rowHeight?rowHeight:36];
  
  [[self window] setNextResponder:self];
  [pasteboardHistoryTable setTarget:self];
  //[pasteboardHistoryTable setAction:@selector(tableAction:)];
  [pasteboardHistoryTable setDoubleAction:@selector(pasteItem:)];
  
  [pasteboardHistoryTable setTarget:self];
  
  newCell = [[[QSObjectCell alloc] init] autorelease];
  [[pasteboardHistoryTable tableColumnWithIdentifier: @"object"] setDataCell:newCell];
  
  newCell = [[[QSPasteboardAccessoryCell alloc] init] autorelease];
  
  [[pasteboardHistoryTable tableColumnWithIdentifier: @"sequence"] setDataCell:newCell];
  
  [pasteboardHistoryTable setDraggingDelegate:[self window]];
  
	//    if (0) {
	//        NSSize imageSize = [[NSImage imageNamed:@"PasteboardProxy"] size];
	//        pasteboardProxyWindow = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, imageSize.width, imageSize.height)
	//                                                         styleMask:NSBorderlessWindowMask
	//                                                           backing:NSBackingStoreBuffered defer:YES];
	//        [pasteboardProxyWindow setMovableByWindowBackground:YES];
	//        
	//        [pasteboardProxyWindow setOpaque:NO];
	//        [pasteboardProxyWindow setHasShadow:YES];
	//        [pasteboardProxyWindow setBackgroundColor:[NSColor clearColor]];
	//        [pasteboardProxyWindow setContentView:[[QSPasteboardProxyView alloc] initWithFrame:NSMakeRect(0, 0, imageSize.width, imageSize.height)]];
	//        [pasteboardProxyWindow setLevel:NSFloatingWindowLevel];  
	//        [pasteboardProxyWindow makeKeyAndOrderFront:self];
	//    }
  
  if ([pasteboardHistoryArray count]) {
		NSPasteboard *pboard = [NSPasteboard generalPasteboard];
		if (![[pboard types] count]) {
			[[pasteboardHistoryArray objectAtIndex:0] putOnPasteboard:pboard];
		}
		[pasteboardItemView setObjectValue:[pasteboardHistoryArray objectAtIndex:0]];  
		
	}
	
	
	[pasteboardHistoryTable bind:@"backgroundColor"
                            toObject:[NSUserDefaultsController sharedUserDefaultsController]
                        withKeyPath:@"values.QSAppearance3B"
                             options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
                                                                                forKey:@"NSValueTransformerName"]];
	
	
	
	[pasteboardHistoryTable bind:@"highlightColor"
                            toObject:[NSUserDefaultsController sharedUserDefaultsController]
                        withKeyPath:@"values.QSAppearance3A"
                             options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
                                                                                forKey:@"NSValueTransformerName"]];
	
	
	[[[pasteboardHistoryTable tableColumnWithIdentifier:@"object"] dataCell] bind:@"textColor"
                                                                                         toObject:[NSUserDefaultsController sharedUserDefaultsController]
                                                                                     withKeyPath:@"values.QSAppearance3T"
                                                                                          options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	[[[pasteboardHistoryTable tableColumnWithIdentifier:@"sequence"] dataCell] bind:@"textColor"
                                                                                           toObject:[NSUserDefaultsController sharedUserDefaultsController]
                                                                                        withKeyPath:@"values.QSAppearance3T"
                                                                                             options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	
	[pasteboardHistoryTable setGridColor:[[NSColor blackColor] colorWithAlphaComponent:0.1]];
	
	
}


- (id)resolveProxyObject:(id)proxy { 
	QSObject *newObject = [QSObject objectWithPasteboard:[NSPasteboard generalPasteboard]];
	return newObject;
}

- (NSArray *)typesForProxyObject:(id)proxy {
	return standardPasteboardTypes;
}


- (void)pasteboardChanged:(NSNotification*)notif {
	if (! [[NSUserDefaults standardUserDefaults] boolForKey:kCapturePasteboardHistory]) return;
	
  int maxCount = [[NSUserDefaults standardUserDefaults] integerForKey:kCapturePasteboardHistoryCount];
	
  while ([pasteboardHistoryArray count] >maxCount) [pasteboardHistoryArray removeLastObject];
  QSObject *newObject = [QSObject objectWithPasteboard:[notif object]];
  
  if (newObject) {
    
    BOOL recievingSelection = [[self selectedObject] isEqual:newObject];
		[[newObject retain] autorelease];
    if ([pasteboardHistoryArray containsObject:newObject]) {
    [pasteboardHistoryArray removeObject:newObject];
    } else {
      
      NSDate *date = [newObject objectForMeta:kQSObjectCreationDate];
      NSString *dateString = [date descriptionWithCalendarFormat:@"%y%m%d.%H%M%S.%F"
                                                        timeZone:[NSTimeZone localTimeZone]
                                                          locale:nil];
#define MAX_NAME_LENGTH 100
      NSString *name = [newObject name];
      if ([name length] > MAX_NAME_LENGTH)
        name = [name substringToIndex:MAX_NAME_LENGTH];
      //name = [NSString stringWithFormat:@"%@.%@", name,dateString];
      
      
      NSString *path = QSApplicationSupportSubPath(@"Data/Clipboard/", YES);
      path = [path stringByAppendingPathComponent:name];
      path = [path stringByAppendingPathExtension:@"qs"];
      path = [path firstUnusedFilePath];
      
      [newObject writeToFile:path];
    }
    
    [pasteboardHistoryArray insertObject:newObject atIndex:0];
		
		if (!supressCapture) {
			switch (mode) {
				case QSPasteboardQueueMode:
					[pasteboardCacheArray addObject:newObject];
					break;
				case QSPasteboardStackMode:
					[pasteboardCacheArray insertObject:newObject atIndex:0];
					break;
			}
		}
		
		supressCapture = NO;
		
    
		[pasteboardHistoryTable reloadData];
    
    if (recievingSelection) {
      [pasteboardHistoryTable selectRow:0 byExtendingSelection:NO];
    } else {
      int row = [pasteboardHistoryTable selectedRow];
      if (row>0) {
        if (row+1<[pasteboardHistoryArray count])
          [pasteboardHistoryTable selectRow:row+1 byExtendingSelection:NO];
        else 
          [pasteboardHistoryTable deselectRow:row];
      }
    }
    
		
		
    //[pasteboardItemView setObjectValue:[pasteboardHistoryArray objectAtIndex:0]];
    
    [QSLib savePasteboardHistory];
  } else {
		//  if (VERBOSE) NSLog(@"Unable to create object");
  }
  // [[pasteboardProxyWindow contentView] setObjectValue:[pasteboardHistoryArray objectAtIndex:0]];
  
  //    [self updatePasteboardMatrix];
}

- (IBAction)clearHistory:(id)sender {
	switch (mode) {
		case QSPasteboardHistoryMode:
			if ([pasteboardHistoryArray count]) {
				[pasteboardHistoryArray removeObjectsInRange:NSMakeRange(1, [pasteboardHistoryArray count] -1)];
				[pasteboardHistoryTable reloadData];
				[QSLib savePasteboardHistory];
			}
			break;
		case QSPasteboardStoreMode:
			[self clearStore];
			break;
		case QSPasteboardQueueMode:
		case QSPasteboardStackMode:
			[pasteboardCacheArray removeAllObjects];
		default:
			break;
	}
	[pasteboardHistoryTable reloadData];
}


- (void)deleteBackward:(id)sender {
	
	int index = [pasteboardHistoryTable selectedRow];
	switch (mode) {
		case QSPasteboardHistoryMode:
			if (index) {
				[pasteboardHistoryArray removeObjectAtIndex:index];
				[pasteboardHistoryTable reloadData];
				[QSLib savePasteboardHistory];
			}
			break;
		case QSPasteboardStoreMode:
			[pasteboardStoreArray replaceObjectAtIndex:index withObject:[QSNullObject nullObject]];
			
			break;
		case QSPasteboardQueueMode:
		case QSPasteboardStackMode:
			
			[pasteboardCacheArray removeObjectAtIndex:index];
		default:
			break;
	}
	[pasteboardHistoryTable reloadData];
	
}

- (void)tableAction:(id)sender {
  
}
- (IBAction)hideWindow:(id)sender {
	[[self window] saveFrame];
  if (![(QSDockingWindow *)[self window] canFade] && [[NSUserDefaults standardUserDefaults] boolForKey:@"QSPasteboardController HideAfterPasting"]) {
		[[self window] orderOut:self];
  } else {
    [(QSDockingWindow *)[self window] hide:self];
  } 	
}
- (id)selectedObject {
  int index = [pasteboardHistoryTable selectedRow];
  if (index<0) return nil;
  if (![currentArray count]) return nil;
  return [currentArray objectAtIndex:index];
}
- (void)copy:(id)sender {
  [[self selectedObject] putOnPasteboard:[NSPasteboard generalPasteboard] includeDataForTypes:nil];
}



#pragma Key  Handling

- (void)keyDown:(NSEvent *)theEvent {
  
	//  NSLog(@"%@", theEvent);
  if ([[NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", nil] containsObject:
       [theEvent charactersIgnoringModifiers]]) {
    int row = [[theEvent charactersIgnoringModifiers] intValue];
		
		if (mode == QSPasteboardStoreMode && [theEvent modifierFlags] & NSAlternateKeyMask) {
			[pasteboardStoreArray replaceObjectAtIndex:row withObject:[QSObject objectWithPasteboard:[NSPasteboard generalPasteboard]]];
			[pasteboardHistoryTable selectRow:row byExtendingSelection:NO];
		} else {
			
			[pasteboardHistoryTable selectRow:row byExtendingSelection:NO];
			[self pasteItem:self];
			[pasteboardHistoryTable reloadData];
		}
    //  if ([theEvent modifierFlags] & NSCommandKeyMask) {
    
    //  }
  }
  else
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
  //   else [super keyDown:theEvent];
}

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent {
	//NSLog(@"%@", theEvent);
	return [pasteboardMenu performKeyEquivalent:(NSEvent *)theEvent];
	return NO;
}


- (void)insertNewline:(id)sender {
  [self pasteItem:self];
}



# pragma Menu Handling

- (IBAction)toggleAdjustRows:(id)sender {
	adjustRowsToFit = !adjustRowsToFit; 	
	if (adjustRowsToFit) [self adjustRowHeight];
	[[NSUserDefaults standardUserDefaults] setBool:adjustRowsToFit forKey:@"QSPasteboardAdjustRowHeight"];
	
}

- (IBAction)showPreferences:(id)sender {
	
	[NSClassFromString(@"QSPreferencesController") showPaneWithIdentifier:@"QSPasteboardPrefPane"];
	[NSApp activateIgnoringOtherApps:YES];
}


- (IBAction)setMode:(id)sender {
	[self switchToMode:[sender tag]];
}
- (void)switchToMode:(int)newMode {
	mode = newMode;
	switch (mode) {
		case QSPasteboardHistoryMode:
			[titleField setStringValue:@"Clipboard History"];
			currentArray = pasteboardHistoryArray;
			break;
		case QSPasteboardStoreMode:
			
			[titleField setStringValue:@"Clipboard Storage"];
			currentArray = pasteboardStoreArray;
			break;
		case QSPasteboardQueueMode:
			[titleField setStringValue:@"Clipboard Cache Old"];
			[self setCacheIsReversed:YES];
			currentArray = pasteboardCacheArray;
			break;
		case QSPasteboardStackMode:
			[titleField setStringValue:@"Clipboard Cache New"];
			[self setCacheIsReversed:NO];
			currentArray = pasteboardCacheArray;
		default:
			break;
	}
	[pasteboardHistoryTable reloadData];
}
- (void)setCacheIsReversed:(BOOL)reverse {
	if (reverse != cacheIsReversed) {
		[pasteboardCacheArray reverse];
		cacheIsReversed = reverse;
	}
}

- (BOOL)validateMenuItem:(NSMenuItem*)anItem {
	//NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	if ([anItem action] == @selector(setMode:) ) {
		[anItem setState:[anItem tag] == mode];
		return YES;
	}
	if ([anItem action] == @selector(toggleAdjustRows:) ) {
		[anItem setState:adjustRowsToFit];
		return YES;
	}
	
	return YES;
}



# pragma Table Handling

- (int) numberOfRowsInTableView:(NSTableView *)tableView {
  return [currentArray count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
  //  rowIndex++;
	if (rowIndex>[currentArray count]) {
		return nil;
	}
  if ([[aTableColumn identifier] isEqualToString:@"object"] && [currentArray count] >rowIndex)
    return [currentArray objectAtIndex:rowIndex];
  if ([[aTableColumn identifier] isEqualToString:@"sequence"]) {
    if (rowIndex<10) return [NSNumber numberWithInt:rowIndex];
  }
	
	//	if ([[aTableColumn identifier] isEqualToString:@"source"]) {
	//        NSString *source = [[pasteboardHistoryArray objectAtIndex:rowIndex] objectForKey:kQSObjectSource];
	//        if (!source) source = @"Unknown";
	//        return source;
	//    } 	
	//    if ([[aTableColumn identifier] isEqualToString:@"name"])
	//        return [[pasteboardHistoryArray objectAtIndex:rowIndex] name];
	//    if ([[aTableColumn identifier] isEqualToString:@"date"])
	//        return [NSDate dateWithTimeIntervalSinceReferenceDate:[[[pasteboardHistoryArray objectAtIndex:rowIndex] objectForKey:kQSObjectSource] floatValue]];  
	
  return nil;
}
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
  //NSLog(@"setCell %d", rowIndex);
  
  if ([[aTableColumn identifier] isEqualToString:@"object"]) {
    [aCell setRepresentedObject:[currentArray objectAtIndex:rowIndex]];
		[aCell setState:NSOffState];
  }
}
static int _draggedRow = -1;
- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard {
	
	_draggedRow = [[rows objectAtIndex:0] intValue];
	
	if ([[currentArray objectAtIndex:_draggedRow] isKindOfClass:[QSNullObject class]]) return NO;
  [[currentArray objectAtIndex:[[rows objectAtIndex:0] intValue]]putOnPasteboard:pboard includeDataForTypes:nil];
  return YES;
}
- (NSDragOperation) tableView:(NSTableView *)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation {
	switch (mode) {
		case QSPasteboardHistoryMode:
			if ([info draggingSource] == tableView) return NSDragOperationNone;
			[tableView setDropRow:0 dropOperation:NSTableViewDropAbove];
			break;
		case QSPasteboardStoreMode:
			if (operation == NSTableViewDropAbove || row == _draggedRow) return NSDragOperationNone;
			break;
		case QSPasteboardQueueMode:
		case QSPasteboardStackMode:
			if (operation != NSTableViewDropAbove) return NSDragOperationNone;
			break;
		default:
			break;
	}
	
	
  if ([info draggingSource] == tableView)
		return NSDragOperationMove;
	return NSDragOperationCopy;
}
- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation {
	
	QSObject *object = nil;
	
	if ([info draggingSource] == tableView)
		object = [currentArray objectAtIndex:_draggedRow];
	else
		object = [QSObject objectWithPasteboard:[info draggingPasteboard]];
	switch (mode) {
		case QSPasteboardHistoryMode:
			if ([info draggingSource] != tableView)
				[object putOnPasteboard:[NSPasteboard generalPasteboard]];
			break;
		case QSPasteboardStoreMode:
			
			[pasteboardStoreArray replaceObjectAtIndex:row withObject:object];
			
			if ([info draggingSource] == tableView)
				[pasteboardStoreArray replaceObjectAtIndex:_draggedRow withObject:[QSNullObject nullObject]];
      break;
		case QSPasteboardQueueMode:
		case QSPasteboardStackMode:
			if ([info draggingSource] == tableView)
				[pasteboardCacheArray moveIndex:_draggedRow toIndex:row];
			else
				[pasteboardCacheArray insertObject:object atIndex:row];
			break;
		default:
			break;
	}
	[pasteboardHistoryTable reloadData];
  //  NSLog(@"source %@", [info draggingSource]);
	
  return YES;
}


# pragma Window Handling

- (void)windowDidResignKey:(NSNotification *)aNotification {
	//	NSLog(@"visible");  
}

- (void)windowDidBecomeKey:(NSNotification *)aNotification {
	//	NSLog(@"visible");
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"QSPasteboardHistoryIsVisible"];  
}
- (void)windowWillClose:(NSNotification *)aNotification {
	//NSLog(@"invisible");
	
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"QSPasteboardHistoryIsVisible"];  
}

- (void)adjustRowHeight {
	float height = (int) (NSHeight([[pasteboardHistoryTable enclosingScrollView] frame])/10-2);
	height = MAX(height, 10.0);
	[[NSUserDefaults standardUserDefaults] setFloat:height forKey:@"QSPasteboardRowHeight"];
	[pasteboardHistoryTable setRowHeight:height];
  
}
- (void)windowDidResize:(NSNotification *)aNotification {
	int key = [[NSApp currentEvent] modifierFlags] & NSAlternateKeyMask;
	
	if ((adjustRowsToFit || key) && !(adjustRowsToFit && key) )
		[self adjustRowHeight];
	
	//if (!adjustRowsToFit && ") ) {
	//	}
}


@end
