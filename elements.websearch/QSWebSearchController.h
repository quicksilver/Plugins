

#import <AppKit/AppKit.h>


@interface QSWebSearchController : NSWindowController {
    IBOutlet NSTextField *webSearchField;
    IBOutlet NSBox *searchBox;
    IBOutlet NSPopUpButton *searchPopUp;
    
    id webSearch;
}
- (IBAction)submitWebSearch:(id)sender;

- (NSString *)resolvedURL:(NSString *)searchURL forString:(NSString *)string encoding:(CFStringEncoding)encoding;
- (void)searchURL:(NSString *)searchURL forString:(NSString *)string encoding:(CFStringEncoding)encoding;
- (void)searchURL:(NSString *)searchURL forString:(NSString *)string;
- (void)searchURL:(NSString *)searchURL;

- (id)webSearch;
- (void)setWebSearch:(id)newWebSearch;

//- (IBAction) hideSearchView:sender;
- (IBAction) showSearchView:sender;
- (void)searchURL:(NSString *)searchURL;

- (void)openPOSTURL:(NSURL *)searchURL;
+ (id)sharedInstance;
@end
