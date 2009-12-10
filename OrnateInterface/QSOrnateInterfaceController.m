#import "QSOrnateInterfaceController.h"
#import <IOKit/IOCFBundle.h>
#import <ApplicationServices/ApplicationServices.h>

#import <QSCore/QSMacros.h>
#import <QSInterface/QSBezelBackgroundView.h>
#import <QSInterface/QSInterface.h>
#import <QSInterface/QSObjectCell.h>
//#import <QSInterface/QSFancyObjectCell.h>
#import <QSInterface/QSSearchObjectView.h>

//#import <QSCore/DRColorPermutator.h>
#import <QSCore/QSResourceManager.h>
#import <QSFoundation/NSGeometry_BLTRExtensions.h>
#import <QSFoundation/QSFoundation.h>
#import <QSInterface/QSInterface.h>
//#import "QSMenuButton.h"


#define repeatWith(x,y) id x;NSEnumerator *rwEnum=[y objectEnumerator];while(x=[rwEnum nextObject])

@implementation QSOrnateInterfaceController


- (id)init {
    self = [self initWithWindowNibName:@"OrnateInterface"];
    if (self) {
        NSLog(@"init");
		// NSApplicationDidChangeScreenParametersNotification
    }
    return self;
}

- (void) setGiltColor:(NSColor *)color{
	
	NSLog(@"color %@",color);
	NSImage *rImage=[[NSBundle bundleForClass:[self class]]imageNamed:@"OrnateRight"];
	NSImage *lImage=[[NSBundle bundleForClass:[self class]]imageNamed:@"OrnateLeft"];
	
	
	if (![color isEqual:[NSColor controlHighlightColor]]){
		DRColorPermutator *perm=[[[DRColorPermutator alloc]init]autorelease];
		NSColor *uiColor=color;
		uiColor=[uiColor colorUsingColorSpaceName:NSDeviceRGBColorSpace];
		float hue=[uiColor hueComponent];
		float saturation=[uiColor saturationComponent]*2;
		
		[perm rotateHueByDegrees:hue*360-30 preservingLuminance:NO fromScratch:YES];
		[perm changeSaturationBy:saturation fromScratch:NO];
		[perm applyToBitmapImageRep:(NSBitmapImageRep *)[rImage bestRepresentationForDevice:nil]];
		[perm applyToBitmapImageRep:(NSBitmapImageRep *)[lImage bestRepresentationForDevice:nil]];
		[lImage setName:nil];
		[rImage setName:nil];
	}
	[leftView setImage:lImage];
	[rightView setImage:rImage];
	
}

- (NSColor *)giltColor{
	return nil;
}


