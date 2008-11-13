#pragma once

#include "AControl.h"

// ---------------------------------------------------------------------------

#define _Basic_Constructors(_class_) \
		_class_( \
				ControlRef inControl, \
				bool inOwner = false) \
		: AControl(inControl,inOwner) {} \
		_class_( \
				WindowRef inOwningWindow, \
				const ControlID &inID, \
				bool inOwner = false) \
		: AControl(inOwningWindow,inID,inOwner) {}

// ---------------------------------------------------------------------------
#pragma mark AEditText

class AEditText :
		public AControl
{
public:
		_Basic_Constructors(AEditText)
		// parameters
		AEditText(
				WindowRef inWindow,
				const Rect &inBoundsRect,
				const ControlFontStyleRec &inStyle,
				CFStringRef inText = CFSTR(""),
				bool inIsPassword = false,
				bool inUseInlineInput = true)
		: AControl(NULL,true)
		{
			CThrownOSStatus err = ::CreateEditTextControl(
					inWindow,&inBoundsRect,
					inText,inIsPassword,inUseInlineInput,
					&inStyle,&mObject);
		}
		// parameters, no style
		AEditText(
				WindowRef inWindow,
				const Rect &inBoundsRect,
				CFStringRef inText = CFSTR(""),
				bool inIsPassword = false,
				bool inUseInlineInput = true)
		: AControl(NULL,true)
		{
			CThrownOSStatus err = ::CreateEditTextControl(
					inWindow,&inBoundsRect,
					inText,inIsPassword,inUseInlineInput,
					NULL,&mObject);
		}
	
	CFStringRef
		CopyCFText() const
		{
			return Data<CFStringRef>(kControlNoPart,kControlEditTextCFStringTag);
		}
	void
		SetCFText(
				CFStringRef inString)
		{
			SetData(kControlNoPart,kControlEditTextCFStringTag,inString);
		}
	CFStringRef
		CopyCFPassword() const
		{
			return Data<CFStringRef>(kControlNoPart,kControlEditTextPasswordCFStringTag);
		}
	void
		SetCFPassword(
				CFStringRef inString)
		{
			SetData(kControlNoPart,kControlEditTextPasswordCFStringTag,inString);
		}
};

// ---------------------------------------------------------------------------
#pragma mark AProgressBar

class AProgressBar :
		public AControl
{
public:
		_Basic_Constructors(AProgressBar)
		// parameters
		AProgressBar(
				WindowRef inWindow,
				const Rect &inBoundsRect,
				SInt32 inValue,
				SInt32 inMin,
				SInt32 inMax,
				bool inIndeterminate = false)
		: AControl(NULL,true)
		{
			CThrownOSStatus err = ::CreateProgressBarControl(
					inWindow,&inBoundsRect,
					inValue,inMin,inMax,
					inIndeterminate,&mObject);
		}
	
	void
		SetIndeterminate(
				bool inIndeterminate = true)
		{
			Boolean value = inIndeterminate;
			SetData(kControlNoPart,kControlProgressBarIndeterminateTag,&value);
		}
};

// ---------------------------------------------------------------------------
#pragma mark AStaticText

class AStaticText :
		public AControl
{
public:
		_Basic_Constructors(AStaticText)
		// parameters
		AStaticText(
				WindowRef inWindow,
				const Rect &inBoundsRect,
				CFStringRef inText,
				const ControlFontStyleRec &inStyle)
		: AControl(NULL,true)
		{
			CThrownOSStatus err = ::CreateStaticTextControl(
					inWindow,&inBoundsRect,
					inText,&inStyle,&mObject);
		}
		// parameters, no style
		AStaticText(
				WindowRef inWindow,
				const Rect &inBoundsRect,
				CFStringRef inText)
		: AControl(NULL,true)
		{
			CThrownOSStatus err = ::CreateStaticTextControl(
					inWindow,&inBoundsRect,
					inText,NULL,&mObject);
		}
	
	void
		SetTextStyle(
				const ControlFontStyleRec &inStyle)
		{
			SetData(kControlNoPart,kControlStaticTextStyleTag,inStyle);
		}
	void
		SetText(
				CFStringRef inText)
		{
			SetData(kControlNoPart,kControlStaticTextCFStringTag,inText);
		}
	CFStringRef
		CopyCFText()
		{
			return Data<CFStringRef>(kControlNoPart,kControlStaticTextCFStringTag);
		}
};

// ---------------------------------------------------------------------------
#pragma mark AUnicodeEditText

