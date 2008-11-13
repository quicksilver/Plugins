/*
 *  XAFile.c
 *  eXttra
 *
 *  Created by nibs ra on 2/9/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAFile.h"
#include "XAAttribute.h"
#include <XAOperation.h>

//#include <CoreFoundation/CFRuntime.h>
#include <CFRuntime.h>

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>
#include "xattr.h"

typedef struct __XAFile
{
	CFRuntimeBase		base;
	CFStringRef			path;
	CFMutableArrayRef	attributes;
	Boolean				edited;
}XAFile;

static Boolean __XAFileEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XAFileRef fileRef1 = (XAFileRef)cf1;
    
    XAFileRef fileRef2 = (XAFileRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= fileRef1 == fileRef2;
    
    return(bRet);
}

static CFHashCode __XAFileHash(CFTypeRef cf)
{
    XAFileRef fileRef = (XAFileRef)cf;
    
    return((CFHashCode)((unsigned int)fileRef));
}

static CFStringRef __XAFileCopyFormattingDesc(CFTypeRef cf,
												 CFDictionaryRef fOpts)
{
    XAFileRef fileRef = (XAFileRef)cf;
    
    CFStringRef			format = CFSTR("[XAFile: %010#x]");
    
	unsigned int		data = (unsigned int)fileRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(fileRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XAFileCopyDebugDesc(CFTypeRef cf)
{
    return(__XAFileCopyFormattingDesc(cf, NULL));
}

static void __XAFileFinalize(CFTypeRef cf)
{
    XAFileRef fileRef = (XAFileRef)cf;
	
	if(fileRef->path)
	{
		CFRelease(fileRef->path); fileRef->path = 0x00;
	}
	
	if(fileRef->attributes)
	{
		CFRelease(fileRef->attributes); fileRef->attributes = 0x00;
	}
	
}

static CFTypeID _kXAFileTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXAFileClass =
{
	0x00,
	"XAFile",
	NULL,
	NULL,
	__XAFileFinalize,
	__XAFileEqual,
	__XAFileHash,
	__XAFileCopyFormattingDesc,
	__XAFileCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XAFile class is used.
*/
void __XAFileClassInitialize(void)
{
    _kXAFileTypeID = _CFRuntimeRegisterClass(&_kXAFileClass);
}

XAFileRef _XAFileAllocate(CFAllocatorRef allocator)
{
    XAFileRef fileRef = NULL;
    
    uint32_t extra = sizeof(XAFile) - sizeof(CFRuntimeBase);
    
    fileRef = (XAFileRef)_CFRuntimeCreateInstance(allocator,
													 _kXAFileTypeID,
													 extra,
													 NULL);
    
    memset((unsigned char *)fileRef + sizeof(CFRuntimeBase), 0x00, extra);

	fileRef->attributes = CFArrayCreateMutable(allocator, 0x00, &kCFTypeArrayCallBacks);

    return(fileRef);
}

CFTypeID XAFileGetTypeID(void)
{
    return(_kXAFileTypeID);
}

XAFileRef XAFileCreateWithPath(CFAllocatorRef allocator, CFStringRef path)
{
	XAFileRef fileRef = _XAFileAllocate(allocator);
	
	fileRef->path = (CFStringRef)CFRetain(path);
		
	XAFileLoadAttributes(fileRef);

    return(fileRef);
}

CFIndex XAFileAttributeCount(XAFileRef fileRef)
{
    return(CFArrayGetCount(fileRef->attributes));
}

XAAttributeRef XAFileAttributeAtIndex(XAFileRef fileRef, CFIndex index)
{
	XAAttributeRef attribute = 0x00;
	
	if((index >= 0x00) && (index < CFArrayGetCount(fileRef->attributes)))
	{
		attribute = (XAAttributeRef)CFArrayGetValueAtIndex(fileRef->attributes, index);
	}
	
    return(attribute);
}

void XAFileRemoveAttributeAtIndex(XAFileRef fileRef, CFIndex index)
{
	if((index >= 0x00) && (index < CFArrayGetCount(fileRef->attributes)))
	{
		//fix this
		CFArrayRemoveValueAtIndex(fileRef->attributes, index);
	}
	
}


