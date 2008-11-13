// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "CCarbonWindowAttachment.h"

#include "AProcess.h"
#include "AEventParameter.h"

#include "CCMArea.h"
#include "CCMWindow.h"

#include "TRegisterer.h"

#include <LWindow.h>
#include <LEventDispatcher.h>
#include <UDrawingState.h>
#include <UEnvironment.h>

static TRegisterer<CCarbonWindowAttachment> gRegisterCarbonWindowAttachment;

// ---------------------------------------------------------------------------

CCarbonWindowAttachment::CCarbonWindowAttachment(
		LStream *inStream)
: LAttachment(inStream),
  AWindowHandler(NULL),
  mEventTypes(*this),mWindow(NULL)
{
	mMessage = msg_FinishCreate;
	
	if (mOwnerHost != NULL) {
		static const int kEventTypeCount = 13;
		static const EventTypeSpec kEventTypes[kEventTypeCount] = {
				{ kEventClassWindow,kEventWindowDrawContent },
				{ kEventClassWindow,kEventWindowActivated },
				{ kEventClassWindow,kEventWindowDeactivated },
				{ kEventClassWindow,kEventWindowBoundsChanged },
				{ kEventClassWindow,kEventWindowClickContentRgn },
//				{ kEventClassWindow,kEventWindowClickResizeRgn },
				{ kEventClassWindow,kEventWindowContextualMenuSelect },
				{ kEventClassWindow,kEventWindowGetIdealSize },
				{ kEventClassWindow,kEventWindowGetMinimumSize },
				{ kEventClassWindow,kEventWindowGetMaximumSize },
				{ kEventClassWindow,kEventWindowClose },
				{ kEventClassWindow,kEventWindowZoom },
				{ kEventClassWindow,kEventWindowGetClickActivation },
				{ kEventClassMouse,kEventMouseDown }
		};
		
		LWindow *window = dynamic_cast<LWindow*>(mOwnerHost);
		
		if (window != NULL) {
			WindowRef windowRef;
			
			mWindow = reinterpret_cast<LWindow*>(window);
			windowRef = mWindow->GetMacWindow();
			::InstallStandardEventHandler(::GetWindowEventTarget(windowRef));
			InstallHandler(windowRef);
			mEventTypes.AddTypes(kEventTypes,kEventTypeCount);
			
			if (UEnvironment::GetOSVersion() < 0x1000)
				mEventTypes.AddType(kEventClassWindow,kEventWindowClickResizeRgn);
		}
	}
}

// ---------------------------------------------------------------------------

