// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACommandObject.h"

// ---------------------------------------------------------------------------

OSStatus
ACommandObject::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	HICommand command;
	
	outEventHandled = false;
	if (inEvent.Class() == kEventClassCommand)
		switch (inEvent.Kind()) {
			
			case kEventCommandProcess:
				inEvent.GetParameter(kEventParamDirectObject,typeHICommand,command);
				outEventHandled = CommandProcess(command);
				break;
			
			case kEventCommandUpdateStatus:
				inEvent.GetParameter(kEventParamDirectObject,typeHICommand,command);
				outEventHandled = CommandUpdateStatus(command);
				break;
		}
	return noErr;
}