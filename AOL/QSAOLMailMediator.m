

#import "QSAOLMailMediator.h"


@implementation QSAOLMailMediator
- (NSString *)scriptPath{
    return [[NSBundle bundleForClass:[QSAOLMailMediator class]]pathForResource:@"America Online" ofType:@"scpt"];
}
- (void) sendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow{
	[[QSReg getClassInstance:@"QSMailMediator"] sendEmailWithScript:[[NSBundle bundleForClass:[self class]]scriptNamed:@"America Online"]
																 to:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow];
}
@end
