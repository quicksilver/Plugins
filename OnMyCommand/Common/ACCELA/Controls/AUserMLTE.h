#include "AUserPane.h"
#include "AControlHandler.h"
#include "ATextEditor.h"

class AUserMLTE :
		public AUserPane,
		public ATextEditor,
		public AControlHandler
{
public:
		AUserMLTE(
				ControlRef inControl,
				TXNFrameOptions inOptions = 0);
	
protected:
	bool mHasFocus;
	Rect mFocusBounds;
	
	// AUserpane
	
	virtual void
		Draw(
				SInt16 inPart);
	virtual ControlPartCode
		HitTest(
				Point inWhere);
	virtual ControlPartCode
		Tracking(
				Point inStartPt,
				ControlActionUPP inActionProc);
	virtual void
		Idle();
	virtual ControlPartCode
		KeyDown(
				SInt16 inKeyCode,
				SInt16 inCharCode,
				SInt16 inModifiers);
	virtual void
		Activate(
				bool inActivating);
	virtual ControlPartCode
		Focus(
				ControlFocusPart inAction);
	
	// AControlHandler
	
	virtual bool
		BoundsChanged(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds);
};
