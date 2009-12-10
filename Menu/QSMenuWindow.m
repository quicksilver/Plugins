

#import "QSMenuWindow.h"

#import <QSFoundation/QSFoundation.h>
#import <QSCore/QSPreferenceKeys.h>

NSRect menuRect2(){
    NSRect menuRect=[[[NSScreen screens]objectAtIndex:0]frame];
    float yOffset=NSHeight(menuRect)-22;
    menuRect.size.height=22;
    
    menuRect=NSOffsetRect(menuRect,0,yOffset);
    //logRect(menuRect);
    return menuRect;
    
    
}

@implementation QSMenuWindow

-(BOOL)canBecomeKeyWindow{
    return YES;
}

-(BOOL)canBecomeMainWindow{
    return YES;
}

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame{
    return .250;
}
- (id)initWithContentRect:(NSRect)contentRect styleMask:(unsigned int)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag{
    NSWindow* result = [super initWithContentRect:contentRect styleMask:NSNonactivatingPanelMask|NSBorderlessWindowMask backing:bufferingType defer:NO];
    //[self setBackgroundColor: [NSColor clearColor]];//colorWithCalibratedWhite:0.75 alpha:0.5]];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setOpaque:NO];
    [self setHasShadow:NO];
    [self setLevel:25];
   // if (DEBUG)
   // [self setMovableByWindowBackground:YES];
    hidden=YES;
    
    fakeMenuWindow=[[QSFakeMenuWindow alloc]init];
    
    return result;
}

- (void)orderOut:(id)sender{
    if ([self isVisible]){
      if([[NSUserDefaults standardUserDefaults]boolForKey:kUseEffects])
            [self setFrame:NSOffsetRect([self frame],0,22) alphaValue:0.0 display:NO animate:YES];
        [super orderOut:sender];
    }
    //[self setAlphaValue:1.0];
}
- (void)makeKeyAndOrderFront:(id)sender{
    [self orderFront:self makeKey:YES];
}

- (void)orderFront:(id)sender{
    [self orderFront:self makeKey:NO];
}
- (void)orderFront:(id)sender makeKey:(BOOL)becomeKey{
        
    if (![self isVisible]){
        if([[NSUserDefaults standardUserDefaults]boolForKey:kUseEffects]){
            [fakeMenuWindow mimic];
            [fakeMenuWindow setAlphaValue:1.0];
        }
        NSRect menuScreenRect=[[[NSScreen screens]objectAtIndex:0]frame];
        [self setFrame:NSMakeRect(0,0,NSWidth(menuScreenRect),NSHeight([self frame])) display:YES animate:NO];
        [self setFrameTopLeftPoint:NSMakePoint(NSMinX(menuScreenRect),NSMaxY(menuScreenRect))];
        if (becomeKey)
            [super makeKeyAndOrderFront:sender];
        
        else
            [super orderFront:sender];
        
        [self setAlphaValue:1.0];
        if([[NSUserDefaults standardUserDefaults]boolForKey:kUseEffects]){
            [fakeMenuWindow setFrame:NSOffsetRect(menuRect2(),0,22) alphaValue:0.2 display:YES animate:YES];
            [fakeMenuWindow orderOut:sender];
        }
    }
}

- (void)keyDown:(NSEvent *)theEvent{
    unichar c = [[theEvent characters] characterAtIndex:0];
    
    if (c=='\t'||c==25||c==27)
        [[self delegate] keyDown:theEvent];
    else
        [super keyDown:theEvent];
}



/*
 - (NSImage *) viewCapture{
     NSRect screenRect=NSMakeRect(0,0,NSWidth([self frame]),128);
     NSImage *viewImage = [[NSImage alloc] initWithSize:screenRect.size];
     [[self contentView]lockFocus];
     NSImageRep *screenRep= [[NSBitmapImageRep alloc]initWithFocusedViewRect:screenRect];
     [[self contentView]unlockFocus];
     
     [viewImage addRepresentation:screenRep];
     [viewImage setDataRetained:YES];
     
     NSLog(@"screen %@",viewImage);
     return viewImage;
 }
 
 
 - (NSImage *) menuBarImage{
     NSWindow *grabWindow;
     NSView *grabbedContentView;
     NSBitmapImageRep *screenBits;
     NSRect mainScreenBounds;
     NSImage *screenImage;
     
     NSRect menuRect=[[[NSScreen screens]objectAtIndex:0]frame];
     
     float yOffset=NSHeight(menuRect)-22;
     menuRect.size.height=22;
     
     grabWindow = [[NSWindow alloc] initWithContentRect: NSOffsetRect(menuRect,0,yOffset)
                                              styleMask: NSBorderlessWindowMask
                                                backing: NSBackingStoreRetained
                                                  defer: NO
                                                 screen: nil];
     
     [grabWindow setAlphaValue: 0.0];
     [grabWindow setLevel: NSPopUpMenuWindowLevel];
     [grabWindow orderWindow: NSWindowAbove  relativeTo: 0];
     
     grabbedContentView = [grabWindow contentView];
     [grabbedContentView lockFocus];
     screenBits = [[NSBitmapImageRep alloc] initWithFocusedViewRect: menuRect];
     [grabbedContentView unlockFocus];
     
     screenImage = [[NSImage alloc] initWithSize: mainScreenBounds.size];
     [screenImage addRepresentation: screenBits];
     [grabWindow close];
     return screenImage;
 }
 */
@end
