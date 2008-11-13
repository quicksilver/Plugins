#include "ToolbarWindow.h"

#include "ACFURL.h"
#include "ANib.h"

DefineAutoToolbar_(TestToolbar,"com.uncommonplace.accela.test.toolbar","toolbar")

// ---------------------------------------------------------------------------

ToolbarWindow::ToolbarWindow()
: AWindow(ANib(CFSTR("Toolbar")),CFSTR("MainWindow")),
  mToolbar(*this,kHIToolbarIsConfigurable)
{
	::ShowHideWindowToolbar(*this,true,false);
	::SetAutomaticControlDragTrackingEnabledForWindow(*this,true);
	Show();
}

// ---------------------------------------------------------------------------
