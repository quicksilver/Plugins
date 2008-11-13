/*
 *  XAAttribute.h
 *  eXttra
 *
 *  Created by nibs ra on 2/9/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _XA_ATTRIBUTE_H_
#define _XA_ATTRIBUTE_H_

/*
#include <XAAttribute.h>
 */

#include <XATypes.h>

XAAttributeRef XAAttributeCreate(CFAllocatorRef allocator);

Boolean XAAttributeLoadFileDescriptor(XAAttributeRef attributeRef, int fd, char *key);

Boolean XAAttributeSaveFileDescriptor(XAAttributeRef attributeRef, int fd);

Boolean XAAttributeRemoveFileDescriptor(XAAttributeRef attributeRef, int fd);

CFStringRef XAAttributeDescription(XAAttributeRef attributeRef);

CFStringRef XAAttributeName(XAAttributeRef attributeRef);

CFDataRef XAAttributeData(XAAttributeRef attributeRef);

void XAAttributeClearState(XAAttributeRef attributeRef);

void XAAttributeSetName(XAAttributeRef attributeRef, CFStringRef name);

void XAAttributeSetString(XAAttributeRef attributeRef, CFStringRef string);

void XAAttributeSetData(XAAttributeRef attributeRef, CFDataRef data);

CFDataRef XACopyAttribute(CFAllocatorRef alloc, int fd, char *key);

#endif

