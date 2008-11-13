// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACarbonEvent.h"

#include <string>
#include <memory>

// ---------------------------------------------------------------------------

ACarbonEvent::ACarbonEvent(
		  UInt32 inClassID,
		  UInt32 inKind,
		  EventTime inWhen,
		  EventAttributes inFlags,
		  CFAllocatorRef inAllocator)
{
	if (inWhen == 0.0)
		inWhen = ::GetCurrentEventTime();
	::CreateEvent(inAllocator,inClassID,inKind,inWhen,inFlags,&mObjectRef);
}

// ---------------------------------------------------------------------------

ACarbonEvent::~ACarbonEvent()
{
}

// ---------------------------------------------------------------------------

UInt32
ACarbonEvent::ParameterSize(
		EventParamName inName,
		EventParamType inType) const
{
	UInt32 paramSize = 0;
	OSStatus err;
	
	err = ::GetEventParameter(mObjectRef,inName,inType,NULL,0,&paramSize,NULL);
	return paramSize;
}

// ---------------------------------------------------------------------------

OSStatus
ACarbonEvent::GetParameterString(
		EventParamName inName,
		std::string &outString) const
{
	UInt32 paramSize;
	OSStatus err;
	
	err = ::GetEventParameter(mObjectRef,inName,typeText,NULL,0,&paramSize,NULL);
	if (err == noErr) {
		std::auto_ptr<char> dataPtr(new char[paramSize]);
		
		err = ::GetEventParameter(mObjectRef,inName,typeText,NULL,paramSize,NULL,dataPtr.get());
		outString = std::string(dataPtr.get(),paramSize);
	}
	return err;
}

// ---------------------------------------------------------------------------

void
ACarbonEvent::Post(
		EventPriority inPriority,
		EventQueueRef inEventLoop)
{
	if (inEventLoop == NULL)
		inEventLoop = ::GetMainEventQueue();
	
	CThrownOSStatus err = ::PostEventToQueue(inEventLoop,*this,inPriority);
}
