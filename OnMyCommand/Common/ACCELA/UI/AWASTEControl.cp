#include "AWASTEControl.h"
#include "ARegion.h"
#include "AGrafPort.h"

// ---------------------------------------------------------------------------

class ChatTextRect :
		public LongRect
{
public:
		ChatTextRect(
				const Rect &inRect);
};

ChatTextRect::ChatTextRect(
		const Rect &inRect)
{
	SInt32 scrollSize;
	
	::WERectToLongRect(&inRect,this);
	::GetThemeMetric(kThemeMetricScrollBarWidth,&scrollSize);
	right -= scrollSize+4;
	left += 4;
}

// ---------------------------------------------------------------------------

class ChatScrollRect :
		public Rect
{
public:
		ChatScrollRect(
				const Rect &inRect);
};

ChatScrollRect::ChatScrollRect(
		const Rect &inRect)
{
	SInt32 scrollSize;
	
	::GetThemeMetric(kThemeMetricScrollBarWidth,&scrollSize);
	top = inRect.top;
	bottom = inRect.bottom;
	right = inRect.right;
	left = inRect.right - scrollSize;
}

// ---------------------------------------------------------------------------

class ALongRect :
		public LongRect
{
public:
		ALongRect(
				const Rect &inRect);
};

ALongRect::ALongRect(
		const Rect &inRect)
{
	::WERectToLongRect(&inRect,this);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AWASTEControl::AWASTEControl(
		ControlRef inControl,
		OptionBits inOptions)
: AControlHandler(inControl),
  ATextInputHandler(inControl),
  mControlTypes(*(AControlHandler*)this),
  mTextTypes(*(ATextInputHandler*)this),
  mControl(inControl),
  mEditor(::GetWindowPort(mControl.OwnerWindow()),ChatTextRect(mControl.Bounds()),ChatTextRect(mControl.Bounds()),inOptions),
  mScrollBar(*this,mControl),
  mLineHeight(mEditor.LineHeight(0,1))
{
	EventTypeSpec eventTypes[] = {
			{ kEventClassControl,kEventControlBoundsChanged },
			{ kEventClassControl,kEventControlDraw },
			{ kEventClassControl,kEventControlActivate },
			{ kEventClassControl,kEventControlDeactivate },
			{ kEventClassControl,kEventControlSetCursor },
			{ kEventClassControl,kEventControlClick },
			{ kEventClassControl,kEventControlDragEnter },
			{ kEventClassControl,kEventControlDragWithin },
			{ kEventClassControl,kEventControlDragLeave },
			{ kEventClassControl,kEventControlDragReceive } };
	
	mControlTypes.AddTypes(eventTypes,10);
	mTextTypes.AddType(kEventClassTextInput,kEventTextInputUnicodeForKeyEvent);
	
	mScrollBar.Embed(mControl);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

bool
AWASTEControl::BoundsChanged(
		UInt32,
		const Rect &,
		const Rect &,
		const Rect &inCurrentBounds)
{
	mEditor.SetViewRect(ALongRect(inCurrentBounds));
	mEditor.CalText();
	return true;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::Draw(
		const AParam<>::ControlPart &,
		const AParam<>::Port &inPort)
{
	Rect bounds = mControl.Bounds();
	CGrafPtr drawPort;
	WindowPtr ownerWindow = mControl.OwnerWindow();
	
	if (inPort.Exists())
		drawPort = inPort;
	else
		drawPort = ::GetWindowPort(ownerWindow);
	
	StSetPort setPort(drawPort);
	
	::BackColor(whiteColor);
	::SetThemeWindowBackground(ownerWindow,kThemeBrushWhite,false);
	::EraseRect(&bounds);
	mEditor.Update(ARegion(bounds));
	::DrawThemeEditTextFrame(&bounds,kThemeStateActive);
	::SetThemeWindowBackground(ownerWindow,kThemeBrushModelessDialogBackgroundActive,false);
	return true;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::Activate()
{
	Rect bounds = mControl.Bounds();
	
	// or perhaps it should activate when it gets focus
	mEditor.Activate();
	::InvalWindowRect(mControl.OwnerWindow(),&bounds);
	return true;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::Deactivate()
{
	Rect bounds = mControl.Bounds();
	
	mEditor.Activate();
	::InvalWindowRect(mControl.OwnerWindow(),&bounds);
	return true;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::SetCursor(
		Point inMouse,
		UInt32)
{
	mEditor.AdjustCursor(inMouse,ARegion());
	return true;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::Click(
		Point inMouse,
		UInt32 inModifiers)
{
	Rect bounds = mControl.Bounds();
	
	inMouse.h -= bounds.left;
	inMouse.v -= bounds.top;
	mEditor.Click(inMouse,inModifiers,EventTimeToTicks(GetHandledEventTime()));
	return true;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::DragEnter(
		DragRef inDragRef)
{
	// or should it be EnterWindow?
	return mEditor.TrackDrag(kDragTrackingEnterHandler,inDragRef) == noErr;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::DragWithin(
		DragRef inDragRef)
{
	return mEditor.TrackDrag(kDragTrackingInWindow,inDragRef) == noErr;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::DragLeave(
		DragRef inDragRef)
{
	return mEditor.TrackDrag(kDragTrackingLeaveHandler,inDragRef) == noErr;
}

// ---------------------------------------------------------------------------

bool
AWASTEControl::DragReceive(
		DragRef inDragRef)
{
	return mEditor.ReceiveDrag(inDragRef) == noErr;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

bool
AWASTEControl::UnicodeForKeyEvent(
		ComponentInstance,
		long,
		const ScriptLanguageRecord &,
		const UniChar *inText,
		Size inTextSize,
		EventRef)
{
	SInt32 selStart,selEnd;
	
	mEditor.GetSelection(selStart,selEnd);
	mEditor.Put(selStart,selEnd,inText,inTextSize,kTextEncodingUnicodeDefault,0);
	return true;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
AWASTEControl::PostDraw()
{
	Rect bounds = mControl.Bounds();
	
	::DrawThemeEditTextFrame(&bounds,mControl.IsActive() ? kThemeStateActive : kThemeStateInactive);
	::SetThemeWindowBackground(mControl.OwnerWindow(),kThemeBrushModelessDialogBackgroundActive,false);
}

// ---------------------------------------------------------------------------

void
AWASTEControl::TrackScrollBar(
		ControlPartCode inPart)
{
	SInt16 dist = 1;
	
	if ((inPart == kControlPageUpPart) || (inPart == kControlPageDownPart)) {
		// whole page
	}
	if ((inPart == kControlUpButtonPart) || (inPart == kControlPageUpPart))
		dist = -dist;
	
	SInt32 value = mScrollBar.Value();
	
	mScrollBar.SetValue(value + dist);
	mScrollBar.Draw();
	
	mEditor.PinScroll(0,dist*mLineHeight);
	mEditor.Update(ARegion(mControl.Bounds()));
	PostDraw();
}

// ---------------------------------------------------------------------------

void
AWASTEControl::AdjustScrollBar()
{
	LongRect destRect,viewRect;
	
	mEditor.GetDestRect(destRect);
	mEditor.GetViewRect(viewRect);
	mScrollBar.SetValue((destRect.top-viewRect.top)/mLineHeight);
	mScrollBar.SetViewSize((destRect.bottom-destRect.top)/mLineHeight);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AWASTEControl::WScrollBar::WScrollBar(
			AWASTEControl &inWASTEControl,
			AControl &inControl)
: AScrollBar(inControl.OwnerWindow(),ScrollBarRect(inControl),0,0,0,0,true),
  mWASTEControl(inWASTEControl)
{
}

// ---------------------------------------------------------------------------

Rect
AWASTEControl::WScrollBar::ScrollBarRect(
		const AControl &inControl)
{
	SInt32 scrollSize;
	Rect bounds = inControl.Bounds();
	
	::GetThemeMetric(kThemeMetricScrollBarWidth,&scrollSize);
	bounds.left = bounds.right-scrollSize;
	return bounds;
}
