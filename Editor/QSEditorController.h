

#import <Foundation/Foundation.h>

@class QSObject;
@interface QSEditorController : NSWindowController {
    QSObject *object;
    IBOutlet NSTextView *textView;
    IBOutlet NSTextField *titleField;

    NSString *filePath;
    NSDate *modificationDate;
}

+ (id)editorForObject:(QSObject *)anObject;
- (void) openDocument:(NSString *)path;
- (IBAction) saveDocument:(id)sender;
- (id)initWithObject:(QSObject *)anObject;
@end
