

#import <AppKit/AppKit.h>

@class QSObjectView;
@interface QSPasteboardProxyView : NSView {
    id objectValue;
    QSObjectView *pasteboardView;
    bool mouseDownCanMoveWindow;
}
- (id)objectValue;
- (void)setObjectValue:(id)newObjectValue;

@end
