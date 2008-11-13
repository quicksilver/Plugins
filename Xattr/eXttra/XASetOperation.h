/*
 *  XASetOperation.h
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _XA_SET_OPERATION_H_
#define _XA_SET_OPERATION_H_

/*
#include <XASetOperation.h>
 */

#include <XATypes.h>


XAOperationRef XASetOperationCreate(CFAllocatorRef allocator, char *key, char *value);

XAOperationRef XASetDataOperationCreate(CFAllocatorRef alloc, char *key, CFStringRef path);

XAOperationRef XASetOperationCreateWithPath(CFAllocatorRef alloc, char *key, CFStringRef path);

#endif


