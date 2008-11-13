#include "AEventObject.h"

#pragma warn_unusedarg off

class AKeyboardHandler :
		public AEventObject
{
public:
	template <class T>
		AKeyboardHandler(
				T inObjectRef)
		: AEventObject(inObjectRef) {}
	
protected:
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// AKeyboardHandler
	
	bool
		RawKeyDown(
				char inChar,
				UInt32 inKeyCode,
				UInt32 inModifiers,
				UInt32 inKeyboardType)
		{ return false; }
	bool
		RawKeyRepeat(
				char inChar,
				UInt32 inKeyCode,
				UInt32 inModifiers,
				UInt32 inKeyboardType)
		{ return false; }
	bool
		RawKeyUp(
				char inChar,
				UInt32 inKeyCode,
				UInt32 inModifiers,
				UInt32 inKeyboardType)
		{ return false; }
	bool
		ModifiersChanged(
				UInt32 inModifiers)
		{ return false; }
};

#pragma warn_unusedarg reset
