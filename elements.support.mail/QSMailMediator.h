

#import <Foundation/Foundation.h>
//#import <QSCore/QSRegistry.h>
#define emailsShareDomain(email1,email2) ![[[email1 componentsSeparatedByString:@"@"]lastObject]caseInsensitiveCompare:[[email2 componentsSeparatedByString:@"@"]lastObject]]
NSString *preferredMailMediatorID();
#define kQSMailMediators @"QSMailMediators"


@protocol QSMailMediator
- (void) sendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow;
@end

@interface QSMailMediator : NSObject <QSMailMediator> {
    NSAppleScript *mailScript;
}
+ (id <QSMailMediator>)defaultMediator;
- (void) sendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow;
- (void) sendEmailWithScript:(NSAppleScript *)script to:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow;
- (NSAppleScript *)mailScript;
- (void)setMailScript:(NSAppleScript *)newMailScript;
- (NSString *)scriptPath;
@end

@interface QSRegistry (QSMailMediator)
- (id <QSMailMediator>)QSMailMediator;
- (NSString *)QSMailMediatorID;
@end