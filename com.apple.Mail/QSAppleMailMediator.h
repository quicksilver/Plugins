

#import <Foundation/Foundation.h>

@interface QSAppleMailMediator : NSObject {
    NSAppleScript *mailScript;
}

- (NSAppleScript *)mailScript;
@end
