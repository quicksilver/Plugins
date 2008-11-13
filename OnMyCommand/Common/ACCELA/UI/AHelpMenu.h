#pragma once

#include "AMenu.h"

#include FW(Carbon,MacHelp.h)

class AHelpMenu :
		public AMenu
{
public:
		AHelpMenu();
	
	MenuItemIndex
		FirstCustomIndex() const
		{
			return mFirstCustomIndex;
		}
	
protected:
	MenuItemIndex mFirstCustomIndex;
};

inline AHelpMenu::AHelpMenu()
: AMenu(NULL,false)
{
	::HMGetHelpMenu(&mObjectRef,&mFirstCustomIndex);
	Retain();
}
