/*
 *  XARemoveOperation.c
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XARemoveOperation.h"
#include <XAOperationInternal.h>
#include "xattr.h"

typedef struct __XARemoveOperation
{
	XAOperation			operation;
	CFStringRef			key;
}XARemoveOperation;

static Boolean __XARemoveOperationEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XARemoveOperationRef operationRef1 = (XARemoveOperationRef)cf1;
    
    XARemoveOperationRef operationRef2 = (XARemoveOperationRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= operationRef1 == operationRef2;
    
    return(bRet);
}

static CFHashCode __XARemoveOperationHash(CFTypeRef cf)
{
    XARemoveOperationRef operationRef = (XARemoveOperationRef)cf;
    
    return((CFHashCode)((unsigned int)operationRef));
}

static CFStringRef __XARemoveOperationCopyFormattingDesc(CFTypeRef cf,
													   CFDictionaryRef fOpts)
{
    XARemoveOperationRef operationRef = (XARemoveOperationRef)cf;
    
    CFStringRef			format = CFSTR("[XARemoveOperation: %010#x]");
    
	unsigned int		data = (unsigned int)operationRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(operationRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XARemoveOperationCopyDebugDesc(CFTypeRef cf)
{
    return(__XARemoveOperationCopyFormattingDesc(cf, NULL));
}

static void __XARemoveOperationFinalize(CFTypeRef cf)
{	
	__XAOperationFinalize(cf);
}

static CFTypeID _kXARemoveOperationTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXARemoveOperationClass = {
	0x00,
	"XARemoveOperation",
	NULL,
	NULL,
	__XARemoveOperationFinalize,
	__XARemoveOperationEqual,
	__XARemoveOperationHash,
	__XARemoveOperationCopyFormattingDesc,
	__XARemoveOperationCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XARemoveOperation class is used.
*/
void __XARemoveOperationClassInitialize(void)
{
    _kXARemoveOperationTypeID = _CFRuntimeRegisterClass(&_kXARemoveOperationClass);
}

XAOperationVTable *XARemoveOperationVTableAllocate(void);

XARemoveOperationRef _XARemoveOperationAllocate(CFAllocatorRef allocator)
{
    XARemoveOperationRef operationRef = NULL;
    
    uint32_t extra = sizeof(XARemoveOperation) - sizeof(CFRuntimeBase);
    
    operationRef = (XARemoveOperationRef)_CFRuntimeCreateInstance(allocator,
																_kXARemoveOperationTypeID,
																extra,
																NULL);
    
    memset((unsigned char *)operationRef + sizeof(CFRuntimeBase), 0x00, extra);
	
	operationRef->operation.vTable = XARemoveOperationVTableAllocate();
	
    return(operationRef);
}

CFTypeID XARemoveOperationGetTypeID(void)
{
    return(_kXARemoveOperationTypeID);
}

XAOperationRef XARemoveOperationCreate(CFAllocatorRef alloc, char *key)
{
	XARemoveOperationRef operationRef = _XARemoveOperationAllocate(alloc);
	
	operationRef->key = CFStringCreateWithCString(alloc, key, kCFStringEncodingUTF8);

    return((XAOperationRef)operationRef);
}


Boolean XARemoveOperationPerform(XAOperationRef opaqueRef, int fd, CFStringRef path)
{
	Boolean bRet = 0x00;
	
	XARemoveOperationRef operationRef = (XARemoveOperationRef)opaqueRef;
	
	CFIndex bSize = CFStringGetLength(operationRef->key) + 0x01;
	
	char *key = calloc(bSize, sizeof(*key));
	
	int options = XATTR_CREATE | XATTR_REPLACE;
	
	if(CFStringGetCString(operationRef->key, key, bSize, kCFStringEncodingUTF8))
	{
		int iRet = fremovexattr(fd, key, options);
		
		if(iRet < 0x00)
		{
			bRet = 0x00;
		}
	}
	
	free(key);
	
	return(bRet);
}

XAOperationVTable *XARemoveOperationVTableAllocate(void)
{
	XAOperationVTable *vTable = malloc(sizeof(*vTable));
	
	vTable->performOperation = XARemoveOperationPerform;
	
	return(vTable);
}

