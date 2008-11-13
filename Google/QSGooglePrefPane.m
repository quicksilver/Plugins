

#import "QSGooglePrefPane.h"
#import <QSCore/QSResourceManager.h>

@implementation QSGooglePrefPane
- (id)init {
    self = [super initWithBundle:[NSBundle bundleForClass:[QSGooglePrefPane class]]];
    if (self) {
    }
    return self;
}

- (NSImage *) icon{
	return [[NSBundle bundleForClass:[self class]] imageNamed:@"Google"];
}

- (NSString *) mainNibName{
return @"QSGooglePrefPane";
}

@end
