// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

#include FW(CoreFoundation,CFArray.h)

class ACFArray :
		public ACFType<CFArrayRef>
{
public:
		ACFArray() {};
		ACFArray(
				CFArrayRef inArray,
				bool inDoRetain = true)
			: ACFType<CFArrayRef>(inArray,inDoRetain) {}
		ACFArray(
				const void **inValues,
				CFIndex inValueCount)
			: ACFType<CFArrayRef>(::CFArrayCreate(kCFAllocatorDefault,inValues,inValueCount,NULL)) {}
	
	CFIndex
		Count() const
		{
			return ::CFArrayGetCount(*this);
		}
	CFIndex
		Count(
				const void *inValue) const
		{
			return ::CFArrayGetCountOfValue(*this,::CFRangeMake(0,Count()),inValue);
		}
	
	const void*
		operator[](
				CFIndex inIndex) const
		{
			return ::CFArrayGetValueAtIndex(*this,inIndex);
		}
	
	void
		ApplyFunction(
				CFRange inRange,
				CFArrayApplierFunction inFunction,
				void *inContext) const;
};

// ---------------------------------------------------------------------------

class ACFMutableArray :
		public ACFArray
{
public:
		// CFMutableArrayRef
		ACFMutableArray(
				CFMutableArrayRef inArray,
				bool inDoRetain = true)
		: ACFArray(inArray,inDoRetain) {}
		// empty
		ACFMutableArray(
				const CFArrayCallBacks &inCallbacks,
				CFIndex inCapacity = 0)
		: ACFArray(::CFArrayCreateMutable(kCFAllocatorDefault,inCapacity,&inCallbacks)) {}
		ACFMutableArray(
				CFIndex inCapacity = 0)
		: ACFArray(::CFArrayCreateMutable(kCFAllocatorDefault,inCapacity,NULL)) {}
	
		operator CFMutableArrayRef() const
		{
			return (CFMutableArrayRef)mObjectRef;
		}
	
	void
		Append(
				const void *inValue);
	void
		Append(
				CFArrayRef inArray);
	void
		Insert(
				CFIndex inAtIndex,
				const void *inValue);
	void
		Set(
				CFIndex inAtIndex,
				const void *inValue);
	void
		Remove(
				CFIndex inAtIndex);
	void
		RemoveAll();
};

// ---------------------------------------------------------------------------

inline void
ACFMutableArray::Append(
		const void *inValue)
{
	::CFArrayAppendValue(*this,inValue);
}
