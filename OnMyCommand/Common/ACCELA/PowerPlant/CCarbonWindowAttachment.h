// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include <LAttachment.h>

#include "AWindowHandler.h"

class LWindow;

class CCarbonWindowAttachment :
		public LAttachment,
		public AWindowHandler
{
public:
	enum { class_ID = 'CWAt' };
	
		CCarbonWindowAttachment(
				LStream *inStream);
		~CCarbonWindowAttachment();
	
protected:
	LWindow *mWindow;
	StHandleEventTypes mEventTypes;
	
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// AWindowHandler
	
	virtual bool
		Update();
	virtual bool
		DrawContent();
	virtual bool
		Activated();
	virtual bool
		Deactivated();
	virtual bool
		ClickContent(
				Point inMouse,
				UInt32 inModifiers);
	virtual bool
		ClickResize(
				Point inMouse,
				UInt32 inModifiers);
	virtual bool
		ContextualMenuSelect(
				Point inMouse,
				UInt32 inModifiers);
	virtual bool
		GetClickActivation(
				Point inMouse,
				UInt32 inModifiers,
				AParam<AWriteOnly>::ClickActivation &outClickActivation);
	virtual bool
		Close();
	virtual bool
		Zoom();
	virtual bool
		BoundsChanged(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds);
	virtual bool
		GetIdealSize(
				AParam<AWriteOnly>::Dimensions &outSize);
	virtual bool
		GetMinimumSize(
				AParam<AWriteOnly>::Dimensions &outSize);
	virtual bool
		GetMaximumSize(
				AParam<AWriteOnly>::Dimensions &outSize);
};
