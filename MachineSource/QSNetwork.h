// QSNetwork.h

#import <Cocoa/Cocoa.h>

@interface QSNetwork : NSObject{
    NSNetService * netService;
    NSFileHandle * listeningSocket;
    int numberOfDownloads;
}
+ (id)sharedInstance;

- (void)toggleSharing;
@end
