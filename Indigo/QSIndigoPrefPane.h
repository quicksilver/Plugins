

#import <Foundation/Foundation.h>

#import <QSInterface/QSPreferencePane.h>
@interface QSIndigoPrefPane : QSPreferencePane {
	IBOutlet NSTextField *targetField;
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passField;
}

- (IBAction)savePassword:(id)sender;
@end