void XAFileAppendAttribute(XAFileRef fileRef, XAAttributeRef attributeRef)
{
	fileRef->edited = 0x01;
	CFArrayAppendValue(fileRef->attributes, attributeRef);	
}

XAErrorCode XAFileSaveAttributes(XAFileRef fileRef)
{
	XAErrorCode eCode = XAErrorImmaterial;
	
	CFIndex bSize = CFStringGetLength(fileRef->path) + 0x01;
	
	char *buffer = calloc(bSize, sizeof(*buffer));
	
	if(CFStringGetCString(fileRef->path, buffer, bSize, kCFStringEncodingUTF8))
	{
		int fd = open(buffer, O_WRONLY, 0x00);
		
		if(fd > 0x00)
		{
			CFIndex index = 0x00;
			
			CFIndex count = XAFileAttributeCount(fileRef);
			
			for(index = 0x00; index < count; index++)
			{
				XAAttributeRef attributeRef = 0x00;
				
				attributeRef = XAFileAttributeAtIndex(fileRef, index);
				
				XAAttributeSaveFileDescriptor(attributeRef, fd);
			}
			
			eCode = XAErrorNone;

			close(fd);
			
		}
		
	}
	fileRef->edited = 0x00;
	
	free(buffer);
	
	return(eCode);
}

XAErrorCode XAFileLoadAttributes(XAFileRef fileRef)
{
	XAErrorCode eCode = XAErrorImmaterial;
	
	CFIndex bSize = CFStringGetLength(fileRef->path) + 0x01;
	
	char *buffer = calloc(bSize, sizeof(*buffer));
	
	if(CFStringGetCString(fileRef->path, buffer, bSize, kCFStringEncodingUTF8))
	{
		int fd = open(buffer, O_RDONLY, 0x00);

		if(fd > 0x00)
		{
			char *keys = 0x00; size_t size = 0x00; int options = 0x00;
			
			CFArrayRemoveAllValues(fileRef->attributes);

			size = flistxattr(fd, keys, size, options);

			if(size > 0x00)
			{
				CFAllocatorRef allocator = CFGetAllocator(fileRef);
				
				char *key = 0x00;
				
				keys = calloc(size, sizeof(*keys));
				
				size = flistxattr(fd, keys, size, options);
				
				eCode = XAErrorNone;
				
				for(key = keys; key < keys + size; key += 0x01 + strlen(key))
				{
					XAAttributeRef attributeRef = 0x00;
					
					attributeRef = XAAttributeCreate(allocator);
					
					if(XAAttributeLoadFileDescriptor(attributeRef, fd, key))
					{
						CFArrayAppendValue(fileRef->attributes, attributeRef);	
						
						CFRelease(attributeRef);
					}else
					{
						CFRelease(attributeRef);

						eCode = XAErrorImmaterial;
						break;
					}
					
				}
				
			}else
			{
				eCode = XAErrorImmaterial;
				//fprintf(stderr, "listxattr error: %s\n", strerr(errno));
			}

			close(fd);

		}

	}
	fileRef->edited = 0x00;
	
	free(buffer);
	
	return(eCode);
}

void XAFileExecuteOperations(XAFileRef fileRef, CFMutableArrayRef operations)
{
	CFIndex bSize = CFStringGetLength(fileRef->path) + 0x01;
	
	char *buffer = calloc(bSize, sizeof(*buffer));
	
	if(CFStringGetCString(fileRef->path, buffer, bSize, kCFStringEncodingUTF8))
	{
		int fd = open(buffer, O_RDONLY, 0x00);
		
		if(fd > 0x00)
		{
			CFIndex index = 0x00;
			CFIndex count = CFArrayGetCount(operations);
			
			for(index = 0x00; index < count; index++)
			{
				XAOperationRef operation = 0x00;
				
				operation = (XAOperationRef)CFArrayGetValueAtIndex(operations, index);
				
				XAPerformOperation(operation, fd, fileRef->path);
			}
			
			close(fd);
		}
		
	}
	
	free(buffer);
}
