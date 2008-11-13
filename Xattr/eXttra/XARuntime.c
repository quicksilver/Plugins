/*
 *  XARuntime.c
 *  eXttra
 *
 *  Created by nibs ra on 2/9/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XARuntime.h"

extern void __XAFileClassInitialize(void);
//extern void __XAStringAttributeClassInitialize(void);
extern void __XAAttributeClassInitialize(void);
extern void __XAJobClassInitialize(void);
extern void __XARemoveOperationClassInitialize(void);
extern void __XASetOperationClassInitialize(void);
extern void __XAGetOperationClassInitialize(void);
extern void __XAListOperationClassInitialize(void);
extern void __XAOperationClassInitialize(void);
//extern void __XADataAttributeClassInitialize(void);
//extern void __XADataAttributeClassInitialize(void);
//extern void __XADataAttributeClassInitialize(void);
//extern void __XAAttributeClassInitialize(void);


int _XAInitializeRuntime(void)
{
	__XAFileClassInitialize();
	
	__XAAttributeClassInitialize();
	
	__XAJobClassInitialize();
	
	__XARemoveOperationClassInitialize();
	
	__XASetOperationClassInitialize();
	
	__XAGetOperationClassInitialize();
	
	__XAListOperationClassInitialize();
	
	__XAOperationClassInitialize();
	
	//__XAJobClassInitialize();
	
	//__XAJobClassInitialize();
	
	//__XAJobClassInitialize();
	
	//__XAAttributeClassInitialize();
	
	return(0x00);
}

#if defined (__MACH__)
#pragma CALL_ON_LOAD _XAInitializeRuntime 
#endif
