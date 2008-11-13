#include "AMenu.h"

// ---------------------------------------------------------------------------
#pragma mark AContextualMenu

class AContextualMenu :
		public AMenu
{
public:
		AContextualMenu(
				MenuRef inMenuRef,
				bool inDoRetain = true)
		: AMenu(inMenuRef,inDoRetain) {}
		AContextualMenu(
				MenuID inMenuID)
		: AMenu(inMenuID,(MenuAttributes)0) {}
	
	AContextualMenu&
		operator<<(
				MenuCommand inCommandID);
		
	void
		Select(
				Point inGlobalLocation,
				const AEDesc *inSelection = NULL,
				UInt32 inHelpType = kCMHelpItemNoHelp,
				ConstStr255Param inHelpItemString = NULL);
	
	virtual void
		ShowHelp() {}
};

const MenuCommand kMenuSeparatorCommand = '----';
