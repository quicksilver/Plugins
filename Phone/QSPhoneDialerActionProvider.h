

#import <Foundation/Foundation.h>
#import <QSCore/QSActionProvider.h>
#define kQSDialNumberAction @"QSDialNumberWithSpeakerAction"
#define kQSDialNumberModemAction @"QSDialNumberWithModemAction"
#define kQSDialNumberBluetoothAction @"QSDialNumberWithBluetoothAction"

NSString *QSFormattedPhoneNumberString(NSString *number);
	
@interface QSPhoneDialerActionProvider : QSActionProvider {

}
- (QSObject *)dialNumber:(QSObject *)dObject;
@end
