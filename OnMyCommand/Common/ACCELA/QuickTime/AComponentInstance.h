// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"

#include "CThrownResult.h"

typedef CThrownResult<ComponentResult> CThrownCR;

// ---------------------------------------------------------------------------

class AComponentInstance :
		public XWrapper<ComponentInstance>
{
public:
		// ComponentInstance
		AComponentInstance(
				ComponentInstance inInstance,
				bool inOwner = false)
		: XWrapper(inInstance,inOwner) {}
		// Component
		AComponentInstance(
				Component inComponent)
		: XWrapper(::OpenComponent(inComponent),true) {}
		// Default component
		AComponentInstance(
				OSType inType,
				OSType inSubType)
		: XWrapper(::OpenDefaultComponent(inType,inSubType),true) {}
	
	Handle
		Storage() const;
	void
		SetStorage(
				Handle inStorage);
	bool
		CanDo(
				short inFTN) const;
};

// ---------------------------------------------------------------------------

inline Handle
AComponentInstance::Storage() const
{
	return ::GetComponentInstanceStorage(*this);
}

inline void
AComponentInstance::SetStorage(
		Handle inStorage)
{
	::SetComponentInstanceStorage(*this,inStorage);
}

inline bool
AComponentInstance::CanDo(
		short inFTN) const
{
	return (::CallComponentCanDo(*this,inFTN) != noErr);	// why non-zero?
}

// ---------------------------------------------------------------------------

inline void
XWrapper<ComponentInstance>::DisposeSelf()
{
	::CloseComponent(mObject);
}
