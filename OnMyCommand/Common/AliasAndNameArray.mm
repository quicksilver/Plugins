//**************************************************************************************
// Filename:	AliasAndNameArray.mm
//				Part of Contextual Menu Workshop by Abracode Inc.
//				http://free.abracode.com/cmworkshop/
// Copyright © 2002-2003 Abracode, Inc.  All rights reserved.
//
// Description:	
//
//**************************************************************************************

#import "AliasAndNameArray.h"
#include <Carbon/Carbon.h>
#include "CFAliasPathAndNameArray.h"
#include "CFObjDel.h"

@implementation AliasAndNameArray

- (NSString *)description
{
    return @"AliasAndNameArray";
}

- (id)init;
{
    if (![super init])
        return nil;

    mArray = new CFAliasPathAndNameArray();

    return self;
}

- (id)initWithKey:(NSString *)inKey withPrefsIdentifier:(NSString *)inID withVersion:(int)version;
{
    if (![super init])
        return nil;
    
     mArray = new CFAliasPathAndNameArray((CFStringRef)inKey, (CFStringRef)inID, (CFIndex)version);
    
    return self;
}

//takes ownership of inArray
- (id)initWithAliasArray: (CFAliasPathAndNameArray *)inArray
{
    if (![super init])
        return nil;
	if(inArray != nil)
	{
		mArray = inArray;
	}
	else
	{
		 mArray = new CFAliasPathAndNameArray();
	}
	return self;
}

//caller should not dispose of array because this object owns it
- (CFAliasPathAndNameArray *) getArray
{
	return mArray;
}


- (void)dealloc;
{
    delete mArray;
    [super dealloc];
}

- (unsigned)count;
{
    if(mArray != NULL)
        return mArray->GetCount();
    return 0;
}

- (NSString *)getNameAtIndex:(unsigned)index;
{
    if(mArray != NULL)
        return (NSString *)mArray->FetchNameAt((CFIndex)index);
    return NULL;
}

- (NSString *)getPathAtIndex:(unsigned)index;
{
    if(mArray != NULL)
    {
        FSRef fileRef;
        if( mArray->FetchFSRefAt((CFIndex)index, fileRef) )
           return [self pathFromFSRef: &fileRef];
		else
			return (NSString *)mArray->FetchPathAt((CFIndex)index);
    }
    return NULL;
}


- (void)setName:(NSString *)name atIndex:(unsigned)index;
{
    if(mArray != NULL)
        mArray->SetNameAt((CFStringRef)name, index);
}

- (void)setPath:(NSString *)path atIndex:(unsigned)index;
{
    if(mArray != NULL)
    {
		mArray->SetPathAt((CFStringRef)path, index);

        FSRef fileRef;
        if([self getFSRefFromPath:path toRef: &fileRef])
        {
            mArray->SetFSRefAt(fileRef, index);
        }
    }
}

- (void)addPath:(NSString *)path;
{
    if((mArray != NULL) && (path != NULL))
    {
        FSRef fileRef;
        if([self getFSRefFromPath:path toRef: &fileRef])
        {
            mArray->AddPair( &fileRef, NULL);
        }
    }
}

- (void)insertPath:(NSString *)path withName:(NSString *)name atIndex:(unsigned)index;
{
    if((mArray != NULL) && (path != NULL))
    {
        FSRef fileRef;
        if([self getFSRefFromPath:path toRef: &fileRef])
        {
            mArray->InsertPairAt( &fileRef, (CFStringRef)name, (CFIndex)index);
        }
    }
}

- (void)removeItemAt:(unsigned)index;
{
    if(mArray != NULL)
        mArray->RemoveItemAt(index);
}

- (unsigned)moveRows:(NSArray *)rowList toRow:(int)newRow;
{
    if((mArray == NULL) || (rowList == NULL)) return 0;

    NSArray *sortedIndexes = [rowList sortedArrayUsingSelector:@selector(compare:)];
    
    return mArray->MoveItems((CFArrayRef)sortedIndexes, newRow);
    
    /*
    unsigned indexCount = [sortedIndexes count];
    
    int oldPos, newPos;

    int lastIndex = newRow;
    for(unsigned i = 0; i < indexCount; i++)
    {
        NSNumber *theNum = (NSNumber *)[sortedIndexes objectAtIndex:i];
        oldPos = [theNum intValue];
        newPos = newRow + i;
        if(oldPos != newPos)
            lastIndex = 
        else
            lastIndex = newPos;
    }
    
    return (unsigned)(lastIndex + 1 - indexCount);
    */
}


- (void)saveArrayToPrefsWithKey:(NSString *)inKey withPrefsIdentifier:(NSString *)inID;
{
    if(mArray != NULL)
    {
        mArray->SaveArrayToPrefs((CFStringRef)inKey, (CFStringRef)inID);
    }
}

- (NSString *)pathFromFSRef:(FSRef *)inRef;
{
    if(inRef == NULL)
        return NULL;

    CFURLRef urlRef = ::CFURLCreateFromFSRef( kCFAllocatorDefault, inRef);
    if(urlRef != NULL)
    {
        CFObjDel urlDel(urlRef);
        NSString * thePath = (NSString *)::CFURLCopyFileSystemPath(urlRef, kCFURLPOSIXPathStyle);
        if(thePath != NULL)
            [thePath autorelease];
        return thePath;
    }
    return NULL;
}

- (BOOL)getFSRefFromPath:(NSString *)inPath toRef: (FSRef *)ioRef;
{
    if((inPath == NULL) || (ioRef == NULL))
        return FALSE;

    CFURLRef urlRef = ::CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)inPath, kCFURLPOSIXPathStyle,false);
    if(urlRef != NULL)
    {
	CFObjDel urlDel(urlRef);
        return ::CFURLGetFSRef(urlRef, ioRef);
    }
    return FALSE;
}



@end
