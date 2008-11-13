

#import <Foundation/Foundation.h>

#define QSPasteboardDidChangeNotification @"QSPasteboardDidChangeNotification"

@interface QSPasteboardMonitor : NSObject {

    NSTimer *pollTimer;

    int lastChangeCount;
}
+ (id)sharedInstance;


@end
