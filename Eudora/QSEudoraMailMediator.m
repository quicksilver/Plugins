

#import "QSEudoraMailMediator.h"

@implementation QSEudoraMailMediator
- (NSString *)scriptPath{
    return [[NSBundle bundleForClass:[QSEudoraMailMediator class]]pathForResource:@"Eudora" ofType:@"scpt"];
}
@end
