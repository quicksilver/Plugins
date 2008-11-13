

#import <AppKit/AppKit.h>
#import "QSFakeMenuWindow.h"


@interface QSMenuWindow : NSPanel {
    bool hidden;
    QSFakeMenuWindow *fakeMenuWindow;
}
- (void)orderFront:(id)sender makeKey:(BOOL)becomeKey;
//- (NSImage *) menuBarImage;
@end
