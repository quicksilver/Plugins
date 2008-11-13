#include "AMenu.h"

// ---------------------------------------------------------------------------

CFStringRef
AMenu::CopyTitleString() const
{
	CFStringRef stringRef;
	
	::CopyMenuTitleAsCFString(mObjectRef,&stringRef);
	return stringRef;
}

// ---------------------------------------------------------------------------

void
AMenu::SetTitleString(
		CFStringRef inString)
{
	OSStatus err;
	
	err = ::SetMenuTitleWithCFString(mObjectRef,inString);
}

// ---------------------------------------------------------------------------


AMenu&
AMenu::operator<<(
		ConstStr255Param inText)
{
	::AppendMenuItemText(mObjectRef,inText);
	return *this;
}
