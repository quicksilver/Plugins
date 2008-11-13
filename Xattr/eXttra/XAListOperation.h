/*
 *  XAListOperation.h
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _XA_LIST_OPERATION_H_
#define _XA_LIST_OPERATION_H_

/*
#include <XAListOperation.h>
 */

#include <XATypes.h>

XAOperationRef XAListOperationCreate(CFAllocatorRef allocator);

void XAListOperationSetListStyle(XAListOperationRef operationRef, XAListStyle style);

void XAListOperationPrintData(XAOperationRef opaqueRef, UInt8 *bytes, UInt32 size);

#endif



