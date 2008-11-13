/*
 *  XAAttribute.c
 *  eXttra
 *
 *  Created by nibs ra on 2/9/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAAttribute.h"
#include "xattr.h"
#include <XAUtilities.h>

#include <CFRuntime.h>

typedef struct __XAAttribute
{
	CFRuntimeBase		base;
	CFStringRef			name;
	CFStringRef			string;
	CFDataRef			data;
	Boolean				edited;
}XAAttribute;

static Boolean __XAAttributeEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XAAttributeRef attributeRef1 = (XAAttributeRef)cf1;
    
    XAAttributeRef attributeRef2 = (XAAttributeRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= attributeRef1 == attributeRef2;
    
    return(bRet);
}

static CFHashCode __XAAttributeHash(CFTypeRef cf)
{
    XAAttributeRef attributeRef = (XAAttributeRef)cf;
    
    return((CFHashCode)((unsigned int)attributeRef));
}

static CFStringRef __XAAttributeCopyFormattingDesc(CFTypeRef cf,
											  CFDictionaryRef fOpts)
{
    XAAttributeRef attributeRef = (XAAttributeRef)cf;
    
    CFStringRef			format = CFSTR("[XAAttribute: %010#x]");
    
	unsigned int		data = (unsigned int)attributeRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(attributeRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XAAttributeCopyDebugDesc(CFTypeRef cf)
{
    return(__XAAttributeCopyFormattingDesc(cf, NULL));
}

static void __XAAttributeFinalize(CFTypeRef cf)
{
    XAAttributeRef attributeRef = (XAAttributeRef)cf;
	
	XAAttributeClearState(attributeRef);
	
}

static CFTypeID _kXAAttributeTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXAAttributeClass =
{
	0x00,
	"XAAttribute",
	NULL,
	NULL,
	__XAAttributeFinalize,
	__XAAttributeEqual,
	__XAAttributeHash,
	__XAAttributeCopyFormattingDesc,
	__XAAttributeCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XAAttribute class is used.
*/
void __XAAttributeClassInitialize(void)
{
    _kXAAttributeTypeID = _CFRuntimeRegisterClass(&_kXAAttributeClass);
}

XAAttributeRef _XAAttributeAllocate(CFAllocatorRef allocator)
{
    XAAttributeRef attributeRef = NULL;
    
    uint32_t extra = sizeof(XAAttribute) - sizeof(CFRuntimeBase);
    
    attributeRef = (XAAttributeRef)_CFRuntimeCreateInstance(allocator,
												  _kXAAttributeTypeID,
												  extra,
												  NULL);
    
    memset((unsigned char *)attributeRef + sizeof(CFRuntimeBase), 0x00, extra);
		
    return(attributeRef);
}

CFTypeID XAAttributeGetTypeID(void)
{
    return(_kXAAttributeTypeID);
}

XAAttributeRef XAAttributeCreate(CFAllocatorRef allocator)
{
	XAAttributeRef attributeRef = _XAAttributeAllocate(allocator);
		
    return(attributeRef);
}

void XAAttributeSetName(XAAttributeRef attributeRef, CFStringRef name)
{
	if(name)
		CFRetain(name);
	
	if(attributeRef->name)
		CFRelease(attributeRef->name);
	
	attributeRef->name = name;
}

void XAAttributeSetString(XAAttributeRef attributeRef, CFStringRef string)
{
	if(string)
		CFRetain(string);
	
	if(attributeRef->string)
		CFRelease(attributeRef->string);
	
	attributeRef->string = string;
}

void XAAttributeSetData(XAAttributeRef attributeRef, CFDataRef data)
{
	if(data)
		CFRetain(data);
	
	if(attributeRef->data)
		CFRelease(attributeRef->data);
	
	attributeRef->data = data;
}

void XAAttributeClearState(XAAttributeRef attributeRef)
{
	XAAttributeSetName(attributeRef, 0x00);
	
	XAAttributeSetString(attributeRef, 0x00);
	
	XAAttributeSetData(attributeRef, 0x00);
	
	attributeRef->edited = 0x00;
}

