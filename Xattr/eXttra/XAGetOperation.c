/*
 *  XAGetOperation.c
 *  eXttra
 *
 *  Created by nibs ra on 4/13/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAAttribute.h"
#include "XAGetOperation.h"
#include <XAOperationInternal.h>
#include <XAListOperation.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include <mach/mach.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "xattr.h"

typedef struct __XAGetOperation
{
	XAOperation			operation;
	CFStringRef			key;
	XAListStyle			listStyle;
}XAGetOperation;

static Boolean __XAGetOperationEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XAGetOperationRef operationRef1 = (XAGetOperationRef)cf1;
    
    XAGetOperationRef operationRef2 = (XAGetOperationRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= operationRef1 == operationRef2;
    
    return(bRet);
}

static CFHashCode __XAGetOperationHash(CFTypeRef cf)
{
    XAGetOperationRef operationRef = (XAGetOperationRef)cf;
    
    return((CFHashCode)((unsigned int)operationRef));
}

static CFStringRef __XAGetOperationCopyFormattingDesc(CFTypeRef cf,
													  CFDictionaryRef fOpts)
{
    XAGetOperationRef operationRef = (XAGetOperationRef)cf;
    
    CFStringRef			format = CFSTR("[XAGetOperation: %010#x]");
    
	unsigned int		data = (unsigned int)operationRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(operationRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XAGetOperationCopyDebugDesc(CFTypeRef cf)
{
    return(__XAGetOperationCopyFormattingDesc(cf, NULL));
}

static void __XAGetOperationFinalize(CFTypeRef cf)
{	
	__XAOperationFinalize(cf);
}

static CFTypeID _kXAGetOperationTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXAGetOperationClass = {
	0x00,
	"XAGetOperation",
	NULL,
	NULL,
	__XAGetOperationFinalize,
	__XAGetOperationEqual,
	__XAGetOperationHash,
	__XAGetOperationCopyFormattingDesc,
	__XAGetOperationCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XAGetOperation class is used.
*/
void __XAGetOperationClassInitialize(void)
{
    _kXAGetOperationTypeID = _CFRuntimeRegisterClass(&_kXAGetOperationClass);
}

XAOperationVTable *XAGetOperationVTableAllocate(void);

XAGetOperationRef _XAGetOperationAllocate(CFAllocatorRef allocator)
{
    XAGetOperationRef operationRef = NULL;
    
    uint32_t extra = sizeof(XAGetOperation) - sizeof(CFRuntimeBase);
    
    operationRef = (XAGetOperationRef)_CFRuntimeCreateInstance(allocator,
															   _kXAGetOperationTypeID,
															   extra,
															   NULL);
    
    memset((unsigned char *)operationRef + sizeof(CFRuntimeBase), 0x00, extra);
	
	operationRef->operation.vTable = XAGetOperationVTableAllocate();
	
	operationRef->listStyle = XADefaultListStyle;

    return(operationRef);
}

CFTypeID XAGetOperationGetTypeID(void)
{
    return(_kXAGetOperationTypeID);
}

XAOperationRef XAGetOperationCreate(CFAllocatorRef alloc, char *key)
{
	XAGetOperationRef operationRef = _XAGetOperationAllocate(alloc);
	
	operationRef->key = CFStringCreateWithCString(alloc, key, kCFStringEncodingUTF8);
	
    return((XAOperationRef)operationRef);
}

Boolean XAGetOperationPerform(XAOperationRef opaqueRef, int fd, CFStringRef path)
{
	Boolean bRet = 0x00;
	
	XAGetOperationRef operationRef = (XAGetOperationRef)opaqueRef;
	
	CFIndex kSize = CFStringGetLength(operationRef->key) + 0x01;
	
	char *gKey = calloc(kSize, sizeof(*gKey));
	
	if(CFStringGetCString(operationRef->key, gKey, kSize, kCFStringEncodingUTF8))
	{
		char *keys = 0x00; size_t size = 0x00; int options = 0x00;
		
		CFIndex bSize = CFStringGetLength(path) + 0x01;
		
		char *buffer = calloc(bSize, sizeof(*buffer));
		
		if(CFStringGetCString(path, buffer, bSize, kCFStringEncodingUTF8))
		{
			char *kFormat = 0x00;
			
			switch(operationRef->listStyle)
			{
				case(XADefaultListStyle):
					kFormat = "%s\n";
					break;
				case(XAParseableListStyle):
					kFormat = "%s:\n";
					break;
				default:
					kFormat = "%s\n";
					break;
			}
			
			fprintf(stdout, kFormat, buffer);
		}
		
		size = flistxattr(fd, keys, size, options);
		
		if(size > 0x00)
		{
			char *key = 0x00;
			
			keys = calloc(size, sizeof(*keys));
			
			size = flistxattr(fd, keys, size, options);
			
			int sLen = 0x00;  
			
			for(key = keys; key < keys + size; key += 0x01 + sLen)
			{
				UInt8 *bytes = 0x00; size_t bSize = 0x00;
				
				UInt32 position = 0x00; int bOptions = 0x00;
				
				sLen = strlen(key);
				
				if(strcmp(gKey, key) == 0x00)
				{
					bSize = fgetxattr(fd, key, (void *)bytes, bSize, position, bOptions);
					
					if(bSize > 0x00)
					{
						bytes = calloc(bSize + 0x01, sizeof(*bytes));
						
						bSize = fgetxattr(fd, key, (void *)bytes, bSize, position, bOptions);
						
						if(bSize > 0x00)
						{
							switch(operationRef->listStyle)
							{
								case(XADefaultListStyle):
									fprintf(stdout, "\t%s\t", key);
									break;
								case(XAParseableListStyle):
									fprintf(stdout, "%s=", key);
									break;
								default:
									fprintf(stdout, "\t%s\t", key);
									break;
							}
							
							XAListOperationPrintData(operationRef, bytes, bSize);
							
							fprintf(stdout, "\n");
						}
						
						free(bytes);
					}
					
				}
			}
			
		}
		
	}
	
	return(bRet);
}

XAOperationVTable *XAGetOperationVTableAllocate(void)
{
	XAOperationVTable *vTable = malloc(sizeof(*vTable));
	
	vTable->performOperation = XAGetOperationPerform;
	
	return(vTable);
}

void XAGetOperationSetListStyle(XAGetOperationRef operationRef, XAListStyle style)
{
	operationRef->listStyle = style;
}