class AUnicodeEditText :
		public AEditText
{
public:
		AUnicodeEditText(
				ControlRef inControl,
				bool inOwner = false)
		: AEditText(inControl,inOwner) {}
		AUnicodeEditText(
				WindowRef inOwningWindow,
				const ControlID &inID,
				bool inOwner = false)
		: AEditText(inOwningWindow,inID,inOwner) {}
		// parameters
		AUnicodeEditText(
				WindowRef inWindow,
				const Rect &inBoundsRect,
				const ControlFontStyleRec &inStyle,
				CFStringRef inText = CFSTR(""),
				bool inIsPassword = false)
		: AEditText(NULL,true)
		{
			CThrownOSStatus err = ::CreateEditUnicodeTextControl(
					inWindow,&inBoundsRect,
					inText,inIsPassword,
					&inStyle,&mObject);
		}
		// parameters, no style
		AUnicodeEditText(
				WindowRef inWindow,
				const Rect &inBoundsRect,
				CFStringRef inText = CFSTR(""),
				bool inIsPassword = false)
		: AEditText(NULL,false)
		{
			CThrownOSStatus err = ::CreateEditUnicodeTextControl(
					inWindow,&inBoundsRect,
					inText,inIsPassword,
					NULL,&mObject);
			mOwner = true;
		}
};

// ---------------------------------------------------------------------------
#pragma mark AScrollBar

#pragma warn_unusedarg off

class AScrollBar :
		public AControl
{
public:
		_Basic_Constructors(AScrollBar);
		AScrollBar(
				WindowRef inWindow,
				const Rect &inBounds,
				SInt32 inValue,
				SInt32 inMinimum,
				SInt32 inMaximum,
				SInt32 inViewSize,
				bool inLiveTracking);
	
protected:
	static pascal void
		ActionProc(
				ControlRef inControl,
				ControlPartCode inPart);
	
	virtual void
		Action(
				ControlPartCode inPart) {}
};

#pragma warn_unusedarg reset

// ---------------------------------------------------------------------------
#pragma mark ABevelButton

class ABevelButton :
		public AControl
{
public:
		_Basic_Constructors(ABevelButton);
		ABevelButton(
				WindowRef inWindow,
				const Rect &inBounds,
				CFStringRef inTitle,
				ControlBevelThickness inThickness = kControlBevelButtonNormalBevel,
				ControlBevelButtonBehavior inBehavior = kControlBehaviorPushbutton,
				const ControlButtonContentInfo *inInfo = NULL,
				SInt16 inMenuID = 0,
				ControlBevelButtonMenuBehavior inMenuBehavior = 0,
				ControlBevelButtonMenuPlacement inMenuPlacement = kControlBevelButtonMenuOnBottom)
		: AControl(NULL,false)
		{
			CThrownOSStatus err = ::CreateBevelButtonControl(
					inWindow,&inBounds,inTitle,
					inThickness,inBehavior,
					const_cast<ControlButtonContentInfo*>(inInfo),
					inMenuID,inMenuBehavior,inMenuPlacement,&mObject);
			mOwner = true;
		}
	
	SInt16
		MenuValue() const;
	void
		SetMenuValue(
				SInt16 inValue);
	MenuHandle
		Menu() const;
	void
		GetContentInfo(
				ControlButtonContentInfo &outContent) const;
	void
		SetContentInfo(
				const ControlButtonContentInfo &inInfo);
	void
		SetIconTransform(
				IconTransformType inTransform);
	void
		SetGraphicAlignment(
				ControlButtonGraphicAlignment inAlign,
				SInt16 inHOffset,
				SInt16 inVOffset);
	void
		SetTextAlignment(
				ControlButtonTextAlignment inAlign,
				SInt16 inHOffset);
	void
		SetTextPlacement(
 				ControlButtonTextPlacement inWhere);
};

// ---------------------------------------------------------------------------
#pragma mark APopupButton

