// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"
#include "FW.h"

#include FW(CoreFoundation,CFBundle.h)

class ACFBundle :
		public ACFBase
{
public:
	
	typedef enum {
		bundle_Main
	} EMainBundle;
	
		// CFBundleRef
		ACFBundle(
				CFBundleRef inBundle,
				bool inDoRetain = true)
			: ACFBase(inBundle,inDoRetain) {}
		// Main bundle
		ACFBundle(
				EMainBundle)
			: ACFBase(::CFBundleGetMainBundle()) {}
		// Bundle ID
		ACFBundle(
				CFStringRef inBundleID)
			: ACFBase(::CFBundleGetBundleWithIdentifier(inBundleID)) {}
		// URL
		ACFBundle(
				CFURLRef inURL,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
			: ACFBase(::CFBundleCreate(inAllocator,inURL),false) {}
	
	// The compiler doesn't like the CFBundleRef
	// version of ACFType::operator T
		operator CFBundleRef() const
		{
			return (CFBundleRef)mObjectRef;
		}
	
	CFURLRef
		CopyURL() const;
	
	CFTypeRef
		GetValueForInfoDictKey(
				CFStringRef inKey) const;
	CFDictionaryRef
		GetInfoDict() const;
	CFDictionaryRef
		GetLocalInfoDict() const;
	CFStringRef
		CopyLocalizedString(
				CFStringRef inKey,
				CFStringRef inTableName = NULL) const;
	
	void
		GetPackageInfo(
				OSType &outType,
				OSType &outCreator) const;
	CFStringRef
		GetIdentifier() const;
	UInt32
		GetVersionNumber() const;
	CFStringRef
		GetDevelopmentRegion() const;
	
	CFURLRef
		CopySupportFilesDirectoryURL() const;
	CFURLRef
		CopyResourcesDirectoryURL() const;
	CFURLRef
		CopyPrivateFrameworksURL() const;
	CFURLRef
		CopySharedFrameworksURL() const;
	CFURLRef
		CopyBuiltInPluginsURL() const;
	
	CFURLRef
		CopyResourceURL(
				CFStringRef inName,
				CFStringRef inType = NULL,
				CFStringRef inSubDir = NULL) const;
	
	static UInt32
		GetTypeID();
	static CFStringRef
		GetAppName();
};

// ---------------------------------------------------------------------------

inline CFURLRef
ACFBundle::CopyURL() const
{
	return ::CFBundleCopyBundleURL(*this);
}

inline CFTypeRef
ACFBundle::GetValueForInfoDictKey(
		CFStringRef inKey) const
{
	return ::CFBundleGetValueForInfoDictionaryKey(*this,inKey);
}

inline CFDictionaryRef
ACFBundle::GetInfoDict() const
{
	return ::CFBundleGetInfoDictionary(*this);
}

inline CFDictionaryRef
ACFBundle::GetLocalInfoDict() const
{
	return ::CFBundleGetLocalInfoDictionary(*this);
}

inline CFStringRef
ACFBundle::CopyLocalizedString(
		CFStringRef inKey,
		CFStringRef inTableName) const
{
	return ::CFBundleCopyLocalizedString(*this,inKey,inKey,inTableName);
}

inline void
ACFBundle::GetPackageInfo(
		OSType &outType,
		OSType &outCreator) const
{
	::CFBundleGetPackageInfo(*this,&outType,&outCreator);
}

inline CFStringRef
ACFBundle::GetIdentifier() const
{
	return ::CFBundleGetIdentifier(*this);
}

inline UInt32
ACFBundle::GetVersionNumber() const
{
	return ::CFBundleGetVersionNumber(*this);
}

inline CFStringRef
ACFBundle::GetDevelopmentRegion() const
{
	return ::CFBundleGetDevelopmentRegion(*this);
}

inline CFURLRef
ACFBundle::CopySupportFilesDirectoryURL() const
{
	return ::CFBundleCopySupportFilesDirectoryURL(*this);
}

inline CFURLRef
ACFBundle::CopyResourcesDirectoryURL() const
{
	return ::CFBundleCopyResourcesDirectoryURL(*this);
}

inline CFURLRef
ACFBundle::CopyPrivateFrameworksURL() const
{
	return ::CFBundleCopyPrivateFrameworksURL(*this);
}

inline CFURLRef
ACFBundle::CopySharedFrameworksURL() const
{
	return ::CFBundleCopySharedFrameworksURL(*this);
}

inline CFURLRef
ACFBundle::CopyBuiltInPluginsURL() const
{
	return ::CFBundleCopyBuiltInPlugInsURL(*this);
}

inline CFURLRef
ACFBundle::CopyResourceURL(
		CFStringRef inName,
		CFStringRef inType,
		CFStringRef inSubDir) const
{
	return CFBundleCopyResourceURL(*this,inName,inType,inSubDir);
}

inline UInt32
ACFBundle::GetTypeID()
{
	return ::CFBundleGetTypeID();
}
