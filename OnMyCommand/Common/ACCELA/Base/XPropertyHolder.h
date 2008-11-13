// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(Carbon,MacTypes.h)

class XPropertyHolder
{
public:
	virtual void
		SetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				const void *inBuffer) = 0;
	virtual void
		GetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				void *inBuffer) const = 0;
	virtual UInt32
		GetPropertySize(
				OSType inCreator,
				OSType inTag) const = 0;
	virtual bool
		HasProperty(
				OSType inCreator,
				OSType inTag) const = 0;
	
	virtual void
		RemoveProperty(
				OSType inCreator,
				OSType inTag) = 0;
	virtual void
		GetPropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 &outAttributes) const = 0;
	virtual void
		ChangePropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 inSet,
				UInt32 inClear) = 0;
	
	template <class T>
	void
		SetProperty(
				OSType inCreator,
				OSType inTag,
				const T &inObject)
		{
			SetPropertyData(inCreator,inTag,sizeof(inObject),&inObject);
		}
	template <class T>
	void
		GetProperty(
				OSType inCreator,
				OSType inTag,
				T &outObject) const
		{
			GetPropertyData(inCreator,inTag,sizeof(outObject),&outObject);
		}
	template <class T>
	T
		Property(
				OSType inCreator,
				OSType inTag) const
		{
			T object;
			GetPropertyData(inCreator,inTag,sizeof(T),&object);
			return object;
		}
	UInt32
		PropertyAttributes(
				OSType inCreator,
				OSType inTag) const
		{
			UInt32 attributes;
			GetPropertyAttributes(inCreator,inTag,attributes);
			return attributes;
		}
};
