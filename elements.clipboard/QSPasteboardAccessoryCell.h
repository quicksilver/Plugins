

#import <Foundation/Foundation.h>


@interface QSPasteboardAccessoryCell : NSCell {
    NSColor *textColor;
}

- (NSColor *)textColor;
- (void)setTextColor:(NSColor *)newTextColor;
@end
