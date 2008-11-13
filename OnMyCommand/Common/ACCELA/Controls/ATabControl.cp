#include "ATabControl.h"

// ---------------------------------------------------------------------------

ATabControl::ATabControl(
		ControlRef inControl,
		UInt16 inInitialTab)
: AControl(inControl),
  AControlHandler(inControl),
  mTypes(*this)
{
	InitTabs(inInitialTab);
}

// ---------------------------------------------------------------------------

ATabControl::ATabControl(
		WindowRef inOwningWindow,
		const ControlID &inID,
		UInt16 inInitialTab)
: AControl(inOwningWindow,inID),
  AControlHandler(mObject),
  mTypes(*this)
{
	InitTabs(inInitialTab);
}

// ---------------------------------------------------------------------------

bool
ATabControl::Hit(
	ControlPartCode,
	UInt32)
{
	bool handled = false;
	
	if (Value() != mLastValue) {
		SelectTab(Value());
		handled = true;
	}
	return handled;
}

// ---------------------------------------------------------------------------

void
ATabControl::InitTabs(
		UInt16 inIndex)
{
	mTypes.AddType(kEventClassControl,kEventControlHit);
	
	SetValue(inIndex);
	SelectTab(inIndex);
}

// ---------------------------------------------------------------------------

void
ATabControl::SelectTab(
		UInt16 inIndex)
{
	mLastValue = inIndex;

	UInt16 i,maxValue = MaxValue();
	ControlID id = GetID();
	
	for (i = 1; i <= maxValue; i++) {
		if (i != mLastValue) {
			AControl userPane(OwnerWindow(),AControlID(id.signature,i),false);
			//Str255 title;
			
			//userPane.GetTitle(title);
			
			userPane.SetVisibility(false,false);
//			userPane.Disable();
		}
	}

	AControl selectedPane(OwnerWindow(),AControlID(id.signature,mLastValue),false);

	::ClearKeyboardFocus( OwnerWindow() );//_tk_
//	selectedPane.Enable();
	selectedPane.SetVisibility(true,true);
	
	AControl::Draw();
}
