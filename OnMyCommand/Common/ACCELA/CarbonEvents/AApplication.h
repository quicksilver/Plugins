// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once
#include "AEventObject.h"
#include "AEventParameter.h"

#pragma warn_unusedarg off

class AApplication :
		public AEventObject
{
public:
	AApplication();
	
	virtual void
		Run();
	
protected:
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	virtual bool
		Activated(
				const AParam<>::Window &inClickedWindow)
		{ return false; }
	virtual bool
		Deactivated()
		{ return false; }
	virtual bool
		Quit()
		{ return false; }
	
	virtual bool
		LaunchNotification(
				const ProcessSerialNumber &inPSN,
				UInt32 inRefCon,
				OSStatus inLaunchErr)
		{ return false; }
	virtual bool
		AppLaunched(
				const ProcessSerialNumber &inPSN)
		{ return false; }
	virtual bool
		AppTerminated(
				const ProcessSerialNumber &inPSN)
		{ return false; }
	virtual bool
		FrontSwitched(
				const ProcessSerialNumber &inPSN)
		{ return false; }
	
	virtual bool
		FocusMenuBar(
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		FocusNextDocumentWindow(
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		FocusNextFloatingWindow(
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		FocusToolbar(
				UInt32 inModifiers)
		{ return false; }
	
	virtual bool
		GetDockTileMenu(
				AParam<AWriteOnly>::Menu &outMenu)
		{ return false; }
	
	virtual bool
		Hidden()
		{ return false; }
	virtual bool
		Shown()
		{ return false; }
	
	virtual bool
		SystemUIModeChanged(
				UInt32 inUIMode)
		{ return false; }
};

#pragma warn_unusedarg reset
