// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACFBundle.h"

// ---------------------------------------------------------------------------

CFStringRef
ACFBundle::GetAppName()
{
	ACFBundle mainBundle(bundle_Main);
	
	return (CFStringRef) mainBundle.GetValueForInfoDictKey(kCFBundleNameKey);
}
