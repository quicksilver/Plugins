

#import "QSPasteboardAccessoryCell.h"



@implementation QSPasteboardAccessoryCell

- (id)initImageCell:(NSImage *)anImage{
    if (self=[super initImageCell:anImage]){
        
    }
    return self;
}

- (void)dealloc{
	[self setTextColor:nil];
	[super dealloc];	
}
- (NSColor *)textColor { return textColor; }

- (void)setTextColor:(NSColor *)newTextColor {
    [textColor release];
    textColor = [newTextColor retain];
	[[self controlView] setNeedsDisplay:YES];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
    
    if (![self isHighlighted]){
    NSBezierPath *roundRect=[NSBezierPath bezierPath];
    [roundRect appendBezierPathWithRoundedRectangle:NSInsetRect(cellFrame,1,1) withRadius:NSWidth(cellFrame)/4];
    [[[self textColor] colorWithAlphaComponent:0.1]set];
    [roundRect fill];
    }
    
    if ([self objectValue]){
        int rank=[[self objectValue]intValue];
        
        
        
        NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[self textColor],NSForegroundColorAttributeName,[self font], NSFontAttributeName,nil];
        NSString *string=[NSString stringWithFormat:@"%d",rank];
        
        NSSize textSize=[string sizeWithAttributes:attributes];
        
        NSRect drawRect=centerRectInRect(rectFromSize(textSize),cellFrame);
        [string drawInRect:drawRect withAttributes:attributes];
    }
}
@end
