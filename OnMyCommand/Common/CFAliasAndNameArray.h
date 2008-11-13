//**************************************************************************************
// Filename:	CFAliasAndNameArray.h
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

class CFAliasAndNameArray : public CFDictArray
{
public:
							CFAliasAndNameArray() { }
							CFAliasAndNameArray(CFStringRef inKey, CFStringRef inPrefsIdentifier, CFIndex theVer);
							CFAliasAndNameArray(CFMutableArrayRef inArray, bool inDoRetain = true)
								: CFDictArray(inArray, inDoRetain)
							{
							}
							CFAliasAndNameArray(const CFAliasAndNameArray& inArray);	// copy constructor
							
		virtual				~CFAliasAndNameArray() { }
		CFAliasAndNameArray&	operator=(const CFAliasAndNameArray& inArray);			// copy assignment

		void				AddPair(const FSRef *inRef, CFStringRef inName);
        void				InsertPairAt(const FSRef *inRef, CFStringRef inName, CFIndex inIndex);
		Boolean				FetchFSRefAt(CFIndex inIndex, FSRef &outRef) const;
		Boolean				FetchFSRefWithMountingAt(CFIndex inIndex, FSRef &outRef) const;

		CFStringRef			FetchNameAt(CFIndex inIndex) const;
		void				SetNameAt(CFStringRef inName, CFIndex inIndex);
		void				SetFSRefAt(const FSRef &inRef, CFIndex inIndex);
		
		CFDataRef			FetchAliasDataAt(CFIndex inIndex);
		void				SetAliasDataAt(CFDataRef inData, CFIndex inIndex);


		void				LoadArrayFromPrefsVersion1(CFStringRef inKey, CFStringRef inPrefsIdentifier);
};