#pragma once

#include "AEventObject.h"

#pragma warn_unusedarg off

class ATextInputHandler :
		public AEventObject
{
public:
	template <class T>
		ATextInputHandler(
				T inObjectRef)
		: AEventObject(inObjectRef) {}
	
protected:
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// ATextInputHandler
	
	virtual bool
		UpdateActiveInputArea(
				ComponentInstance inComponent,
				long inRefCon,
				const ScriptLanguageRecord &inScript,
				long inFixLength,
				void *inText,
				Size inTextSize,
				EventParamType textType)	// ..and several optional parameters
		{ return false; }
	virtual bool
		UnicodeForKeyEvent(
				ComponentInstance inComponent,
				long inRefCon,
				const ScriptLanguageRecord &inScript,
				const UniChar *inText,
				Size inTextSize,
				EventRef inKeyboardEvent)	// ..and a glyph info array
		{ return false; }
};

#pragma warn_unusedarg reset
