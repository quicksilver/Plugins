#include "FW.h"
#include "CThrownResult.h"

#include FW(ApplicationServices,AppleEvents.h)

class AAppleEvent;

#pragma warn_unusedarg off

class AAppleEventHandler
{
public:
		AAppleEventHandler(
				AEEventClass inClass,
				AEEventID inID);
	virtual
		~AAppleEventHandler();
	
protected:
	const AEEventClass mClass;
	const AEEventID mID;
	
	static AEEventHandlerUPP sHandlerUPP;
	
	static pascal OSErr
		Callback(
				const AppleEvent *inEvent,
				AppleEvent *outReply,
				long inRefCon);
	
	virtual OSErr
		HandleAppleEvent(
				const AAppleEvent &inEvent,
				AAppleEvent &outReply)
		{
			return errAEEventNotHandled;
		}
};

#pragma warn_unusedarg reset

// ---------------------------------------------------------------------------

inline
AAppleEventHandler::AAppleEventHandler(
		AEEventClass inClass,
		AEEventID inID)
: mClass(inClass),mID(inID)
{
	CThrownOSErr err = ::AEInstallEventHandler(inClass,inID,sHandlerUPP,(long)this,false);
}

inline
AAppleEventHandler::~AAppleEventHandler()
{
	CThrownOSErr err = ::AERemoveEventHandler(mClass,mID,sHandlerUPP,false);
}
