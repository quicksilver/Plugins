//**************************************************************************************
// Filename:	AliasAndNameArray.h
//				Part of Contextual Menu Workshop by Abracode Inc.
//				http://free.abracode.com/cmworkshop/
// Copyright © 2002-2003 Abracode, Inc.  All rights reserved.
//
// Description:	
//
//**************************************************************************************

#import <AppKit/AppKit.h>

class CFAliasPathAndNameArray;

@interface AliasAndNameArray : NSObject
{
    CFAliasPathAndNameArray *mArray;
}

- (id)initWithKey:(NSString *)inKey withPrefsIdentifier:(NSString *)inID withVersion:(int)version;
- (id)initWithAliasArray: (CFAliasPathAndNameArray *)inArray;
- (unsigned)count;
- (CFAliasPathAndNameArray *) getArray;
- (NSString *)getNameAtIndex:(unsigned)index;
- (NSString *)getPathAtIndex:(unsigned)index;
- (void)setName:(NSString *)name atIndex:(unsigned)index;
- (void)setPath:(NSString *)path atIndex:(unsigned)index;
- (void)addPath:(NSString *)path;
- (void)insertPath:(NSString *)path withName:(NSString *)name atIndex:(unsigned)index;
- (void)removeItemAt:(unsigned)index;
- (unsigned)moveRows:(NSArray *)rowList toRow:(int)newRow;
- (void)saveArrayToPrefsWithKey:(NSString *)inKey withPrefsIdentifier:(NSString *)inID;
- (NSString *)pathFromFSRef:(FSRef *)inRef;
- (BOOL)getFSRefFromPath:(NSString *)inPath toRef: (FSRef *)ioRef;

@end
