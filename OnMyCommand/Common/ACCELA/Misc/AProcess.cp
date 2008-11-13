// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AProcess.h"

#include <stdio.h>

// ---------------------------------------------------------------------------

ASignatureProcess::ASignatureProcess(
		OSType inSignature)
{
	ProcessInfoRec info = { 0 };
	
	while (::GetNextProcess(this) == noErr) {
		GetInfo(info);
		if (info.processSignature == inSignature)
			break;
	}
	
	if (info.processSignature != inSignature) {
		highLongOfPSN = 0;
		lowLongOfPSN = kNoProcess;
	}
}
