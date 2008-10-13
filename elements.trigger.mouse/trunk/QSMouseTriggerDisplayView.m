

#import "QSMouseTriggerDisplayView.h"



@implementation QSMouseTriggerDisplayView

- (id)initWithFrame:(NSRect)frame anchor:(int)thisAnchor{
    self = [super initWithFrame:frame];
    if (self) {
        anchor=thisAnchor;
        // Initialization code here.
		
    }
    return self;
}


- (void)drawRect:(NSRect)rect {
    
    NSColor *highlight=[NSColor alternateSelectedControlColor];
    if (anchor<5){
	//	[[NSColor whiteColor]set];
	//	NSRectFill(rect);
        NSImage *image=[[NSBundle bundleForClass:[QSMouseTriggerDisplayView class]]imageNamed:@"Flare"];
		
		
        NSRect drawRect=alignRectInRect(rectFromSize([image size]),rect,anchor);
        [image drawInRect:drawRect fromRect:rectFromSize([image size]) operation:NSCompositeSourceOver fraction:1.0];
        [highlight set];
        NSRectFillUsingOperation(rect,NSCompositeSourceIn);
        
    }else{
        [self _drawRect:(NSRect)rect withGradientFrom:highlight to:[[NSColor selectedTextBackgroundColor] colorWithAlphaComponent:0.0] start:anchor-5];    
    }
}


- (void)_drawRect:(NSRect)rect withGradientFrom:(NSColor*)colorStart to:(NSColor*)colorEnd start:(NSRectEdge)edge{
    NSRect remainingRect;
    int i;
    int index = (edge==NSMinXEdge||edge==NSMaxXEdge)?rect.size.width:rect.size.height;
    remainingRect = rect;
    
    NSColor *colors[index];
    NSRect rects[index];
    
    for ( i = 0; i < index; i++ ){
        NSDivideRect ( remainingRect, &rects[i], &remainingRect, 1.0, edge);
        colors[i]=[colorStart blendedColorWithFraction:(float)i/(float)index ofColor:colorEnd];
    }
    NSRectFillListWithColors(&rects[0],&colors[0],index);
}



@end
