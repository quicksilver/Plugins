#include "AControl.h"
#include "AControlHandler.h"
#include "ATextEditor.h"
#include "AToolboxClass.h"

#include FW(Carbon,MacTextEditor.h) 

class AMTextControl :
		public AControlHandler
{
public:
		AMTextControl(
				ControlRef inControl,
				TXNFrameOptions inOptions = 0,
				TXNFrameType inFrameType = kTXNTextEditStyleFrameType,
				TXNFileType inFileType = kTXNTextensionFile,
				TXNPermanentTextEncodingType inEncoding = kTXNSystemDefaultEncoding);
	
	void
		AttachToWindow(
				WindowRef inWindow)
		{ mEditor.AttachToWindow(inWindow); }

protected:
	AControl mControl;
	ATextEditor mEditor;
	
	// AControlHandler
	
	virtual bool
		Dispose();
	virtual bool
		Draw(
				const AParam<>::ControlPart &inPart,
				const AParam<>::Port &inGrafPort);
	virtual bool
		Track(
				Point inMouse,
				AParam<AReadWrite>::Modifiers &ioModifiers,
				AParam<AWriteOnly>::ControlPart &outPart);
	virtual bool
		BoundsChanged(
				UInt32 inAttributes,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds);
	virtual bool
		SetFocusPart(
				AParam<AReadWrite>::ControlPart &ioFocusPart);
	virtual bool
		GetFocusPart(
				AParam<AWriteOnly>::ControlPart &outFocusPart);
	virtual bool
		Activate();
	virtual bool
		Deactivate();
};
