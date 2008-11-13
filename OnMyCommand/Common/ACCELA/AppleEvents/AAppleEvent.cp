// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AAppleEvent.h"

// ---------------------------------------------------------------------------

OSType
ASelfEvent::GetAppSignature()
{
	static OSType signature = 0L;
	
	if (signature == 0L) {
		static const ProcessSerialNumber psn = { 0,kCurrentProcess };
		ProcessInfoRec info;
		
		::GetProcessInformation(&psn,&info);
		signature = info.processSignature;
	}
	return signature;
}
