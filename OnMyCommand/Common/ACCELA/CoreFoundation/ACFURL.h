// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

#include FW(CoreFoundation,CFURL.h)

class ACFURL :
		public ACFType<CFURLRef>
{
public:
		// CFURLRef
		ACFURL(
				CFURLRef inURL,
				bool inDoRetain = true)
			: ACFType<CFURLRef>(inURL,inDoRetain) {}
		// Bytes
		ACFURL(
				const UInt8 *inBytes,
				CFIndex inLength,
				CFURLRef inBaseURL = NULL,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman)
			: ACFType<CFURLRef>(::CFURLCreateWithBytes(kCFAllocatorDefault,inBytes,inLength,inEncoding,inBaseURL)) {}
		// CFStringRef
		ACFURL(
				CFStringRef inString,
				CFURLRef inBaseURL = NULL)
			: ACFType<CFURLRef>(::CFURLCreateWithString(kCFAllocatorDefault,inString,inBaseURL)) {}
		// Path
		ACFURL(
				CFStringRef inPathString,
				CFURLPathStyle inPathStyle,
				bool inIsDirectory)
			: ACFType<CFURLRef>(::CFURLCreateWithFileSystemPath(kCFAllocatorDefault,inPathString,inPathStyle,inIsDirectory)) {}
		// FSRef
		ACFURL(
				const FSRef &inFSRef)
			: ACFType<CFURLRef>(::CFURLCreateFromFSRef(kCFAllocatorDefault,&inFSRef)) {}
	
	FSRef
		MakeFSRef() const;
	CFStringRef
		String() const;
	
	bool
		CanBeDecomposed() const;
	bool
		HasDirectoryPath() const;
	CFStringRef
		CopyScheme() const;
	CFStringRef
		CopyNetLocation() const;
	CFStringRef
		CopyPath() const;
	CFStringRef
		CopyStrictPath(
				bool outIsAbsolute) const;
	CFStringRef
		CopyFileSystemPath(
				CFURLPathStyle inPathStyle = kCFURLPOSIXPathStyle) const;
	CFStringRef
		CopyResourceSpecifier() const;
	CFStringRef
		CopyHostName() const;
	CFStringRef
		CopyUserName() const;
	CFStringRef
		CopyPassword() const;
	SInt32
		PortNumber() const;
	
	CFStringRef
		CopyParameterString(
				CFStringRef inEscapeCharacters = CFSTR("")) const;
	CFStringRef
		CopyQueryString(
				CFStringRef inEscapeCharacters = CFSTR("")) const;
	CFStringRef
		CopyFragmentString(
				CFStringRef inEscapeCharacters = CFSTR("")) const;
};

// ---------------------------------------------------------------------------

inline FSRef
ACFURL::MakeFSRef() const
{
	FSRef fsRef;
	::CFURLGetFSRef(*this,&fsRef);
	return fsRef;
}

inline CFStringRef
ACFURL::String() const
{
	return ::CFURLGetString(*this);
}

inline bool
ACFURL::CanBeDecomposed() const
{
	return ::CFURLCanBeDecomposed(*this);
}

inline bool
ACFURL::HasDirectoryPath() const
{
	return ::CFURLHasDirectoryPath(*this);
}

inline CFStringRef
ACFURL::CopyScheme() const
{
	return ::CFURLCopyScheme(*this);
}

inline CFStringRef
ACFURL::CopyNetLocation() const
{
	return ::CFURLCopyNetLocation(*this);
}

inline CFStringRef
ACFURL::CopyPath() const
{
	return ::CFURLCopyPath(*this);
}

inline CFStringRef
ACFURL::CopyStrictPath(
		bool outIsAbsolute) const
{
	Boolean absolute;
	CFStringRef path = ::CFURLCopyStrictPath(*this,&absolute);
	outIsAbsolute = absolute;
	return path;
}

inline CFStringRef
ACFURL::CopyFileSystemPath(
		CFURLPathStyle inPathStyle) const
{
	return ::CFURLCopyFileSystemPath(*this,inPathStyle);
}

inline CFStringRef
ACFURL::CopyResourceSpecifier() const
{
	return ::CFURLCopyResourceSpecifier(*this);
}

inline CFStringRef
ACFURL::CopyHostName() const
{
	return ::CFURLCopyHostName(*this);
}

inline CFStringRef
ACFURL::CopyUserName() const
{
	return ::CFURLCopyUserName(*this);
}

inline CFStringRef
ACFURL::CopyPassword() const
{
	return ::CFURLCopyPassword(*this);
}

inline SInt32
ACFURL::PortNumber() const
{
	return ::CFURLGetPortNumber(*this);
}

inline CFStringRef
ACFURL::CopyParameterString(
		CFStringRef inEscapeCharacters) const
{
	return ::CFURLCopyParameterString(*this,inEscapeCharacters);
}

inline CFStringRef
ACFURL::CopyQueryString(
		CFStringRef inEscapeCharacters) const
{
	return ::CFURLCopyQueryString(*this,inEscapeCharacters);
}

inline CFStringRef
ACFURL::CopyFragmentString(
		CFStringRef inEscapeCharacters) const
{
	return ::CFURLCopyFragment(*this,inEscapeCharacters);
}