- (void) windowDidLoad{
    [super windowDidLoad];
	   NSLog(@"awake %@",[self window]);
	   logRect([[self window]frame]);
    [[self window]setLevel:kCGUtilityWindowLevel];
    
	QSWindow *window=(QSWindow *)[self window];
	   NSLog(@"win %x",window);
  //  [window setHideOffset:NSMakePoint(0,-20)];
    //[window setShowOffset:NSMakePoint(0,-10)];
    
	   logRect([window frame]);
	   [window setFrame:NSMakeRect(0,0,728,346) display:YES];
	[window setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSGrowEffect",@"transformFn",@"show",@"type",[NSNumber numberWithFloat:0.144],@"duration",nil]];
	[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSShrinkEffect",@"transformFn",@"hide",@"type",nil]];
	
	
	//   [[self window] contentView];
    
    standardRect=centerRectInRect([[self window]frame],[[NSScreen mainScreen]frame]);
	
	[[self window]setFrame:standardRect display:YES];
	
	
	[bezelView bind:@"color"
		   toObject:[NSUserDefaultsController sharedUserDefaultsController]
						  withKeyPath:@"values.QSAppearance1B"
			options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	[self bind:@"giltColor"
	  toObject:[NSUserDefaultsController sharedUserDefaultsController]
   withKeyPath:@"values.QSAppearance2B"
	   options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	[commandView bind:@"textColor"
			 toObject:[NSUserDefaultsController sharedUserDefaultsController]
		  withKeyPath:@"values.QSAppearance1T"
			  options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	
	[bezelView setGlassStyle:QSGlossDownArc];
	
	[bezelView setRadius:0.0];
    [[self window]setHasShadow:NO];
    [[self window]setMovableByWindowBackground:NO];
	  [(QSWindow *)[self window]setFastShow:YES];
	
	
	   NSArray *theControls=[NSArray arrayWithObjects:dSelector,aSelector,iSelector,nil];
	   foreach(theControl,theControls){
		   NSCell *theCell=[[[QSFancyObjectCell alloc]init]autorelease];
		   [theControl setCell:theCell];
		   [theCell setIconSize:NSMakeSize(128,128)];
		   [theCell setAlignment:NSCenterTextAlignment];
		   [theCell setImagePosition:NSImageBelow];
		   [theControl setPreferredEdge:NSMinYEdge];
		   [theControl setResultsPadding:NSMinY([dSelector frame])-NSMinY([bezelView frame])];
		   [theControl setPreferredEdge:NSMinYEdge];
		   //  [[((QSSearchObjectView *)theControl)->resultController window]setHideOffset:NSMakePoint(0,NSMinY([iSelector frame]))];
		   // [[((QSSearchObjectView *)theControl)->resultController window]setShowOffset:NSMakePoint(0,NSMinY([dSelector frame]))];
		   
		   [(QSObjectCell *)theCell setShowDetails:YES];
		   [(QSObjectCell *)theCell setTextColor:[NSColor whiteColor]];
		   //[(QSObjectCell *)theCell setState:NSOnState];
		   
		   [theCell bind:@"highlightColor"
				toObject:[NSUserDefaultsController sharedUserDefaultsController]
			 withKeyPath:@"values.QSAppearance1A"
				 options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
		   
		   [theCell bind:@"textColor"
				toObject:[NSUserDefaultsController sharedUserDefaultsController]
			 withKeyPath:@"values.QSAppearance1T"
				 options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	   }
	   
	   //[(dSelector->resultController)->resultTable setBackgroundColor:[NSColor blackColor]];
	   // [[self menuButton]setHidden:![NSApp isUIElement]];
	   
	   NSLog(@"win %d",[[self window]frame].size.height);
	   [self contractWindow:nil];
	   [[self window]setAlphaValue:1.0];
	   NSLog(@"win %d",[[self window]frame].size.height);
}

- (NSSize)maxIconSize{
    return NSMakeSize(128,128);
}



- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
	return NSOffsetRect(NSInsetRect(rect,8,0),0,-21);
}


- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification{
    
}









- (void)showMainWindow:(id)sender{
	[[self window]setFrame:[self rectForState:[self expanded]]  display:YES];
	//if ([[self window]isVisible])[[self window]pulse:self];
    [super showMainWindow:sender];
}

- (void)expandWindow:(id)sender{ 
    if (![self expanded])
        [[self window]setFrame:[self rectForState:YES] display:YES animate:YES];
    [super expandWindow:sender];
}
- (void)contractWindow:(id)sender{
    if ([self expanded])
        [[self window]setFrame:[self rectForState:NO] display:YES animate:YES];
    [super contractWindow:sender];
}


- (NSRect)rectForState:(BOOL)shouldExpand{ 
    NSRect newRect=standardRect;
    NSRect screenRect=[[NSScreen mainScreen]frame];
    if (!shouldExpand){
        newRect.size.width-=NSMaxX([iSelector frame])-NSMaxX([aSelector frame]);
        newRect=centerRectInRect(newRect,[[NSScreen mainScreen]frame]);
    }
    newRect=centerRectInRect(newRect,screenRect);
    newRect=NSOffsetRect(newRect,0,NSHeight(screenRect)/8);
    return newRect;
}






@end
















