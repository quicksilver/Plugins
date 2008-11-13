// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFString.h"

class ACFMutableString :
		public ACFString
{
public:
		// plain
		ACFMutableString(
				CFIndex inMaxLen = 0)
		: ACFString((CFStringRef)::CFStringCreateMutable(kCFAllocatorDefault,inMaxLen),false) {}
		// CFStringRef
		ACFMutableString(
				CFStringRef inString,
				CFIndex inMaxLen = 0)
		: ACFString((CFStringRef)::CFStringCreateMutableCopy(kCFAllocatorDefault,inMaxLen,inString),false) {}
		// CFMutableStringRef
		ACFMutableString(
				CFMutableStringRef inString,
				bool inDoRetain = true)
		: ACFString(inString,inDoRetain) {}
		// substring
		ACFMutableString(
				CFStringRef inString,
				const CFRange &inRange)
		: ACFString((CFStringRef)::CFStringCreateMutable(kCFAllocatorDefault,0),false)
		{
			Append(ACFString(inString,inRange));
		}
		// Pascal string
		ACFMutableString(
				ConstStringPtr inString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFString((CFStringRef)::CFStringCreateMutable(inAllocator,0),false)
		{
			Append(inString,inEncoding);
		}
		// C string
		ACFMutableString(
				const char *inString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFString((CFStringRef)::CFStringCreateMutable(inAllocator,0),false)
		{
			Append(inString,inEncoding);
		}
		// UniChars
		ACFMutableString(
				const UniChar *inCharacters,
				CFIndex inNumChars,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFString((CFStringRef)::CFStringCreateMutable(inAllocator,0),false)
		{
			Append(inCharacters,inNumChars);
		}
		// Bytes
		ACFMutableString(
				const UInt8 *inBytes,
				CFIndex inByteCount,
				CFStringEncoding inEncoding,
				bool inIsExtRep,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFString((CFStringRef)::CFStringCreateMutable(inAllocator,0),false)
		{
			Append(ACFString(inBytes,inByteCount,inEncoding,inIsExtRep,inAllocator));
		}
	
	// ACFString
	
	virtual bool
		Localize();
	
	// ACFMutableString
	
		operator CFMutableStringRef()
		{
			return (CFMutableStringRef)mObjectRef;
		}
	
	void
		Append(
				CFStringRef inString);
	void
		Append(
				const UniChar *inChars,
				CFIndex inNumChars);
	void
		Append(
				ConstStringPtr inPString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman);
	void
		Append(
				const char *inCString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman);
	
	ACFMutableString&
		operator<<(
				CFStringRef inString)
		{
			Append(inString);
			return *this;
		}
	ACFMutableString&
		operator<<(
				ConstStringPtr inPString)
		{
			Append(inPString);
			return *this;
		}
	ACFMutableString&
		operator<<(
				const char *inCString)
		{
			Append(inCString);
			return *this;
		}
	
	void
		Insert(
				CFIndex inIndex,
				CFStringRef inString);
	void
		Delete(
				CFRange inRange);
	void
		Replace(
				CFRange inRange,
				CFStringRef inReplacement);
	void
		ReplaceAll(
				CFStringRef inNewString);
	
	void
		Pad(
				CFStringRef inPadString,
				CFIndex inLength,
				CFIndex inIndexToPad);
	void
		Trim(
				CFStringRef inTrimString);
	void
		TrimWhitespace();
	
	void
		Lowercase(
				const void *inLocaleTBD = NULL);
	void
		Uppercase(
				const void *inLocaleTBD = NULL);
	void
		Capitalize(
				const void *inLocaleTBD = NULL);
};

inline void
ACFMutableString::Append(
		CFStringRef inString)
{
	::CFStringAppend(*this,inString);
}

inline void
ACFMutableString::Append(
		const UniChar *inChars,
		CFIndex inNumChars)
{
	::CFStringAppendCharacters(*this,inChars,inNumChars);
}

inline void
ACFMutableString::Append(
		ConstStr255Param inPString,
		CFStringEncoding inEncoding)
{
	::CFStringAppendPascalString(*this,inPString,inEncoding);
}

inline void
ACFMutableString::Append(
		const char *inCString,
		CFStringEncoding inEncoding)
{
	::CFStringAppendCString(*this,inCString,inEncoding);
}


inline void
ACFMutableString::Insert(
		CFIndex inIndex,
		CFStringRef inString)
{
	::CFStringInsert(*this,inIndex,inString);
}

inline void
ACFMutableString::Delete(
		CFRange inRange)
{
	::CFStringDelete(*this,inRange);
}

inline void
ACFMutableString::Replace(
		CFRange inRange,
		CFStringRef inReplacement)
{
	::CFStringReplace(*this,inRange,inReplacement);
}

inline void
ACFMutableString::ReplaceAll(
		CFStringRef inNewString)
{
	::CFStringReplaceAll(*this,inNewString);
}


inline void
ACFMutableString::Pad(
		CFStringRef inPadString,
		CFIndex inLength,
		CFIndex inIndexToPad)
{
	::CFStringPad(*this,inPadString,inLength,inIndexToPad);
}

inline void
ACFMutableString::Trim(
		CFStringRef inTrimString)
{
	::CFStringTrim(*this,inTrimString);
}

inline void
ACFMutableString::TrimWhitespace()
{
	::CFStringTrimWhitespace(*this);
}


inline void
ACFMutableString::Lowercase(
		const void *inLocaleTBD)
{
	::CFStringLowercase(*this,(CFLocaleRef)inLocaleTBD);//_tk_
}

inline void
ACFMutableString::Uppercase(
		const void *inLocaleTBD)
{
	::CFStringUppercase(*this,(CFLocaleRef)inLocaleTBD);//_tk_
}

inline void
ACFMutableString::Capitalize(
		const void *inLocaleTBD)
{
	::CFStringCapitalize(*this,(CFLocaleRef)inLocaleTBD);//_tk_
}
