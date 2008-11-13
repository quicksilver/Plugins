// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AMenuHandler.h"
#include "AEventParameter.h"

// ---------------------------------------------------------------------------

OSStatus
AMenuHandler::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	if (inEvent.Class() == kEventClassMenu)
		switch (inEvent.Kind()) {
			case kEventMenuBeginTracking:
				outEventHandled = BeginTracking(
						AEventParameter<MenuTrackingMode>(inEvent,kEventParamCurrentMenuTrackingMode,typeMenuTrackingMode),
						ATypeParam<>::UInt32(inEvent,kEventParamMenuContext));
				break;
			
			case kEventMenuEndTracking:
				outEventHandled = EndTracking(
						ATypeParam<>::UInt32(inEvent,kEventParamMenuContext));
				break;
			
			case kEventMenuChangeTrackingMode:
				outEventHandled = ChangeTrackingMode(
						AEventParameter<MenuTrackingMode>(inEvent,kEventParamCurrentMenuTrackingMode,typeMenuTrackingMode),
						AEventParameter<MenuTrackingMode>(inEvent,kEventParamNewMenuTrackingMode,typeMenuTrackingMode),
						ATypeParam<>::UInt32(inEvent,kEventParamMenuContext));
				break;
			
			case kEventMenuOpening:
				outEventHandled = Opening(
						ATypeParam<>::Boolean(inEvent,kEventParamMenuFirstOpen));
				break;
			
			case kEventMenuClosed:
				outEventHandled = Closed();
				break;
			
			case kEventMenuTargetItem:
				outEventHandled = TargetItem(
						AParam<>::MenuItem(inEvent),
						AEventParameter<MenuCommand>(inEvent,kEventParamMenuCommand,typeMenuCommand));
				break;
			
			case kEventMenuMatchKey:
				{
					AParam<AWriteOnly>::MenuItem matchIndex(inEvent);
					
					outEventHandled = MatchKey(
							AEventParameter<EventRef>(inEvent,kEventParamEventRef),
							AEventParameter<MenuEventOptions>(inEvent,kEventParamMenuEventOptions,typeMenuEventOptions),
							matchIndex);
				}
				break;
			
			case kEventMenuEnableItems:
				outEventHandled = EnableItems(
						ATypeParam<>::Boolean(inEvent,kEventParamEnableMenuForKeyEvent));
				break;
			
			case kEventMenuPopulate:
			case kEventMenuMeasureItemHeight:
			case kEventMenuDrawItem:
			case kEventMenuDrawItemContent:
				break;
			
			case kEventMenuDispose:
				outEventHandled = Dispose();
				break;
		}
	return noErr;
}
