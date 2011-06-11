//
//  QSUIAccessPlugIn_Action.m
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSUIAccessPlugIn_Action.h"

//#import <QSCore/QSSeparatorObject.h>
#import <ApplicationServices/ApplicationServices.h>
#import <QSCore/QSInterfaceMediator.h>
#import "QSUIAccessPlugIn_Source.h"
//#import <QSCore/QSMacros.h>
#import <QSCore/QSTypes.h>

@implementation QSUIAccessPlugIn_Action


NSArray *MenuItemsForElement(AXUIElementRef element, NSInteger depth, NSString *elementName, NSInteger menuIgnoreDepth, NSDictionary *process) {
  NSArray *children = nil;
  AXUIElementCopyAttributeValue(element, kAXChildrenAttribute, &children);
  [children autorelease];
  NSInteger childrenCount = [children count];
  if (childrenCount < 1 || childrenCount > 50 || depth < 1) {
    QSObject *menuObject = [QSObject objectForUIElement:element name:elementName process:process];
    return (menuObject) ? [NSArray arrayWithObject:menuObject] : [NSArray array];
  }
  
  NSMutableArray *menuItems = [NSMutableArray array];
  BOOL menuSkipped = NO;
  for (id child in children) {
    CFTypeRef enabled = NULL;
    if (AXUIElementCopyAttributeValue(child, kAXEnabledAttribute, &enabled) != kAXErrorSuccess) continue;
    [enabled autorelease];
    if (!CFBooleanGetValue(enabled)) continue;
    CFStringRef name = nil;
    
    // try not to get the name attribute and test it unless we really have to
    if ((menuIgnoreDepth > 2 && !menuSkipped) && (AXUIElementCopyAttributeValue(child, kAXTitleAttribute, &name) == kAXErrorSuccess))
    {
      [name autorelease];
      if ([name isEqualToString:@"Apple"])
      {
        menuSkipped = YES;
        continue;
      }
    }
    else if (menuIgnoreDepth > 0 && !menuSkipped && (AXUIElementCopyAttributeValue(child, kAXTitleAttribute, &name) == kAXErrorSuccess)) {
      [name autorelease];
      if ([name isEqualToString:@"Services"])
      {
        menuSkipped = YES;
        continue;
      }
    }
    
    [menuItems addObjectsFromArray:MenuItemsForElement(child,depth - 1,name,menuIgnoreDepth - 1, process)];
  }
  
  return menuItems;
}

- (QSObject *)appMenus:(QSObject *)dObject pickItem:(QSObject *)iObject{
	return [self pickUIElement:iObject];
}	


- (QSObject *)searchAppMenus:(QSObject *)dObject{
  dObject = [self resolvedProxy:dObject];
  NSDictionary *process = [dObject objectForType:QSProcessType];
	pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
	AXUIElementRef app=AXUIElementCreateApplication (pid);	
  [app autorelease];
	AXUIElementRef menuBar;
	AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
	NSArray *items=MenuItemsForElement(menuBar,5,nil,3,process);
	
	[QSPreferredCommandInterface showArray:items];
	return nil;
}	

NSArray *WindowsForApp(id process, BOOL appName)
{
	pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
  AXUIElementRef appElement = AXUIElementCreateApplication(pid);
  [appElement autorelease];
  NSArray *appWindows = nil;
  AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute, &appWindows);
  [appWindows autorelease];
  NSMutableArray *windowObjects = [NSMutableArray array];
  for (id aWindow in appWindows) {
    NSString *windowTitle = nil;
    AXUIElementCopyAttributeValue(aWindow, kAXTitleAttribute, &windowTitle);
    if (!windowTitle) continue;
    [windowTitle autorelease];
    QSObject *object = [QSObject objectForWindow:aWindow name:windowTitle process:process];
    if (!object) continue;
    if (appName) [object setName:[windowTitle stringByAppendingFormat:@" — %@",[process objectForKey:@"NSApplicationName"]]];
    [object setObject:process forType:kWindowsProcessType];
    [windowObjects addObject:object];
  }
  return windowObjects;
}

