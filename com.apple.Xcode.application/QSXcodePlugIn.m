//
//  QSXcodePlugIn.m
//  QSXcodePlugIn
//
//  Created by Nicholas Jitkoff on 6/12/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSXcodePlugIn.h"
#define kQSXcodePlugInType @"qs.apple.xcode.project"

@implementation QSXcodePlugIn

- (BOOL)validParserForPath:(NSString *)path{
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isDirectory, exists;
    exists=[manager fileExistsAtPath:[path stringByStandardizingPath] isDirectory:&isDirectory];
	return exists && ![[path pathExtension]caseInsensitiveCompare:@"xcodeproj"];
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
	//- (NSArray *)objectsFromData:(NSData *)data encoding:(NSStringEncoding)encoding settings:(NSDictionary *)settings source:(NSURL *)source{
	NSLog(@"path %@",path);
  
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile:[path stringByAppendingPathComponent:@"project.pbxproj"]];
	//NSString *rootid=[dict objectForKey:@"rootObject"];
	NSDictionary *objectDict=[dict objectForKey:@"objects"];
	NSString *rootID=[dict objectForKey:@"rootObject"];
	NSDictionary *root=[objectDict objectForKey:rootID];
	root=[objectDict objectForKey:[root objectForKey:@"mainGroup"]];
  NSString *basePath = [path stringByDeletingLastPathComponent];
  NSDictionary *variables = [NSDictionary dictionaryWithObjectsAndKeys:
    basePath, @"SOURCE_ROOT",
    nil];
	NSArray *children = [self childrenOfXcodeObject:root objectList:objectDict variables:variables path:basePath];
	NSLog(@"root %@ %@ %@",root,rootID, children);
	return children;
  }
- (NSArray *)childrenOfXcodeObject:(NSDictionary *)object objectList:(NSDictionary *)objectDict variables:(NSDictionary *)variables path:(NSString *)basePath{
  NSMutableArray *children = [NSMutableArray array];
  
  NSArray *childIDs = [object valueForKey:@"children"];
  for(NSString * childID in childIDs) {
    NSDictionary *child = [objectDict objectForKey:childID];
    NSString *type = [child objectForKey:@"isa"];
    NSString *sourceTree = [child objectForKey:@"sourceTree"];
    NSString *childPath = [child objectForKey:@"path"];
    NSString *path = nil;
    
    if ([sourceTree isEqualToString:@"SOURCE_ROOT"]) {
      path = [variables objectForKey:@"SOURCE_ROOT"];  
    } else if ([sourceTree isEqualToString:@"<group>"]) {
      path = basePath;
    } else if ([sourceTree isEqualToString:@"<absolute>"]) {
    
    } else {
      path = sourceTree; 
    }
    
    if (childPath) path = [path stringByAppendingPathComponent:childPath];
    
    
    NSLog(@"child %@",child);
    NSLog(@"path %@", path);
    if ([type isEqualToString:@"PBXGroup"]) {
      NSArray *grandchildren = [self childrenOfXcodeObject:child objectList:objectDict variables:variables path:path];
      [children addObjectsFromArray:grandchildren];
    } else if ([type isEqualToString:@"PBXFileReference"]) {
      QSObject *object = [QSObject fileObjectWithPath:path];
      if (object) [children addObject:object];
    }
  }
  return children;
  //  NSMutableArray *children = [self childrenOfXcodeObject:child objectList:objectDict];
}

- (id)initFileObject:(QSObject *)object ofType:(NSString *)type{
	NSString *filePath=[object singleFilePath];
	[object setObject:filePath forType:kQSXcodePlugInType];
	[object setPrimaryType:kQSXcodePlugInType];
	//	[object setDetails:[[mditem valueForAttribute:kMDItemAuthors]lastObject]];
	return object;
	
}


// Object Handler Methods

 - (void)setQuickIconForObject:(QSObject *)object{
	 [object setIcon:nil]; // An icon that is either already in memory or easy to load
 }
 - (BOOL)loadIconForObject:(QSObject *)object{
	 return NO;
	 id data=[object objectForType:kQSXcodePlugInType];
	 [object setIcon:nil];
	 return YES;
}


@end
