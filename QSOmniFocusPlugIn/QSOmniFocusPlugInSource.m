//
//  QSOmniFocusPlugInSource.m
//  QSOmniFocusPlugIn
//
//  Created by Nicholas Jitkoff on 5/17/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import "QSOmniFocusPlugIn_Prefix.pch"
#import "QSOmniFocusPlugInSource.h"
#import <QSCore/QSObject.h>


@implementation QSOmniFocusPlugInSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return NO;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}


// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}
- (NSAppleScript *)script {
  static NSAppleScript *script = nil;
  if (!script) {
    NSString *path = [[NSBundle bundleForClass:[self class]] pathForResource:@"OmniFocus" ofType:@"scpt"];
    NSLog(@"path %@", path);
    NSURL *url = [NSURL fileURLWithPath:path];
    script = [[NSAppleScript alloc] initWithContentsOfURL:url
                                                   error:nil];
  }
  return script;
}


- (BOOL)loadChildrenForObject:(QSObject *)object{
	NSArray *children=[self objectsForEntry:nil];
	
	if (children){
		[object setChildren:children];
		return YES;   
	}
	return NO;
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
  
		id result=[[[self script] executeSubroutine:@"get_projects"
                                      arguments:nil
                                          error:nil]objectValue];
		NSLog(@"res %@ %@",result, [self script]);

		//NSArray *names=[result objectAtIndex:1];
    
		NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
		QSObject *newObject;
		
    NSDictionary *project;
    NSEnumerator *enumerator = [result objectEnumerator];
		while (project = [enumerator nextObject]){
      NSString *ident = [project objectAtIndex:0];
      NSString *name = [project objectAtIndex:1];
      
      NSLog(@"new %@ %@", name, ident);
			newObject=[QSObject objectWithName:name];
      [newObject setIdentifier:ident];
			[newObject setObject:ident forType:kQSOmniFocusPlugInType];
			[newObject setPrimaryType:kQSOmniFocusPlugInType];
			if (newObject) [objects addObject:newObject];
		}
		
    return objects;
}


// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:nil]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:kQSOmniFocusPlugInType];
	[object setIcon:nil];
    return YES;
}
*/
@end
