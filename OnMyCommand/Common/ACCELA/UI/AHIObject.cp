#include "AHIObject.h"
#include "AEventParameter.h"

EventHandlerUPP
		AHIObjectClass::sHandlerProc = NewEventHandlerUPP(AHIObjectClass::EventHandler);

// ---------------------------------------------------------------------------
// The HIObjectRef is not retained, since the C++ object is deleted when the
// HIObject is finally released. Retaining it here would prevent that.

AHICustomObject::AHICustomObject(
		HIObjectRef inObject)
: AHIObject(inObject,false)
{
	static const UInt32 kNumEvents = 3;
	static const EventTypeSpec kEventTypes[kNumEvents] = {
			{ kEventClassHIObject,kEventHIObjectInitialize },
			{ kEventClassHIObject,kEventHIObjectDestruct },
			{ kEventClassAHIObject,kEventAHIObjectGetObjectPtr } };
	
	InstallHandler(::HIObjectGetEventTarget(*this));
	AddTypes(kEventTypes,kNumEvents);
}

// ---------------------------------------------------------------------------

OSStatus
AHICustomObject::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	OSStatus result = noErr;
	
	if (inEvent.Class() == kEventClassHIObject)
		switch (inEvent.Kind()) {
			
			case kEventHIObjectInitialize:
				// Must make sure that AEventObject::EventHandler
				// does not call CallNextEventHandler, since that needs
				// to be done differently for this event
				result = ::CallNextEventHandler(sCurrentCallRef,inEvent);
				if (result == noErr) try {
					result = Initialize(inEvent);
				}
				catch (...) {}
				outEventHandled = true;
				break;
			
			case kEventHIObjectPrintDebugInfo:
				outEventHandled = PrintDebugInfoSelf();
				break;
			
			case kEventHIObjectDestruct:
				delete this;
				outEventHandled = true;
				break;
		}
	else if ((inEvent.Class() == kEventClassAHIObject) &&
	         (inEvent.Kind()  == kEventAHIObjectGetObjectPtr)) {
		// dynamic_cast<void*> returns a pointer to the most derived type
		// so when you use this event, be sure you're prepared for that
		inEvent.SetParameter(kEventParamDirectObject,typeVoidPtr,dynamic_cast<void*>(this));
		outEventHandled = true;
	}
	
	return result;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AHIObjectClass::AHIObjectClass(
		CFStringRef inClassID,
		CFStringRef inBaseClassID,
		OptionBits inOptions)
: mClassID(inClassID)
{
	// The destruct event is actually not handled by this class object,
	// but registering for that event is required by HIObjectRegisterSubclass
	static const UInt32 kNumEvents = 2;
	static const EventTypeSpec kEventTypes[kNumEvents] = {
			{ kEventClassHIObject,kEventHIObjectConstruct },
			{ kEventClassHIObject,kEventHIObjectDestruct } };
	
	CThrownOSStatus err = ::HIObjectRegisterSubclass(
			inClassID,inBaseClassID,inOptions,
			sHandlerProc,kNumEvents,kEventTypes,
			this,&mClassRef);
}

// ---------------------------------------------------------------------------
// This function is used instead of AEventObject::EventHandler because of
// the different ways of using CallNextEventHandler.

pascal OSStatus
AHIObjectClass::EventHandler(
		EventHandlerCallRef,
		EventRef inEventRef,
		void *inUserData)
{
	typedef ASpecificParameter<HIObjectRef,kEventParamHIObjectInstance,typeHIObjectRef>
			HIObjectParam;
	
	ACarbonEvent event(inEventRef);
	OSStatus err = eventNotHandledErr;
	
	if ((event.Class() == kEventClassHIObject) && (event.Kind() == kEventHIObjectConstruct)) try {
		AHIObjectClass *classObject = reinterpret_cast<AHIObjectClass*>(inUserData);
		void *object = classObject->Construct(HIObjectParam(event));
		
		event.SetParameter(kEventParamHIObjectInstance,typeVoidPtr,sizeof(object),&object);
		err = noErr;
	}
	catch (...) {}
	
	return err;
}

// ---------------------------------------------------------------------------
