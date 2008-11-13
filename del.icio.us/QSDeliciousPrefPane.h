

#import <Foundation/Foundation.h>
#import <PreferencePanes/PreferencePanes.h>


@interface QSDeliciousPrefPane : NSPreferencePane {
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passField;
}

- (IBAction)savePassword:(id)sender;
@end
