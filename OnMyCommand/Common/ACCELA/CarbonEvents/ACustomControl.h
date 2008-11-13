// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AControlHandler.h"

#pragma warn_unusedarg off

class ACustomControl :
		public AControlHandler
{
public:
		ACustomControl(
				WindowRef inOwningWindow,
				const Rect &inBounds,
				Collection inData = 0L);
		ACustomControl(
				ControlRef inControl);
	
protected:
	
	// AEventObject
	
	virtual EventTargetRef
		GetEventTarget() const;
	virtual EventTypeSpec*
		GetEventTypes();
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// ACustomControl
	
	virtual bool
		Initialize(
				Collection inCollection)
		{ return true; }
	virtual bool
		Dispose()
		{ return true; }
	
	virtual bool
		GetOptimalBounds(
				Rect &outOptimalBounds,
				short &outBaseline,
				bool &outHasOffset)
		{ return false; }
	
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
				ControlPartCode &outPart)
		{ return false; }
	virtual bool
		Draw()
		{ return false; }
	
	virtual bool
		ApplyBackground(
				ControlRef inSubControl,
				short inDrawDepth,
				bool inColor,
				GrafPtr inPort)
		{ return false; }
	virtual bool
		ApplyTextColor(
				ControlRef inSubControl,
				short inDrawDepth,
				bool inColor,
				GrafPtr inPort)
		{ return false; }
	
	virtual bool
		SetFocusPart(
				ControlPartCode inFocusPart)
		{ return false; }
	virtual bool
		GetFocusPart(
				ControlPartCode &outFocusPart)
		{ return false; }
	
	virtual bool
		Activate()
		{ return false; }
	virtual bool
		Deactivate()
		{ return false; }
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
		Track(
				Point inMouse,
				UInt32 inModifiers,
				// ControlActionUPP?
				ControlPartCode &outPartCode)
		{ return false; }
	virtual bool
		GetScrollToHereStartPoint(
				Point &ioMouse,
				UInt32 inModifiers)
		{ return false; }
	virtual bool
		GetIndicatorDragConstraint(
				Point inMouse,
				UInt32 inModifiers,
				IndicatorDragConstraint &outConstraint)
		{ return false; }
	virtual bool
		IndicatorMoved(
				RgnHandle inIndicatorRegion,
				bool inIsGhosting)
		{ return false; }
	virtual bool
		GhostingFinished(
				Point inMouse)
		{ return false; }
	virtual bool
		GetActionProcPart(
				UInt32 inModifiers,
				ControlPartCode &ioPartCode)
		{ return false; }
	virtual bool
		GetPartRegion(
				ControlPartCode inPartCode,
				RgnHandle ioRegion)
		{ return false; }
	virtual bool
		GetPartBounds(
				ControlPartCode inPartCode,
				Rect &outBounds)
		{ return false; }
	virtual bool
		SetData(
				ControlPartCode inPartCode,
				ResType inDataTag,
				Ptr inBuffer,
				Size inBufferSize)
		{ return false; }
	virtual bool
		GetData(
				ControlPartCode inPartCode,
				ResType inDataTag,
				Ptr inBuffer,
				Size &ioBufferSize)
		{ return false; }
	virtual bool
		ValueFieldChanged()
		{ return false; }
	virtual bool
		AddedSubControl(
				ControlRef inSubControl)
		{ return false; }
	virtual bool
		RemovingSubControl(
				ControlRef inSubControl)
		{ return false; }
	virtual bool
		BoundsChanged(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds)
		{ return false; }
	virtual bool
		OwningWindowChanged(
				UInt32 inAttributes,
				WindowRef inOriginalOwner,
				WindowRef inCurrentOwner)
		{ return false; }
	virtual bool
		ArbitraryMessage(
				short inMessage,
				long inParam,
				long &outResult)
		{ return false; }
};

#pragma warn_unusedarg reset
