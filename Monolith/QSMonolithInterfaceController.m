#import "QSMonolithInterfaceController.h"
#import "QSPasteboardController.h"
#import <Carbon/Carbon.h>

#import <QSCore/BLTRExtensions.h>

#import <IOKit/IOCFBundle.h>
#import <ApplicationServices/ApplicationServices.h>
#import "QSPasteboardMonitor.h"

//#import "QSMenuButton.h"

NSRect alignRectInRect(NSRect innerRect,NSRect outerRect,int quadrant);

@implementation QSMonolithInterfaceController


- (id)init {
    self = [super initWithWindowNibName:@"MonolithInterface"];
    if (self) {

    }
    return self;
}

- (void) windowDidLoad{
        [super windowDidLoad];
        logRect([[self window]frame]);
    [[self window] setLevel:NSFloatingWindowLevel];
//[[self window] setFrameUsingName:@"WindowInterfaceWindow"];
    
    [[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];
    [(QSWindow *)[self window]setHideOffset:NSMakePoint(500,0)];
    [(QSWindow *)[self window]setShowOffset:NSMakePoint(-500,0)];
    
	[[aSelector cell]setImagePosition:NSImageAbove];
  //  standardRect=[[self window]frame],[[NSScreen mainScreen]frame]);

   // [setHidden:![NSApp isUIElement]];

    
   // [[[self window] _borderView]_resetDragMargins];
   //  */
    [self contractWindow:self];
}

- (void)updateViewLocations{
    [super updateViewLocations];

    [[[self window]contentView]display];
}


- (void)hideMainWindow:(id)sender{

//    [[self window] saveFrameUsingName:@"WindowInterfaceWindow"];
    
    [super hideMainWindow:sender];
}

- (NSSize)maxIconSize{
    return NSMakeSize(128,128);
}
- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
    //
    return NSOffsetRect(NSInsetRect(rect,8,0),0,-21);
    return NSMakeRect(0,[(NSView *)[window firstResponder]frame].origin.y,NSWidth(rect),0);
}






- (void)expandWindow:(id)sender{ 
  
    NSRect expandedRect=[[self window]frame];
    
    float diff=128;
    expandedRect.size.height+=diff;
    expandedRect.origin.y-=diff;
     if (!expanded)
    [[self window]setFrame:expandedRect display:YES animate:YES];
    [super expandWindow:sender];
}

- (void)contractWindow:(id)sender{
    NSRect contractedRect=[[self window]frame];
    float diff=128;
    contractedRect.size.height-=diff;
    contractedRect.origin.y+=diff;
    
    if (expanded)
        [[self window]setFrame:contractedRect display:YES animate:YES];
    
    [super contractWindow:sender];
}


@end
















