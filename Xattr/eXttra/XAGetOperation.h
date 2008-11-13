/*
 *  XAGetOperation.h
 *  eXttra
 *
 *  Created by nibs ra on 4/13/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _XA_GET_OPERATION_H_
#define _XA_GET_OPERATION_H_

/*
#include <XAGetOperation.h>
 */

#include <XATypes.h>


XAOperationRef XAGetOperationCreate(CFAllocatorRef alloc, char *key);

void XAGetOperationSetListStyle(XAGetOperationRef operationRef, XAListStyle style);

#endif

