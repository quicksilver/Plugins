// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AApplication.h"

// ---------------------------------------------------------------------------

AApplication::AApplication()
: AEventObject(kApplication)
{
}

// ---------------------------------------------------------------------------

OSStatus
AApplication::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	outEventHandled = false;
	if (inEvent.Class() == kEventClassApplication)
		switch (inEvent.Kind()) {
			
			case kEventAppActivated:
				outEventHandled = Activated(AParam<>::Window(inEvent));
				break;
			
			case kEventAppDeactivated:
				outEventHandled = Deactivated();
				break;
			
			case kEventAppQuit:
				outEventHandled = Quit();
				break;
			
			case kEventAppLaunchNotification:
				outEventHandled = LaunchNotification(
						AEventParameter<ProcessSerialNumber>(inEvent,kEventParamProcessID,typeProcessSerialNumber),
						ATypeParam<>::UInt32(inEvent,kEventParamLaunchRefCon),
						AEventParameter<OSStatus>(inEvent,kEventParamLaunchErr,typeOSStatus));
				break;
			
			case kEventAppLaunched:
				outEventHandled = AppLaunched(
						AEventParameter<ProcessSerialNumber>(inEvent,kEventParamProcessID,typeProcessSerialNumber));
				break;
			
			case kEventAppTerminated:
				outEventHandled = AppTerminated(
						AEventParameter<ProcessSerialNumber>(inEvent,kEventParamProcessID,typeProcessSerialNumber));
				break;
			
			case kEventAppFrontSwitched:
				outEventHandled = FrontSwitched(
						AEventParameter<ProcessSerialNumber>(inEvent,kEventParamProcessID,typeProcessSerialNumber));
				break;
			
			case kEventAppFocusMenuBar:
				outEventHandled = FocusMenuBar(AParam<>::Modifiers(inEvent));
				break;
			
			case kEventAppFocusNextDocumentWindow:
				outEventHandled = FocusNextDocumentWindow(AParam<>::Modifiers(inEvent));
				break;
			
			case kEventAppFocusNextFloatingWindow:
				outEventHandled = FocusNextFloatingWindow(AParam<>::Modifiers(inEvent));
				break;
			
			case kEventAppFocusToolbar:
				outEventHandled = FocusToolbar(AParam<>::Modifiers(inEvent));
				break;
			
			case kEventAppGetDockTileMenu:
				{
					AParam<AWriteOnly>::Menu dockTileMenu(inEvent);
					
					outEventHandled = GetDockTileMenu(dockTileMenu);
				}
				break;
			
			case kEventAppHidden:
				outEventHandled = Hidden();
				break;
			
			case kEventAppShown:
				outEventHandled = Shown();
				break;
			
			case kEventAppSystemUIModeChanged:
				outEventHandled = SystemUIModeChanged(
						ATypeParam<>::UInt32(inEvent,kEventParamSystemUIMode));
				break;
	}
	return noErr;
}

// ---------------------------------------------------------------------------

void
AApplication::Run()
{
	::RunApplicationEventLoop();
}
