//**************************************************************************************
// Filename:	CFAliasArray.h
//				Part of Contextual Menu Workshop by Abracode Inc.
//				http://free.abracode.com/cmworkshop/
// Copyright © 2002-2003 Abracode, Inc.  All rights reserved.
//
// Description:	CFArray-based list of aliases
//				Design goals:
//				- not to throw
//				- unique aliases (not to allow aliases pointing to the same object)
//				- load and save aliases to preferences file via CFPreferences
//				- access items (Add & Fetch) via FSRef
//				- the object does own the array and deletes it

//
//**************************************************************************************
// Revision History:
// Monday, August 19, 2002 - Original
//**************************************************************************************

#pragma once

#if defined(__MACH__)
	#include <CoreFoundation/CoreFoundation.h>
	#include <Carbon/Carbon.h>
#else
	#include <CFArray.h>
	#include <Aliases.h>
#endif //defined(__MACH__)


class CFAliasArray
{
public:
							CFAliasArray();
							CFAliasArray(CFStringRef inKey, CFStringRef inPrefsIdentifier);
		virtual				~CFAliasArray();

		CFIndex				GetCount() const;
		void				AddItem(const FSRef *inRef);
		void				RemoveItemAt(CFIndex inIndex);
		void				RemoveAllItems();
		Boolean				FetchItemAt(CFIndex inIndex, FSRef &outRef) const;
		CFDataRef			FetchAliasDataAt(CFIndex inIndex);
		
		void				LoadArrayFromPrefs(CFStringRef inKey, CFStringRef inPrefsIdentifier);
		void				SaveArrayToPrefs(CFStringRef inKey, CFStringRef inPrefsIdentifier) const;
		
protected:
	CFMutableArrayRef		mArray;
	CFTypeID				mDataType;

private:
							CFAliasArray(const CFAliasArray&);
		CFAliasArray&			operator=(const CFAliasArray&);
};