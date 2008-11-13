#include "AWindow.h"
#include "AAutoToolbar.H"

DeclareAutoToolbar_(TestToolbar)

class ToolbarWindow :
		public AWindow
{
public:
		ToolbarWindow();
	
protected:
	AAutoToolbar<TestToolbar> mToolbar;
};
