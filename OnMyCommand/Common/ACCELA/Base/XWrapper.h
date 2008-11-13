// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

// XWrapper:
//
// Abstract base class template for wrapping data types
// that have a specific way to be disposed. Subclasses
// should specialize DisposeSelf().

#include "FW.h"

#include FW(CoreServices,MacTypes.h)

template <class T>
class XWrapper
{
public:
		XWrapper(
				T inObject,
				bool inOwner = false)
		: mObject(inObject),mOwner(inOwner) {}
		XWrapper()
		: mObject(NULL),mOwner(false) {}
	virtual
		~XWrapper()
		{
			if (mOwner && (mObject != NULL)) DisposeSelf();//_tk_
		}
	
		operator T() const
		{
			return mObject;
		}
	
	void
		Reset(
				T inObject,
				bool inOwner = false)
		{
			if (mOwner && (mObject != NULL) && (inObject != mObject)) DisposeSelf();//_tk_
			mObject = inObject;
			mOwner = inOwner;
		}
	T
		Detach()
		{
			mOwner = false;
			return mObject;
		}
	T
		Get() const
		{
			return mObject;
		}
	//_tk_
	void
		Dispose()
		{
			if (mObject != NULL)
			{
				if(mOwner) DisposeSelf();
				mObject = NULL;
				mOwner = false;
			}
		}
	
protected:
	T mObject;
	bool mOwner;
	
	virtual void
		DisposeSelf();
};
