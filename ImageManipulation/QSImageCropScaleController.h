/* QSImageCropScaleController */

#import <Cocoa/Cocoa.h>

@interface QSImageCropScaleController : NSWindowController
{
    IBOutlet NSButton *centerButton;
    IBOutlet NSTextField *cHeightField;
    IBOutlet NSTextField *cWidthField;
    IBOutlet NSTextField *oHeightField;
    IBOutlet NSTextField *oWidthField;
    IBOutlet NSTextField *psHeightField;
    IBOutlet id psSlider;
    IBOutlet NSTextField *psWidthField;
    IBOutlet NSButton *resetButton;
    IBOutlet NSTextField *sHeightField;
    IBOutlet NSTextField *sWidthField;
}
- (IBAction)cancel:(id)sender;
- (IBAction)centerCrop:(id)sender;
- (IBAction)ok:(id)sender;
- (IBAction)reset:(id)sender;
- (IBAction)setValueForSender:(id)sender;
@end
