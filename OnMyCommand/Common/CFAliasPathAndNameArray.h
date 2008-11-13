//**************************************************************************************
// Filename:	CFAliasPathAndNameArray.h
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
   #include <Carbon/Carbon.h>
#else
	#include <CFArray.h>
#endif //defined(__MACH__)

#include "CFDictArray.h"

const CFIndex kTheLatestPrefsVersion = 3;

class CFAliasPathAndNameArray : public CFDictArray
{
public:
							CFAliasPathAndNameArray()
								: CFDictArray() { }
							CFAliasPathAndNameArray(CFStringRef inKey, CFStringRef inPrefsIdentifier, CFIndex theVer = kTheLatestPrefsVersion);
							CFAliasPathAndNameArray(CFMutableArrayRef inArray, bool inDoRetain = true)
								: CFDictArray(inArray, inDoRetain)
							{
							}
							CFAliasPathAndNameArray(const CFAliasPathAndNameArray& inArray);	// copy constructor
							
	virtual					~CFAliasPathAndNameArray() { }
	CFAliasPathAndNameArray&	operator=(const CFAliasPathAndNameArray& inArray);			// copy assignment

	virtual void		AddItem(CFDictionaryRef inItem);
	void				AddPair(const FSRef *inRef, CFStringRef inName);
	void				AddItemAliasPathAndName(CFDataRef inAliasData, CFStringRef inPath, CFStringRef inName);

	void				InsertPairAt(const FSRef *inRef, CFStringRef inName, CFIndex inIndex);

	Boolean				FetchFSRefAt(CFIndex inIndex, FSRef &outRef) const;
	Boolean				FetchFSRefWithMountingAt(CFIndex inIndex, FSRef &outRef) const;

	CFStringRef			FetchNameAt(CFIndex inIndex) const;
	void				SetNameAt(CFStringRef inName, CFIndex inIndex);

	CFStringRef			FetchPathAt(CFIndex inIndex) const;
	void				SetPathAt(CFStringRef inPath, CFIndex inIndex);

	void				SetFSRefAt(const FSRef &inRef, CFIndex inIndex);

	CFDataRef			FetchAliasDataAt(CFIndex inIndex);
	void				SetAliasDataAt(CFDataRef inData, CFIndex inIndex);


	void				LoadArrayFromPrefsVersion1(CFStringRef inKey, CFStringRef inPrefsIdentifier);
	void				LoadArrayFromPrefsVersion2(CFStringRef inKey, CFStringRef inPrefsIdentifier);
	
};