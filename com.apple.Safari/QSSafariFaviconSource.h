

#import <Foundation/Foundation.h>


@interface QSSafariFaviconSource : NSObject {
    NSMutableDictionary *iconCache;
    NSDictionary *webSiteURLToIconURLDict;
}
+ (id)sharedInstance;
- (NSImage *)faviconForURL:(NSURL *)url;
- (void) loadSafariIcons;
@end
