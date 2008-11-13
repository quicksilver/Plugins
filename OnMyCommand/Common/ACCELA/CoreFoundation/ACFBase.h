// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XRefCountObject.h"
#include "FW.h"

#include FW(CoreFoundation,CFBase.h)

// ---------------------------------------------------------------------------

inline void
XRefCountObject<CFTypeRef>::Retain()
{
	if (mObjectRef != NULL) ::CFRetain(mObjectRef);
}

inline void
XRefCountObject<CFTypeRef>::Release()
{
	if (mObjectRef != NULL) ::CFRelease(mObjectRef);
}

inline UInt32
XRefCountObject<CFTypeRef>::GetRetainCount() const
{
	return ::CFGetRetainCount(mObjectRef);
}

// ---------------------------------------------------------------------------

class ACFBase :
		public XRefCountObject<CFTypeRef>
{
public:
		ACFBase() {}
		ACFBase(
				CFTypeRef inObject,
				bool inDoRetain = true)
		: XRefCountObject<CFTypeRef>(inObject,inDoRetain) {}
	
	CFTypeID
		GetTypeID() const;
	bool
		operator==(
				const ACFBase &inOther) const;
	CFHashCode
		Hash() const;
	CFStringRef
		CopyDescription() const;
};

// ---------------------------------------------------------------------------

template <class T>
class ACFType :
		public ACFBase
{
public:
		operator T() const
		{
			// this used to be a static_cast, but I couldn't work
			// around the const issues that came up in some cases
			return (T)mObjectRef;
		}
	bool
		operator==(
				T inRef) const
		{
			return ::CFEqual(*this,inRef);
		}
	
protected:
		ACFType() {}
		ACFType(
				CFTypeRef inObject,
				bool inDoRetain = true)
		: ACFBase(inObject,inDoRetain) {}
};

// ---------------------------------------------------------------------------

inline bool
ACFBase::operator==(
		const ACFBase &inOther) const
{
	return ::CFEqual(*this,inOther);
}

inline CFHashCode
ACFBase::Hash() const
{
	return ::CFHash(*this);
}

inline CFStringRef
ACFBase::CopyDescription() const
{
	return ::CFCopyDescription(*this);
}
