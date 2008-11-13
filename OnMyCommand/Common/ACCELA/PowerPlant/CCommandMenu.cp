// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "CCommandMenu.h"

#include <PP_Resources.h>

// ---------------------------------------------------------------------------

void
CCommandMenu::ReadCommandNumbers()
{
	SInt16**	theMcmdH = (SInt16**) ::GetResource(ResType_MenuCommands, mMENUid);

	if (theMcmdH != nil) {
		if (::GetHandleSize((Handle) theMcmdH) > 0) {
			::HLock((Handle)theMcmdH);
			mNumCommands = (*theMcmdH)[0];
			if (mNumCommands > 0) {
				short i;
				CommandT *commands = (CommandT*) &(*theMcmdH)[1];
				
				for (i = 0; i < mNumCommands; i++)
					SetCommand(i+1,commands[i]);
			}
		}
		::ReleaseResource((Handle) theMcmdH);
	}
}

// ---------------------------------------------------------------------------

CommandT
CCommandMenu::CommandFromIndex(
		SInt16 inIndex) const
{
	MenuCommand commandID;
	
	::GetMenuItemCommandID(mMacMenuH,inIndex,&commandID);
	return commandID;
}

// ---------------------------------------------------------------------------

SInt16
CCommandMenu::IndexFromCommand(
		CommandT inCommand) const
{
	MenuItemIndex index;
	
	::GetIndMenuItemWithCommandID(mMacMenuH,inCommand,1,NULL,&index);
	return index;
}

// ---------------------------------------------------------------------------

bool
CCommandMenu::FindNextCommand(
		SInt16 &ioIndex,
		SInt32 &outCommand) const
{
	MenuCommand commandID;
	bool found = false;
	
	if (ioIndex <= 0)
		ioIndex = 1;
	if (ioIndex <= ::CountMenuItems(mMacMenuH)) {
		::GetMenuItemCommandID(mMacMenuH,++ioIndex,&commandID);
		outCommand = commandID;
		found = true;
	}
	return found;
}

// ---------------------------------------------------------------------------

void
CCommandMenu::SetCommand(
		SInt16 inIndex,
		CommandT inCommand)
{
	::SetMenuItemCommandID(mMacMenuH,inIndex,inCommand);
}

// ---------------------------------------------------------------------------

void
CCommandMenu::InsertCommand(
		ConstStringPtr inItemText,
		CommandT inCommand,
		SInt16 inAfterItem)
{
	CFStringRef itemString;
	
	itemString = ::CFStringCreateWithPascalString(NULL,inItemText,kCFStringEncodingMacRoman);
	::InsertMenuItemTextWithCFString(mMacMenuH,itemString,inAfterItem,0,inCommand);
	::CFRelease(itemString);
}
