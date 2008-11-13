/*
 *  XAOperation.c
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAOperation.h"


#include <XAOperationInternal.h>

static Boolean __XAOperationEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XAOperationRef operationRef1 = (XAOperationRef)cf1;
    
    XAOperationRef operationRef2 = (XAOperationRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= operationRef1 == operationRef2;
    
    return(bRet);
}

static CFHashCode __XAOperationHash(CFTypeRef cf)
{
    XAOperationRef operationRef = (XAOperationRef)cf;
    
    return((CFHashCode)((unsigned int)operationRef));
}

static CFStringRef __XAOperationCopyFormattingDesc(CFTypeRef cf,
												   CFDictionaryRef fOpts)
{
    XAOperationRef operationRef = (XAOperationRef)cf;
    
    CFStringRef			format = CFSTR("[XAOperation: %010#x]");
    
	unsigned int		data = (unsigned int)operationRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(operationRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XAOperationCopyDebugDesc(CFTypeRef cf)
{
    return(__XAOperationCopyFormattingDesc(cf, NULL));
}

void __XAOperationFinalize(CFTypeRef cf)
{	
    XAOperation *operationRef = (XAOperation *)cf;
	
	free(operationRef->vTable);
}

static CFTypeID _kXAOperationTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXAOperationClass = {
	0x00,
	"XAOperation",
	NULL,
	NULL,
	__XAOperationFinalize,
	__XAOperationEqual,
	__XAOperationHash,
	__XAOperationCopyFormattingDesc,
	__XAOperationCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XAOperation class is used.
*/
void __XAOperationClassInitialize(void)
{
    _kXAOperationTypeID = _CFRuntimeRegisterClass(&_kXAOperationClass);
}

XAOperationVTable *XAOperationVTableAllocate(void);

XAOperationRef _XAOperationAllocate(CFAllocatorRef allocator)
{
    XAOperation *operationRef = NULL;
    
    uint32_t extra = sizeof(XAOperation) - sizeof(CFRuntimeBase);
    
    operationRef = (XAOperation *)_CFRuntimeCreateInstance(allocator,
														   _kXAOperationTypeID,
														   extra,
														   NULL);
    
    memset((unsigned char *)operationRef + sizeof(CFRuntimeBase), 0x00, extra);

	operationRef->vTable = XAOperationVTableAllocate();
	
    return((XAOperationRef)operationRef);
}

CFTypeID XAOperationGetTypeID(void)
{
    return(_kXAOperationTypeID);
}

XAOperationRef XAOperationCreate(CFAllocatorRef allocator)
{
	XAOperationRef operationRef = _XAOperationAllocate(allocator);
	
    return(operationRef);
}

Boolean XAPerformOperation(XAOperationRef opaqueRef, int fd, CFStringRef path)
{
	XAOperation *operationRef = (XAOperation *)opaqueRef;
	
	Boolean bRet = operationRef->vTable->performOperation(opaqueRef, fd, path);
	
    return(bRet);
}

Boolean XAOperationPerform(XAOperationRef opaqueRef, int fd, CFStringRef path)
{
    return(0x00);
}

XAOperationVTable *XAOperationVTableAllocate(void)
{
	XAOperationVTable *vTable = malloc(sizeof(*vTable));
	
	vTable->performOperation = XAOperationPerform;
	
	return(vTable);
}

