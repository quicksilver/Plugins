// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AEventObject.h"
#include "AEventParameter.h"

#pragma warn_unusedarg off

class AControlHandler :
		public AEventObject
{
public:
		AControlHandler(
				ControlRef inControl)
		: AEventObject(inControl) {}
	
protected:
	
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// AControlHandler
	
	// init/dispose
	virtual bool
		Initialize(
				Collection inCollection,
				UInt32 outFeatures)
		{ return false; }
	virtual bool
		Dispose()
		{ return false; }
	
	// bounds
	virtual bool
		GetOptimalBounds(
				ATypeParam<AWriteOnly>::Rect &outOptimalBounds,
				ATypeParam<AWriteOnly>::SInt16 &outBaseLine)
		{ return false; }
	virtual bool
		BoundsChanged(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds)
		{ return false; }
	
	// hitting
	virtual bool
		Hit(
				ControlPartCode inPart,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		SimulateHit()
		{ return false; }
	virtual bool
		HitTest(
				Point inMouse,
				AParam<AWriteOnly>::ControlPart &outPart)
		{ return false; }
	
	// drawing
	virtual bool
		Draw(
				const AParam<>::ControlPart &inPart,
				const AParam<>::Port &inGrafPort)
		{ return false; }
	
	// colors
	virtual bool
		ApplyBackground(
				ControlRef inSubControl,
				SInt16 inDepth,
				bool inDrawInColor,
				const AParam<>::Port &inPort)
		{ return false; }
	virtual bool
		ApplyTextColor(
				ControlRef inSubControl,
				SInt16 inDepth,
				bool inDrawInColor,
				const AParam<>::Context &inContext,
				const AParam<>::Port &inPort)
		{ return false; }
	
	// focus
	virtual bool
		SetFocusPart(
				AParam<AReadWrite>::ControlPart &ioFocusPart)
		{ return false; }
	virtual bool
		GetFocusPart(
				AParam<AWriteOnly>::ControlPart &outFocusPart)
		{ return false; }
	
	// activation
	virtual bool
		Activate()
		{ return false; }
	virtual bool
		Deactivate()
		{ return false; }
	
	// mouse
	virtual bool
		SetCursor(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		ContextualMenuClick(
				Point inMouse)
		{ return false; }
	virtual bool
		Click(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		Track(
				Point inMouse,
				AParam<AReadWrite>::Modifiers &ioModifiers,
				AParam<AWriteOnly>::ControlPart &outPart)
		{ return false; }
	
	// drag - new in OS X 10.2
	virtual bool
		DragEnter(
				DragRef inDragRef)
		{ return false; }
	virtual bool
		DragWithin(
				DragRef inDragRef)
		{ return false; }
	virtual bool
		DragLeave(
				DragRef inDragRef)
		{ return false; }
	virtual bool
		DragReceive(
				DragRef inDragRef)
		{ return false; }
	
	// details
	virtual bool
		GetScrollToHereStartPoint(
				Point inMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		GetIndicatorDragConstraint(
				Point inMouse,
				UInt32 inModifiers,
				AEventParameter<IndicatorDragConstraint,AWriteOnly> &outConstraint)
		{ return false; }
	virtual bool
		IndicatorMoved(
				RgnHandle inIndicatorRegion,
				bool inIsGhosting)
		{ return false; }
	virtual bool
		GhostingFinished(
				Point inOffset)
		{ return false; }
	virtual bool
		GetActionProcPart(
				UInt32 inModifiers,
				AParam<AReadWrite>::ControlPart &ioPart)
		{ return false; }
	
	virtual bool
		GetPartRegion(
				ControlPartCode inPart,
				RgnHandle inRegion)
		{ return false; }
	virtual bool
		GetPartBounds(
				ControlPartCode inPart,
				ATypeParam<AWriteOnly>::Rect &outBounds)
		{ return false; }
	
	// data
	virtual bool
		SetData(
				ControlPartCode inPart,
				UInt32 inTag,
				void *inBuffer,
				SInt32 inDataSize)
		{ return false; }
	virtual bool
		GetData(
				ControlPartCode inPart,
				UInt32 inTag,
				void *inBuffer,
				ATypeParam<AReadWrite>::SInt32 &ioDataSize)
		{ return false; }
	
	virtual bool
		ValueFieldChanged()
		{ return false; }
	
	// hierarchy
	virtual bool
		AddedSubControl(
				ControlRef inSubControl)
		{ return false; }
	virtual bool
		RemovingSubControl(
				ControlRef inSubControl)
		{ return false; }
	virtual bool
		OwningWindowChanged(
				UInt32 inAttributes,
				WindowRef inOriginalOwner,
				WindowRef inNewOwner)
		{ return false; }
	
	virtual bool
		ArbitraryMessage(
				SInt32 inMessage,
				SInt32 inParam,
				ATypeParam<AWriteOnly>::SInt32 &outResult)
		{ return false; }
};

#pragma warn_unusedarg reset