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

#import "QSUIAccessPlugIn_Source.h"
//#import <QSCore/QSMacros.h>

@implementation QSUIAccessPlugIn_Action

- (QSObject *)getUIElementForApplication:(QSObject *)dObject{
  dObject = [self resolvedProxy:dObject];
	pid_t pid=[[[dObject objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];
	AXUIElementRef app=AXUIElementCreateApplication (pid);
	QSObject *object=[QSObject objectForUIElement:app];
	[object setObject:app forType:kQSUIElementType];
	[app release];
	return object;
}

NSArray *MenuItemsForElement(AXUIElementRef element, NSInteger depth, NSString *elementName, NSInteger menuIgnoreDepth) {
  NSArray *children = nil;
  AXUIElementCopyAttributeValue(element, kAXChildrenAttribute, &children);
  NSInteger childrenCount = [children count];
  if (childrenCount < 1 || childrenCount > 50 || depth < 1) {
    QSObject *menuObject = (elementName) ? [QSObject objectForUIElement:element name:elementName] : [QSObject objectForUIElement:element];
    return (menuObject) ? [NSArray arrayWithObject:menuObject] : [NSArray array];
  }
  
  NSMutableArray *menuItems = [NSMutableArray array];
  BOOL menuSkipped = NO;
  for (id child in children) {
    CFBooleanRef enabled = NULL;
    if ((AXUIElementCopyAttributeValue(child, kAXEnabledAttribute, &enabled) != kAXErrorSuccess) || (!CFBooleanGetValue(enabled))) continue;
    CFStringRef name = nil;
    
    // try not to get the name attribute and test it unless we really have to
    if (menuIgnoreDepth > 2 && !menuSkipped && (AXUIElementCopyAttributeValue(child, kAXTitleAttribute, &name) == kAXErrorSuccess) && [name isEqualToString:@"Apple"]) {
      menuSkipped = YES;
      continue;
    }
    else if (menuIgnoreDepth > 0 && !menuSkipped && (AXUIElementCopyAttributeValue(child, kAXTitleAttribute, &name) == kAXErrorSuccess) && [name isEqualToString:@"Services"]) {
      menuSkipped = YES;
      continue;
    }
    
    [menuItems addObjectsFromArray:MenuItemsForElement(child,depth - 1,name,menuIgnoreDepth - 1)];
  }
  
  return menuItems;
}

- (QSObject *)appMenus:(QSObject *)dObject pickItem:(QSObject *)iObject{
	return [self pickUIElement:iObject];
}	


- (QSObject *)searchAppMenus:(QSObject *)dObject{
  dObject = [self resolvedProxy:dObject];
	pid_t pid=[[[dObject objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];
	AXUIElementRef app=AXUIElementCreateApplication (pid);	
	AXUIElementRef menuBar;
	AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
	NSArray *items=MenuItemsForElement(menuBar,7,nil,3);
	
	[QSPreferredCommandInterface showArray:items];
	return nil;
}	

NSArray *WindowsForApp(id process)
{
	pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
  AXUIElementRef appElement = AXUIElementCreateApplication(pid);
  NSArray *appWindows = nil;
  AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute, &appWindows);
  NSMutableArray *windowObjects = [NSMutableArray array];
  for (id aWindow in appWindows) {
    QSObject *object = [QSObject objectForWindow:aWindow];
    if (!object) continue;
    [object setObject:process forType:kWindowsProcessType];
    [windowObjects addObject:object];
  }
  return windowObjects;
}

- (QSObject *)getWindowsForApp:(QSObject *)dObject
{
  dObject = [self resolvedProxy:dObject];
  id process = [dObject objectForType:QSProcessType];
  NSArray *windowObjects = WindowsForApp(process);
  return (windowObjects) ? [QSPreferredCommandInterface showArray:windowObjects] : nil;
}

- (QSObject *)focusedWindowForApp:(QSObject *)dObject{
  dObject = [self resolvedProxy:dObject];
  id process = [dObject objectForType:QSProcessType];
  pid_t pid = [[process objectForKey:@"NSApplicationProcessIdentifier"] intValue];
  AXUIElementRef appElement = AXUIElementCreateApplication(pid);
  id focusedWindow = nil;
  AXUIElementCopyAttributeValue(appElement, kAXFocusedWindowAttribute, &focusedWindow);
  QSObject *window = [QSObject objectForWindow:focusedWindow];
  [window setObject:process forType:kWindowsProcessType];
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
    NSArray *windowObjects = WindowsForApp(anApp);
    if (windowObjects) [windows addObjectsFromArray:windowObjects];
  }
	[QSPreferredCommandInterface showArray:windows];
	return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	if ([action isEqualToString:@"QSPickMenuItemsAction"]){
	  dObject = [self resolvedProxy:dObject];
		pid_t pid=[[[dObject objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];
		AXUIElementRef app=AXUIElementCreateApplication (pid);	
		AXUIElementRef menuBar;
		AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
		NSArray *actions=MenuItemsForElement(menuBar,7,nil,3);
		
		//NSLog(@"actions: %@",actions);
		return [NSArray arrayWithObjects:[NSNull null],actions,nil];
		return nil;
	}else if ([action isEqualToString:@"QSPickMenusAction"]){
	  dObject = [self resolvedProxy:dObject];
		pid_t pid=[[[dObject objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];
		AXUIElementRef app=AXUIElementCreateApplication (pid);	
		AXUIElementRef menuBar;
		AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
	
		NSArray *actions=MenuItemsForElement(menuBar,1,nil,0);
				
		//NSLog(@"actions: %@",actions);
		return [NSArray arrayWithObjects:[NSNull null],actions,nil];
		return nil;
	}else if ([action isEqualToString:@"ListWindowsForApp"]) {
	  dObject = [self resolvedProxy:dObject];
    id process = [dObject objectForType:QSProcessType];
    NSArray *windowObjects = WindowsForApp(process);
    return (windowObjects) ? [NSArray arrayWithObjects:[NSNull null],windowObjects,nil] : [NSArray array];
	}else{
		AXUIElementRef element=[dObject objectForType:kQSUIElementType];
		NSArray *actions=nil;
		AXUIElementCopyActionNames (element, &actions);	
		[actions autorelease];
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

@end
