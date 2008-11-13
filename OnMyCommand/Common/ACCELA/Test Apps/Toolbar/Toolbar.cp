#include "AApplication.h"
#include "ANib.h"

#include "ToolbarWindow.h"

const CFStringRef kMainNibFileName = CFSTR("ToolbarTest");

const CFStringRef kMenuBarNibName  = CFSTR("MenuBar");
const CFStringRef kToolbarTestNibName = CFSTR("MainWindow");

// ---------------------------------------------------------------------------
// This application demonstrates a simple usage case for AAutoToolbar, which
// adds a toolbar to a window based on the contents of an xml file - in this
// case, toolbar.xml. The name of that file is referenced in the usage of
// the DefineAutoToolbar_ macro in ToolbarWindow.cp.
// ---------------------------------------------------------------------------

class ToolbarTest :
		public AApplication
{
public:
		ToolbarTest();
	
private:
	void
		DisplayToolbarWindow();
};

// ---------------------------------------------------------------------------

ToolbarTest::ToolbarTest()
{
	ANib nib(CFSTR("Toolbar"));
	
	nib.SetMenuBar(CFSTR("MenuBar"));
	new ToolbarWindow;
}

// ---------------------------------------------------------------------------

int
main()
{
	ToolbarTest app;
	
	app.Run();
	
	return 0;
}