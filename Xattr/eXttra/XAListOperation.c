/*
 *  XAListOperation.c
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAListOperation.h"

#include <XAOperationInternal.h>
#include <XAUtilities.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include "xattr.h"

typedef struct __XAListOperation
{
	XAOperation			operation;
	XAListStyle			listStyle;
}XAListOperation;

static Boolean __XAListOperationEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XAListOperationRef operationRef1 = (XAListOperationRef)cf1;
    
    XAListOperationRef operationRef2 = (XAListOperationRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= operationRef1 == operationRef2;
    
    return(bRet);
}

static CFHashCode __XAListOperationHash(CFTypeRef cf)
{
    XAListOperationRef operationRef = (XAListOperationRef)cf;
    
    return((CFHashCode)((unsigned int)operationRef));
}

static CFStringRef __XAListOperationCopyFormattingDesc(CFTypeRef cf,
													   CFDictionaryRef fOpts)
{
    XAListOperationRef operationRef = (XAListOperationRef)cf;
    
    CFStringRef			format = CFSTR("[XAListOperation: %010#x]");
    
	unsigned int		data = (unsigned int)operationRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(operationRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XAListOperationCopyDebugDesc(CFTypeRef cf)
{
    return(__XAListOperationCopyFormattingDesc(cf, NULL));
}

static void __XAListOperationFinalize(CFTypeRef cf)
{	
	__XAOperationFinalize(cf);
}

static CFTypeID _kXAListOperationTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXAListOperationClass = {
	0x00,
	"XAListOperation",
	NULL,
	NULL,
	__XAListOperationFinalize,
	__XAListOperationEqual,
	__XAListOperationHash,
	__XAListOperationCopyFormattingDesc,
	__XAListOperationCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XAListOperation class is used.
*/
void __XAListOperationClassInitialize(void)
{
    _kXAListOperationTypeID = _CFRuntimeRegisterClass(&_kXAListOperationClass);
}

XAOperationVTable *XAListOperationVTableAllocate(void);

XAListOperationRef _XAListOperationAllocate(CFAllocatorRef allocator)
{
    XAListOperationRef operationRef = NULL;
    
    uint32_t extra = sizeof(XAListOperation) - sizeof(CFRuntimeBase);
    
    operationRef = (XAListOperationRef)_CFRuntimeCreateInstance(allocator,
															 _kXAListOperationTypeID,
															 extra,
															 NULL);
    
    memset((unsigned char *)operationRef + sizeof(CFRuntimeBase), 0x00, extra);

	operationRef->operation.vTable = XAListOperationVTableAllocate();
	
	operationRef->listStyle = XADefaultListStyle;
	
    return(operationRef);
}

CFTypeID XAListOperationGetTypeID(void)
{
    return(_kXAListOperationTypeID);
}

XAOperationRef XAListOperationCreate(CFAllocatorRef allocator)
{
	XAListOperationRef operationRef = _XAListOperationAllocate(allocator);
		
    return((XAOperationRef)operationRef);
}

void XAListOperationPrintData(XAOperationRef opaqueRef, UInt8 *bytes, UInt32 size)
{
	char printable = 0x00;

	if(XAPrintableData(bytes, size))
	{
		char *sTemp = (char *)calloc(size + 0x01, sizeof(*sTemp));
		
		if(sTemp)
		{
			int index = 0x00; int sIndex = 0x00;
			
			char cNull = 0x00;
			
			for(index = 0x00; index < size; index++)
			{
				if(bytes[index] == 0x00)
				{
					if(!cNull)
					{
						sTemp[sIndex++] = ' ';
					}
					
					cNull = 0x01;
				}else
				{
					sTemp[sIndex++] = bytes[index];
					cNull = 0x00;
					printable = 0x01;
				}
				
			}
			
			if(printable)
			{
				fprintf(stdout, "%s", sTemp);
			}
			
			free(sTemp);
		}
		
	}
	
	if(!printable)
	{
		UInt32 index = 0x00;
		
		fprintf(stdout, "<%0#4x", bytes[0x00]);
		
		for(index = 0x01; index < size; index++)
		{
			fprintf(stdout, ", %0#4x", bytes[index]);
		}
		
		fprintf(stdout, ">");
		
	}

}

Boolean XAListOperationPerform(XAOperationRef opaqueRef, int fd, CFStringRef path)
{
	Boolean bRet = 0x00;
	
	XAListOperationRef operationRef = (XAListOperationRef)opaqueRef;
	
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
		
		int sLen = 0x00;  int maxLen = 0x00;
		
		for(key = keys; key < keys + size; key += 0x01 + sLen)
		{
			sLen = strlen(key);
			
			maxLen = max(maxLen, sLen);
		}
		
		for(key = keys; key < keys + size; key += 0x01 + sLen)
		{
			UInt8 *bytes = 0x00; size_t bSize = 0x00;
			
			UInt32 position = 0x00; int bOptions = 0x00;
			
			sLen = strlen(key);

			bSize = fgetxattr(fd, key, (void *)bytes, bSize, position, bOptions);
			
			if(bSize > 0x00)
			{
				bytes = calloc(bSize + 0x01, sizeof(*bytes));
				
				bSize = fgetxattr(fd, key, (void *)bytes, bSize + 0x01, position, bOptions);
				
				if(bSize > 0x00)
				{
					switch(operationRef->listStyle)
					{
						case(XADefaultListStyle):
							fprintf(stdout, "\t%*s\t", maxLen, key);
							break;
						case(XAParseableListStyle):
							fprintf(stdout, "%s=", key);
							break;
						default:
							fprintf(stdout, "\t%*s\t", maxLen, key);
							break;
					}
					
					XAListOperationPrintData(operationRef, bytes, bSize);

					fprintf(stdout, "\n");
				}
				
				free(bytes);
			}
			
		}
		
	}
	
	return(bRet);
}

XAOperationVTable *XAListOperationVTableAllocate(void)
{
	XAOperationVTable *vTable = malloc(sizeof(*vTable));
	
	vTable->performOperation = XAListOperationPerform;
	
	return(vTable);
}


void XAListOperationSetListStyle(XAListOperationRef operationRef, XAListStyle style)
{
	operationRef->listStyle = style;
}

