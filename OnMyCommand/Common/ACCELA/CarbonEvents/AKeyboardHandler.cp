#include "AKeyboardHandler.h"
#include "AEventParameter.h"

// ---------------------------------------------------------------------------

#define KeyParams_(_event_) \
		AEventParameter<char>(_event_,kEventParamKeyMacCharCodes,typeChar), \
		AEventParameter<UInt32>(_event_,kEventParamKeyCode,typeUInt32), \
		AParam<>::Modifiers(_event_), \
		AEventParameter<UInt32>(_event_,kEventParamKeyboardType,typeUInt32)

OSStatus
AKeyboardHandler::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	if (inEvent.Class() == kEventClassKeyboard)
		switch (inEvent.Kind()) {
			
			case kEventRawKeyDown:
				outEventHandled = RawKeyDown(KeyParams_(inEvent));
				break;
			
			case kEventRawKeyRepeat:
				outEventHandled = RawKeyRepeat(KeyParams_(inEvent));
				break;
			
			case kEventRawKeyUp:
				outEventHandled = RawKeyUp(KeyParams_(inEvent));
				break;
			
			case kEventRawKeyModifiersChanged:
				outEventHandled = ModifiersChanged(AParam<>::Modifiers(inEvent));
		}
	return noErr;
}
