// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include <LMenu.h>

class CCommandMenu : public LMenu {
public:
		CCommandMenu()
		: LMenu() {}
		CCommandMenu(
				ResIDT inMenuID)
		: LMenu(inMenuID) {}
		CCommandMenu(
				SInt16 inMenuID,
				ConstStringPtr inTitle,
				bool inAlwaysThemeSavvy = false)
		: LMenu(inMenuID,inTitle,inAlwaysThemeSavvy) {}
	
	CommandT
		CommandFromIndex(
				SInt16 inIndex) const;
	SInt16
		IndexFromCommand(
				CommandT inCommand) const;
	bool
		FindNextCommand(
				SInt16 &ioIndex,
				SInt32 &outCommand) const;
	void
		SetCommand(
				SInt16 inIndex,
				CommandT inCommand);
	void
		InsertCommand(
				ConstStringPtr inItemText,
				CommandT inCommand,
				SInt16 inAfterItem);
	
protected:
	void
		ReadCommandNumbers();
};
