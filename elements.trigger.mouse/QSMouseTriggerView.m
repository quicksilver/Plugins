

#import "QSMouseTriggerManager.h"
#import "QSMouseTriggerView.h"
#import "QSMouseTriggerDisplayView.h"

//#import <QSInterface/QSInterface.h>

#define ESIZE 1


NSRect rectForAnchor(int anchor, NSRect rect,int size, int inset){
    
    switch(anchor){
        case QSMaxXAnchor:
            return NSMakeRect(NSMaxX(rect)-size,rect.origin.y+inset,size,NSHeight(rect)-inset*2);
        case QSMinXAnchor:
            return NSMakeRect(rect.origin.x,rect.origin.y+inset,size,NSHeight(rect)-inset*2);
        case QSMaxYAnchor:
            return NSMakeRect(rect.origin.x+inset,NSMaxY(rect)-size,NSWidth(rect)-inset*2,size);
        case QSMinYAnchor:
            return NSMakeRect(rect.origin.x+inset,rect.origin.y,NSWidth(rect)-inset*2,size);
        default:
        {
            NSRect cornerRect=NSMakeRect(0,0,size,size);
            cornerRect=alignRectInRect(cornerRect,rect,oppositeQuadrant(anchor));
            return cornerRect;
        }
    }
    
    return NSMakeRect(0,0,100,100);
}




@implementation QSMouseTriggerWindow


- (BOOL)canBecomeKeyWindow{return NO;}
- (BOOL)canBecomeMainWindow{return NO;}

@end


@implementation QSMouseTriggerView


+ (id)triggerWindowWithAnchor:(int)thisAnchor onScreenNum:(int)thisScreen{
    NSWindow* window = [[[QSMouseTriggerWindow alloc]initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:YES]autorelease];
    [window setBackgroundColor: [NSColor clearColor]];
    [window setOpaque:NO];
    [window setCanHide:NO];
    [window setAllowsToolTipsWhenApplicationIsInactive:YES];
    [window setIgnoresMouseEvents:YES];
    [window setHasShadow:NO];
    [window setLevel:kCGPopUpMenuWindowLevel-1];
    [window setSticky:YES];
    [window setContentView:[[[self alloc]initWithFrame:NSZeroRect anchor:thisAnchor onScreenNum:thisScreen]autorelease]];
    //[window setDelegate:[window contentView]]];
    return window;
}

- (id)initWithFrame:(NSRect)frame anchor:(int)thisAnchor onScreenNum:(int)thisScreen{
    self = [super initWithFrame:frame];
    if (self) {
        anchor=thisAnchor;
        screenNum=thisScreen;
		screen=nil;
	//	NSLog(@"init with screen %d",thisScreen);
    }
    return self;
}
- (void)viewDidMoveToWindow{
    [self updateFrame];
    [self registerForDraggedTypes:standardPasteboardTypes];
}
- (void)updateFrame{
    int inset=0;
    if (anchor>4) inset=32;
    NSRect rect=rectForAnchor(anchor,[[self screen]frame],anchor<5?2:1,64);
  //  NSLog(@"View %d:%d",screen, anchor);
//logRect(rect);
	[[self window]setFrame:rect display:YES];
    
    if (trackingRect)[self removeTrackingRect:trackingRect];
    trackingRect=[self addTrackingRect:[self frame] owner:self userData:nil assumeInside:NO];
    
    [self updateDisplayFrame];
}

- (void)updateDisplayFrame{
    if (displayWindow){
        NSRect rect;
        if (anchor<5)
            rect=rectForAnchor(anchor,[[self screen]frame],64,NO);
        else
            rect=rectForAnchor(anchor,[[self screen]frame],8,NO);
        
        [displayWindow setFrame:rect display:YES];
	//	NSLog(@"display");
//        logRect(rect);
        
    }
}
- (void)drawRect:(NSRect)rect {
    
    if (1 ||active){
		// ***warning   * this should be enabled only if dragging destination
        [[NSColor colorWithDeviceWhite:0.0 alpha:0.05]set];
    }else{
        [[NSColor clearColor]set];
    }
      // [[NSColor redColor]set];
    
    NSRectFill(rect);
    
}


