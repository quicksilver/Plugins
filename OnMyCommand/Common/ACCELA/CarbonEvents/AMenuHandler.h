// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AEventObject.h"
#include "AEventParameter.h"

#pragma warn_unusedarg off

class AMenuHandler :
		public AEventObject
{
public:
		AMenuHandler(
				MenuRef inMenu)
		: AEventObject(inMenu) {}
		AMenuHandler() {}
	
protected:
	// AEventObject
	
	OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// AMenuHandler
	
	virtual bool
		BeginTracking(
				MenuTrackingMode inMode,
				UInt32 inContext)
		{ return false; }
	virtual bool
		EndTracking(
				UInt32 inContext)
		{ return false; }
	virtual bool
		ChangeTrackingMode(
				MenuTrackingMode inCurrentMode,
				MenuTrackingMode inNewMode,
				UInt32 inContext)
		{ return false; }
	virtual bool
		Opening(
				bool inFirstOpen)
		{ return false; }
	virtual bool
		Closed()
		{ return false; }
	virtual bool
		TargetItem(
				MenuItemIndex inItem,
				MenuCommand inCommand)
		{ return false; }
	virtual bool
		MatchKey(
				EventRef inEvent,
				MenuEventOptions inOptions,
				AParam<AWriteOnly>::MenuItem &outIndex)
		{ return false; }
	virtual bool
		EnableItems(
				bool inForKeyEvent)
		{ return false; }
	virtual bool
		Dispose()
		{ return false; }
};

#pragma warn_unusedarg reset