CCarbonWindowAttachment::~CCarbonWindowAttachment()
{
	// If the window is already gone, then assume my EventHandlerRef is invalid
	if ((mWindow != NULL) && (mWindow->GetMacWindow() == NULL))
		mEventHandlerRef = NULL;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::Update()
{
	if (mWindow->IsVisible())
		mWindow->UpdatePort();
	else
		mWindow->Refresh();
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::DrawContent()
{
	CCMWindow *ccmWindow = NULL;
	
	if (!mWindow->IsVisible()) {
		ccmWindow = dynamic_cast<CCMWindow*>(mWindow);
		if (ccmWindow != NULL)
			ccmWindow->BeVisible();
		else {
			mWindow->Refresh();
			return true;	// ...?
		}
	}
	
	{
		::SetOrigin(0,0);
		mWindow->OutOfFocus(NULL);
		mWindow->Draw(NULL);
		mWindow->OutOfFocus(NULL);
	}
	
	if (ccmWindow != NULL)
		ccmWindow->BeInvisible();
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::Activated()
{
	mWindow->Activate();
	LCommander::SetUpdateCommandStatus(true);
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::Deactivated()
{
	mWindow->Deactivate();
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::Close()
{
	mWindow->ProcessCommand(cmd_Close);
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::Zoom()
{
	Rect bounds;
	
	mWindow->DoSetZoom(!mWindow->CalcStandardBounds(bounds));
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::BoundsChanged(
		UInt32 inAttributes,
		const Rect &,	// inOriginalBounds
		const Rect &,	// inPreviousBounds
		const Rect &inCurrentBounds)
{
	bool eventHandled = false;
	
	if ((UEnvironment::GetOSVersion() >= 0x1000)  &&
		(inAttributes & kWindowBoundsChangeSizeChanged)) {
    	StPortOriginState savePort(mWindow->GetMacPort());
		
		eventHandled = true;
		LView::OutOfFocus(NULL);
		mWindow->DoSetBounds(inCurrentBounds);
		mWindow->UpdatePort();
		::QDFlushPortBuffer(mWindow->GetMacPort(),NULL);
	}
	return eventHandled;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::ClickContent(
		Point inMouse,
		UInt32 inModifiers)
{
	EventRecord clickEvent = {
			mouseDown,0,::EventTimeToTicks(GetHandledEventTime()),inMouse,inModifiers };
	bool wasHilited = ::IsWindowHilited(mWindow->GetMacWindow());
	
	if (::IsWindowUpdatePending(mWindow->GetMacWindow()))
		mWindow->UpdatePort();
	mWindow->ClickInContent(clickEvent);
	
	if (!::StillDown() && !wasHilited && !::IsWindowHilited(mWindow->GetMacWindow())) {
		const EventTypeSpec kMouseUpType = { kEventClassMouse,kEventMouseUp };
		EventRef mouseUpEvent;
		
		if (::ReceiveNextEvent(1,&kMouseUpType,kEventDurationNoWait,false,&mouseUpEvent) == noErr) {
			ACarbonEvent event(mouseUpEvent);
			AParam<>::Mouse mouse(event);
			WindowRef hitWindow;
			
			::FindWindow(mouse,&hitWindow);
			if (hitWindow == mWindow->GetMacWindow()) {
				AProcess frontProcess,currentProcess(kCurrentProcess);
				
				::GetFrontProcess(&frontProcess);
				if (frontProcess != currentProcess)
					currentProcess.SetFront();
				mWindow->Select();
			}
		}
	}
	
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::ClickResize(
		Point inMouse,
		UInt32 inModifiers)
{
	EventRecord clickEvent = {
			mouseDown,0,::EventTimeToTicks(GetHandledEventTime()),
			inMouse,inModifiers };
	
	mWindow->ClickInGrow(clickEvent);
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::GetClickActivation(
		Point inWhere,
		UInt32 inModifiers,
		AParam<AWriteOnly>::ClickActivation &outClickActivation)
{
	bool handled = false;
	
	// Contextual menu click: activate and handle
	if ((inModifiers & controlKey) || ::IsShowContextualMenuEvent(GetCurrentEvent())) {
		outClickActivation = kActivateAndHandleClick;
		handled = true;
	}
	else {
		WindowRef windowRef;
		WindowPartCode partCode = ::FindWindow(inWhere,&windowRef);
		
		// Only check content clicks
		if ((partCode == inContent) && (windowRef == mWindow->GetMacWindow())) {
			mWindow->GlobalToPortPoint(inWhere);
			
			// Floating window: activate and handle
			if (mWindow->HasAttribute(windAttr_Floating) && (UDesktop::FetchTopModal() == NULL))
				outClickActivation = kActivateAndHandleClick;
			// Click in background: activate and ignore
			else if (mWindow->FindSubPaneHitBy(inWhere.h,inWhere.v) == NULL)
				outClickActivation = kActivateAndIgnoreClick;
			// GetSelectClick or DelaySelect: handle and don't activate
			else if (mWindow->HasAttribute(windAttr_GetSelectClick|windAttr_DelaySelect))
				outClickActivation = kDoNotActivateAndHandleClick;
			// Hit no panes: activate and ignore
			else
				outClickActivation = kActivateAndIgnoreClick;
			handled = true;
		}
	}
	return handled;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::ContextualMenuSelect(
		Point inMouse,
		UInt32 inModifiers)
{
	bool eventHandled = true;
	SMouseDownEvent cmMouseDown = {
			inMouse, { 0,0 },
			{ mouseDown,0,::EventTimeToTicks(GetHandledEventTime()),
			  inMouse,inModifiers|controlKey },
			false };
	
	if (!mWindow->IsActive()) {
		if (!UDesktop::FrontWindowIsModal()) {  
			UDesktop::SelectDeskWindow(mWindow);
			mWindow->Activate();
			mWindow->UpdatePort();
		}
	}
	
	mWindow->GlobalToPortPoint(cmMouseDown.wherePort);
	cmMouseDown.whereLocal = cmMouseDown.wherePort;
	
	LPane *hitPane = mWindow->FindDeepSubPaneContaining(cmMouseDown.whereLocal.h,cmMouseDown.whereLocal.v);
	CCMArea *area;
	
	if (hitPane != NULL) {
		area = dynamic_cast<CCMArea*>(hitPane);
		if (area == NULL) {
			LView *superView;
			
			UCMArea::FindSuperCMArea(hitPane,area,superView);
		}
	}
	else
		area = dynamic_cast<CCMArea*>(mWindow);
	
	if (area)
		area->CMClick(cmMouseDown);
	else
		eventHandled = false;
	
	return eventHandled;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::GetIdealSize(
		AParam<AWriteOnly>::Dimensions &outSize)
{
	Rect idealRect;
	
	mWindow->CalcStandardBounds(idealRect);
	
	Point windowSize = {
			idealRect.bottom-idealRect.top,
			idealRect.right-idealRect.left };
	
	outSize = windowSize;
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::GetMinimumSize(
		AParam<AWriteOnly>::Dimensions &outSize)
{
	Rect minMaxSize;
	
	mWindow->GetMinMaxSize(minMaxSize);
	
	Point windowSize = { minMaxSize.top,minMaxSize.left };
	
	outSize = windowSize;
	return true;
}

// ---------------------------------------------------------------------------

bool
CCarbonWindowAttachment::GetMaximumSize(
		AParam<AWriteOnly>::Dimensions &outSize)
{
	Rect minMaxSize;
	
	mWindow->GetMinMaxSize(minMaxSize);
	
	Point windowSize = { minMaxSize.bottom,minMaxSize.right };
	
	outSize = windowSize;
	return true;
}

// ---------------------------------------------------------------------------

OSStatus
CCarbonWindowAttachment::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	OSStatus err = noErr;
	
	// Right-clicks should get reported by the standard handler, but they don't
	// Maybe it's because I'm handling ClickContentRgn instead of HandleContentClick
	if (inEvent.Class() == kEventClassMouse) {
		if (inEvent.Kind() == kEventMouseDown) {
			const EventMouseButton button = AEventParameter<EventMouseButton>(inEvent,kEventParamMouseButton,typeMouseButton);
			const UInt32 modifiers = AParam<>::Modifiers(inEvent);
			
			if ((button == kEventMouseButtonSecondary) ||
				(modifiers & controlKey) ||
				(::IsShowContextualMenuEvent(inEvent))) {
				ContextualMenuSelect(AParam<>::Mouse(inEvent),modifiers);
				outEventHandled = true;
			}
		}
	}
	if (!outEventHandled)
		err = AWindowHandler::HandleEvent(inEvent,outEventHandled);
	
	if (LCommander::GetUpdateCommandStatus()) {
		LEventDispatcher::GetCurrentEventDispatcher()->UpdateMenus();
		LCommander::SetUpdateCommandStatus(false);
	}
	
	return err;
}
