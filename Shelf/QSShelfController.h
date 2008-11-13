/* QSShelfController */

#import <Cocoa/Cocoa.h>
@class QSObject;
@interface QSShelfController : NSWindowController{
    IBOutlet NSTabView *tabView;
    IBOutlet NSTableView *shelfTableView;
    NSArray *objectArray;
    
}

+ (id)sharedInstance;

- (BOOL)addObject:(QSObject *)object atIndex:(int)index;
@end
