// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "GetCGFunction.h"

// ---------------------------------------------------------------------------

void*
GetCGFunction(
		CFStringRef inFunctionName)
{
	CFBundleRef bundle = ::CFBundleGetBundleWithIdentifier(CFSTR("com.apple.CoreGraphics"));
	
	return ::CFBundleGetFunctionPointerForName(bundle,inFunctionName);
}
