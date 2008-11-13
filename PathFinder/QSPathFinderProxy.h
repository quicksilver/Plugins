

#import <Foundation/Foundation.h>

#import "QSFSBrowserMediator.h"

@protocol pathFinderListener
- (bycopy NSArray *)selectedPaths;
- (bycopy NSString*)currentDirectory;
- (oneway void)showPath:(bycopy NSString*)path inNewWindow:(BOOL)newWindow;
- (oneway void)selectPath:(bycopy NSString*)path byExtendingSelection:(BOOL)extend;
- (oneway void)showInfoForPath:(bycopy NSString*)path;
@end


@interface QSPathFinderProxy : NSObject <QSFSBrowserMediator> {
    NSAppleScript *pathFinderScript;
}
- (void)activatePathFinder;
- (id <pathFinderListener>)pathFinderListener;

@end
