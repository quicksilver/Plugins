// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XRefCountObject.h"
#include "XValueType.h"

#include "CThrownResult.h"

#include <string>

// ---------------------------------------------------------------------------

inline void
XRefCountObject<EventRef>::Retain()
{
	::RetainEvent(mObjectRef);
}

inline void
XRefCountObject<EventRef>::Release()
{
	::ReleaseEvent(mObjectRef);
}

inline UInt32
XRefCountObject<EventRef>::GetRetainCount() const
{
	return ::GetEventRetainCount(mObjectRef);
}

// ---------------------------------------------------------------------------

class ACarbonEvent :
		public XRefCountObject<EventRef>
{
public:
		ACarbonEvent(
				EventRef inEventRef,
				bool inDoRetain = true)
		: XRefCountObject<EventRef>(inEventRef,inDoRetain) {}
		ACarbonEvent(
				UInt32 inClassID,
				UInt32 inKind,
				EventTime inWhen = 0.0,
				EventAttributes inFlags = kEventAttributeNone,
				CFAllocatorRef inAllocator = kCFAllocatorDefault);
	virtual
		~ACarbonEvent();
	
	// ACarbonEvent
	
	UInt32
		Class() const;
	UInt32
		Kind() const;
	EventTime
		Time() const;
	OSStatus
		SetTime(EventTime inTime);
	
	bool
		IsUserCancel() const;
	
	OSStatus
		SetParameter(
				EventParamName inName,
				EventParamType inType,
				Size inSize,
				const void *inData);
	OSStatus
		SetParameterString(
				EventParamName inName,
				const std::string &inString)
		{
			return SetParameter(inName,typeText,inString.length(),inString.c_str());
		}
	template <class T>
	OSStatus
		SetParameter(
				EventParamName inName,
				EventParamType inType,
				const T &inParameter)
		{
			return SetParameter(inName,inType,sizeof(T),&inParameter);
		}
	template <class T>
	OSStatus
		SetParameter(
				EventParamName inName,
				const T &inParameter)
		{
			return SetParameter(inName,XValueType<T>::GetType(),sizeof(T),&inParameter);
		}
	
	bool
		HasParameter(
				EventParamName inName,
				EventParamType inType) const
		{
			return ::GetEventParameter(mObjectRef,inName,inType,NULL,0,NULL,NULL) == noErr;
		}
	UInt32
		ParameterSize(
				EventParamName inName,
				EventParamType inType) const;
	OSStatus
		GetParameter(
				EventParamName inName,
				EventParamType inType,
				Size inSize,
				void *outData) const;
	template <class T>
	OSStatus
		GetParameter(
				EventParamName inName,
				EventParamType inType,
				T &outParameter) const
		{
			return GetParameter(inName,inType,sizeof(T),&outParameter);
		}
	template <class T>
	OSStatus
		GetParameter(
				EventParamName inName,
				T &outParameter) const
		{
			return GetParameter(inName,XValueType<T>::GetType(),NULL,sizeof(T),NULL,&outParameter);
		}
	template <class T>
	T
		Parameter(
				EventParamName inName,
				EventParamType inType = XValueType<T>::GetType()) const
		{
			T value;
			CThrownOSStatus err = GetParameter(inName,inType,value);
			return value;
		}
	OSStatus
		GetParameterString(
				EventParamName inName,
				std::string &outString) const;
	
	OSStatus
		SendTo(
				EventTargetRef inTarget);
	OSStatus
		SendTo(
				WindowRef inWindow);
	OSStatus
		SendTo(
				ControlRef inControl);
	OSStatus
		SendTo(
				MenuRef inMenu);
	OSStatus
		SendToApplication();
	
	void
		Post(
				EventPriority inPriority = kEventPriorityStandard,
				EventQueueRef inEventLoop = NULL);
};

// ---------------------------------------------------------------------------

inline UInt32
ACarbonEvent::Class() const
{
	return ::GetEventClass(mObjectRef);
}

inline UInt32
ACarbonEvent::Kind() const
{
	return ::GetEventKind(mObjectRef);
}

inline EventTime
ACarbonEvent::Time() const
{
	return ::GetEventTime(mObjectRef);
}

inline OSStatus
ACarbonEvent::SetTime(EventTime inTime)
{
	return ::SetEventTime(mObjectRef,inTime);
}

inline bool
ACarbonEvent::IsUserCancel() const
{
	return ::IsUserCancelEventRef(mObjectRef);
}

inline OSStatus
ACarbonEvent::SetParameter(
		EventParamName inName,
		EventParamType inType,
		Size inSize,
		const void *inData)
{
	return ::SetEventParameter(mObjectRef,inName,inType,inSize,inData);
}

inline OSStatus
ACarbonEvent::GetParameter(
		EventParamName inName,
		EventParamType inType,
		Size inSize,
		void *outData) const
{
	return ::GetEventParameter(mObjectRef,inName,inType,NULL,inSize,NULL,outData);
}

inline OSStatus
ACarbonEvent::SendTo(
		EventTargetRef inTarget)
{
	return ::SendEventToEventTarget(*this,inTarget);
}

inline OSStatus
ACarbonEvent::SendTo(
		WindowRef inWindow)
{
	return ::SendEventToEventTarget(*this,::GetWindowEventTarget(inWindow));
}

inline OSStatus
ACarbonEvent::SendTo(
		ControlRef inControl)
{
	return ::SendEventToEventTarget(*this,::GetControlEventTarget(inControl));
}

inline OSStatus
ACarbonEvent::SendTo(
		MenuRef inMenu)
{
	return ::SendEventToEventTarget(*this,::GetMenuEventTarget(inMenu));
}

inline OSStatus
ACarbonEvent::SendToApplication()
{
	return ::SendEventToEventTarget(*this,::GetApplicationEventTarget());
}
