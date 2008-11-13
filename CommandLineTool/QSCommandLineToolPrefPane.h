

#import <Foundation/Foundation.h>
#import <PreferencePanes/PreferencePanes.h>


@interface QSCommandLineToolPrefPane : NSPreferencePane {
    IBOutlet NSButton *toolInstallButton;
    IBOutlet NSTextField *toolInstallStatus;
	
    IBOutlet NSImageView *toolImageView;
}

- (BOOL)toolIsInstalled;
- (IBAction)installCommandLineTool:(id)sender;


- (void) populateFields;
- (void)setValueForSender:(id)sender;
@end
