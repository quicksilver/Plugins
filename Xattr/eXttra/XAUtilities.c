/*
 *  XAUtilities.c
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAUtilities.h"

Boolean XAPrintableData(UInt8 *data, size_t size)
{
	Boolean bRet = 0x01;
	
	size_t index = 0x00;
	
	for(index = 0x00; index < size; index++)
	{
		Boolean valid = data[index] < 0xf5;
		valid &= data[index] != 0xc0;
		valid &= data[index] != 0xc1;
		
		if(!valid)
		{
			bRet = 0x00;
			break;
		}
		
	}
	
	return(bRet);
}

