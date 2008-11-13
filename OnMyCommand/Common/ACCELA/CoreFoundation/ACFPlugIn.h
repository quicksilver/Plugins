// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

class ACFPlugIn :
		public ACFBase
{
public:
		ACFPlugIn(
				CFPlugInRef inPlugIn,
				bool inDoRetain = true)
			: ACFBase(inPlugIn,inDoRetain) {}
		ACFPlugIn(
				CFURLRef inURL,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
			: ACFBase(::CFPluginCreate(inAllocator,inURL)) {}
	
		operator CFPlugInRef()
		{
			return (CFPlugInRef)mObjectRef;
		}
	
	CFBundleRef
		GetBundle() const;
	
	void
		SetLoadOnDemand(
				bool inLoad);
	bool
		IsLoadOnDemand() const;
	
	CFArrayRef
		FindFactories(
				CFUUIDRef inUUID) const;
	void*
		CreateInstance(
				CFUUIDRef inFactory,
				CFUUIDRef inType) const;
	
	bool
		RegisterFactoryFunction(
				CFUUIDRef inFactoryID,
				CFStringRef inName);
};
