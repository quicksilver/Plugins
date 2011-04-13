//
//  QSUIAccessPlugIn_Action.h
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#define kQSUIElementType @"qs.ui.element"
#define kQSUIActionType @"qs.ui.action"
#define kWindowsAction @"WindowsAction"
#define kWindowsProcessType @"WindowsProcessInfo"

//#import <QSCore/QSObject.h>
//#import <QSCore/QSActionProvider.h>
#import "QSUIAccessPlugIn_Action.h"
#define QSUIAccessPlugIn_Type @"QSUIAccessPlugIn_Type"
@interface QSUIAccessPlugIn_Action : QSActionProvider
{
}
- (QSObject *)getWindowsForApp:(QSObject *)dObject;
- (QSObject *)focusedWindowForApp:(QSObject *)dObject;
- (QSObject *)appWindows:(QSObject *)dObject raiseWindow:(QSObject *)iObject;
- (QSObject *)activateWindow:(QSObject *)dObject;
- (QSObject *)raiseWindow:(QSObject *)dObject;
- (void)pressButton:(id)button inWindow:(id)window;
- (QSObject *)zoomWindow:(QSObject *)dObject;
- (QSObject *)allAppWindows:(QSObject *)dObject;
- (id)resolveProxyObject:(id)proxy;

- (QSObject *)resolvedProxy:(QSObject *)dObject;

@end

