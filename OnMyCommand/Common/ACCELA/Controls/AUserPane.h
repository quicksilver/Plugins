#include "AControl.h"

#pragma warn_unusedarg off

class AUserPane :
		public AControl
{
public:
		AUserPane(
				ControlRef inControl,
				bool inDoRetain = true);
	virtual
		~AUserPane();
	
protected:
	virtual void
		Draw(
				SInt16 inPart) {}
	virtual ControlPartCode
		HitTest(
				Point inWhere)
		{ return kControlNoPart; }
	virtual ControlPartCode
		Tracking(
				Point inStartPt,
				ControlActionUPP inActionProc)
		{ return kControlNoPart; }
	virtual void
		Idle() {}
	virtual ControlPartCode
		KeyDown(
				SInt16 inKeyCode,
				SInt16 inCharCode,
				SInt16 inModifiers)
		{ return kControlNoPart; }
	virtual void
		Activate(
				bool inActivating) {}
	virtual ControlPartCode
		Focus(
				ControlFocusPart inAction)
		{ return kControlNoPart; }
	
	static AUserPane*
		ObjectPtr(
				ControlRef inControl);
	
	// callbacks
	static pascal void
		DrawProc(
				ControlRef inControl,
				SInt16 inPart);
	static pascal ControlPartCode
		HitTestProc(
				ControlRef inControl,
				Point inWhere);
	static pascal ControlPartCode
		TrackingProc(
				ControlRef inControl,
				Point inStartPt,
				ControlActionUPP inActionProc);
	static pascal void
		IdleProc(
				ControlRef inControl);
	static pascal ControlPartCode
		KeyDownProc(
				ControlRef inControl,
				SInt16 inKeyCode,
				SInt16 inCharCode,
				SInt16 inModifiers);
	static pascal void
		ActivateProc(
				ControlRef inControl,
				Boolean inActivating);
	static pascal ControlPartCode
		FocusProc(
				ControlRef inControl,
				ControlFocusPart inAction);
};

#pragma warn_unusedarg reset
