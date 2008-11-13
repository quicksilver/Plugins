/*
 *  XASetOperation.c
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAAttribute.h"
#include "XASetOperation.h"
#include <XAOperationInternal.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <mach/mach.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "xattr.h"

typedef struct __XASetOperation
{
	XAOperation			operation;
	CFStringRef			key;
	CFDataRef			data;
}XASetOperation;

static Boolean __XASetOperationEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XASetOperationRef operationRef1 = (XASetOperationRef)cf1;
    
    XASetOperationRef operationRef2 = (XASetOperationRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= operationRef1 == operationRef2;
    
    return(bRet);
}

static CFHashCode __XASetOperationHash(CFTypeRef cf)
{
    XASetOperationRef operationRef = (XASetOperationRef)cf;
    
    return((CFHashCode)((unsigned int)operationRef));
}

static CFStringRef __XASetOperationCopyFormattingDesc(CFTypeRef cf,
													   CFDictionaryRef fOpts)
{
    XASetOperationRef operationRef = (XASetOperationRef)cf;
    
    CFStringRef			format = CFSTR("[XASetOperation: %010#x]");
    
	unsigned int		data = (unsigned int)operationRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(operationRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XASetOperationCopyDebugDesc(CFTypeRef cf)
{
    return(__XASetOperationCopyFormattingDesc(cf, NULL));
}

static void __XASetOperationFinalize(CFTypeRef cf)
{	
	__XAOperationFinalize(cf);
}

static CFTypeID _kXASetOperationTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXASetOperationClass = {
	0x00,
	"XASetOperation",
	NULL,
	NULL,
	__XASetOperationFinalize,
	__XASetOperationEqual,
	__XASetOperationHash,
	__XASetOperationCopyFormattingDesc,
	__XASetOperationCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XASetOperation class is used.
*/
void __XASetOperationClassInitialize(void)
{
    _kXASetOperationTypeID = _CFRuntimeRegisterClass(&_kXASetOperationClass);
}

XAOperationVTable *XASetOperationVTableAllocate(void);

XASetOperationRef _XASetOperationAllocate(CFAllocatorRef allocator)
{
    XASetOperationRef operationRef = NULL;
    
    uint32_t extra = sizeof(XASetOperation) - sizeof(CFRuntimeBase);
    
    operationRef = (XASetOperationRef)_CFRuntimeCreateInstance(allocator,
																_kXASetOperationTypeID,
																extra,
																NULL);
    
    memset((unsigned char *)operationRef + sizeof(CFRuntimeBase), 0x00, extra);
	
	operationRef->operation.vTable = XASetOperationVTableAllocate();
	
    return(operationRef);
}

CFTypeID XASetOperationGetTypeID(void)
{
    return(_kXASetOperationTypeID);
}

CFDataRef XACopyEADataForPath(CFStringRef path)
{
	CFDataRef data = 0x00;

	CFIndex bSize = CFStringGetLength(path) + 0x01;
	
	char *buffer = calloc(bSize, sizeof(*buffer));
	
	if(CFStringGetCString(path, buffer, bSize, kCFStringEncodingUTF8))
	{
		int fd = open(buffer, O_RDONLY, 0x00);
		
		if(fd > 0x00)
		{
			struct stat sb;
			
			if(!fstat(fd, &sb))
			{
				off_t size = sb.st_size;
				
				if(size <= 0x1000)
				{
					UInt8 *bytes = malloc(size * sizeof(*bytes));
					
					read(fd, bytes, size);
					
					data = CFDataCreateWithBytesNoCopy(CFGetAllocator(path),
													   bytes, size,
													   kCFAllocatorMalloc);

				}
				
			}
			
			close(fd);
		}
		
	}
	
	free(buffer);
	
	return(data);
}

XAOperationRef XASetOperationCreate(CFAllocatorRef alloc, char *key, char *value)
{
	XASetOperationRef operationRef = _XASetOperationAllocate(alloc);
	
	operationRef->key = CFStringCreateWithCString(alloc, key, kCFStringEncodingUTF8);

	operationRef->data = CFDataCreate(alloc, (unsigned char *)value, strlen(value));

    return((XAOperationRef)operationRef);
}

XAOperationRef XASetDataOperationCreate(CFAllocatorRef alloc, char *key, CFStringRef path)
{
	CFDataRef data = XACopyEADataForPath(path);
	
	XASetOperationRef operationRef = 0x00;
	
	if(data)
	{
		operationRef = _XASetOperationAllocate(alloc);
		
		operationRef->key = CFStringCreateWithCString(alloc, key, kCFStringEncodingUTF8);
		
		operationRef->data = data;
	}
	
    return((XAOperationRef)operationRef);
}

XAOperationRef XASetOperationCreateWithPath(CFAllocatorRef alloc, char *key, CFStringRef path)
{
	XASetOperationRef operationRef = 0x00;
	
	CFIndex bSize = CFStringGetLength(path) + 0x01;
	
	char *buffer = calloc(bSize, sizeof(*buffer));
	
	if(CFStringGetCString(path, buffer, bSize, kCFStringEncodingUTF8))
	{
		int fd = open(buffer, O_RDONLY, 0x00);
		
		if(fd > 0x00)
		{
			operationRef = _XASetOperationAllocate(alloc);

			operationRef->key = CFStringCreateWithCString(alloc, key, kCFStringEncodingUTF8);
			
			operationRef->data = XACopyAttribute(alloc, fd, key);
				
			close(fd);
		}
		
	}
	
	free(buffer);
	
    return((XAOperationRef)operationRef);
}


Boolean XASetOperationPerform(XAOperationRef opaqueRef, int fd, CFStringRef path)
{
	Boolean bRet = 0x00;
	
	XASetOperationRef operationRef = (XASetOperationRef)opaqueRef;
	
	const UInt8 *bytes = CFDataGetBytePtr(operationRef->data);
	
	size_t size = CFDataGetLength(operationRef->data);
	
	CFIndex bSize = CFStringGetLength(operationRef->key) + 0x01;
	
	char *key = calloc(bSize, sizeof(*key));
	
	UInt32 position = 0x00; int options = 0x00;
	
	if(CFStringGetCString(operationRef->key, key, bSize, kCFStringEncodingUTF8))
	{
		size = fsetxattr(fd, key, (void *)bytes, size, position, options);
	}
	
	free(key);	
	
	return(bRet);
}

XAOperationVTable *XASetOperationVTableAllocate(void)
{
	XAOperationVTable *vTable = malloc(sizeof(*vTable));
	
	vTable->performOperation = XASetOperationPerform;
	
	return(vTable);
}