- (QSObject *)getWindowsForApp:(QSObject *)dObject
{
  dObject = [self resolvedProxy:dObject];
  id process = [dObject objectForType:QSProcessType];
  NSArray *windowObjects = WindowsForApp(process, NO);
  if (windowObjects) [QSPreferredCommandInterface showArray:windowObjects];
  return nil;
}

- (QSObject *)focusedWindowForApp:(QSObject *)dObject{
  dObject = [self resolvedProxy:dObject];
  id process = [dObject objectForType:QSProcessType];
  pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
  AXUIElementRef appElement = AXUIElementCreateApplication(pid);
  [appElement autorelease];
  id focusedWindow = nil;
  AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute, &focusedWindow);
  [focusedWindow autorelease];
  QSObject *window = [QSObject objectForWindow:focusedWindow name:nil process:process];
  return window;
}

- (QSObject *)appWindows:(QSObject *)dObject activateWindow:(QSObject *)iObject
{
  return [self activateWindow:iObject];
}

- (QSObject *)activateWindow:(QSObject *)dObject
{
  dObject = [self resolvedProxy:dObject];
  id aWindow = [dObject objectForType:kWindowsType];
  if (!aWindow) return nil;
  AXUIElementPerformAction(aWindow,kAXRaiseAction);
	id process = [dObject objectForType:kWindowsProcessType];
	if (process) [[NSWorkspace sharedWorkspace] activateApplication:process];
  return nil;
}

- (QSObject *)raiseWindow:(QSObject *)dObject
{
  dObject = [self resolvedProxy:dObject];
  id aWindow = [dObject objectForType:kWindowsType];
  if (!aWindow) return nil;
  AXUIElementPerformAction(aWindow,kAXRaiseAction);
  return nil;
}

void PressButtonInWindow(id buttonName, id window)
{
  AXUIElementRef button;
  AXUIElementCopyAttributeValue(window,buttonName, &button);
  [button autorelease];
  AXUIElementPerformAction(button,kAXPressAction);
}

- (QSObject *)zoomWindow:(QSObject *)dObject
{
  dObject = [self resolvedProxy:dObject];
  id aWindow = [dObject objectForType:kWindowsType];
  if (!aWindow) return nil;
  PressButtonInWindow(kAXZoomButtonAttribute, aWindow);
  return nil;
}

- (QSObject *)minimizeWindow:(QSObject *)dObject
{
  dObject = [self resolvedProxy:dObject];
  id aWindow = [dObject objectForType:kWindowsType];
  if (!aWindow) return nil;
  PressButtonInWindow(kAXMinimizeButtonAttribute, aWindow);
  return nil;
}

- (QSObject *)closeWindow:(QSObject *)dObject
{
  dObject = [self resolvedProxy:dObject];
  id aWindow = [dObject objectForType:kWindowsType];
  if (!aWindow) return nil;
  PressButtonInWindow(kAXCloseButtonAttribute, aWindow);
  return nil;
}

- (QSObject *)allAppWindows:(QSObject *)dObject
{
  NSArray *launchedApps = [[NSWorkspace sharedWorkspace] launchedApplications];
  NSMutableArray *windows = [NSMutableArray array];
  for (NSDictionary *anApp in launchedApps) {
    NSArray *windowObjects = WindowsForApp(anApp, YES);
    if (windowObjects) [windows addObjectsFromArray:windowObjects];
  }
	[QSPreferredCommandInterface showArray:windows];
	return nil;
}

