// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AEventObject.h"
#include "AEventParameter.h"

#pragma warn_unusedarg off

class ACommandHandler :
		public AEventObject
{
public:
	template <class T>
		ACommandHandler(
				T inTarget)
		: AEventObject(inTarget) {}
		ACommandHandler() {}
	
protected:
	// AEventObject
	
	OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// ACommandHandler
	
	virtual bool
		ProcessCommand(
				const HICommand &inCommand,
				const AParam<AReadOnly>::Modifiers &inModifiers)
		{ return false; }
	virtual bool
		UpdateCommandStatus(
				const HICommand &inCommand,
				const AParam<AReadOnly>::Modifiers &inModifiers)
		{ return false; }
};

class ACommandEvent :
		public ACarbonEvent
{
public:
		ACommandEvent(
				const HICommand inCommand);
		ACommandEvent(
				UInt32 inCommandID,
				UInt32 inAttributes = 0);
};

#pragma warn_unusedarg reset
