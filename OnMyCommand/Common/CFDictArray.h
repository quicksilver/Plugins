//**************************************************************************************
// Filename:	CFDictArray.h
//				Part of Contextual Menu Workshop by Abracode Inc.
//				http://free.abracode.com/cmworkshop/
// Copyright © 2002-2003 Abracode, Inc.  All rights reserved.
//
// Description:	CFArray-based list of CFDictionaryRefs
//				Design goals:
//				- not to throw
//				- load and save to preferences file via CFPreferences
//				- the object does own the array and deletes it

//
//**************************************************************************************
// Revision History:
// Monday, August 19, 2002 - Original
//**************************************************************************************

#pragma once

#if defined(__MACH__)
	#include <CoreFoundation/CoreFoundation.h>
#else
    #include <CFArray.h>
#endif //defined(__MACH__)

class CFDictArray
{
public:
							CFDictArray();
							CFDictArray(CFStringRef inKey, CFStringRef inPrefsIdentifier);
							CFDictArray(CFMutableArrayRef inArray, bool inDoRetain = true);
							CFDictArray(const CFDictArray& inArray);	// copy constructor
	virtual					~CFDictArray();
	CFDictArray&			operator=(const CFDictArray& inArray);		// copy assignment

	virtual CFIndex			GetCount() const;
	virtual void			AddItem(CFDictionaryRef inItem);
	virtual void			InsertItemAt(CFDictionaryRef inItem, CFIndex inIndex);
	virtual void			RemoveItemAt(CFIndex inIndex);
	virtual void			RemoveAllItems();
	virtual CFIndex			MoveOneItem(CFIndex fromIndex, CFIndex toIndex);
	virtual CFIndex			MoveItems(CFArrayRef inIndexList, CFIndex toIndex);
	virtual CFDictionaryRef	FetchItemAt(CFIndex inIndex) const;
	
	virtual void			SetItemAt(CFDictionaryRef inItem, CFIndex inIndex);

	virtual void			LoadArrayFromPrefs(CFStringRef inKey, CFStringRef inPrefsIdentifier);		
	virtual void			SaveArrayToPrefs(CFStringRef inKey, CFStringRef inPrefsIdentifier) const;

	virtual CFStringRef		GetItemStringForKey(CFIndex inIndex, CFStringRef inKey);
	virtual void			SetItemStringForKey(CFIndex inIndex, CFStringRef inKey, CFStringRef inString);

	virtual Boolean			GetItemBooleanForKey(CFIndex inIndex, CFStringRef inKey, Boolean defaultValue);
	virtual void			SetItemBooleanForKey(CFIndex inIndex, CFStringRef inKey, Boolean inValue);

	virtual CFMutableDictionaryRef	ReplaceDictionaryWithMutableCopyAt(CFIndex inIndex);

	// caller must retain the array if s/he wishes to keep it
	CFMutableArrayRef		GetArray() { return mArray; }
	CFMutableArrayRef		Detach() { CFMutableArrayRef outArr = mArray; mArray = NULL; return outArr; }

protected:
	CFMutableArrayRef		mArray;
};