// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XSystem.h"

UInt32 XSystem::sOSVersion = 0;

UInt32
XSystem::OSVersion()
{
	if (sOSVersion == 0) 
		::Gestalt(gestaltSystemVersion,(long*)&sOSVersion);
	return sOSVersion;
}
