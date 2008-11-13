#include "AWindow.h"

// ---------------------------------------------------------------------------

AWindow::AWindow(
		WindowClass inWindowClass,
		WindowAttributes inAttributes,
		const Rect &inContentBounds)
{
	::CreateNewWindow(inWindowClass,inAttributes,&inContentBounds,&mObjectRef);
}

// ---------------------------------------------------------------------------

AWindow::AWindow(
		SInt16 inID,
		WindowRef inBehindWindow)
{
	mObjectRef = ::GetNewCWindow(inID,NULL,inBehindWindow);
	if (mObjectRef == NULL) {
		CThrownOSStatus err;
		
		err = ::CreateWindowFromResource(inID,&mObjectRef);
	}
}

// ---------------------------------------------------------------------------

AWindow::AWindow(
		Collection inCollection)
{
	CThrownOSStatus err;
	
	err = ::CreateWindowFromCollection(inCollection,&mObjectRef);
}

// ---------------------------------------------------------------------------

AWindow::AWindow(
		IBNibRef inNib,
		CFStringRef inName)
{
	CThrownOSStatus err;
	
	if (inNib != NULL)
		err = ::CreateWindowFromNib(inNib,inName,&mObjectRef);
	else
		throw paramErr;
}
