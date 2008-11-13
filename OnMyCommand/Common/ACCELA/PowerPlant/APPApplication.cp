// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "APPApplication.h"
#include "ATimer.h"

#include <LModelDirector.h>
#include <LPeriodical.h>
#include <PP_Resources.h>
#include <UAppleEventsMgr.h>
#include <UCursor.h>
#include <UEnvironment.h>

class APeriodicalTimer : ATimer {
public:
		APeriodicalTimer()
		: ATimer(kEventDurationNoWait,kEventDurationSecond/10) {}
	
protected:
	void
		Time()
		{
			EventRecord event = { nullEvent,0,::TickCount(),{0,0},0 };
			
			LPeriodical::DevoteTimeToRepeaters(event);
			if (::GetNumEventsInQueue(::GetCurrentEventQueue()) == 0)
				LPeriodical::DevoteTimeToIdlers(event);
		}
};

// ---------------------------------------------------------------------------

APPApplication::APPApplication()
{
	sTopCommander = this;
	UEnvironment::InitEnvironment();
	SetUseSubModelList(true);
	SetModelKind(cApplication);
	
	mPeriodicalTimer = new APeriodicalTimer;
}

// ---------------------------------------------------------------------------

APPApplication::~APPApplication()
{
	delete mPeriodicalTimer;
}

// ---------------------------------------------------------------------------

Boolean
APPApplication::ObeyCommand(
		CommandT inCommand,
		void *ioParam)
{
#pragma unused(ioParam)
	bool handled = true;
	
	switch (inCommand) {
		
		case kHICommandAbout:
			ShowAboutBox();
		
		default:
			handled = LCommander::ObeyCommand(inCommand,ioParam);
	}
	return handled;
}

// ---------------------------------------------------------------------------

void
APPApplication::FindCommandStatus(
		CommandT inCommand,
		Boolean &outEnabled,
		Boolean &outUsesMark,
		UInt16 &outMark,
		Str255 outName)
{
#pragma unused(outUsesMark,outMark,outName)
	switch (inCommand) {
		
		case kHICommandAbout:
		case kHICommandQuit:
			outEnabled = true;
			break;
	}
}

// ---------------------------------------------------------------------------

OSStatus
APPApplication::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	HICommand command;
	OSStatus err = noErr;
	
	switch (inEvent.GetClass()) {
		
		case kEventClassCommand:
			switch (inEvent.GetKind()) {
				
				case kEventCommandProcess:
					outEventHandled = true;
					inEvent.GetParameter(kEventParamDirectObject,typeHICommand,command);
					ObeyCommand(command.commandID,NULL);
					break;
				
				case kEventCommandUpdateStatus: {
					Boolean enabled,usesMark;
					UInt16 mark;
					Str255 itemName;
					
					outEventHandled = true;
					inEvent.GetParameter(kEventParamDirectObject,typeHICommand,command);
					enabled = false;
					usesMark = false;
					mark = noMark;
					itemName[0] = 0;
					GetTarget()->FindCommandStatus(command.commandID,enabled,usesMark,mark,itemName);
					if (enabled)
						::EnableMenuCommand(command.menu.menuRef,command.commandID);
					else
						::DisableMenuCommand(command.menu.menuRef,command.commandID);
					if (usesMark)
						::SetMenuCommandMark(command.menu.menuRef,command.commandID,mark);
					if (itemName[0]) {
						MenuItemIndex itemIndex;
						
						err = ::GetIndMenuItemWithCommandID(command.menu.menuRef,command.commandID,1,NULL,&itemIndex);
						if (err == noErr)
							::SetMenuItemText(command.menu.menuRef,itemIndex,itemName);
					}
				}
			}
			break;
	}
	if (!outEventHandled)
		err = AApplication::HandleEvent(inEvent,outEventHandled);
	return err;
}

// ---------------------------------------------------------------------------

void
APPApplication::HandleAppleEvent(
		const AppleEvent &inAppleEvent,
		AppleEvent &outAEReply,
		AEDesc &outResult,
		SInt32 inAENumber)
{
	switch (inAENumber) {

		case ae_OpenApp:
			StartUp();
			break;

		case ae_ReopenApp:
			DoReopenApp();
			break;
		
		case ae_SwitchTellTarget: {
			StAEDescriptor targD;
			LModelObject *newTarget = NULL;

			targD.GetOptionalParamDesc(inAppleEvent, keyAEData, typeWildCard);
			if (targD.mDesc.descriptorType != typeNull) {
				StAEDescriptor	token;
				LModelDirector::Resolve(targD.mDesc, token.mDesc);
				newTarget = GetModelFromToken(token);
			}

			SetTellTarget(newTarget);
			break;
		}

		case ae_GetData:
		case ae_GetDataSize:
		case ae_SetData:

				// If we reach this point, no other object has handled
				// this get/set event. That means whatever thing the
				// event is trying to get/set doesn't exist or isn't
				// supported.

			Throw_(errAEEventNotHandled);
			break;

		default:
			LModelObject::HandleAppleEvent(inAppleEvent,outAEReply,outResult,inAENumber);
			break;
	}
}

// ---------------------------------------------------------------------------

void
APPApplication::MakeMenuBar()
{
	MenuBarHandle menuBar;
	
	menuBar = ::GetNewMBar(MBAR_Initial);
	::SetMenuBar(menuBar);
	::DisposeMenuBar(menuBar);
}

// ---------------------------------------------------------------------------

void
APPApplication::MakeModelDirector()
{
	new LModelDirector(this);
}

// ---------------------------------------------------------------------------

void
APPApplication::Run()
{
	try {
		MakeMenuBar();
		MakeModelDirector();
		Initialize();

		ForceTargetSwitch(this);
		UCursor::InitTheCursor();
	}
	catch (...) {
		SignalStringLiteral_("App Initialization failed.");
	}
	
	AApplication::Run();
}
