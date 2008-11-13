// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AEventObject.h"
#include "AEventParameter.h"

#pragma warn_unusedarg off

class AWindowHandler :
		public AEventObject
{
public:
		AWindowHandler(
				WindowRef inWindow);
		AWindowHandler() {}
		
protected:
	
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// AWindowHandler
	
	virtual bool
		Update()
		{ return false; }
	virtual bool
		DrawContent()
		{ return false; }
	virtual bool
		Activated()
		{ return false; }
	virtual bool
		Deactivated()
		{ return false; }
	virtual bool
		ClickDrag(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickCollapse(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickClose(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickZoom(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickProxyIcon(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickToolbarButton(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickStructure(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickContent(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ContentClick(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ClickResize(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		GetClickActivation(
				Point inMouse,
				UInt32 inModifiers,
				AParam<AWriteOnly>::ClickActivation &outClickActivation)
		{ return false; }
	virtual bool
		Shown()
		{ return false; }
	virtual bool
		Hidden()
		{ return false; }
	virtual bool
		BoundsChanging(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				ATypeParam<AReadWrite>::Rect &ioCurrentBounds)
		{ return false; }
	virtual bool
		BoundsChanged(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds)
		{ return false; }
	virtual bool
		ResizeStarted()
		{ return false; }
	virtual bool
		ResizeCompleted()
		{ return false; }
	virtual bool
		DragStarted()
		{ return false; }
	virtual bool
		DragCompleted()
		{ return false; }
	virtual bool
		CursorChange(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		Collapse()
		{ return false; }
	virtual bool
		Collapsed()
		{ return false; }
	virtual bool
		Expand()
		{ return false; }
	virtual bool
		Expanded()
		{ return false; }
	virtual bool
		Close()
		{ return false; }
	virtual bool
		Closed()
		{ return false; }
	virtual bool
		Zoom()
		{ return false; }
	virtual bool
		Zoomed()
		{ return false; }
	virtual bool
		CloseAll()
		{ return false; }
	virtual bool
		ZoomAll()
		{ return false; }
	virtual bool
		CollapseAll()
		{ return false; }
	virtual bool
		ContextualMenuSelect(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		PathSelect()
		{ return false; }
	virtual bool
		GetIdealSize(
				AParam<AWriteOnly>::Dimensions &outSize)
		{ return false; }
	virtual bool
		GetMinimumSize(
				AParam<AWriteOnly>::Dimensions &outSize)
		{ return false; }
	virtual bool
		GetMaximumSize(
				AParam<AWriteOnly>::Dimensions &outSize)
		{ return false; }
	virtual bool
		ProxyBeginDrag(
				DragRef inDrag)
		{ return false; }
	virtual bool
		ProxyEndDrag()
		{ return false; }
	virtual bool
		FocusAcquired()
		{ return false; }
	virtual bool
		FocusRelinquish()
		{ return false; }
	virtual bool
		SwitchToolbarMode()
		{ return false; }
};

#pragma warn_unusedarg reset