class APopupButton :
		public AControl
{
public:
		_Basic_Constructors(APopupButton);
		APopupButton(
				WindowRef inWindow,
				const Rect &inBounds,
				CFStringRef inTitle,
				SInt16 inMenuID,
				bool inVariableWidth = false,
				SInt16 inTitleJust = teJustLeft,
				SInt16 inTitleStyle = normal)
		: AControl(NULL,false)
		{
			CThrownOSStatus err = ::CreatePopupButtonControl(
					inWindow,&inBounds,inTitle,
					inMenuID,inVariableWidth,-1,	// auto-calc width
					inTitleJust,inTitleStyle,
					&mObject);
			mOwner = true;
		}
		APopupButton(
				WindowRef inWindow,
				const Rect &inBounds,
				CFStringRef inTitle,
				MenuRef inMenu,
				bool inVariableWidth = false,
				SInt16 inTitleJust = teJustLeft,
				SInt16 inTitleStyle = normal)
		: AControl(NULL,false)
		{
			CThrownOSStatus err = ::CreatePopupButtonControl(
					inWindow,&inBounds,inTitle,
					0,inVariableWidth,-1,
					inTitleJust,inTitleStyle,
					&mObject);
			SetMenu(inMenu);
			mOwner = true;
		}
	
	void
		SetMenu(
				MenuRef inMenu)
		{
			SetData(kControlNoPart,kControlPopupButtonMenuRefTag,inMenu);
		}
	void
		SetOwnedMenu(
				MenuRef inMenu)
		{
			SetData(kControlNoPart,kControlPopupButtonOwnedMenuRefTag,inMenu);
		}
	void
		SetExtraHeight(
				SInt16 inHeight)
		{
			SetData(kControlNoPart,kControlPopupButtonExtraHeightTag,inHeight);
		}
	void
		SetCheckCurrent(
				bool inDoCheck)
		{
			Boolean doCheck = inDoCheck;
			SetData(kControlNoPart,kControlPopupButtonCheckCurrentTag,doCheck);
		}
	
	MenuRef
		Menu() const
		{
			return Data<MenuRef>(kControlNoPart,kControlPopupButtonMenuRefTag);
		}
	SInt16
		ExtraHeight() const
		{
			return Data<SInt16>(kControlNoPart,kControlPopupButtonExtraHeightTag);
		}
	bool
		DoesCheckCurrent() const
		{
			return Data<Boolean>(kControlNoPart,kControlPopupButtonCheckCurrentTag);
		}
};

// ---------------------------------------------------------------------------
#pragma mark ADisclosureButton

class ADisclosureButton :
		public AControl
{
public:
		_Basic_Constructors(ADisclosureButton);
		ADisclosureButton(
				WindowRef inWindow,
				const Rect &inBounds,
				SInt32 inValue,
				bool inAutoToggles)
		: AControl(NULL,false)
		{
			CThrownOSStatus err = ::CreateDisclosureButtonControl(inWindow,&inBounds,inValue,inAutoToggles,&mObject);
			mOwner = true;
		}
};

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline SInt16
ABevelButton::MenuValue() const
{
	SInt16 menuValue;
	CThrownOSStatus err = ::GetBevelButtonMenuValue(*this,&menuValue);
	return menuValue;
}

inline void
ABevelButton::SetMenuValue(
		SInt16 inValue)
{
	CThrownOSStatus err = ::SetBevelButtonMenuValue(*this,inValue);
}

inline MenuHandle
ABevelButton::Menu() const
{
	MenuHandle menu;
	CThrownOSStatus err = ::GetBevelButtonMenuHandle(*this,&menu);
	return menu;
}

inline void
ABevelButton::GetContentInfo(
		ControlButtonContentInfo &outContent) const
{
	CThrownOSStatus err = ::GetBevelButtonContentInfo(*this,&outContent);
}

inline void
ABevelButton::SetContentInfo(
		const ControlButtonContentInfo &inInfo)
{
	CThrownOSStatus err = ::SetBevelButtonContentInfo(*this,const_cast<ControlButtonContentInfo*>(&inInfo));
}

inline void
ABevelButton::SetIconTransform(
		IconTransformType inTransform)
{
	CThrownOSStatus err = ::SetBevelButtonTransform(*this,inTransform);
}

inline void
ABevelButton::SetGraphicAlignment(
		ControlButtonGraphicAlignment inAlign,
		SInt16 inHOffset,
		SInt16 inVOffset)
{
	CThrownOSStatus err = ::SetBevelButtonGraphicAlignment(*this,inAlign,inHOffset,inVOffset);
}

inline void
ABevelButton::SetTextAlignment(
		ControlButtonTextAlignment inAlign,
		SInt16 inHOffset)
{
	CThrownOSStatus err = ::SetBevelButtonTextAlignment(*this,inAlign,inHOffset);
}

inline void
ABevelButton::SetTextPlacement(
		ControlButtonTextPlacement inWhere)
{
	CThrownOSStatus err = ::SetBevelButtonTextPlacement(*this,inWhere);
}

// ---------------------------------------------------------------------------
