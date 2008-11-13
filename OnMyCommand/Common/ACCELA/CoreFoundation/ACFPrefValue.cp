// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACFPrefValue.h"

// ---------------------------------------------------------------------------

bool
ACFPrefs::KeyExists(
		CFStringRef inKey)
{
	CFPropertyListRef prefData = ::CFPreferencesCopyAppValue(inKey,kCFPreferencesCurrentApplication);
	bool exists = (prefData != NULL);
	
	if (exists)
		::CFRelease(prefData);
	return exists;
}