/* QSController */


#import <Cocoa/Cocoa.h>
#import <QSInterface/QSResizingInterfaceController.h>


@interface QSOrnateInterfaceController : QSResizingInterfaceController{
    NSRect standardRect;
	IBOutlet NSView *bezelView;
	IBOutlet NSImageView *leftView;
	IBOutlet NSImageView *rightView;
}

- (NSRect)rectForState:(BOOL)expanded;
@end