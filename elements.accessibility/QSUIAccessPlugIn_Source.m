//
//  QSUIAccessPlugIn_Source.m
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//
#import "QSUIAccessPlugIn_Action.h"
#import "QSUIAccessPlugIn_Source.h"
//#import <QSCore/QSCore.h>
//#import <QSCore/QSMacros.h>

@implementation QSUIAccessPlugIn_Source
- (NSString *)identifierForObject:(id <QSObject>)object{
	
	id element=[object objectForType:kQSUIElementType];
    return nil;
}

// Object Handler Methods


- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"Object"]]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:kQSUIElementType];
	[object setIcon:nil];
    return YES;
}

- (BOOL)objectHasChildren:(QSObject *)object{
	id element=[object objectForType:kQSUIElementType];
	CFIndex count=-1;
	AXUIElementGetAttributeValueCount(element, kAXChildrenAttribute, &count);
	return count;
}

- (NSString *)detailsOfObject:(QSObject *)object{
	return nil;
	id element=[object objectForType:kQSUIElementType];
	NSString *role;
	//	NSString *subRole;
	AXUIElementCopyAttributeValue (element, kAXRoleDescriptionAttribute, &role);
	//	AXUIElementCopyAttributeValue (element, kAXRoleAttribute, &name);
	//	AXUIElementCopyAttributeValue (element, kAXSubRoleAttribute, &name);
	
	[role autorelease];
	return role;
	
	//	[subRole release];
	
}

- (NSArray *)childrenForElement:(AXUIElementRef)element{
	CFIndex count=-1;
	NSArray *children=nil;
	AXUIElementGetAttributeValueCount(element, kAXChildrenAttribute, &count);
	AXUIElementCopyAttributeValues(element, kAXChildrenAttribute, 0, count, &children);
	return [children autorelease];
}
- (NSArray *)objectsForElements:(NSArray *)elements{
	if (!elements)return nil;
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:[elements count]];
	for(NSString * element in elements){
		NSString *name; 
		AXUIElementCopyAttributeValue (element, kAXTitleAttribute, &name);
		[name autorelease];
		//NSLog(@"name %@",name);
		if (![name length])continue;
		QSObject *object=[QSObject objectForUIElement:element];
		[objects addObject:object];		
	}
	return objects;
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
    AXUIElementRef element=[object objectForType:kQSUIElementType];
	
	NSString *role;
	AXUIElementCopyAttributeValue (element, kAXRoleAttribute, &role);
	
	
	BOOL showGrandchildren=[role isEqualToString:kAXMenuItemRole] || [role isEqualToString:kAXMenuBarItemRole];
	
	NSArray *children=[self childrenForElement:element];
	NSArray *altChildren=nil;
	
	if (showGrandchildren && [children count]){
		altChildren=children;
		children=[self childrenForElement:[children objectAtIndex:0]];
	}
	
	[object setChildren:[self objectsForElements:children] ];
	[object setAltChildren:[self objectsForElements:altChildren]];
	
	return YES;
}


@end




@implementation QSObject (UIElement)


+(QSObject *)objectForUIElement:(id)element{
	NSString *name = nil;
	if (AXUIElementCopyAttributeValue(element, kAXTitleAttribute, &name) != kAXErrorSuccess) return nil;
	[name autorelease];
	if (AXValueGetType(name) == kAXValueAXErrorType) return nil;
	return [self objectForUIElement:element name:name];
}
+(QSObject *)objectForUIElement:(id)element name:(NSString *)name{	
	QSObject *object=[QSObject objectWithName:name];
	[object setObject:element forType:kQSUIElementType];
	return object;
}

@end



