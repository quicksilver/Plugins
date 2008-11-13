// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AControl.h"
#include "AControlHandler.h"

#pragma warn_unusedarg off

class AFontPopup :
		public AControl,
		public AControlHandler,
		public ACommandHandler
{
public:
		AFontPopup(
				ControlRef inControl);
		AFontPopup(
				WindowRef inOwningWindow,
				const ControlID &inID);
	
protected:
	StHandleEventTypes mControlEventTypes,mMenuEventTypes;
	AFontMenu mMenu;
	
	// ACommandHandler
	
	bool
		ProcessCommand(
				const HICommand &inCommand,
				UInt32 inModifiers);
	
	// AFontPopup
	
	virtual void
		FontSelected(
				FMFontFamily inFontFamily,
				FMFontStyle inStyle) {}
};

#pragma warn_unusedarg reset
