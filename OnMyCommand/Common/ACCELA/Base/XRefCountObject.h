// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

/*
	XRefCountObject:
	
	Abstract base class for wrapping reference-counted
	toolbox objects. Constructors, destructor, and
	operator= all handle retaining and releasing.
*/

#include "FW.h"

#include FW(CoreServices,MacTypes.h)

template <class T>
class XRefCountObject {
public:
		XRefCountObject(
				T inObjectRef,
				bool inDoRetain = true)
		: mObjectRef(inObjectRef)
		{ if (inDoRetain && (inObjectRef != NULL)) Retain(); }
		XRefCountObject(
				const XRefCountObject<T> &inObject)
		: mObjectRef(inObject.mObjectRef)
		{ if (mObjectRef != NULL) Retain(); }
	virtual
		~XRefCountObject()
		{ if (mObjectRef != NULL) Release(); }
	
	// Access to object reference
		operator T() const
		{ return mObjectRef; }
	const T&
		Get() const
		{ return mObjectRef; }
	
	// operator =
	XRefCountObject<T>&
		operator =(
				const XRefCountObject &inOther)
		{
			if (inOther.mObjectRef != mObjectRef) {
				if (mObjectRef != NULL) Release();
				mObjectRef = inOther.mObjectRef;
				if (mObjectRef != NULL) Retain();
			}
			return *this;
		}
	XRefCountObject&
		operator =(
				T inNewObject)
		{
			Reset(inNewObject);
			return *this;
		}
	
	// Reset: use a different object reference
	virtual void
		Reset(
				T inObjectRef,
				bool inDoRetain = true)
		{
			if (inObjectRef != mObjectRef) {
				Release();
				mObjectRef = inObjectRef;
				if (inDoRetain && (inObjectRef != NULL)) Retain();
			}
		}
	
	// These functions are only defined
	// for individual types
	virtual void
		Retain();
	virtual void
		Release();
	virtual UInt32
		GetRetainCount() const;
	
protected:
	T mObjectRef;
	
		XRefCountObject()
		: mObjectRef(NULL) {}
};
