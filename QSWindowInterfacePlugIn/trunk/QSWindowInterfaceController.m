#import "QSWindowInterfaceController.h"
#import <Carbon/Carbon.h>
#import <QSFoundation/NSGeometry_BLTRExtensions.h>
#import <QSEffects/QSWindow.h>
#import <QSInterface/QSSearchObjectView.h>

#import <IOKit/IOCFBundle.h>
#import <ApplicationServices/ApplicationServices.h>
//#import "QSMenuButton.h"

#define EXPAND_HEIGHT 28

//NSRect alignRectInRect(NSRect innerRect,NSRect outerRect,int quadrant);

@implementation QSWindowInterfaceController

- (id)init {
	if (self = [super initWithWindowNibName:@"QSWindowInterface"]){
    }
    return self;
}

- (NSSize)maxIconSize{
    return NSMakeSize(32,32);
}

- (void) windowDidLoad{
	[super windowDidLoad];
    [[self window] setLevel:NSModalPanelWindowLevel];
    [[self window] setFrameAutosaveName:@"WindowInterfaceWindow"];
    
    [[self window]setFrame:constrainRectToRect([[self window]frame],[[[self window]screen]visibleFrame]) display:NO];
    [(QSWindow *)[self window]setHideOffset:NSMakePoint(0,-99)];
    [(QSWindow *)[self window]setShowOffset:NSMakePoint(0,99)];

    [self contractWindow:self];
}

- (void)updateViewLocations{
    [super updateViewLocations];
}


- (void)hideMainWindow:(id)sender{
    [[self window] saveFrameUsingName:@"WindowInterfaceWindow"];
    [super hideMainWindow:sender];
	[self contractWindow:self];
}



- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
    return NSOffsetRect(NSInsetRect(rect,8,0),0,-21);
}



- (void)showIndirectSelector:(id)sender{
    if (![iSelector superview] && !expanded)
        [iSelector setFrame:NSOffsetRect([aSelector frame],0,-26)];
    [super showIndirectSelector:sender];
}

- (void)expandWindow:(id)sender{ 
    NSRect expandedRect=[[self window]frame];
	
    expandedRect.size.height+=EXPAND_HEIGHT;
    expandedRect.origin.y-=EXPAND_HEIGHT;
     if (!expanded)
    [[self window]setFrame:expandedRect display:YES animate:YES];
	 
    [super expandWindow:sender];
}

- (void)contractWindow:(id)sender{
    NSRect contractedRect=[[self window]frame];
    
    contractedRect.size.height-=EXPAND_HEIGHT;
    contractedRect.origin.y+=EXPAND_HEIGHT;

    if (expanded)
        [[self window]setFrame:contractedRect display:YES animate:YES];
    
    [super contractWindow:sender];
}


@end