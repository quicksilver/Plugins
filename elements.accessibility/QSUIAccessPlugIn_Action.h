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

#define kCurrentFocusedWindowProxy @"CurrentFocusedWindow"
#define kCurrentDocumentProxy @"CurrentDocument"

//#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>
#import "QSUIAccessPlugIn_Action.h"
#define QSUIAccessPlugIn_Type @"QSUIAccessPlugIn_Type"
@interface QSUIAccessPlugIn_Action : QSActionProvider {}

- (QSObject *)appMenus:(QSObject *)dObject pickItem:(QSObject *)iObject;
- (QSObject *)searchAppMenus:(QSObject *)dObject;
- (QSObject *)getWindowsForApp:(QSObject *)dObject;
- (QSObject *)focusedWindowForApp:(QSObject *)dObject;
- (QSObject *)appWindows:(QSObject *)dObject activateWindow:(QSObject *)iObject;
- (QSObject *)activateWindow:(QSObject *)dObject;
- (QSObject *)raiseWindow:(QSObject *)dObject;
- (QSObject *)zoomWindow:(QSObject *)dObject;
- (QSObject *)minimizeWindow:(QSObject *)dObject;
- (QSObject *)closeWindow:(QSObject *)dObject;
- (QSObject *)allAppWindows:(QSObject *)dObject;
- (QSObject *)allAppMenus:(QSObject *)dObject;
- (QSObject *)activeAppObject;
- (id)resolveProxyObject:(id)proxy;
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject;
- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject;
- (QSObject *)uiElement:(QSObject *)dObject performAction:(QSObject *)iObject;
- (QSObject *)pressUIElement:(QSObject *)dObject;
- (void)activateProcessOfElement:(AXUIElementRef) element;
- (QSObject *)pickUIElement:(QSObject *)dObject;
- (QSObject *)resolvedProxy:(QSObject *)dObject;
- (QSObject *)currentDocumentForApp:(QSObject *)appObject;
- (QSObject *)firstDocumentObjectForElement:(AXUIElementRef)element depth:(NSInteger)depth title:(NSString *)title;
- (void)selectAndDisplayObject:(QSObject *)object;
- (QSObject *)fetchCurrentFocusedWindow;
- (QSObject *)fetchCurrentDocument;
- (QSObject *)fetchCurrentApp;

@end

