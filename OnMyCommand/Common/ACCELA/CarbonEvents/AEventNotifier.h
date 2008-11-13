#pragma once

#include "AEventObject.h"

// AEventNotifier calls an object's method when it receives a
// particular event. It's useful for things like being notified
// when a window is closed.

// Just be wary of doing things like deleting the AWindow object
// from inside this handler, since that can lead to a crash.

template <class T>
class AEventNotifier :
		public AEventObject
{
public:
	typedef void (T::*CallbackType)();
	
	template <class EventTargetType>
		AEventNotifier(
				EventTargetType inTarget,
				T &inNotifyObject,
				CallbackType inCallback,
				UInt32 inClass,
				UInt32 inKind)
		: AEventObject(inTarget),
		  mNotifyObject(inNotifyObject),
		  mCallback(inCallback)
		{
			AddType(inClass,inKind);
		}
	
protected:
	T &mNotifyObject;
	CallbackType mCallback;
	
	OSStatus
		HandleEvent(
				ACarbonEvent &,
				bool &outEventHandled)
		{
			(mNotifyObject.*(mCallback))();
			outEventHandled = true;
			return noErr;
		}
};
