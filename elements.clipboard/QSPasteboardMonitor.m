

#import "QSPasteboardMonitor.h"


@implementation QSPasteboardMonitor

+ (id)sharedInstance{
    static QSPasteboardMonitor *_sharedInstance;
    if (!_sharedInstance){
        _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
        
    }
    return _sharedInstance;
}

- (id) init{
    if (self=[super init]){
        pollTimer=[[NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(checkPasteboard:) userInfo:nil repeats:YES]retain];
        lastChangeCount=0;
    }
    return self;
}

- (void)checkPasteboard:(NSTimer *)timer{
    int changeCount=[[NSPasteboard generalPasteboard]changeCount];
    if (changeCount==lastChangeCount) return;
    lastChangeCount=changeCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:QSPasteboardDidChangeNotification object:[NSPasteboard generalPasteboard]];
}


@end
