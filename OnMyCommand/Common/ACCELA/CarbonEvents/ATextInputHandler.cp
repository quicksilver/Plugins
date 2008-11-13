#include "ATextInputHandler.h"
#include "AEventParameter.h"

// ----------------------------------------------------------------------------

OSStatus
ATextInputHandler::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	if (inEvent.Class() == kEventClassTextInput)
		switch (inEvent.Kind()) {
			
			case kEventTextInputUpdateActiveInputArea:
				{
					Size textSize = inEvent.ParameterSize(kEventParamTextInputSendText,typeUnicodeText);
					std::auto_ptr<char> eventText(new char[textSize]);
					EventParamType textType = typeUnicodeText;	// when will it be plain text?
					
					outEventHandled = UpdateActiveInputArea(
							AEventParameter<ComponentInstance>(inEvent,kEventParamTextInputSendComponentInstance,typeComponentInstance),
							AEventParameter<long>(inEvent,kEventParamTextInputSendRefCon,typeLongInteger),
							AEventParameter<ScriptLanguageRecord>(inEvent,kEventParamTextInputSendSLRec,typeIntlWritingCode),
							AEventParameter<long>(inEvent,kEventParamTextInputSendFixLen,typeLongInteger),
							eventText.get(),
							textSize,
							textType);
				}
				break;
			
			case kEventTextInputUnicodeForKeyEvent:
				{
					Size textSize = inEvent.ParameterSize(kEventParamTextInputSendText,typeUnicodeText)/sizeof(UniChar);
					std::auto_ptr<UniChar> eventText(new UniChar[textSize]);
					
					inEvent.GetParameter(kEventParamTextInputSendText,typeUnicodeText,textSize*sizeof(UniChar),eventText.get());
					outEventHandled = UnicodeForKeyEvent(
							AEventParameter<ComponentInstance>(inEvent,kEventParamTextInputSendComponentInstance,typeComponentInstance),
							AEventParameter<long>(inEvent,kEventParamTextInputSendRefCon,typeLongInteger),
							AEventParameter<ScriptLanguageRecord>(inEvent,kEventParamTextInputSendSLRec,typeIntlWritingCode),
							eventText.get(),
							textSize,
							AEventParameter<EventRef>(inEvent,kEventParamTextInputSendKeyboardEvent,typeEventRef));
				}
				break;
			
			default:
				break;
		}
	return noErr;
}
