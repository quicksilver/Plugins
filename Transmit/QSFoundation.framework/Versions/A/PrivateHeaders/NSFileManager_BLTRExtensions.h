//
//  NSFileManager_CarbonExtensions.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Thu Apr 03 2003.
//  Copyright (c) 2003 Blacktree, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSFileManager (Carbon)
- (bool) isVisible:(NSString *)chem;
- (BOOL)movePathToTrash:(NSString *)filepath;

@end

@interface NSFileManager (Scanning)
- (NSString *)resolveAliasAtPath:(NSString *)aliasFullPath;
- (NSString *)resolveAliasAtPathWithUI:(NSString *)aliasFullPath;
- (NSString *)typeOfFile:(NSString *)path;
- (NSArray *) itemsForPath:(NSString *)path depth:(int)depth types:(NSArray *)types;
- (NSDate *) modifiedDate:(NSString *)path depth:(int)depth;
- (NSDate *)pastOnlyModifiedDate:(NSString *)path;

- (NSString *)fullyResolvedPathForPath:(NSString *)sourcePath;
@end

@interface NSFileManager (BLTRExtensions)
- (int)defaultDragOperationForMovingPaths:(NSArray *)sources toDestination:(NSString *)destination;
    
- (BOOL)createDirectoriesForPath:(NSString *)path;
- (BOOL)filesExistAtPaths:(NSArray *)paths;
- (NSDictionary *)conflictsForFiles:(NSArray *)files inDestination:(NSString *)destination;
@end