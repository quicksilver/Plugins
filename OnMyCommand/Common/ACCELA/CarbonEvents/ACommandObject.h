// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AEventObject.h"

class ACommandObject :
		public AEventObject
{
public:
	ACommandObject() {}
	
protected:
	virtual EventTypeSpec*
		GetEventTypes();
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	virtual bool
		CommandProcess(
				const HICommand &)	// inCommand
		{ return false; }
	virtual bool
		CommandUpdateStatus(
				const HICommand &)	// inCommand
		{ return false; }
};