- (QSObject *)allAppMenus:(QSObject *)dObject
{
  NSArray *launchedApps = [[NSWorkspace sharedWorkspace] launchedApplications];
  NSMutableArray *menus = [NSMutableArray array];
  for (NSDictionary *process in launchedApps) {
    pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
    AXUIElementRef app = AXUIElementCreateApplication(pid);	
    [app autorelease];
  	AXUIElementRef menuBar;
  	AXUIElementCopyAttributeValue(app, kAXMenuBarAttribute, &menuBar);
    [menuBar autorelease];
    QSObject *object = [QSObject objectByMergingObjects:MenuItemsForElement(menuBar,5,nil,3,process)];
    [object setName:[process objectForKey:@"NSApplicationName"]];
    [object setIcon:[[NSWorkspace sharedWorkspace] iconForFile:[process objectForKey:@"NSApplicationPath"]]];
  	[menus addObject:object];
  }
	[QSPreferredCommandInterface showArray:menus];
	return nil;
}

- (QSObject *)activeAppObject
{
  NSDictionary *curAppInfo = [[NSWorkspace sharedWorkspace] activeApplication];
  QSObject *curAppObject = [QSObject fileObjectWithPath:[curAppInfo objectForKey:@"NSApplicationPath"]];
  [curAppObject setName:[curAppInfo objectForKey:@"NSApplicationName"]];
  [curAppObject setObject:curAppInfo forType:QSProcessType];
  return curAppObject;
}

- (QSObject *)focusedWindowObject
{
  return [self focusedWindowForApp:[self activeAppObject]];
}

- (QSObject *)currentDocumentObject
{
  return [self currentDocumentForApp:[self activeAppObject]];
}

- (id)resolveProxyObject:(id)proxy{
  if ([[proxy identifier] isEqualToString:kCurrentFocusedWindowProxy]) return [self focusedWindowObject];
  if ([[proxy identifier] isEqualToString:kCurrentDocumentProxy]) return [self currentDocumentObject];
  return nil;
}


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	if ([action isEqualToString:@"QSPickMenuItemsAction"]){
	  dObject = [self resolvedProxy:dObject];
	  NSDictionary *process = [dObject objectForType:QSProcessType];
		pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
		AXUIElementRef app=AXUIElementCreateApplication (pid);	
    [app autorelease];
		AXUIElementRef menuBar;
		AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
    [menuBar autorelease];
		NSArray *actions=MenuItemsForElement(menuBar,5,nil,3, process);
		
		//NSLog(@"actions: %@",actions);
		return [NSArray arrayWithObjects:[NSNull null],actions,nil];
		return nil;
	}else if ([action isEqualToString:@"ListWindowsForApp"]) {
	  dObject = [self resolvedProxy:dObject];
    id process = [dObject objectForType:QSProcessType];
    NSArray *windowObjects = WindowsForApp(process, NO);
    return (windowObjects) ? [NSArray arrayWithObjects:[NSNull null],windowObjects,nil] : [NSArray array];
	}else{
    // AXUIElementRef element=[dObject objectForType:kQSUIElementType];
    // NSArray *actions=nil;
    // AXUIElementCopyActionNames (element, &actions);  
    // [actions autorelease];
		//NSLog(@"actions: %@",actions);
		return nil;	
	}
	
	
}


- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	AXUIElementRef element=[dObject objectForType:kQSUIElementType];
	NSArray *actions=nil;
	AXUIElementCopyActionNames (element, &actions);
	[actions autorelease];
	if ([actions containsObject:kAXPickAction])
		return [NSArray arrayWithObject:@"QSUIElementPickAction"];
	if ([actions containsObject:kAXPressAction])
		return [NSArray arrayWithObject:@"QSUIElementPressAction"];
	return nil;
}

- (QSObject *)uiElement:(QSObject *)dObject performAction:(QSObject *)iObject{
	AXUIElementRef element=[dObject objectForType:kQSUIElementType];
	[self activateProcessOfElement:element];
	AXUIElementPerformAction (element, [iObject objectForType:kQSUIActionType]);
	return nil;
}

