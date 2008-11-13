

#import "QSPasteboardObjectView.h"
//#import <QSCore/QSCore.h>

@implementation QSPasteboardObjectView

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender {    
    [[QSObject objectWithPasteboard:[sender draggingPasteboard]] putOnPasteboard:[NSPasteboard generalPasteboard] includeDataForTypes:nil];
    return YES;
}

@end
