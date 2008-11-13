// note - the HIObject classes are untested and probably incomplete

#include "ACFString.h"
#include "AEventObject.h"

#include <Carbon/Carbon.h>

// ---------------------------------------------------------------------------
#pragma mark AHIObject
// The base AHIObject class is intended for wrapping existing or standard
// HIObjects. For creating custom-class HIObjects, subclass AHICustomObject
// and use AHIObjectClassT.

class AHIObject :
		public ACFType<HIObjectRef>
{
public:
		// HIObjectRef
		AHIObject(
				HIObjectRef inObject,
				bool inDoRetain = true)
		: ACFType<HIObjectRef>(inObject,inDoRetain) {}
		// class ID
		AHIObject(
				CFStringRef inClassID,
				EventRef inConstructEvent)
		{
			CThrownOSStatus err = ::HIObjectCreate(
					inClassID,inConstructEvent,
					const_cast<HIObjectRef*>((const OpaqueHIObjectRef**)&mObjectRef));
		}
		// bundle
		AHIObject(
				CFBundleRef inBundle)
		{
			CThrownOSStatus err = ::HIObjectCreateFromBundle(
					inBundle,
					const_cast<HIObjectRef*>((const OpaqueHIObjectRef**)&mObjectRef));
		}
	
		operator EventTargetRef() const
		{
			return ::HIObjectGetEventTarget(*this);
		}
	
	void
		PrintDebugInfo() const;
	
	// class
	CFStringRef
		CopyClassID() const;
	bool
		IsOfClass(
				CFStringRef inClassID) const;
	
	// accessibility
	bool
		IsAccessibilityIgnored() const;
	void
		SetAccessibilityIgnored(
				bool inIgnored);
};

// ---------------------------------------------------------------------------

inline void
AHIObject::PrintDebugInfo() const
{
	::HIObjectPrintDebugInfo(*this);
}

inline CFStringRef
AHIObject::CopyClassID() const
{
	return ::HIObjectCopyClassID(*this);
}

inline bool
AHIObject::IsOfClass(
		CFStringRef inClassID) const
{
	return ::HIObjectIsOfClass(*this,inClassID);
}

inline bool
AHIObject::IsAccessibilityIgnored() const
{
	return ::HIObjectIsAccessibilityIgnored(*this);
}

inline void
AHIObject::SetAccessibilityIgnored(
		bool inIgnored)
{
	::HIObjectSetAccessibilityIgnored(*this,inIgnored);
}

// ---------------------------------------------------------------------------
#pragma mark AHICustomObject

class AHICustomObject :
		public AHIObject,
		public AEventObject
{
protected:
		AHICustomObject(
				HIObjectRef inObject);
	
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// AHICustomObject
	
	// Unlike most event handler functions, Initialize returns an OSStatus.
	// This is because the event is always considered to be handled, due to
	// the special use of CallNextEventHandler for this event.
	virtual OSStatus
		Initialize(
				const ACarbonEvent &)
		{
			return noErr;
		}
	virtual bool
		PrintDebugInfoSelf()
		{
			return false;
		}
};

// ---------------------------------------------------------------------------
#pragma mark AHIObjectClass

class AHIObjectClass
{
public:
		AHIObjectClass(
				CFStringRef inClassID,
				CFStringRef inBaseClassID,
				OptionBits inOptions);
	virtual
		~AHIObjectClass()
		{
			::HIObjectUnregisterClass(mClassRef);
		}
	
		operator HIObjectClassRef() const
		{
			return mClassRef;
		}
	
protected:
	HIObjectClassRef mClassRef;
	ACFString mClassID;
	
	static EventHandlerUPP sHandlerProc;
	
	virtual void*
		Construct(
				HIObjectRef inObject) = 0;
	virtual void
		Destruct(
				void *inObject) = 0;
	virtual OSStatus
		Initialize(
				void */*inObject*/,
				const ACarbonEvent &)
		{
			return noErr;
		}
	virtual void
		PrintDebugInfo(
				void */*inObject*/) {}
	
	static pascal OSStatus
		EventHandler(
				EventHandlerCallRef inHandlerCallRef,
				EventRef inEvent,
				void *inUserData);
};

// ---------------------------------------------------------------------------
#pragma mark AHIInitEvent

class AHIInitEvent :
		public ACarbonEvent
{
public:
		AHIInitEvent()
		: ACarbonEvent(kEventClassHIObject,kEventHIObjectInitialize) {}
};

enum {
	kEventClassAHIObject = 'AHIO',
	
	kEventAHIObjectGetObjectPtr = 1,
	
	kEventParamAHIOInitParam = 'AOIP'
};

// ---------------------------------------------------------------------------
#pragma mark AHIObjectClassT
// Since your HIObject will be created inside the call to HIObjectCreate,
// you need to use AHIObjectClassT<>::MakeObject to create the object and
// get a pointer to it. It is assumed that your class inherits from
// AHICustomObject.

template <class T>
class AHIObjectClassT :
		public AHIObjectClass
{
public:
		AHIObjectClassT(
				CFStringRef inClassID,
				CFStringRef inBaseClassID = NULL,
				OptionBits inOptions = 0)
		: AHIObjectClass(inClassID,inBaseClassID,inOptions) {}
	virtual
		~AHIObjectClassT() {}
	
	// Simple version, for zero or one parameters
	T*
		MakeObject(
				void *inData = NULL)
		{
			AHIInitEvent initEvent;
			initEvent.SetParameter(kEventParamAHIOInitParam,typeVoidPtr,inData);
			return MakeObject(initEvent);
		}
	// Full-on init event version
	T*
		MakeObject(
				const ACarbonEvent &inInitEvent)
		{
			HIObjectRef hiObject;
			CThrownOSStatus err = ::HIObjectCreate(mClassID,inInitEvent,&hiObject);
			ACarbonEvent getPtrEvent(kEventClassAHIObject,kEventAHIObjectGetObjectPtr);
			T *madeObject;	// gcc doesn't like using ACarbonEvent::Parameter<> here
			err = getPtrEvent.SendTo(::HIObjectGetEventTarget(hiObject));
			err = getPtrEvent.GetParameter(kEventParamDirectObject,typeVoidPtr,madeObject);
			return madeObject;
		}
	
protected:
	virtual void*
		Construct(
				HIObjectRef inObject)
		{
			return new T(inObject);
		}
	virtual OSStatus
		Initialize(
				void *inObject,
				const ACarbonEvent &inEvent)
		{
			return reinterpret_cast<T*>(inObject)->Initialize(inEvent);
		}
	virtual void
		Destruct(
				void *inObject)
		{
			delete reinterpret_cast<T*>(inObject);
		}
	virtual void
		PrintDebugInfo(
				void *inObject)
		{
			reinterpret_cast<T*>(inObject)->PrintDebugInfoSelf();
		}
};

// ---------------------------------------------------------------------------
