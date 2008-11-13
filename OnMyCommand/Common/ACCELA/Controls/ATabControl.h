// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AControl.h"
#include "AControlHandler.h"

class ATabControl :
		public AControl,
		public AControlHandler
{
public:
		ATabControl(
				ControlRef inControl,
				UInt16 inInitialTab = 1);
		ATabControl(
				WindowRef inOwningWindow,
				const ControlID &inID,
				UInt16 inInitialTab = 1);
	
	// ATabControl
	
	void
		ChangedTab()	// Replace with ValueFieldChanged
		{ Hit(0,0); }	// when available in CarbonLib
	
protected:
	StHandleEventTypes mTypes;
	SInt16 mLastValue;
	
	// AControlHandler
	
	virtual bool
		Hit(
				ControlPartCode inPart,
				UInt32 inModifiers);
	
	// ATabControl
	
	void
		InitTabs(
				UInt16 inIndex);
	void
		SelectTab(
				UInt16 inIndex);
};
