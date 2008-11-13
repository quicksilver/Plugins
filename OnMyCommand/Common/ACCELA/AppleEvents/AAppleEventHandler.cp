#include "AAppleEventHandler.h"
#include "AAppleEvent.h"

AEEventHandlerUPP AAppleEventHandler::sHandlerUPP = NewAEEventHandlerUPP(Callback);

// ---------------------------------------------------------------------------

pascal OSErr
AAppleEventHandler::Callback(
		const AppleEvent *inEvent,
		AppleEvent *outReply,
		long inRefCon)
{
	OSErr result = errAEEventNotHandled;
	
	try {
		result = (reinterpret_cast<AAppleEventHandler*>(inRefCon))->HandleAppleEvent(
				*static_cast<const AAppleEvent*>(inEvent),
				*static_cast<AAppleEvent*>(outReply));
	}
	catch (...) {}
	
	return result;
}
