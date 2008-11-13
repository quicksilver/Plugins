

#import <AppKit/AppKit.h>


@interface QSWebSearchController : NSWindowController {
    IBOutlet NSTextField *webSearchField;
    IBOutlet NSBox *searchBox;
    IBOutlet NSPopUpButton *searchPopUp;
    
    id webSearch;
}
- (IBAction)submitWebSearch:(id)sender;


- (id)webSearch;
- (void)setWebSearch:(id)newWebSearch;

//- (IBAction) hideSearchView:sender;
- (IBAction) showSearchView:sender;
- (void)searchURL:(NSURL *)searchURL;

- (void)openPOSTURL:(NSURL *)searchURL;
- (void)searchURL:(NSURL *)searchURL forString:(NSString *)string;
+ (id)sharedInstance;
@end
