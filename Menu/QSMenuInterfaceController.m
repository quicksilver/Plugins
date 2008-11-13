#import "QSMenuInterfaceController.h"
#import <Carbon/Carbon.h>
#import <IOKit/IOCFBundle.h>
#import <ApplicationServices/ApplicationServices.h>

#import <QSInterface/QSSearchObjectView.h>


@implementation QSMenuInterfaceController


- (id)init {
    self = [self initWithWindowNibName:@"MenuInterface"];
    if (self) {

    }
    return self;
}


- (void)windowDidLoad{
    [super windowDidLoad];
    [menuButton setMenuOffset:NSMakePoint(0.0,1.0)];
	[[self window]setOpaque:YES];
	[[[self window]contentView]setDepth:1.5];
	[[self menuButton]setDrawBackground:YES];
	
    [[dSelector cell] setBezeled:YES];
    [[aSelector cell] setBezeled:YES];
    [[iSelector cell] setBezeled:YES];
    [[dSelector cell] setShowDetails:NO];
    [[aSelector cell] setShowDetails:NO];
    [[iSelector cell] setShowDetails:NO];
    [[dSelector cell] setTextColor:[NSColor blackColor]];
    [[aSelector cell] setTextColor:[NSColor blackColor]];
    [[iSelector cell] setTextColor:[NSColor blackColor]];
    
    
    [dSelector setPreferredEdge:NSMinYEdge];
    [aSelector setPreferredEdge:NSMinYEdge];
    [iSelector setPreferredEdge:NSMinYEdge];
	
    [dSelector setResultsPadding:1];
    [aSelector setResultsPadding:1];
    [iSelector setResultsPadding:1];
   // NSLog(@"menu!");

    [self updateViewLocations];
}

- (void)updateViewLocations{
    [super updateViewLocations];

    NSRect dFrame=[dSelector frame];
    NSRect aFrame=[aSelector frame];
    NSRect iFrame=[iSelector frame];
    dFrame.size.width=MIN(256,(int)[[dSelector cell]cellSize].width);
    aFrame.size.width=MIN(256,(int)[[aSelector cell]cellSize].width);
    iFrame.size.width=MIN(256,(int)[[iSelector cell]cellSize].width);
    aFrame.origin.x=NSMaxX(dFrame)+4;
    iFrame.origin.x=NSMaxX(aFrame)+4;
    [dSelector setFrame:dFrame];
    [aSelector setFrame:aFrame];
    [iSelector setFrame:iFrame];
    [[[self window]contentView]setNeedsDisplay:YES];
}

- (NSSize)maxIconSize{
    return NSMakeSize(32,32);
}
- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
   // logRect(rect);
    return NSOffsetRect(rect,0,-NSHeight([window frame]));
 
}
@end
















