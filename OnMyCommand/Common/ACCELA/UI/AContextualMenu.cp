#include "AContextualMenu.h"
#include "ACarbonEvent.h"

// ---------------------------------------------------------------------------

AContextualMenu&
AContextualMenu::operator<<(
		MenuCommand inCommandID)
{
	MenuRef menuRef;
	MenuItemIndex index;
	CThrownOSStatus err;
	
	if (inCommandID == kMenuSeparatorCommand) {
		::AppendMenu(mObjectRef,"\p-");
	}
	else {
		err = ::GetIndMenuItemWithCommandID(NULL,inCommandID,1,&menuRef,&index);
		if (::IsMenuItemEnabled(menuRef,index)) {
			MenuItemIndex newItemIndex;
			
			err = ::CopyMenuItems(menuRef,index,1,mObjectRef,::CountMenuItems(mObjectRef));
			newItemIndex = ::CountMenuItems(mObjectRef);
			err = ::SetMenuItemCommandKey(mObjectRef,newItemIndex,false,0);
			err = ::SetMenuItemKeyGlyph(mObjectRef,newItemIndex,kMenuNullGlyph);
		}
	}
	return *this;
}

// ---------------------------------------------------------------------------

void
AContextualMenu::Select(
		Point inGlobalLocation,
		const AEDesc *inSelection,
		UInt32 inHelpType,
		ConstStr255Param inHelpItemString)
{
	CThrownOSStatus err;
	UInt32 selectionType;
	SInt16 selectedMenuID;
	MenuRef selectedMenuRef;
	MenuItemIndex selectedItem;
	
	err = ::ContextualMenuSelect(
			mObjectRef,inGlobalLocation,false,inHelpType,inHelpItemString,inSelection,
			&selectionType,&selectedMenuID,&selectedItem);
	
	switch (selectionType) {
		
		case kCMMenuItemSelected: {
			MenuCommand selectedCommand;
			
			selectedMenuRef = ::GetMenuHandle(selectedMenuID);
			err = GetMenuItemCommandID(selectedMenuRef,selectedItem,&selectedCommand);
			
			ACarbonEvent commandEvent(kEventClassCommand,kEventCommandProcess);
			HICommand command = { kHICommandFromMenu,selectedCommand,{ selectedMenuRef,selectedItem } };
			
			commandEvent.SetParameter(kEventParamDirectObject,command);
			::PostEventToQueue(::GetMainEventQueue(),commandEvent,kEventPriorityStandard);
			break;
		}
		
		case kCMShowHelpSelected:
			ShowHelp();
			break;
	};
}

// ---------------------------------------------------------------------------
