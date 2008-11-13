// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACarbonEvent.h"

template <class T>
class AToolboxClass
{
protected:
		AToolboxClass(
				CFStringRef inClassID,
				ToolboxObjectClassRef inBaseClass,
				const EventTypeSpec inInitEvent)
		{
			CThrownOSStatus err = ::RegisterToolboxObjectClass(
					inClassID,inBaseClass,
					1,&inInitEvent,
					sEventHandlerUPP,this,
					&mClassRef);
		}
	virtual
		~AToolboxClass()
		{
//			::UnregisterToolboxObjectClass(mClassRef);	// crashes
		}
	
		operator ToolboxObjectClassRef()
		{
			return mClassRef;
		}
	
	virtual void
		MakeObject(
				ACarbonEvent &inEvent) = 0;
	
	static pascal OSStatus
		EventHandler(
				EventHandlerCallRef,
				EventRef inEvent,
				void *inUserData)
		{
			// This should be the first handler installed,
			// so no need for CallNextEventHandler
			ACarbonEvent event(inEvent);
			((AToolboxClass<T>*)inUserData)->MakeObject(event);
			return noErr;
		}
	
	ToolboxObjectClassRef mClassRef;
	
	static EventHandlerUPP sEventHandlerUPP;
};

const EventTypeSpec kInitControlEventType = {
		kEventClassControl,
		kEventControlInitialize };
const EventTypeSpec kInitWindowEventType = {
		kEventClassWindow,
		kEventWindowInit };

template <class T>
class AControlClass :
		public AToolboxClass<T>
{
public:
		AControlClass(
				CFStringRef inClassID,
				ToolboxObjectClassRef inBaseClass = NULL)
		: AToolboxClass<T>(inClassID,inBaseClass,kInitControlEventType) {}
	
protected:
	virtual void
		MakeObject(
				ACarbonEvent &inEvent)
		{
			UInt32 features = 0;
			new T(AEventParameter<ControlRef>(inEvent,kEventParamDirectObject),features);
			inEvent.SetParameter(kEventParamControlFeatures,typeUInt32,features);
		}
};
