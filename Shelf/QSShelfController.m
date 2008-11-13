#import "QSShelfController.h"
#import <QSBase/QSCore.h>
#import <QSBase/QSObject_Pasteboard.h>
#import <QSBase/QSLibrarian.h>
#import <QSBase/QSDockingWindow.h>
#import <QSBase/QSObjectView.h> 
#import <QSBase/QSObjectCell.h>
#import <QSBase/QSInterfaceController.h>

#import <QSBase/QSInterfaceMediator.h>



@implementation QSShelfController

+ (void)initialize {
	[self loadPlugIn];
}

+ (void)loadPlugIn{
	NSMenu *modulesMenu=[[[NSApp mainMenu]itemWithTag:128]submenu];
	NSMenuItem *modMenuItem=[modulesMenu addItemWithTitle:@"Shelf" action:@selector(showShelf:) keyEquivalent:@"s"];
	[modMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask|NSCommandKeyMask];
	[modMenuItem setTarget:self];
	
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	if([defaults boolForKey:@"QSGeneralShelfIsVisible"]){
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showShelfHidden:) name:@"QSApplicationDidFinishLaunchingNotification" object:nil];
	}	
	NSImage *image=[NSImage imageNamed:@"Catalog"];
	image=[image duplicateOfSize:QSSize16];
	[modMenuItem setImage:image];
	return ;	
}

+ (void)showShelfHidden:(id)sender{
	[(QSDockingWindow *)[[self sharedInstance]window]orderFrontHidden:sender];
}



+ (void)showClipboardHidden:(id)sender{
	[(QSDockingWindow *)[[self sharedInstance]window]orderFrontHidden:sender];
}




+ (id)sharedInstance{
    static id _sharedInstance;
    if (!_sharedInstance) _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    return _sharedInstance;
}

+ (void)showShelf:(id)sender{
	[(QSDockingWindow *)[[self sharedInstance]window]toggle:sender];
}


- (id)init {
    self = [self initWithWindowNibName:@"QSShelf"];
    if (self) {

    } 
    return self;
}

- (void)awakeFromNib{
    NSMutableArray *types=[[standardPasteboardTypes mutableCopy]autorelease];
    [types addObjectsFromArray:[[QSReg objectHandlers]allKeys]];
    [shelfTableView registerForDraggedTypes:types];
    
    
    //[[self window] addInternalWidgetsForStyleMask:NSUtilityWindowMask];
    
    QSObjectCell *objectCell=nil;
    
    [shelfTableView setVerticalMotionCanBeginDrag: TRUE];
    // [shelfTableView setRowHeight:20];
    objectCell = [[[QSObjectCell alloc] init] autorelease];
    [[shelfTableView tableColumnWithIdentifier: @"Name"] setDataCell:objectCell];
    
    [shelfTableView setTarget:self];
    
    //[shelfTableView setAction:@selector(tableAction:)];
    [shelfTableView setDoubleAction:@selector(tableDoubleAction:)];
   // [(QSTableView *)shelfTableView setDraggingDelegate:[self window]];
	
	
	[shelfTableView bind:@"backgroundColor"
						toObject:[NSUserDefaultsController sharedUserDefaultsController]
					 withKeyPath:@"values.QSAppearance3B"
						 options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
															 forKey:@"NSValueTransformerName"]];
	
	
	
	[shelfTableView bind:@"highlightColor"
						toObject:[NSUserDefaultsController sharedUserDefaultsController]
					 withKeyPath:@"values.QSAppearance3A"
						 options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
															 forKey:@"NSValueTransformerName"]];
	
	
	[[[shelfTableView tableColumnWithIdentifier:@"Name"] dataCell] bind:@"textColor"
																		 toObject:[NSUserDefaultsController sharedUserDefaultsController]
																	  withKeyPath:@"values.QSAppearance3T"
																		  options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	
	[shelfTableView setGridColor:[[NSColor blackColor]colorWithAlphaComponent:0.1]];
	
	
//	[shelfTableView bind:@"backgroundColor"
//						toObject:[NSUserDefaultsController sharedUserDefaultsController]
//					 withKeyPath:@"values.QSAppearance3B"
//						 options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
//															 forKey:@"NSValueTransformerName"]];
//	
//	
//	
//	[shelfTableView bind:@"highlightColor"
//						toObject:[NSUserDefaultsController sharedUserDefaultsController]
//					 withKeyPath:@"values.QSAppearance3A"
//						 options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
//															 forKey:@"NSValueTransformerName"]];
//	
//	
//	[[[shelfTableView tableColumnWithIdentifier:@"Name"] dataCell] bind:@"textColor"
//																		 toObject:[NSUserDefaultsController sharedUserDefaultsController]
//																	  withKeyPath:@"values.QSAppearance3T"
//																		  options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
//		
//	[shelfTableView setGridColor:[[NSColor blackColor]colorWithAlphaComponent:0.1]];
	
    return;
    //  int i;
    //  for(i=0;i<[tabView numberOfTabViewItems];i++){
    
    //     NSTableView *tableView=[[NSTableView alloc]initWithFrame:NSZeroRect];
    // [[tabView tabViewItemAtIndex:i]setView:
    //    tableView];
    
    //    [tableView setDataSource:self];
    //       [tableView addTableColumn:[[NSTableColumn alloc]initWithIdentifier:@"Name"]];
    //[[[QSShelfView alloc]initWithName:[[tabView tabViewItemAtIndex:i]identifier]]autorelease];
    }


