
#ifndef _XA_OPERATION_INTERNAL_H_
#define _XA_OPERATION_INTERNAL_H_

/*
#include <XAOperationInternal.h>
 */

#include <XATypes.h>

//#include <CoreFoundation/CFRuntime.h>
#include <CFRuntime.h>

typedef struct __XAOperationVTable
{
	Boolean (*performOperation)(XAOperationRef opaqueRef, int fd, CFStringRef path);
}XAOperationVTable;


typedef struct __XAOperation
{
	CFRuntimeBase		base;
	XAOperationVTable	*vTable;
}XAOperation;

void __XAOperationFinalize(CFTypeRef cf);


Boolean XAPerformOperation(XAOperationRef opaqueRef, int fd, CFStringRef path);


#endif