- (QSObject *)pressUIElement:(QSObject *)dObject{
	AXUIElementRef element=[dObject objectForType:kQSUIElementType];
	[self activateProcessOfElement:element];
	AXUIElementPerformAction (element, kAXPressAction);
	return nil;
}
- (void)activateProcessOfElement:(AXUIElementRef) element{
	pid_t pid=-1;
	AXUIElementGetPid (element, &pid);
	ProcessSerialNumber psn;
	GetProcessForPID(pid,&psn);
	SetFrontProcessWithOptions (&psn,kSetFrontProcessFrontWindowOnly);
}
- (QSObject *)pickUIElement:(QSObject *)dObject{
	AXUIElementRef element=[dObject objectForType:kQSUIElementType];	
	[self activateProcessOfElement:element];
	AXUIElementPerformAction (element,kAXPressAction);
	return nil;
}

- (QSObject *)resolvedProxy:(QSObject *)dObject
{
  if ([dObject respondsToSelector:@selector(resolvedObject)]) return [dObject resolvedObject];
  if ([dObject respondsToSelector:@selector(object)]) return [self resolvedProxy:[dObject object]];
  return dObject;
}

- (QSObject *)currentDocumentForApp:(QSObject *)appObject
{
  NSDictionary *process = [[self resolvedProxy:appObject] objectForType:QSProcessType];
  pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
  AXUIElementRef app = AXUIElementCreateApplication(pid);
  [(id)app autorelease];
  AXUIElementRef window = nil;
  AXUIElementCopyAttributeValue(app, kAXFocusedWindowAttribute, &window);
  [(id)window autorelease];
  return [self firstDocumentObjectForElement:window depth:3 title:nil];
}

- (QSObject *)firstDocumentObjectForElement:(AXUIElementRef)element depth:(NSInteger)depth title:(NSString *)title
{
  if (depth == 0) return nil;
  
  NSString *currentPath = nil;
  AXUIElementCopyAttributeValue(element, kAXDocumentAttribute, &currentPath);
  [currentPath autorelease];
  if (currentPath) return [QSObject fileObjectWithPath:[[NSURL URLWithString:currentPath] path]];
  
  if (!title)
  {
    AXUIElementCopyAttributeValue(element, kAXTitleAttribute, &title);
    [title autorelease];
  }
  
  NSURL *currentURL = nil;
  AXUIElementCopyAttributeValue(element, kAXURLAttribute, &currentURL);
  [currentURL autorelease];
  if (currentURL)
  {
    if ([currentURL isFileURL]) return [QSObject fileObjectWithPath:[currentURL path]];
    return [QSObject URLObjectWithURL:[currentURL description] title:title];
  }
  
  NSArray *children = nil;
  AXUIElementCopyAttributeValue(element, kAXChildrenAttribute, &children);
  [children autorelease];
  if ([children count] == 0) return nil;
  for (id child in children)
  {
    AXUIElementCopyAttributeValue(child, kAXDocumentAttribute, &currentPath);
    [currentPath autorelease];
    if (currentPath) return [QSObject fileObjectWithPath:[[NSURL URLWithString:currentPath] path]];

    AXUIElementCopyAttributeValue(child, kAXURLAttribute, &currentURL);
    [currentURL autorelease];
    if (currentURL)
    {
      if ([currentURL isFileURL]) return [QSObject fileObjectWithPath:[currentURL path]];
      return [QSObject URLObjectWithURL:[currentURL description] title:title];
    }
    
    QSObject *childDoc = [self firstDocumentObjectForElement:child depth:depth - 1 title:title];
    if (childDoc) return childDoc;
  }
  return nil;
}

- (void)selectAndDisplayObject:(QSObject *)object
{
  if (object) [QSPreferredCommandInterface executePartialCommand:[NSArray arrayWithObject:object]];
  else NSBeep();
}

- (QSObject *)fetchCurrentFocusedWindow
{
  [self selectAndDisplayObject:[self focusedWindowObject]];
  return nil;
}

- (QSObject *)fetchCurrentDocument
{
  [self selectAndDisplayObject:[self currentDocumentObject]];
  return nil;
}

- (QSObject *)fetchCurrentApp
{
  [self selectAndDisplayObject:[self activeAppObject]];
  return nil;
}

@end
