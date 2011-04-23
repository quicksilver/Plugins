//
//  QSUIAccessPlugIn_Source.m
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//
#import "QSUIAccessPlugIn_Action.h"
#import "QSUIAccessPlugIn_Source.h"
#import <QSCore/QSCore.h>
//#import <QSCore/QSMacros.h>

@implementation QSUIAccessPlugIn_Source
- (NSString *)identifierForObject:(id <QSObject>)object{
  return nil;
}

// Object Handler Methods

- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"Object"]]; // An icon that is either already in memory or easy to load
}

- (BOOL)objectHasChildren:(QSObject *)object{
	id element=[object objectForType:kQSUIElementType];
	CFIndex count=0;
	AXUIElementGetAttributeValueCount(element, kAXChildrenAttribute, &count);
	return count;
}

- (NSString *)detailsOfObject:(QSObject *)object{
  return nil;
}

- (NSArray *)childrenForElement:(AXUIElementRef)element{
	CFIndex count=0;
	NSArray *children=nil;
	AXUIElementGetAttributeValueCount(element, kAXChildrenAttribute, &count);
	AXUIElementCopyAttributeValues(element, kAXChildrenAttribute, 0, count, &children);
	return [children autorelease];
}

- (NSArray *)objectsForElements:(NSArray *)elements process:(NSDictionary *)process {
	if (!elements)return nil;
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:[elements count]];
	for(NSString * element in elements){
		NSString *name = nil; 
		AXUIElementCopyAttributeValue (element, kAXTitleAttribute, &name);
		[name autorelease];
		//NSLog(@"name %@",name);
		if (![name length]) continue;
		QSObject *object=[QSObject objectForUIElement:element name:name process:process];
		[objects addObject:object];		
	}
	return objects;
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
  AXUIElementRef element = [object objectForType:kQSUIElementType];
	NSArray *children = [self childrenForElement:element];
  NSDictionary *process = [object objectForType:kWindowsProcessType];
	[object setChildren:[self objectsForElements:children process:process]];
	return YES;
}

@end


QSObject * QSObjectForAXUIElementWithNameProcessType(id element, NSString *name, NSDictionary *process, NSString *type)
{
  if (!name) {
    NSString *newName = nil;
    if (AXUIElementCopyAttributeValue(element, kAXTitleAttribute, &newName) != kAXErrorSuccess) return nil;
    if (AXValueGetType(newName) == kAXValueAXErrorType) return nil;
    [newName autorelease];
    name = newName;
  }
  
  QSObject *object = [QSObject objectWithName:name];
	[object setObject:element forType:type];
	[object setObject:process forType:kWindowsProcessType];
	return object;
}

@implementation QSObject (UIElement)
+ (QSObject *)objectForUIElement:(id)element name:(NSString *)name process:(NSDictionary *)process
{
  QSObject *object = QSObjectForAXUIElementWithNameProcessType(element, name, process, kQSUIElementType);
  NSString *path = [process objectForKey:@"NSApplicationPath"];
  if (path) {
    [object setIcon:[[NSWorkspace sharedWorkspace] iconForFile:path]];
  }
  return object;
}
@end

@implementation QSObject (Windows)
+ (QSObject *)objectForWindow:(id)element name:(NSString *)name process:(NSDictionary *)process
{
  QSObject *object = QSObjectForAXUIElementWithNameProcessType(element, name, process, kWindowsType);
  [object setIcon:[QSResourceManager imageNamed:@"WindowIcon"]];
  CFArrayRef windows = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements, kCGNullWindowID);
  for (NSDictionary *info in (NSArray *)windows)
  {
    if (![(NSNumber *)[info objectForKey:kCGWindowOwnerPID] isEqual:[process objectForKey:@"NSApplicationProcessIdentifier"]]) continue;
    CFStringRef windowName = [info objectForKey:kCGWindowName];
    if (!windowName) continue;
    if ([windowName localizedCompare:[object name]] != 0) continue;
    CGImageRef windowImage = CGWindowListCreateImage(CGRectNull, kCGWindowListOptionIncludingWindow, [[info objectForKey:kCGWindowNumber] unsignedIntValue], kCGWindowImageBoundsIgnoreFraming);
    if ((!windowImage) || (CGImageGetWidth(windowImage) < 1) || (CGImageGetHeight(windowImage) < 1)) {
      continue;
    }
    else {
      NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithCGImage:windowImage];
      NSImage *icon = [[NSImage alloc] init];
      [icon addRepresentation:rep];
      [rep release];
      [object setIcon:icon];
      [icon release];
    }
    CGImageRelease(windowImage);
    break;
  }
  [windows release];
  
  return object;
}
@end

