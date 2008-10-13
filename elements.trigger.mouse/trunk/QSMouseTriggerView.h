

#import <AppKit/AppKit.h>

typedef enum _QSRectBits {
    QSCenterAnchor = 0,
    QSTopRightAnchor = 1,
    QSTopLeftAnchor = 2,
    QSBottomLeftAnchor = 3,
    QSBottomRightAnchor = 4,
    QSMinXAnchor = 5,
    QSMinYAnchor = 6,
    QSMaxXAnchor = 7,
    QSMaxYAnchor = 8
} QSRectBits;


enum {					/* masks for the Anchors */
QSCenterAnchorMask		= 1 << QSCenterAnchor,
QSTopRightAnchorMask		= 1 << QSTopRightAnchor,
QSTopLeftAnchorMask		= 1 << QSTopLeftAnchor,
QSBottomLeftAnchorMask		= 1 << QSBottomLeftAnchor,
QSBottomRightAnchorMask		= 1 << QSBottomRightAnchor,
QSMinXAnchorMask                = 1 << QSMinXAnchor,
QSMinYAnchorMask                = 1 << QSMinYAnchor,
QSMaxXAnchorMask                = 1 << QSMaxXAnchor,
QSMaxYAnchorMask                = 1 << QSMaxYAnchor
};



NSRect rectForAnchor(int anchor, NSRect rect,int size, int inset);

@interface QSMouseTriggerWindow : NSPanel
@end
@class QSWindow;
@interface QSMouseTriggerView : NSView {
    BOOL active;
    bool dragging;
    QSWindow *displayWindow;
    NSTrackingRectTag trackingRect;
    bool captureMode;
	NSScreen *screen;
	@public
    int anchor;
	int screenNum;
	//NSPasteboard *dragPboard;
}

//+ (id)triggerWindowWithAnchor:(int)thisAnchor onScreen:(NSScreen *)screen;
+ (id)triggerWindowWithAnchor:(int)thisAnchor onScreenNum:(int)thisScreen;
- (NSWindow *)displayWindow;
- (void)updateDisplayFrame;
- (void)updateFrame;
- (bool)captureMode;
- (void)setCaptureMode:(BOOL)flag;
- (NSScreen *)screen;
- (void)showTriggerList;
@end