CFDataRef XACopyAttribute(CFAllocatorRef alloc, int fd, char *key)
{	
	CFDataRef dNice = 0x00;

	UInt8 *bytes = 0x00; size_t size = 0x00; UInt32 position = 0x00; int options = 0x00;
	
	size = fgetxattr(fd, key, (void *)bytes, size, position, options);
	
	if(size > 0x00)
	{
		bytes = calloc(size, sizeof(*bytes));
		
		size = fgetxattr(fd, key, (void *)bytes, size, position, options);
		
		if(size > 0x00)
		{
			dNice = CFDataCreateWithBytesNoCopy(alloc, bytes, size, kCFAllocatorMalloc);
		}
		
	}
	
	return(dNice);
}

Boolean XAAttributeLoadFileDescriptor(XAAttributeRef attributeRef, int fd, char *key)
{
	Boolean bRet = 0x00;
	
	UInt8 *bytes = 0x00; size_t size = 0x00; UInt32 position = 0x00; int options = 0x00;
	
	size = fgetxattr(fd, key, (void *)bytes, size, position, options);

	if(size > 0x00)
	{
		bytes = calloc(size, sizeof(*bytes));
		
		size = fgetxattr(fd, key, (void *)bytes, size, position, options);
		
		if(size > 0x00)
		{
			CFAllocatorRef alloc = CFGetAllocator(attributeRef);
			
			CFStringRef sTemp = 0x00;
			
			CFStringRef dTemp = 0x00;
			
			CFDataRef dNice = 0x00;
			
			dNice = CFDataCreateWithBytesNoCopy(alloc, bytes, size, kCFAllocatorMalloc);
			
			sTemp = CFStringCreateWithCString(alloc, key, kCFStringEncodingUTF8);
			
			if(XAPrintableData(bytes, size))
			{
				dTemp = CFStringCreateWithBytes(alloc, bytes, size, kCFStringEncodingUTF8, 0x00);
			}else
			{
				dTemp = CFCopyDescription(dNice);
			}
			
			XAAttributeSetData(attributeRef, dNice);
			
			CFRelease(dNice);
			
			XAAttributeSetName(attributeRef, sTemp);
			
			CFRelease(sTemp);
			
			XAAttributeSetString(attributeRef, dTemp);
			
			CFRelease(dTemp);
			
			bRet = 0x01;
		}
		
	}
	
	return(bRet);
}

Boolean XAAttributeSaveFileDescriptor(XAAttributeRef attributeRef, int fd)
{
	Boolean bRet = 0x01;
	
	if(attributeRef->edited)
	{
		const UInt8 *bytes = CFDataGetBytePtr(attributeRef->data);
		
		size_t size = CFDataGetLength(attributeRef->data);
		
		CFIndex bSize = CFStringGetLength(attributeRef->name) + 0x01;
		
		char *key = calloc(bSize, sizeof(*key));
		
		UInt32 position = 0x00; int options = 0x00;
		
		if(CFStringGetCString(attributeRef->name, key, bSize, kCFStringEncodingUTF8))
		{
			size = fsetxattr(fd, key, (void *)bytes, size, position, options);
		}
		
		free(key);
	}
	
	return(bRet);
}

Boolean XAAttributeRemoveFileDescriptor(XAAttributeRef attributeRef, int fd)
{
	Boolean bRet = 0x01;
	
	CFIndex bSize = CFStringGetLength(attributeRef->name) + 0x01;
	
	char *key = calloc(bSize, sizeof(*key));
	
	int options = XATTR_CREATE | XATTR_REPLACE;
	
	if(CFStringGetCString(attributeRef->name, key, bSize, kCFStringEncodingUTF8))
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

CFStringRef XAAttributeDescription(XAAttributeRef attributeRef)
{
	return(attributeRef->string);
}

CFStringRef XAAttributeName(XAAttributeRef attributeRef)
{
	return(attributeRef->name);
}

CFDataRef XAAttributeData(XAAttributeRef attributeRef)
{
	return(attributeRef->data);
}


