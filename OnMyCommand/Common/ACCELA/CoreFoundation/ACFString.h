// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

#include FW(Carbon,CarbonEvents.h)

class ACFString :
		public ACFType<CFStringRef>
{
public:
		// NULL
		ACFString() {}
		// CFStringRef
		ACFString(
				CFStringRef inString,
				bool inDoRetain = true)
		: ACFType<CFStringRef>(inString,inDoRetain) {}
		// CFMutableStringRef
		ACFString(
				CFMutableStringRef inString,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFType<CFStringRef>(::CFStringCreateCopy(inAllocator,inString)) {}
		// Substring
		ACFString(
				CFStringRef inString,
				const CFRange &inSubRange,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFType<CFStringRef>(::CFStringCreateWithSubstring(inAllocator,inString,inSubRange)) {}
		// Pascal string
		ACFString(
				ConstStr255Param inPString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFType<CFStringRef>(::CFStringCreateWithPascalString(inAllocator,inPString,inEncoding),false) {}
		// C string
		ACFString(
				const char *inCString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFType<CFStringRef>(::CFStringCreateWithCString(inAllocator,inCString,inEncoding),false) {}
		// UniChars
		ACFString(
				const UniChar *inCharacters,
				CFIndex inNumChars,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFType<CFStringRef>(::CFStringCreateWithCharacters(inAllocator,inCharacters,inNumChars),false) {}
		// Bytes
		ACFString(
				const UInt8 *inBytes,
				CFIndex inByteCount,
				CFStringEncoding inEncoding,
				bool inIsExtRep,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFType<CFStringRef>(::CFStringCreateWithBytes(inAllocator,inBytes,inByteCount,inEncoding,inIsExtRep)) {}
		// Formatted
		ACFString(
				CFDictionaryRef inFormatOptions,
				CFStringRef inFormat,
				...)
		{
			va_list args;
			va_start(args,inFormat);
			mObjectRef = ::CFStringCreateWithFormatAndArguments(
					kCFAllocatorDefault,
					inFormatOptions,
					inFormat,
					args);
			va_end(args);
		}
		// Services scrap type
		ACFString(
				OSType inType)
		: ACFType<CFStringRef>(::CreateTypeStringWithOSType(inType)) {}
	
	UniChar
		operator[](
				CFIndex inIndex) const;
	CFIndex
		Length() const;
	void
		GetCharacters(
				CFRange inRange,
				UniChar *inBuffer) const;
	const UniChar*
		CharactersPtr() const;
	bool
		GetPascalString(
				StringPtr inBuffer,
				CFIndex inBufferSize = 256,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman) const;
	bool
		GetCString(
				char *inBuffer,
				CFIndex inBufferSize,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman) const;
	const char*
		CStringPtr(
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman) const;
	CFIndex
		GetBytes(
				CFRange inRange,
				CFStringEncoding inEncoding,
				UInt8 inLossByte,
				bool inIsExternal,
				UInt8 *inBuffer,
				CFIndex inMaxBufLen,
				CFIndex &outUsedBufLen) const;
	CFIndex
		GetBytesLen(
				CFStringEncoding inEncoding,
				UInt8 inLossByte = 0,
				bool inIsExternal = true) const
		{
			CFIndex usedBufLen;
			GetBytes(CFRangeMake(0,Length()),inEncoding,inLossByte,inIsExternal,NULL,0,usedBufLen);
			return usedBufLen;
		}
	UInt8*
		MakeBytesBuffer(
				CFStringEncoding inEncoding,
				CFIndex &outBufferLen,
				UInt8 inLossByte = 0,
				bool inIsExternal = true) const;
	CFStringEncoding
		FastestEncoding() const;
	CFStringEncoding
		SmallestEncoding() const;
	
	CFRange
		Find(
				CFStringRef inSearchString,
				CFOptionFlags inOptions = 0L) const;
	bool
		HasPrefix(
				CFStringRef inPrefix) const;
	bool
		HasSuffix(
				CFStringRef inSuffix) const;
	
	CFArrayRef
		Separate(
				CFStringRef inSeparator) const;
	
	virtual bool
		Localize();

//_tk_ problematic with interface-less unix code
//	void
//		EncodePascalString(
//				StringPtr outPString) const;
	
	SInt32
		MakeInt() const;
	double
		MakeDouble() const;
};

// ---------------------------------------------------------------------------

inline UniChar
ACFString::operator[](
		CFIndex inIndex) const
{
	return ::CFStringGetCharacterAtIndex(*this,inIndex);
}

inline CFIndex
ACFString::Length() const
{
	return ::CFStringGetLength(*this);
}

inline void
ACFString::GetCharacters(
		CFRange inRange,
		UniChar *inBuffer) const
{
	::CFStringGetCharacters(*this,inRange,inBuffer);
}

inline const UniChar*
ACFString::CharactersPtr() const
{
	return ::CFStringGetCharactersPtr(*this);
}

inline bool
ACFString::GetPascalString(
		StringPtr inBuffer,
		CFIndex inBufferSize,
		CFStringEncoding inEncoding) const
{
	return ::CFStringGetPascalString(*this,inBuffer,inBufferSize,inEncoding);
}

inline bool
ACFString::GetCString(
		char *inBuffer,
		CFIndex inBufferSize,
		CFStringEncoding inEncoding) const
{
	return ::CFStringGetCString(*this,inBuffer,inBufferSize,inEncoding);
}

inline const char*
ACFString::CStringPtr(
		CFStringEncoding inEncoding) const
{
	return ::CFStringGetCStringPtr(*this,inEncoding);
}

inline CFIndex
ACFString::GetBytes(
		CFRange inRange,
		CFStringEncoding inEncoding,
		UInt8 inLossByte,
		bool inIsExternal,
		UInt8 *inBuffer,
		CFIndex inMaxBufLen,
		CFIndex &outUsedBufLen) const
{
	return ::CFStringGetBytes(*this,inRange,inEncoding,inLossByte,inIsExternal,inBuffer,inMaxBufLen,&outUsedBufLen);
}

inline CFStringEncoding
ACFString::FastestEncoding() const
{
	return CFStringGetFastestEncoding(*this);
}

inline CFStringEncoding
ACFString::SmallestEncoding() const
{
	return CFStringGetSmallestEncoding(*this);
}

inline CFRange
ACFString::Find(
		CFStringRef inSearchString,
		CFOptionFlags inFlags) const
{
	return ::CFStringFind(*this,inSearchString,inFlags);
}

inline bool
ACFString::HasPrefix(
		CFStringRef inPrefix) const
{
	return ::CFStringHasPrefix(*this,inPrefix);
}

inline bool
ACFString::HasSuffix(
		CFStringRef inSuffix) const
{
	return ::CFStringHasSuffix(*this,inSuffix);
}

inline CFArrayRef
ACFString::Separate(
		CFStringRef inSeparator) const
{
	return ::CFStringCreateArrayBySeparatingStrings(kCFAllocatorDefault,*this,inSeparator);
}

inline SInt32
ACFString::MakeInt() const
{
	return ::CFStringGetIntValue(*this);
}

inline double
ACFString::MakeDouble() const
{
	return ::CFStringGetDoubleValue(*this);
}

// ---------------------------------------------------------------------------

#include <iostream>

inline std::ostream&
operator<<(
		std::ostream &inStream,
		const ACFString &inString)
{
	if (inString.Get() != NULL) {
		const char *cStringPtr = inString.CStringPtr();
		if (cStringPtr != NULL) {
			inStream << cStringPtr;
		}
		else {
			CFIndex stringLength = inString.Length();
			char *buffer = new char[stringLength];
			if (buffer != NULL) {
				if (inString.GetCString(buffer,stringLength))
					inStream << buffer;
			}
			delete[] buffer;
		}
	}
	return inStream;
}
