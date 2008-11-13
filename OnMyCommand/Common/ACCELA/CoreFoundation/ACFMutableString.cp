// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACFMutableString.h"

// ---------------------------------------------------------------------------

bool
ACFMutableString::Localize()
{
	bool localized = ACFString::Localize();
	
	if (localized)
		Reset(::CFStringCreateMutableCopy(kCFAllocatorDefault,0,(CFStringRef)mObjectRef),false);
	
	return localized;
}
