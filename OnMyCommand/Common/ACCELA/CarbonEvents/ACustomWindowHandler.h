// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AWindowHandler.h"

#pragma warn_unusedarg off

class ACustomWindowHandler :
		public AWindowHandler
{
public:
	explicit
		ACustomWindowHandler(
				WindowRef inWindowRef)
		: AWindowHandler(inWindowRef) {}
	
protected:
	
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// ACustomWindowHandler
	
	virtual bool
		Init(
				UInt32 inFeatures)
		{ return false; }
	virtual bool
		Dispose()
		{ return false; }
	virtual bool
		DrawFrame()
		{ return false; }
	virtual bool
		DrawPart(
				WindowPartCode inPartCode)
		{ return false; }
	virtual bool
		GetRegion(
				WindowRegionCode inRegionCode,
				RgnHandle outRegion)
		{ return false; }
	virtual bool
		HitTest(
				Point inMouse,
				AParam<AWriteOnly>::WindowPart &outPartCode)
		{ return false; }
	virtual bool
		DragHilite(
				bool inDoHilite)
		{ return false; }
	virtual bool
		Modified(
				bool inModified)
		{ return false; }
	virtual bool
		SetupProxyDragImage(
				RgnHandle outImageRgn,
				RgnHandle outOutlineRgn,
				ATypeParam<AWriteOnly>::GWorldPtr &outImageGWorld)
		{ return false; }
	virtual bool
		StateChanged(
				UInt32 inStateFlags)
		{ return false; }
	virtual bool
		MeasureTitle(
				ATypeParam<AWriteOnly>::SInt16 &outFullWidth,
				ATypeParam<AWriteOnly>::SInt16 &outTextWidth)
		{ return false; }
	virtual bool
		DrawGrowBox()
		{ return false; }
	virtual bool
		GetGrowImageRegion(
				Rect inGrowRect,
				RgnHandle outGrowRgn)
		{ return false; }
	virtual bool
		Paint()
		{ return false; }
};

#pragma warn_unusedarg reset