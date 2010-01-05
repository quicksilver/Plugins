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

NSArray *MenuItemsForElement(AXUIElementRef element, int depth, NSString *name) {
  NSArray *children = nil;
  AXUIElementCopyAttributeValue(element, kAXChildrenAttribute, &children);
  if (([children count] < 1) || (depth < 1)) {
    QSObject *menuObject = (name) ? [QSObject objectForUIElement:element name:name] : [QSObject objectForUIElement:element];
    return (menuObject) ? [NSArray arrayWithObject:menuObject] : [NSArray array];
  }
  
  NSMutableArray *menuItems = [NSMutableArray array];
  for (id child in children) {
    CFBooleanRef enabled = NULL;
    if ((AXUIElementCopyAttributeValue(child, kAXEnabledAttribute, &enabled) != kAXErrorSuccess) || (!CFBooleanGetValue(enabled))) continue;
    CFStringRef name = nil;
    if (AXUIElementCopyAttributeValue(child, kAXTitleAttribute, &name) == kAXErrorSuccess) {
      if (([name isEqualToString:@"Apple"]) || ([name isEqualToString:@"Services"])) continue;
    }
   [menuItems addObjectsFromArray:MenuItemsForElement(child,depth - 1,name)];
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
	NSArray *items=MenuItemsForElement(menuBar,7,nil);
	
	[QSPreferredCommandInterface showArray:items];
	return nil;
}	

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	if ([action isEqualToString:@"QSPickMenuItemsAction"]){
	  dObject = [self resolvedProxy:dObject];
		pid_t pid=[[[dObject objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];
		AXUIElementRef app=AXUIElementCreateApplication (pid);	
		AXUIElementRef menuBar;
		AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
		NSArray *actions=MenuItemsForElement(menuBar,7,nil);
		
		//NSLog(@"actions: %@",actions);
		return [NSArray arrayWithObjects:[NSNull null],actions,nil];
		return nil;
	}else if ([action isEqualToString:@"QSPickMenusAction"]){
	  dObject = [self resolvedProxy:dObject];
		pid_t pid=[[[dObject objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];
		AXUIElementRef app=AXUIElementCreateApplication (pid);	
		AXUIElementRef menuBar;
		AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
	
		NSArray *actions=MenuItemsForElement(menuBar,0,nil);
				
		//NSLog(@"actions: %@",actions);
		return [NSArray arrayWithObjects:[NSNull null],actions,nil];
		return nil;
	}else {
		AXUIElementRef element=[dObject objectForType:kQSUIElementType];
		NSArray *actions=nil;
		AXUIElementCopyActionNames (element, &actions);	
		[actions autorelease];
		//NSLog(@"actions: %@",actions);
		return nil;	
	}
	
	
}


//- (NSArray *) validActionObjectsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{

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