- (void)mouseEntered:(NSEvent *)theEvent{ 
	// ***warning   * should i check for a mouse exited event before showing?

    if (dragging)return;
    [self showTriggerList];
	// NSLog(@"entered %x",[[self window]windowNumber]);
    active=YES;
    [self setNeedsDisplay:YES];
    
    if (!captureMode)
        [[self displayWindow]orderFront:self];
    [[QSMouseTriggerManager sharedInstance] handleMouseTriggerEvent:theEvent forView:self];
	
    
}

-(void)dealloc{
	//NSLog(@"dealloc %d:%d",screen,anchor);
	[screen release];
	screen=nil;
	[super dealloc];
}

- (NSScreen *)screen{
	if (!screen)
		screen=[[NSScreen screenWithNumber:screenNum]retain];
	return screen;	
}

- (void)mouseExited:(NSEvent *)theEvent{
    if (dragging)return;
    active=NO;
    [self setNeedsDisplay:YES];
    
    if (!captureMode)
        [[self displayWindow]orderOut:self];
    [[QSMouseTriggerManager sharedInstance] handleMouseTriggerEvent:theEvent forView:self];
    
    
}

- (void)showTriggerList{
//	NSWindow *descWindow=[[QSMouseTriggerManager sharedInstance] triggerDescriptionWindowForAnchor:anchor onScreen:[[self window]screen]];
	//	NSLog(@"triggers, %@",descWindow);	
}

- (void)rightMouseDown:(NSEvent *)theEvent{
    [super rightMouseDown:theEvent];
    [[QSMouseTriggerManager sharedInstance] handleMouseTriggerEvent:theEvent forView:self];
}
- (void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
	
    [[QSMouseTriggerManager sharedInstance] handleMouseTriggerEvent:theEvent forView:self];
	
    
	//	[[NSDistributedNotificationCenter defaultCenter]postNotificationName:@"com.apple.HIToolbox.endMenuTrackingNotification" object:nil];
	// [QSTriggerController handleMouseTriggerEvent:theEvent for]
	
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender{
	//   NSLog(@"drag enter");
    dragging=YES;
    [[self displayWindow]orderFront:self];
	[[QSMouseTriggerManager sharedInstance] handleMouseTriggerEvent:nil type:101 forView:self];
    return NSDragOperationEvery;
}



- (void)draggingExited:(id <NSDraggingInfo>)sender{
	//NSLog(@"drag exit");
    
    dragging=NO;
    [[self displayWindow]orderOut:self];
	[[QSMouseTriggerManager sharedInstance] handleMouseTriggerEvent:nil type:102 forView:self];

}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender{
    dragging=NO;
		[[QSMouseTriggerManager sharedInstance]setMouseTriggerObject:
			[QSObject objectWithPasteboard:[sender draggingPasteboard]]];
		
		[[self displayWindow]orderOut:self];
		
	[[QSMouseTriggerManager sharedInstance] handleMouseTriggerEvent:nil type:100 forView:self];
 
	return YES;
	
}



- (NSWindow *)displayWindow{
    if (!displayWindow){
        displayWindow=[[QSWindow alloc]initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:YES];

		[displayWindow setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"show",@"type",[NSNumber numberWithFloat:0.2],@"duration",nil]];
		[displayWindow setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"hide",@"type",[NSNumber numberWithFloat:0.2],@"duration",nil]];
		
			
        [displayWindow setHidesOnDeactivate:NO];
        [displayWindow setBackgroundColor: [NSColor clearColor]];
        [displayWindow setOpaque:NO];
        [displayWindow setCanHide:NO];
        [displayWindow setHasShadow:NO];
        [displayWindow setLevel:kCGStatusWindowLevel];
        [displayWindow setIgnoresMouseEvents:YES];
        
        [displayWindow setSticky:YES];
        [displayWindow setContentView:[[[QSMouseTriggerDisplayView alloc]initWithFrame:NSZeroRect anchor:anchor]autorelease]];
        [self updateDisplayFrame];
    }
    
    return displayWindow;
    
}


- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification{
    [self updateFrame];
    //[self updateDisplayFrame];
	[displayWindow release];
	displayWindow=nil;

}

- (bool)captureMode {
    return captureMode;
}

- (void)setCaptureMode:(BOOL)flag {
    if (flag)
        [[self displayWindow]orderFront:self];
    else
        [[self displayWindow]orderOut:self];
    
    captureMode = flag;
}
@end
