#include "AControls.h"

// ---------------------------------------------------------------------------

AScrollBar::AScrollBar(
		WindowRef inWindow,
		const Rect &inBounds,
		SInt32 inValue,
		SInt32 inMinimum,
		SInt32 inMaximum,
		SInt32 inViewSize,
		bool inLiveTracking)
: AControl(NULL,false)
{
	static ControlActionUPP actionUPP = NewControlActionUPP(ActionProc);
	
	CThrownOSStatus err = ::CreateScrollBarControl(
			inWindow,&inBounds,
			inValue,inMinimum,inMaximum,
			inViewSize,
			inLiveTracking,inLiveTracking ? actionUPP : NULL,
			&mObject);
	mOwner = true;
}

// ---------------------------------------------------------------------------

pascal void
AScrollBar::ActionProc(
		ControlRef inControl,
		ControlPartCode inPart)
{
	AControl control(inControl);
	AScrollBar *scrollBar = dynamic_cast<AScrollBar*>(control.Property<AScrollBar*>('ACEL','obj '));
	
	if (scrollBar != NULL)
		scrollBar->Action(inPart);
}

// ---------------------------------------------------------------------------
