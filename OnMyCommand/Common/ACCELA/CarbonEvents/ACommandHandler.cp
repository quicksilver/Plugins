// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACommandHandler.h"
#include "AEventParameter.h"

// ---------------------------------------------------------------------------

OSStatus
ACommandHandler::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	OSStatus err = noErr;
	
	if (inEvent.Class() == kEventClassCommand)
		switch (inEvent.Kind()) {
			
			case kEventCommandProcess:
				outEventHandled = ProcessCommand(
						AParam<>::Command(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventCommandUpdateStatus:
				outEventHandled = UpdateCommandStatus(
						AParam<>::Command(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
		}
	
	if (!outEventHandled)
		err = AEventObject::HandleEvent(inEvent,outEventHandled);
	return err;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ACommandEvent::ACommandEvent(
		const HICommand inCommand)
: ACarbonEvent(kEventClassCommand,kEventCommandProcess)
{
	SetParameter(kEventParamDirectObject,inCommand);
}

// ---------------------------------------------------------------------------

ACommandEvent::ACommandEvent(
		UInt32 inCommandID,
		UInt32 inAttributes)
: ACarbonEvent(kEventClassCommand,kEventCommandProcess)
{
	const HICommand command = {
			inAttributes,inCommandID,
			{ NULL,0 } };
	
	SetParameter(kEventParamDirectObject,command);
}
