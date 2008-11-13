/*
 *  XAOperation.h
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _XA_OPERATION_H_
#define _XA_OPERATION_H_

/*
#include <XAOperation.h>
 */

#include <XATypes.h>

Boolean XAPerformOperation(XAOperationRef opaqueRef, int fd, CFStringRef path);

Boolean XAOperationPerform(XAOperationRef opaqueRef, int fd, CFStringRef path);


#endif


