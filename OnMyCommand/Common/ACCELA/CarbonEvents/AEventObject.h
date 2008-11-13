// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACarbonEvent.h"

#include FW(Carbon,CarbonEvents.h)

#include <vector>

typedef struct OpaqueApplicationRef *ApplicationRef;	// Just to have something

// ---------------------------------------------------------------------------

class AEventObject
{
public:
		AEventObject()
		: mEventHandlerRef(NULL) {}
	template <class T>
		AEventObject(
				T inObjectRef)
		: mEventHandlerRef(NULL)
		{ InstallHandler(inObjectRef); }
	virtual
		~AEventObject();
	
	::EventHandlerRef
		EventHandlerRef() const
		{ return mEventHandlerRef; }
	
	void
		AddTypes(
				const EventTypeSpec *inTypes,
				UInt32 inTypeCount);
	void
		AddType(
				const EventTypeSpec &inType)
		{ return AddTypes(&inType,1); }
	void
		AddType(
				UInt32 inClass,
				UInt32 inKind)
		{
			EventTypeSpec eventType = { inClass,inKind };
			AddTypes(&eventType,1);
		}
	void
		RemoveTypes(
				const EventTypeSpec *inTypes,
				UInt32 inTypeCount);
	void
		RemoveType(
				const EventTypeSpec &inType)
		{ return RemoveTypes(&inType,1); }
	
	static EventRef
		GetCurrentEvent()
		{ return sCurrentEvent; }
	static EventHandlerUPP
		GetEventHandlerUPP()
		{ return sEventHandlerUPP; }
	
protected:
	::EventHandlerRef mEventHandlerRef;
	
	static EventTime sHandledEventTime;
	static EventRef sCurrentEvent;
	static EventHandlerCallRef sCurrentCallRef;
	static EventHandlerUPP sEventHandlerUPP;
	
	static EventTime
		GetHandledEventTime();
	
	virtual EventTargetRef
		GetEventTarget() const
		{ return NULL; }
	
	void
		InstallHandler(
				ApplicationRef);
	void
		InstallHandler(
				WindowRef inTarget);
	void
		InstallHandler(
				ControlRef inTarget);
	void
		InstallHandler(
				MenuRef inTarget);
	void
		InstallHandler(
				EventTargetRef inTargetRef);
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	static OSStatus
		CallNextHandler();
	
	static pascal OSStatus
		EventHandler(
				EventHandlerCallRef inHandlerCallRef,
				EventRef inEvent,
				void *inUserData);
};

const ApplicationRef kApplication = NULL;

// ---------------------------------------------------------------------------

class StHandleEventTypes {
public:
	 StHandleEventTypes(
	 		AEventObject &inObject);
	 ~StHandleEventTypes();
	
	void
		AddTypes(
				const EventTypeSpec *inTypes,
				UInt32 inTypeCount);
	void
		AddType(
				const EventTypeSpec &inType)
		{ AddTypes(&inType,1); }
	void
		AddType(
				UInt32 inClass,
				UInt32 inKind)
		{ EventTypeSpec eventType = { inClass,inKind };
		  AddTypes(&eventType,1); }
	
protected:
	typedef std::vector<EventTypeSpec> EventTypeArray;
	
	AEventObject &mObject;
	EventTypeArray mTypes;
};
