

#import "QSMailsmithMailMediator.h"

//#import <QSCore/QSMailMediator.h>
@implementation QSMailsmithMailMediator
- (void) sendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow{
	[[QSReg getClassInstance:@"QSMailMediator"] sendEmailWithScript:[[NSBundle bundleForClass:[self class]]scriptNamed:@"Mailsmith"]
																 to:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow];
}
@end
