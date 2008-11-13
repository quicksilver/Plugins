/*
 *  XAFile.h
 *  eXttra
 *
 *  Created by nibs ra on 2/9/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _XA_FILE_H_
#define _XA_FILE_H_

/*
#include <XAFile.h>
 */

#include <XATypes.h>

XAFileRef XAFileCreateWithPath(CFAllocatorRef allocator, CFStringRef path);

CFIndex XAFileAttributeCount(XAFileRef fileRef);

XAAttributeRef XAFileAttributeAtIndex(XAFileRef fileRef, CFIndex index);

void XAFileRemoveAttributeAtIndex(XAFileRef fileRef, CFIndex index);

void XAFileAppendAttribute(XAFileRef fileRef, XAAttributeRef attributeRef);

XAErrorCode XAFileSaveAttributes(XAFileRef fileRef);

XAErrorCode XAFileLoadAttributes(XAFileRef fileRef);

void XAFileExecuteOperations(XAFileRef fileRef, CFMutableArrayRef operations);


#endif


