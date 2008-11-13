

#import "QSPasteboardProxyView.h"
#import "QSObject.h"
#import "QSObjectView.h"

#import "QSObject_Pasteboard.h"

#import "BLTRExtensions.h"
@implementation QSPasteboardProxyView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        [self registerForDraggedTypes:[NSArray arrayWithObjects:@"Apple URL pasteboard type",NSColorPboardType, NSFileContentsPboardType, NSFilenamesPboardType, NSFontPboardType, NSHTMLPboardType, NSPDFPboardType, NSPICTPboardType, NSPostScriptPboardType, NSRulerPboardType, NSRTFPboardType, NSRTFDPboardType, NSStringPboardType, NSTabularTextPboardType, NSTIFFPboardType, NSURLPboardType, NSVCardPboardType, NSFilesPromisePboardType, nil]];
        mouseDownCanMoveWindow=YES;
        
        //    rotateByAngle
    }
    return self;
}

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    [[NSImage imageNamed:@"PasteboardProxy"]compositeToPoint:NSZeroPoint operation:NSCompositeSourceOver];

    
    NSAffineTransform *transform=[NSAffineTransform transform];
    [transform rotateByDegrees:-8];
    [transform concat];
  //  [[NSColor blueColor]set];
//    NSFrameRect(NSMakeRect(15,45,64,64));
    NSImage *image=[[self objectValue]image];
    [image setSize:NSMakeSize(128,128)];
    [[NSGraphicsContext currentContext]setImageInterpolation:NSImageInterpolationHigh];

    [image drawInRect:NSMakeRect(15,45,64,64) fromRect:NSMakeRect(0,0,[image size].width,[image size].height) operation:NSCompositeSourceOver fraction:1.0];

    [[[self objectValue]name] drawInRect:NSMakeRect(15,25,64,16) withAttributes:nil];
//    if [self objectValue]


}

- (BOOL)mouseDownCanMoveWindow{return NO;}



- (void)mouseDown:(NSEvent *)theEvent{
    
    bool inRect=[self mouse:[theEvent locationInWindow] inRect:NSMakeRect(20,45,64,64)];
    NSLog(@"inrect:%d",inRect);

    if (!inRect){
        [super mouseDown:theEvent];
        return;
    }
    
  //  BOOL keepOn = YES;
    BOOL isInside = YES;
    NSPoint mouseLoc;
    
    theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
    mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    isInside = [self mouse:mouseLoc inRect:[self bounds]];
    
    switch ([theEvent type]) {
        case NSLeftMouseDragged:
           // [super mouseDragged:theEvent];
            if (objectValue){
                NSImage *dragImage=[[self objectValue]image];
                NSSize dragOffset = NSMakeSize(0.0, 0.0);
                NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
                [[self objectValue] putOnPasteboard:pboard includeDataForTypes:nil];
                [self dragImage:[dragImage imageWithAlphaComponent:0.5] at:NSZeroPoint offset:dragOffset
                          event:theEvent pasteboard:pboard source:self slideBack:YES];
            }
                
            break;
        case NSLeftMouseUp:
            //if (isInside)
          //  NSLog(@"mouseUp");
            break;
        default:
            break;
    }

    return;
}



- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)isLocal{
        return NSDragOperationEvery;
}

//Dragging

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {    
    [[QSObject objectWithPasteboard:[sender draggingPasteboard]]
putOnPasteboard:[NSPasteboard generalPasteboard] includeDataForTypes:nil];
    return YES;
}

//



- (id)objectValue { return [[objectValue retain] autorelease]; }

- (void)setObjectValue:(id)newObjectValue {
    [objectValue release];
    objectValue = [newObjectValue retain];
    [self setNeedsDisplay:YES];
}

@end
