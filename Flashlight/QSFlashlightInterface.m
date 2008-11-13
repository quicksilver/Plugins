//
//  QSFlashlightInterface.m
//  QSFlashlightInterface
//
//  Created by Nicholas Jitkoff on 7/7/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSFlashlightInterface.h"
#import <QSEffects/QSEffects.h>
#import <QSInterface/QSInterface.h>

#import <QSEffects/QSWindow.h>
@implementation QSFlashlightInterface

- (id)init {
    self = [self initWithWindowNibName:@"Flashlight"];
    if (self) {
		
    }
    return self;
}


- (void)windowDidLoad{
    [super windowDidLoad];
    [menuButton setMenuOffset:NSMakePoint(0.0,1.0)];
	[[self window]setLevel:kCGMainMenuWindowLevel-1];
    [menuButton setImage:[[NSBundle mainBundle] imageNamed:@"QuicksilverMenuLight"]];
	[menuButton setAlternateImage:[[NSBundle mainBundle] imageNamed:@"QuicksilverMenuPressed"]];

	
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
	
	[[dSelector cell] setBezeled:YES];
	[[aSelector cell] setBezeled:YES];
	[[iSelector cell] setBezeled:YES];	
	
	[[dSelector cell] setShowDetails:NO];
	[[aSelector cell] setShowDetails:NO];
	[[iSelector cell] setShowDetails:NO];
	
	[[dSelector cell] setTextColor:[NSColor blackColor]];
	[[aSelector cell] setTextColor:[NSColor blackColor]];
	[[iSelector cell] setTextColor:[NSColor blackColor]];
	
	[[dSelector cell] setHighlightsBy:NSNoCellMask];
	[[aSelector cell] setHighlightsBy:NSNoCellMask];
	[[iSelector cell] setHighlightsBy:NSNoCellMask];
	
	//	NSLog(@"%d",[[dSelector cell]showsStateBy]);
    
    [[self window]setMovableByWindowBackground:NO];
    [dSelector setPreferredEdge:NSMinYEdge];
    [aSelector setPreferredEdge:NSMinYEdge];
    [iSelector setPreferredEdge:NSMinYEdge];
	
    [dSelector setResultsPadding:5];
    [aSelector setResultsPadding:5];
    [iSelector setResultsPadding:5];
    
	
    [self updateViewLocations];
	[[self window] display];
}

- (void)updateViewLocations{
    [super updateViewLocations];
	
    NSRect dFrame=[dSelector frame];
    NSRect aFrame=[aSelector frame];
    NSRect iFrame=[iSelector frame];
    dFrame.size.width=MIN(256,(int)[dSelector cellSize].width);
    aFrame.size.width=MIN(256,(int)[aSelector cellSize].width);
    iFrame.size.width=MIN(256,(int)[iSelector cellSize].width);
    aFrame.origin.x=NSMaxX(dFrame)-9;
    iFrame.origin.x=NSMaxX(aFrame)-9;
    [dSelector setFrame:dFrame];
    [aSelector setFrame:aFrame];
    [iSelector setFrame:iFrame];
	
	NSRect windowRect=[[self window]frame];
	windowRect.size.width=12+([iSelector superview]?NSMaxX([iSelector frame]):NSMaxX([aSelector frame]));
    [[self window]setFrame:windowRect display:YES];
	
	
    [[[self window]contentView]setNeedsDisplay:YES];
}


-(void) showInterface:(id)sender{
	NSScreen *screen=[NSScreen mainScreen];
	[[self window]setFrameTopLeftPoint:NSMakePoint(NSMinX([screen frame]),NSMaxY([screen visibleFrame]))];   
    [super showInterface:sender];
}




- (NSSize)maxIconSize{
    return NSMakeSize(32,32);
}
- (NSRect)window:(NSWindow *)window willPositionSheet:(NSWindow *)sheet usingRect:(NSRect)rect{
	// logRect(rect);
    return NSOffsetRect(rect,0,-NSHeight([window frame]));
	
}
@end
















