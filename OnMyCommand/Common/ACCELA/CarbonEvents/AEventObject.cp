// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AEventObject.h"
#include "XValueChanger.h"

#include "CThrownResult.h"

EventRef
		AEventObject::sCurrentEvent = NULL;
EventTime
		AEventObject::sHandledEventTime = 0.0;
EventHandlerCallRef
		AEventObject::sCurrentCallRef = NULL;
EventHandlerUPP
		AEventObject::sEventHandlerUPP = NewEventHandlerUPP(AEventObject::EventHandler);

// ---------------------------------------------------------------------------

AEventObject::~AEventObject()
{
	if (mEventHandlerRef != NULL)
		::RemoveEventHandler(mEventHandlerRef);
}

// ---------------------------------------------------------------------------

void
AEventObject::AddTypes(
	const EventTypeSpec *inTypes,
	UInt32 inTypeCount)
{
	CThrownOSStatus err;
	
	if (mEventHandlerRef == NULL)
		throw paramErr;
	err = ::AddEventTypesToHandler(mEventHandlerRef,inTypeCount,inTypes);
}

// ---------------------------------------------------------------------------

void
AEventObject::RemoveTypes(
	const EventTypeSpec *inTypes,
	UInt32 inTypeCount)
{
	CThrownOSStatus err;
	
	if (mEventHandlerRef == NULL)
		throw paramErr;
	err = ::RemoveEventTypesFromHandler(mEventHandlerRef,inTypeCount,inTypes);
}

// ---------------------------------------------------------------------------

void
AEventObject::InstallHandler(
		ApplicationRef)
{
	if (mEventHandlerRef == NULL)
		::InstallEventHandler(::GetApplicationEventTarget(),sEventHandlerUPP,0,NULL,this,&mEventHandlerRef);
}

// ---------------------------------------------------------------------------

void
AEventObject::InstallHandler(
		WindowRef inTarget)
{
	if ((mEventHandlerRef == NULL) && (inTarget != NULL))
		::InstallEventHandler(::GetWindowEventTarget(inTarget),sEventHandlerUPP,0,NULL,this,&mEventHandlerRef);
}

// ---------------------------------------------------------------------------

void
AEventObject::InstallHandler(
		ControlRef inTarget)
{
	if ((mEventHandlerRef == NULL) && (inTarget != NULL))
		::InstallEventHandler(::GetControlEventTarget(inTarget),sEventHandlerUPP,0,NULL,this,&mEventHandlerRef);
}

// ---------------------------------------------------------------------------

void
AEventObject::InstallHandler(
		MenuRef inTarget)
{
	if ((mEventHandlerRef == NULL) && (inTarget != NULL))
		::InstallEventHandler(::GetMenuEventTarget(inTarget),sEventHandlerUPP,0,NULL,this,&mEventHandlerRef);
}

// ---------------------------------------------------------------------------

void
AEventObject::InstallHandler(
		EventTargetRef inTargetRef)
{
	::InstallEventHandler(inTargetRef,sEventHandlerUPP,0,NULL,this,&mEventHandlerRef);
}

// ---------------------------------------------------------------------------

OSStatus
AEventObject::HandleEvent(
		ACarbonEvent &,	// inEvent
		bool &outEventHandled)
{
	outEventHandled = false;
	return noErr;
}

// ---------------------------------------------------------------------------

EventTime
AEventObject::GetHandledEventTime()
{
	if (sHandledEventTime != 0.0)
		return sHandledEventTime;
	else
		return ::GetCurrentEventTime();
}

// ---------------------------------------------------------------------------

OSStatus
AEventObject::CallNextHandler()
{
	OSStatus err = -1;
	
	if ((sCurrentCallRef != NULL) && (sCurrentEvent != NULL))
		err = ::CallNextEventHandler(sCurrentCallRef,sCurrentEvent);
	return err;
}

// ---------------------------------------------------------------------------

pascal OSStatus
AEventObject::EventHandler(
		EventHandlerCallRef inHandlerCallRef,
		EventRef inEventRef,
		void *inUserData)
{
	OSErr err;
	bool handled = false;
	ACarbonEvent incomingEvent(inEventRef);
	
	try {
		XValueChanger<EventRef> newEvent(sCurrentEvent,inEventRef);
		XValueChanger<EventTime> newTime(sHandledEventTime,incomingEvent.Time());
		XValueChanger<EventHandlerCallRef> newCallRef(sCurrentCallRef,inHandlerCallRef);
		AEventObject *object = static_cast<AEventObject*>(inUserData);
		
		err = object->HandleEvent(incomingEvent,handled);
		if (!handled)
			err = CallNextHandler();
	}
	catch (...) {
		err = CallNextHandler();
	}
	return err;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

StHandleEventTypes::StHandleEventTypes(
	AEventObject &inObject)
: mObject(inObject)
{
}

// ---------------------------------------------------------------------------

StHandleEventTypes::~StHandleEventTypes()
{
	if ((mTypes.size() > 0) && (mObject.EventHandlerRef() != NULL)) {
		try {
			mObject.RemoveTypes(&mTypes[0],mTypes.size());
		}
		catch (...) {
		}
	}
}

// ---------------------------------------------------------------------------

void
StHandleEventTypes::AddTypes(
		const EventTypeSpec *inTypes,
		UInt32 inTypeCount)
{
	UInt32 i;
	
	for (i = 0; i < inTypeCount; i++)
		mTypes.push_back(inTypes[i]);
	mObject.AddTypes(inTypes,inTypeCount);
}
