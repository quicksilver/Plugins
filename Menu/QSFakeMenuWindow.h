

#import <AppKit/AppKit.h>


@interface QSFakeMenuWindow : NSWindow {

    unsigned char *_screenBytes;
}

- (void) mimic;

-(NSImage *)menuBarImage;
//- (NSRect) menuRect;
@end
