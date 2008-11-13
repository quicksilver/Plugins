#include "AMTextControl.h"
#include "AWindow.h"

// ---------------------------------------------------------------------------

AMTextControl::AMTextControl(
		ControlRef inControl,
		TXNFrameOptions inOptions,
		TXNFrameType inFrameType,
		TXNFileType inFileType,
		TXNPermanentTextEncodingType inEncoding)
: AControlHandler(inControl),
  mControl(inControl),
  mEditor(
  		mControl.OwnerWindow(),mControl.Bounds(),
  		inOptions,inFrameType,inFileType,inEncoding)
{
	static const EventTypeSpec events[] = {
			{ kEventClassControl,kEventControlDispose },
			{ kEventClassControl,kEventControlDraw },
			{ kEventClassControl,kEventControlClick },
			{ kEventClassControl,kEventControlBoundsChanged },
			{ kEventClassControl,kEventControlSetFocusPart },
			{ kEventClassControl,kEventControlGetFocusPart },
			{ kEventClassControl,kEventControlActivate },
			{ kEventClassControl,kEventControlDeactivate } };
	
	AddTypes(events,8);
}

// ---------------------------------------------------------------------------
// Dispose: the control has received a dispose event

bool
AMTextControl::Dispose()
{
	delete this;
	return true;
}

// ---------------------------------------------------------------------------

bool
AMTextControl::Draw(
		const AParam<>::ControlPart &,
		const AParam<>::Port &)
{
/*
	GrafPtr port;
	
	if (inGrafPort.Exists())
		port = inGrafPort;
	else
		port = ::GetWindowPort(mControl.OwnerWindow());
*/
	mEditor.Draw(NULL);
	
	Rect bounds = mControl.Bounds();
	
	if (AWindow(mControl.OwnerWindow()).Attributes() & kWindowCompositingAttribute)
		::OffsetRect(&bounds,-bounds.left,-bounds.top);
//	::InsetRect(&bounds,1,1);
	::DrawThemeEditTextFrame(&bounds,mControl.IsActive() ? kThemeStateActive : kThemeStateInactive);
	
	return true;
}

// ---------------------------------------------------------------------------

bool
AMTextControl::Track(
		Point,
		AParam<AReadWrite>::Modifiers &,
		AParam<AWriteOnly>::ControlPart &outPart)
{
	EventRecord eventRecord;
	
	ConvertEventRefToEventRecord(GetCurrentEvent(),&eventRecord);
	mEditor.Click(eventRecord);
	outPart = kControlEditTextPart;
	return true;
}

// ---------------------------------------------------------------------------
// BoundsChanged: the control is being resized

bool
AMTextControl::BoundsChanged(
		UInt32,
		const Rect &,
		const Rect &,
		const Rect &inCurrentBounds)
{
	mEditor.SetFrameBounds(inCurrentBounds);
	return true;
}

// ---------------------------------------------------------------------------

bool
AMTextControl::SetFocusPart(
		AParam<AReadWrite>::ControlPart &ioFocusPart)
{
	if (ioFocusPart == kControlNoPart)
		mEditor.Focus(false);
	else {
		mEditor.Focus(true);
		ioFocusPart = kControlEditTextPart;
	}
	return true;
}

// ---------------------------------------------------------------------------

bool
AMTextControl::GetFocusPart(
		AParam<AWriteOnly>::ControlPart &outFocusPart)
{
	outFocusPart = kControlEditTextPart;
	return true;
}

// ---------------------------------------------------------------------------

bool
AMTextControl::Activate()
{
	mEditor.Activate();
	return true;
}

// ---------------------------------------------------------------------------

bool
AMTextControl::Deactivate()
{
	mEditor.Focus(false);
	return true;
}
