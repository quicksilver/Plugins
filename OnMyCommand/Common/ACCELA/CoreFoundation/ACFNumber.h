// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"
#include "FW.h"

#include FW(CoreFoundation,CFNumber.h)

class ACFNumber :
		public ACFType<CFNumberRef>
{
public:
		// CFNumberRef
		ACFNumber(
				CFNumberRef inNumber,
				bool inDoRetain = true)
			: ACFType<CFNumberRef>(inNumber,inDoRetain) {}
		// short
		ACFNumber(
				short inValue)
			: ACFType<CFNumberRef>(::CFNumberCreate(kCFAllocatorDefault,kCFNumberShortType,&inValue),false) {}
		// long
		ACFNumber(
				long inValue)
			: ACFType<CFNumberRef>(::CFNumberCreate(kCFAllocatorDefault,kCFNumberLongType,&inValue),false) {}
		// unsigned long
		ACFNumber(
				unsigned long inValue)
			{
				long long longValue = inValue;
				mObjectRef = ::CFNumberCreate(kCFAllocatorDefault,kCFNumberLongLongType,&longValue);
			}
	
		operator long() const
		{
			long longValue;
			::CFNumberGetValue(*this,kCFNumberLongType,&longValue);
			return longValue;
		}
	bool
		GetValue(
				CFNumberType inType,
				void *ioValue)
		{
			return ::CFNumberGetValue(*this,inType,ioValue);
		}
	
	CFNumberType
		NumberType() const
		{
			return ::CFNumberGetType(*this);
		}
	
	bool
		operator==(
				CFNumberRef inOther) const
		{
			return ::CFNumberCompare(*this,inOther,NULL) == kCFCompareEqualTo;
		}
	bool
		operator<(
				CFNumberRef inOther) const
		{
			return ::CFNumberCompare(*this,inOther,NULL) == kCFCompareLessThan;
		}
	bool
		operator>(
				CFNumberRef inOther) const
		{
			return ::CFNumberCompare(*this,inOther,NULL) == kCFCompareGreaterThan;
		}
};
