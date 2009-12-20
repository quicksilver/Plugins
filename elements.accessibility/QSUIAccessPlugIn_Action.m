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

- (NSArray *)menuItemsForElement:(AXUIElementRef)element depth:(int)depth leavesOnly:(BOOL)leavesOnly{
	
	CFIndex count=-1;
	NSArray *children=nil;
	AXUIElementGetAttributeValueCount(element, kAXChildrenAttribute, &count);
	if (!count) return nil;
	NSMutableArray *childrenObjects=[NSMutableArray arrayWithCapacity:count];
	
	
	AXUIElementCopyAttributeValues(element, kAXChildrenAttribute, 0, count, &children);	

	NSArray *attributes=[NSArray arrayWithObjects:kAXTitleAttribute,kAXEnabledAttribute,kAXRoleAttribute,nil];
	for(NSString * child in children){
		NSArray *array=nil;
		NSArray *attributeValues;
		AXUIElementCopyMultipleAttributeValues (child,attributes,0,&attributeValues); 
		NSString *name=[attributeValues objectAtIndex:0]; 
		NSNumber *enabled=[attributeValues objectAtIndex:1];
		NSString *role=[attributeValues objectAtIndex:2];
		if (AXValueGetType(name)==kAXValueAXErrorType)continue;
		if (![name isKindOfClass:[NSString class]]) continue;
		if ([name isEqualToString:@"Apple"])continue;
		if ([name isEqualToString:@"Services"])continue;
		if (![enabled boolValue]) continue;
		
		
		BOOL isMenu=[role isEqualToString:@"AXMenu"];
		if (isMenu){
				array=[self menuItemsForElement:child depth:depth leavesOnly:leavesOnly];
		}else if (depth){
			array=[self menuItemsForElement:child depth:depth-1 leavesOnly:leavesOnly];
		}
		
		if ([array count]){
			[childrenObjects addObjectsFromArray:array];
		}
		
		if (!isMenu && (!leavesOnly || ![array count])){
			//NSLog(@"%@ %@ %@",name,enabled,role);
			if ([name isEqualToString:@"-"]){
				//[childrenObjects addObject:[QSSeparatorObject separatorWithName:@""]];
			}else{
				QSObject *object=[QSObject objectForUIElement:child name:name];
				[childrenObjects addObject:object];	
			}
		}
		[attributeValues release];
	}
	[children release];
	
	return childrenObjects;
	
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
	NSArray *items=[self menuItemsForElement:menuBar depth:7 leavesOnly:YES];
	
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
		NSArray *actions=[self menuItemsForElement:menuBar depth:7 leavesOnly:YES];
		
		//NSLog(@"actions: %@",actions);
		return [NSArray arrayWithObjects:[NSNull null],actions,nil];
		return nil;
	}else if ([action isEqualToString:@"QSPickMenusAction"]){
	  dObject = [self resolvedProxy:dObject];
		pid_t pid=[[[dObject objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];
		AXUIElementRef app=AXUIElementCreateApplication (pid);	
		AXUIElementRef menuBar;
		AXUIElementCopyAttributeValue (app, kAXMenuBarAttribute, &menuBar);
	
		NSArray *actions=[self menuItemsForElement:menuBar depth:0 leavesOnly:YES];
				
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
