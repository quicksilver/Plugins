

#import <AppKit/AppKit.h>


@interface QSMouseTriggerDisplayView : NSView {
    BOOL active;
    int anchor;
}
- (void)_drawRect:(NSRect)rect withGradientFrom:(NSColor*)colorStart to:(NSColor*)colorEnd start:(NSRectEdge)edge;
@end
