#import "QSMiniInterfaceController.h"

#import <QSFoundation/NSGeometry_BLTRExtensions.h>
#import <IOKit/IOCFBundle.h>
#import <ApplicationServices/ApplicationServices.h>
#import <QSEffects/QSEffects.h>
#import <QSInterface/QSInterface.h>

#import <QSEffects/QSWindow.h>

//#import "QSMenuButton.h"

#define DIFF 18

NSRect alignRectInRect(NSRect innerRect,NSRect outerRect,int quadrant);

@implementation QSMiniInterfaceController


- (id)init {
    self = [super initWithWindowNibName:@"MiniInterface"];
    if (self) {

    }
    return self;
}

- (void) windowDidLoad{
        [super windowDidLoad];
    [[self window] setLevel:NSModalPanelWindowLevel];
    [[self window] setFrameAutosaveName:@"MiniInterfaceWindow"];
    
    [[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];
    [(QSWindow *)[self window]setHideOffset:NSMakePoint(150,0)];
    [(QSWindow *)[self window]setShowOffset:NSMakePoint(-150,0)];
    
	
	[[self window] setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSVExpandEffect",@"transformFn",@"show",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]];
	//	[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:.25],@"duration",nil]];
	
	[[self window] setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSExplodeEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.2],@"duration",nil]
							  forKey:kQSWindowExecEffect];
	
	[[self window] setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"hide",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]
							  forKey:kQSWindowFadeEffect];
	
	[[self window] setWindowProperty:[NSDictionary dictionaryWithObjectsAndKeys:@"QSVContractEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:0.333],@"duration",nil,[NSNumber numberWithFloat:0.25],@"brightnessB",@"QSStandardBrightBlending",@"brightnessFn",nil]
							  forKey:kQSWindowCancelEffect];
	
	
	
	[dSelector setCollectionSpace:0.0f];
	[iSelector setCollectionSpace:0.0f];
	[dSelector setCollectionEdge:NSMinXEdge];
	[iSelector setCollectionEdge:NSMinXEdge];
	
	
	
    [self contractWindow:self];
}

- (void)updateViewLocations{
    [super updateViewLocations];

 //   [[[self window]contentView]display];
}


- (void)hideMainWindow:(id)sender{

    [[self window] saveFrameUsingName:@"MiniInterfaceWindow"];
    
    [super hideMainWindow:sender];
}

- (NSSize)maxIconSize{
    return NSMakeSize(32,32);
}
- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
    //
    return NSOffsetRect(NSInsetRect(rect,8,0),0,-21);
    return NSMakeRect(0,[(NSView *)[window firstResponder]frame].origin.y,NSWidth(rect),0);
}


- (void)showIndirectSelector:(id)sender{
    if (![iSelector superview] && !expanded)
        [iSelector setFrame:NSOffsetRect([aSelector frame],0,-NSHeight([aSelector frame]))];
    [super showIndirectSelector:sender];
}

- (void)expandWindow:(id)sender{ 
  
    NSRect expandedRect=[[self window]frame];
    
   // float diff=28;
    expandedRect.size.height+=DIFF;
    expandedRect.origin.y-=DIFF;
     if (!expanded)
    [[self window]setFrame:expandedRect display:YES animate:YES];
    [super expandWindow:sender];
}

- (void)contractWindow:(id)sender{
    NSRect contractedRect=[[self window]frame];
    
    contractedRect.size.height-=DIFF;
    contractedRect.origin.y+=DIFF;
    
    if (expanded)
        [[self window]setFrame:contractedRect display:YES animate:YES];
    
    [super contractWindow:sender];
}


@end
















