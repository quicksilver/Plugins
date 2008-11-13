#include "AUserPane.h"

// ---------------------------------------------------------------------------

AUserPane::AUserPane(
		ControlRef inControl,
		bool inDoRetain)
: AControl(inControl,inDoRetain)
{
	static ControlUserPaneDrawUPP drawUPP = NewControlUserPaneDrawUPP(DrawProc);
	static ControlUserPaneHitTestUPP hitTestUPP = NewControlUserPaneHitTestUPP(HitTestProc);
	static ControlUserPaneTrackingUPP trackingUPP = NewControlUserPaneTrackingUPP(TrackingProc);
	static ControlUserPaneIdleUPP idleUPP = NewControlUserPaneIdleUPP(IdleProc);
	static ControlUserPaneKeyDownUPP keyDownUPP = NewControlUserPaneKeyDownUPP(KeyDownProc);
	static ControlUserPaneActivateUPP activateUPP = NewControlUserPaneActivateUPP(ActivateProc);
	static ControlUserPaneFocusUPP focusUPP = NewControlUserPaneFocusUPP(FocusProc);
	
	SetData(kControlEntireControl,kControlUserPaneDrawProcTag,drawUPP);
	SetData(kControlEntireControl,kControlUserPaneHitTestProcTag,hitTestUPP);
	SetData(kControlEntireControl,kControlUserPaneTrackingProcTag,trackingUPP);
	SetData(kControlEntireControl,kControlUserPaneIdleProcTag,idleUPP);
	SetData(kControlEntireControl,kControlUserPaneKeyDownProcTag,keyDownUPP);
	SetData(kControlEntireControl,kControlUserPaneActivateProcTag,activateUPP);
	SetData(kControlEntireControl,kControlUserPaneFocusProcTag,focusUPP);
	
	SetProperty('ACEL','obj ',this);
}

// ---------------------------------------------------------------------------

AUserPane::~AUserPane()
{
	static const Size procPtrSize = sizeof(ControlUserPaneDrawUPP);
	static const UInt32 nullValue = NULL;
	
	try {
		SetData(kControlEntireControl,kControlUserPaneDrawProcTag,procPtrSize,&nullValue);
		SetData(kControlEntireControl,kControlUserPaneHitTestProcTag,procPtrSize,&nullValue);
		SetData(kControlEntireControl,kControlUserPaneTrackingProcTag,procPtrSize,&nullValue);
		SetData(kControlEntireControl,kControlUserPaneIdleProcTag,procPtrSize,&nullValue);
		SetData(kControlEntireControl,kControlUserPaneKeyDownProcTag,procPtrSize,&nullValue);
		SetData(kControlEntireControl,kControlUserPaneActivateProcTag,procPtrSize,&nullValue);
		SetData(kControlEntireControl,kControlUserPaneFocusProcTag,procPtrSize,&nullValue);
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------

AUserPane*
AUserPane::ObjectPtr(
		ControlRef inControl)
{
	AUserPane *object = NULL;
	AControl control(inControl);
	
	control.GetProperty('ACEL','obj ',object);
	return object;
}

// ---------------------------------------------------------------------------

pascal void
AUserPane::DrawProc(
		ControlRef inControl,
		SInt16 inPart)
{
	AUserPane *object = ObjectPtr(inControl);
	
	if (object != NULL)
		object->Draw(inPart);
}

// ---------------------------------------------------------------------------

pascal ControlPartCode
AUserPane::HitTestProc(
		ControlRef inControl,
		Point inWhere)
{
	AUserPane *object = ObjectPtr(inControl);
	ControlPartCode result = kControlNoPart;
	
	if (object != NULL)
		result = object->HitTest(inWhere);
	return result;
}

// ---------------------------------------------------------------------------

pascal ControlPartCode
AUserPane::TrackingProc(
		ControlRef inControl,
		Point inStartPt,
		ControlActionUPP inActionProc)
{
	AUserPane *object = ObjectPtr(inControl);
	ControlPartCode result = kControlNoPart;
	
	if (object != NULL)
		result = object->Tracking(inStartPt,inActionProc);
	return result;
}

// ---------------------------------------------------------------------------

pascal void
AUserPane::IdleProc(
		ControlRef inControl)
{
	AUserPane *object = ObjectPtr(inControl);
	
	if (object != NULL)
		object->Idle();
}

// ---------------------------------------------------------------------------

pascal ControlPartCode
AUserPane::KeyDownProc(
		ControlRef inControl,
		SInt16 inKeyCode,
		SInt16 inCharCode,
		SInt16 inModifiers)
{
	AUserPane *object = ObjectPtr(inControl);
	ControlPartCode result = kControlNoPart;
	
	if (object != NULL)
		result = object->KeyDown(inKeyCode,inCharCode,inModifiers);
	return result;
}

// ---------------------------------------------------------------------------

pascal void
AUserPane::ActivateProc(
		ControlRef inControl,
		Boolean inActivating)
{
	AUserPane *object = ObjectPtr(inControl);
	
	if (object != NULL)
		object->Activate(inActivating);
}

// ---------------------------------------------------------------------------

pascal ControlPartCode
AUserPane::FocusProc(
		ControlRef inControl,
		ControlFocusPart inAction)
{
	AUserPane *object = ObjectPtr(inControl);
	ControlPartCode result = kControlNoPart;
	
	if (object != NULL)
		result = object->Focus(inAction);
	return result;
}