- (void)windowDidBecomeKey:(NSNotification *)aNotification{
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"QSGeneralShelfIsVisible"];   
}
- (void)windowWillClose:(NSNotification *)aNotification{
}
- (BOOL)windowShouldClose:(id)sender{
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"QSGeneralShelfIsVisible"];    

	return YES;
}
- (void)windowDidLoad {
    
    [super windowDidLoad];
    [[self window]setMovableByWindowBackground:YES];

    [[self window]setLevel:27];
    
    [[self window] setHidesOnDeactivate:NO];
    
    [(QSDockingWindow *)[self window] setAutosaveName:@"ShelfWindow"];
    [[QSLib shelfNamed:@"General"] makeObjectsPerformSelector:@selector(loadIcon)];
	
	[[self window] addInternalWidgetsForStyleMask:NSUtilityWindowMask];    
    //[[self window] addInternalWidgets];
    //[[self window] setMovableByWindowBackground:YES];

  //  [[self window]setContentView:[[QSShelfView alloc]initWithFrame:NSZeroRect]];
  
    //    [webSearchWindow setFrameTopLeftPoint:[mainWindow frame].origin];
}


- (BOOL)addObject:(QSObject *)object atIndex:(int)index{
    NSMutableArray *shelfArray=[[QSLibrarian sharedInstance]shelfNamed:@"General"];
    [shelfArray insertObject:object atIndex:index];
    [shelfTableView reloadData];
    [shelfTableView selectRow:index byExtendingSelection:NO];
    if ([[self window]isVisible])[(QSDockingWindow *)[self window]show:self];
    [[QSLibrarian sharedInstance]saveShelf:@"General"];
	return YES;
}


//Outline Methods

