/*
 *  XAJob.h
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#ifndef _XA_JOB_H_
#define _XA_JOB_H_

/*
#include <XAJob.h>
 */

#include <XATypes.h>

XAJobRef XAJobCreateWithArguments(CFAllocatorRef allocator, int argc, char **argv);

void XAJobExecute(XAJobRef jobRef);



#endif


