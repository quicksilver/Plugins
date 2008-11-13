
#ifndef _XA_TYPES_H_
#define _XA_TYPES_H_

/*
#include <XATypes.h>
 */

#include <CoreFoundation/CoreFoundation.h>

#ifndef min
#define min(x, y) ((x) > (y)) ? (y) : (x)
#endif

#ifndef max
#define max(x, y) ((x) < (y)) ? (y) : (x)
#endif

typedef CFTypeRef					XAOperationRef;

typedef struct __XAJob				*XAJobRef;

typedef struct __XAListOperation	*XAListOperationRef;

typedef struct __XASetOperation		*XASetOperationRef;

typedef struct __XAGetOperation		*XAGetOperationRef;

typedef struct __XARemoveOperation	*XARemoveOperationRef;

typedef struct __XAFile				*XAFileRef;

typedef struct __XAAttribute		*XAAttributeRef;


typedef enum XAErrorCode
{
	XAErrorNone			= 0x00,
	XAErrorImmaterial	= 0x01
}XAErrorCode;

typedef enum XAListStyle
{
	XADefaultListStyle		= 0x00,
	XAParseableListStyle	= 0x01
}XAListStyle;




#endif