- (int)numberOfRowsInTableView:(NSTableView *)tableView{
    return [[QSLib shelfNamed:@"General"]count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
    if ([[aTableColumn identifier]isEqualToString:@"Name"]){
        NSString *source=[[[[QSLibrarian sharedInstance]shelfNamed:@"General"] objectAtIndex:rowIndex]displayName];
        if (!source)source=@"Unknown";
        return source;
    }
    return nil;
}



- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex{
        if ([[aTableColumn identifier]isEqualToString:@"Name"]){
            [aCell setRepresentedObject:[[QSLib shelfNamed:@"General"] objectAtIndex:rowIndex]];
            [aCell setState:NSOffState];
        }
 }

- (void)keyDown:(NSEvent *)theEvent{
	//NSLog(@"KeyD: %@",[theEvent characters]);
	[self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];

	
}
- (void)deleteBackward:(id)sender{
    NSLog(@"delete");
    int index=[shelfTableView selectedRow];

    NSMutableArray *shelfArray=[[QSLibrarian sharedInstance]shelfNamed:@"General"];
    if (index>=0) [shelfArray removeObjectAtIndex:index];

    [[QSLibrarian sharedInstance]saveShelf:@"General"];

    [shelfTableView reloadData];
}

- (BOOL)tableView:(NSTableView *)tv didDepositRow:(int)rowToMove at:(int)newPosition{
   // NSLog(@"accept drag");
    NSMutableArray *shelfArray=[[QSLibrarian sharedInstance]shelfNamed:@"General"];
    [shelfArray insertObject:[shelfArray objectAtIndex:rowToMove] atIndex:newPosition];
    [shelfArray removeObjectAtIndex:rowToMove+(rowToMove>newPosition?1:0)];
    return YES;
}



static int _moveRow = -1;

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard{
	NSLog(@"drag");
    _moveRow = [[rows objectAtIndex:0]intValue];
    [[[[QSLibrarian sharedInstance]shelfNamed:@"General"] objectAtIndex:_moveRow] putOnPasteboard:pboard];
    return YES;
}

- (void)tableView:(NSTableView *)tv dropEndedWithOperation:(NSDragOperation)operation{
    if (VERBOSE)NSLog(@"dropped withOp %d",operation);
    
    if (operation==NSDragOperationDelete || operation==NSDragOperationMove){
        NSMutableArray *shelfArray=[[QSLibrarian sharedInstance]shelfNamed:@"General"];
        if (index>=0) [shelfArray removeObjectAtIndex:_moveRow];
        
        [[QSLibrarian sharedInstance]saveShelf:@"General"];
        
        [shelfTableView reloadData];
    }
}

- (BOOL)tableView:(NSTableView*)tableView acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)operation{
    
    if ([info draggingSource]!=tableView){
        id theObject=nil;
        if ([[info draggingSource]isKindOfClass:[QSObjectView class]])theObject=[[info draggingSource]objectValue];
        else theObject=[QSObject objectWithPasteboard:[info draggingPasteboard]];
        
        if (theObject) [[QSLib shelfNamed:@"General"]insertObject:theObject atIndex:MAX(row,0)];
    }
    else{
        [self tableView:tableView didDepositRow:_moveRow at:MAX(row,0)];
    }
  //  id source=[info draggingSource];
    [[QSLibrarian sharedInstance]saveShelf:@"General"];
    [tableView reloadData];
    return YES;
}


- (void)paste:(id)sender{
    [[QSLib shelfNamed:@"General"]insertObject:[QSObject objectWithPasteboard:[NSPasteboard generalPasteboard]]
                                                                 atIndex:MAX([shelfTableView selectedRow],0)];
    [QSLib saveShelf:@"General"];
    [shelfTableView reloadData];
}

- (void)copy:(id)sender{
      int index=[shelfTableView selectedRow];
    [[[[QSLibrarian sharedInstance]shelfNamed:@"General"] objectAtIndex:index] putOnPasteboard:[NSPasteboard generalPasteboard] includeDataForTypes:nil];
}

- (IBAction)tableDoubleAction:(id)sender{
    id selectedObject=[[QSLib shelfNamed:@"General"] objectAtIndex:[shelfTableView selectedRow]];
    QSAction *action=[[QSLib rankedActionsForDirectObject:selectedObject indirectObject:nil]objectAtIndex:0];
    int argumentCount=[(QSAction *)action argumentCount];
     
   // if (VERBOSE) NSLog(@"double %@ %@",selectedObject, action);
    if (argumentCount==2)
        [[QSReg preferredCommandInterface] executePartialCommand:[NSArray arrayWithObjects:selectedObject,nil]];
    else
        [action performOnDirectObject:selectedObject indirectObject:nil];
    
    
// ***warning   * if ambiguous this should ask which action to use
}

- (NSMenu *)tableView:(NSTableView*)tableView menuForTableColumn:(NSTableColumn *)column row:(int)row{
    [tableView selectRow:row byExtendingSelection:NO];
    //NSLog(@"menu");
    return [[column dataCell] menuForObject:[[QSLib shelfNamed:@"General"] objectAtIndex:row]];
}
- (NSDragOperation)tableView:(NSTableView*)tableView validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)operation{
//      NSLog(@"validate %@",[info draggingSource]);
    if (operation==NSTableViewDropAbove)
        return NSDragOperationEvery;
    else
        return NSDragOperationNone;
}


@end
