#include "AWindow.h"

// ---------------------------------------------------------------------------

class ASheetWindow :
		public AWindow
{
public:
		// WindowRef
		ASheetWindow(
				WindowRef inWindow,
				bool inDoRetain = true)
		: AWindow(inWindow,inDoRetain) {}
		// nib
		ASheetWindow(
				IBNibRef inNib,
				CFStringRef inName)
		: AWindow(inNib,inName) {}
		// resource
		ASheetWindow(
				SInt16 inID,
				WindowRef inBehindWindow = (WindowRef)-1L)
		: AWindow(inID,inBehindWindow) {}
	
	void
		Show(
				WindowRef inParentWindow);
	void
		Hide();
	WindowRef
		Parent() const;
};

// ---------------------------------------------------------------------------

inline void
ASheetWindow::Show(
		WindowRef inParentWindow)
{
	CThrownOSStatus err = ::ShowSheetWindow(*this,inParentWindow);
}

inline void
ASheetWindow::Hide()
{
	CThrownOSStatus err = ::HideSheetWindow(*this);
}

inline WindowRef
ASheetWindow::Parent() const
{
	WindowRef parent;
	CThrownOSStatus err = ::GetSheetWindowParent(*this,&parent);
	return parent;
}
