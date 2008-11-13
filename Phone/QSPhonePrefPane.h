

#import <Foundation/Foundation.h>
#import <QSInterface/QSPreferencePane.h>


@interface QSPhonePrefPane : QSPreferencePane {
	IBOutlet NSTextField *testInput;
	IBOutlet NSTextField *testOutput;
	IBOutlet NSPopUpButton *countryPopUp;
	
	
	IBOutlet NSPopUpButton *callTypePopUp;
	
	IBOutlet NSTextField *prefixField;
	IBOutlet NSTextField *suffixField;
	
	IBOutlet NSButton *useDefaultSwitch;
	
}
- (IBAction)selectCountry:(id)sender;
- (IBAction)testStringChanged:(id)sender;
- (IBAction)setValueForSender:(id)sender;
- (void)populateFields;
@end
