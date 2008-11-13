// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(CoreServices,MacTypes.h)

template <class T>
class CThrownResult {
public:
		CThrownResult(
				T inValue = 0)
		: mValue(inValue),mGoodValue(0),mAllowedValue(0)
		{
			if (inValue != 0) throw inValue;
		}
	
	CThrownResult&
		operator =(
				T inValue)
		{
			mValue = inValue;
			if ((inValue != mGoodValue) && (inValue != mAllowedValue)) throw inValue; return *this;
		}
	
	void
		Allow(
				T inAllowedValue)
		{ mAllowedValue = inAllowedValue; }
	void
		Disallow()
		{ mAllowedValue = mGoodValue; }
	
		operator T() const
		{ return mValue; }
	
protected:
	T mValue,mGoodValue,mAllowedValue; 
};

typedef CThrownResult<OSStatus> CThrownOSStatus;
typedef CThrownResult<OSErr> CThrownOSErr;
