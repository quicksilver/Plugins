#include "AUserMLTE.h"
#include "AGrafPort.h"
#include "ARegion.h"
#include "AWindow.h"

static Rect
InsetTextRect(
		const Rect &inRect)
{
	Rect inset = inRect;
	
	::InsetRect(&inset,1,1);
	return inset;
}

// ---------------------------------------------------------------------------

AUserMLTE::AUserMLTE(
				ControlRef inControl,
				TXNFrameOptions inOptions)
: AUserPane(inControl),
  ATextEditor(OwnerWindow(),InsetTextRect(Bounds()),inOptions),
  AControlHandler(inControl),
  mHasFocus(false)
{
	AddType(kEventClassControl,kEventControlBoundsChanged);
}

// ---------------------------------------------------------------------------

void
AUserMLTE::Draw(
		SInt16)
{
	StSetPort setPort(::GetWindowPort(OwnerWindow()));
	Rect bounds = Bounds();
	
	::EraseRect(&bounds);
	ATextEditor::Draw();
	::DrawThemeListBoxFrame(&bounds,IsActive() ? kThemeStateActive: kThemeStateInactive);
	if (mHasFocus)
		::DrawThemeFocusRect(&bounds,true);
}

// ---------------------------------------------------------------------------

ControlPartCode
AUserMLTE::HitTest(
		Point inWhere)
{
	Rect bounds = Bounds();
	ControlPartCode result = kControlNoPart;
	
	if (::PtInRect(inWhere,&bounds))
		result = kControlEditTextPart;
	return result;
}

// ---------------------------------------------------------------------------

ControlPartCode
AUserMLTE::Tracking(
		Point inStartPt,
		ControlActionUPP)
{
	// make sure it's focused
	if (!mHasFocus) {
		AWindow owner(OwnerWindow());
		
		owner.ClearFocus();
		owner.SetFocus(*this,kControlEditTextPart);
	}
	
	ControlPartCode hitPart = HitTest(inStartPt);
	
	if (hitPart == kControlEditTextPart) {
		StSetPort setPort(::GetWindowPort(OwnerWindow()));
		EventRecord event = {
				mouseDown,0,::TickCount(),
				inStartPt,::GetCurrentEventKeyModifiers() };
		
		ATextEditor::Click(event);
	}
	return hitPart;
}

// ---------------------------------------------------------------------------

void
AUserMLTE::Idle()
{
	ARegion cursorRegion(Bounds());
	
	AdjustCursor(cursorRegion);
}

// ---------------------------------------------------------------------------

ControlPartCode
AUserMLTE::KeyDown(
		SInt16 inKeyCode,
		SInt16 inCharCode,
		SInt16 inModifiers)
{
	EventRecord event = {
			keyDown,(inKeyCode << 16) | inCharCode,::TickCount(),{0,0},inModifiers };
	
	ATextEditor::KeyDown(event);
	return kControlEditTextPart;
}

// ---------------------------------------------------------------------------

void
AUserMLTE::Activate(
		bool inActivating)
{
	StSetPort setPort(::GetWindowPort(OwnerWindow()));
	
	ATextEditor::Activate(inActivating);
	ATextEditor::Focus(mHasFocus);
	
	Rect bounds = Bounds();
	
	::DrawThemeListBoxFrame(&bounds,inActivating ? kThemeStateActive : kThemeStateInactive);
	if (mHasFocus)
		::DrawThemeFocusRect(&bounds,inActivating);
}

// ---------------------------------------------------------------------------

ControlPartCode
AUserMLTE::Focus(
		ControlFocusPart inAction)
{
	ControlPartCode result = kControlNoPart;
	
	switch (inAction) {
		
		case kControlEditTextPart:
			result = 1;
			mHasFocus = true;
			ATextEditor::Focus(true);
			break;
		
		case kControlFocusPrevPart:
		case kControlFocusNextPart:
			mHasFocus = !mHasFocus;
			ATextEditor::Focus(mHasFocus);
			if (mHasFocus)
				result = 1;
			break;
		
		case kControlFocusNoPart:
		default:
			mHasFocus = false;
			ATextEditor::Focus(false);
	}
	return result;
}

// ---------------------------------------------------------------------------

bool
AUserMLTE::BoundsChanged(
		UInt32,
		const Rect &,
		const Rect &,
		const Rect &inCurrentBounds)
{
	Rect textBounds = inCurrentBounds;
	Rect oldBounds;
	StSetPort setPort(::GetWindowPort(OwnerWindow()));
	
	GetViewRect(oldBounds);
	::InsetRect(&oldBounds,-2,-2);
	::EraseRect(&oldBounds);
	::InsetRect(&textBounds,1,1);
	SetFrameBounds(textBounds);
	return true;
}
