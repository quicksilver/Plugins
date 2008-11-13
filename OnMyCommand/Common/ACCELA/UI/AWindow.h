#pragma once

#include "XRefCountObject.h"
#include "XPropertyHolder.h"

#include "CThrownResult.h"

#include FW(CoreFoundation,CFString.h)
#include FW(CoreServices,Folders.h)
#include FW(Carbon,IBCarbonRuntime.h)
#include FW(Carbon,MacWindows.h)

// ---------------------------------------------------------------------------

class AWindow :
		public XRefCountObject<WindowRef>,
		public XPropertyHolder
{
public:
		AWindow(
				WindowRef inWindowRef,
				bool inDoRetain = true)
		: XRefCountObject<WindowRef>(inWindowRef,inDoRetain) {}
		AWindow(
				WindowClass inWindowClass,
				WindowAttributes inAttributes,
				const Rect &inContentBounds);
		AWindow(
				SInt16 inID,
				WindowRef inBehindWindow = (WindowRef)-1L);
		AWindow(
				Collection inCollection);
		AWindow(
				IBNibRef inNib,
				CFStringRef inName);
	
	// XPropertyHolder
	
	void
		SetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				const void *inBuffer);
	void
		GetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				void *inBuffer) const;
	UInt32
		GetPropertySize(
				OSType inCreator,
				OSType inTag) const;
	bool
		HasProperty(
				OSType inCreator,
				OSType inTag) const;
	void
		RemoveProperty(
				OSType inCreator,
				OSType inTag);
	void
		GetPropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 &outAttributes) const;
	void
		ChangePropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 inSet,
				UInt32 inClear);
	
	// AWindow
	
	WindowAttributes
		Attributes() const;
	void
		ChangeAttributes(
				WindowAttributes inSet,
				WindowAttributes inClear);
	void
		SetModality(
				WindowModality inModality,
				WindowRef inParentWindow = NULL);
	WindowModality
		Modality() const;
	void
		GetModality(
				WindowModality &outModality,
				WindowRef &outParentWindow) const;
	CGrafPtr
		GetPort();
	
	// size & position
	void
		GetBounds(
				WindowRegionCode inRegion,
				Rect &outBounds) const;
	Rect
		Bounds(
				WindowRegionCode inRegion = kWindowContentRgn) const;
	void
		SetBounds(
				WindowRegionCode inRegion,
				const Rect &inBounds);
	void
		Reposition(
				WindowPositionMethod inMethod,
				WindowRef inParentWindow = NULL);
	void
		MoveStructure(
				short inHGlobal,
				short inVGlobal);
	
	// zooming
	bool
		IsInStandardState();
	bool
		IsInStandardState(
				Point &outIdealSize,
				Rect &outIdealStandardState);
	void
		ZoomIdeal(
				WindowPartCode inPartCode,
				Point &ioIdealSize);
	void
		GetIdealUserState(
				Rect &outUserState);
	void
		GetGreatestAreaDevice(
				WindowRegionCode inRegionCode,
				GDHandle &outDevice,
				Rect &outRect);
	
	// grouping
	WindowGroupRef
		GetGroup() const;
	void
		SetGroup(
				WindowGroupRef inGroup);
	bool
		IsInGroup(
				WindowGroupRef inGroup) const;
	
	// visibility
	void
		Show();
	void
		Hide();
	bool
		IsVisible() const;
	
	// validation
	void
		InvalRect(
				const Rect &inRect);
	void
		InvalRegion(
				RgnHandle inRegion);
	void
		ValidRect(
				const Rect &inRect);
	void
		ValidRegion(
				RgnHandle inRegion);
	
	// activation
	bool
		IsActive() const;
	void
		Activate();
	void
		Deactivate();
	WindowActivationScope
		GetActivationScope() const;
	void
		SetActivationScope(
				WindowActivationScope inScope);
	
	// content
	RGBColor
		ContentColor() const;
	void
		SetContentColor(
				const RGBColor &inColor);
	void
		GetContentPattern(
				PixPatHandle outPattern) const;
	void
		SetContentPattern(
				PixPatHandle inPattern);
	
	// scrolling
	void
		Scroll(
				const Rect &inRect,
				SInt16 inH,
				SInt16 inV,
				ScrollWindowOptions inOptions = kScrollWindowNoOptions,
				RgnHandle outExposedRgn = NULL);
	void
		Scroll(
				RgnHandle inRegion,
				SInt16 inH,
				SInt16 inV,
				ScrollWindowOptions inOptions = kScrollWindowNoOptions,
				RgnHandle outExposedRgn = NULL);
	
	// ordering
	void
		BringToFront();
	void
		SendBehind(
				WindowRef inBehindWindow);
	void
		Select();
	
	// name
	void
		SetTitle(
				ConstStr255Param inTitle);
	void
		GetTitle(
				Str255 outTitle) const;
	void
		SetTitle(
				CFStringRef inTitle);
	CFStringRef
		CopyTitle() const;
	void
		SetAlternateTitle(
				CFStringRef inTitle);
	CFStringRef
		CopyAlternateTitle() const;
	
	// proxy
	void
		SetProxy(
				const FSSpec &inSpec);
	void
		GetProxy(
				FSSpec &outSpec) const;
	void
		SetProxy(
				AliasHandle inAlias);
	void
		GetProxy(
				AliasHandle &outAlias) const;
	void
		SetProxy(
				const FSRef &inFSRef);
	void
		SetProxy(
				OSType inCreator,
				OSType inType,
				SInt16 inVRefNum = kOnSystemDisk);
	void
		SetProxy(
				IconRef inIcon);
	void
		GetProxy(
				IconRef &outIcon) const;
	void
		RemoveProxy();
	
	// modified
	bool
		IsModified() const;
	void
		SetModified(
				bool inModified);
	
	// focus
	ControlRef
		FocusedControl() const;
	void
		SetFocus(
				ControlRef inControl,
				ControlFocusPart inPart = kControlFocusNextPart);
	void
		AdvanceFocus();
	void
		ReverseFocus();
	void
		ClearFocus();
};

// ---------------------------------------------------------------------------

inline Rect
AWindow::Bounds(
		WindowRegionCode inRegion) const
{ Rect bounds;
  CThrownOSStatus err = ::GetWindowBounds(*this,inRegion,&bounds);
  return bounds; }

inline void
AWindow::GetBounds(
		WindowRegionCode inRegion,
		Rect &outBounds) const
{ CThrownOSStatus err = ::GetWindowBounds(*this,inRegion,&outBounds); }

inline WindowAttributes
AWindow::Attributes() const
{ WindowAttributes attributes;
  CThrownOSStatus err = ::GetWindowAttributes(*this,&attributes);
  return attributes; }

inline void
AWindow::ChangeAttributes(
		WindowAttributes inSet,
		WindowAttributes inClear)
{ CThrownOSStatus err = ::ChangeWindowAttributes(*this,inSet,inClear); }

inline void
AWindow::SetModality(
		WindowModality inModality,
		WindowRef inParentWindow)
{ CThrownOSStatus err = ::SetWindowModality(*this,inModality,inParentWindow); }

inline WindowModality
AWindow::Modality() const
{ WindowModality modality;
  CThrownOSStatus err = ::GetWindowModality(*this,&modality,NULL);
  return modality; }

inline void
AWindow::GetModality(
		WindowModality &outModality,
		WindowRef &outParentWindow) const
{ CThrownOSStatus err = ::GetWindowModality(*this,&outModality,&outParentWindow); }

inline CGrafPtr
AWindow::GetPort()
{ return ::GetWindowPort(*this); }

inline WindowGroupRef
AWindow::GetGroup() const
{ return ::GetWindowGroup(*this); }

inline void
AWindow::SetGroup(
		WindowGroupRef inGroup)
{ CThrownOSStatus err = ::SetWindowGroup(*this,inGroup); }

inline bool
AWindow::IsInGroup(
		WindowGroupRef inGroup) const
{ return ::IsWindowContainedInGroup(*this,inGroup); }

inline void
AWindow::Show()
{ ::ShowWindow(*this); }

inline void
AWindow::Hide()
{ ::HideWindow(*this); }

inline bool
AWindow::IsVisible() const
{ return ::IsWindowVisible(*this); }

inline void
AWindow::InvalRect(
		const Rect &inRect)
{
	InvalWindowRect(*this,&inRect);
}

inline void
AWindow::InvalRegion(
		RgnHandle inRegion)
{
	InvalWindowRgn(*this,inRegion);
}

inline void
AWindow::ValidRect(
		const Rect &inRect)
{
	ValidWindowRect(*this,&inRect);
}

inline void
AWindow::ValidRegion(
		RgnHandle inRegion)
{
	ValidWindowRgn(*this,inRegion);
}

inline bool
AWindow::IsActive() const
{ return ::IsWindowActive(*this); }

inline void
AWindow::Activate()
{ CThrownOSStatus err = ::ActivateWindow(*this,true); }

inline void
AWindow::Deactivate()
{ CThrownOSStatus err = ::ActivateWindow(*this,false); }

inline WindowActivationScope
AWindow::GetActivationScope() const
{ WindowActivationScope scope;
  CThrownOSStatus err = ::GetWindowActivationScope(*this,&scope);
  return scope; }

inline void
AWindow::SetActivationScope(
		WindowActivationScope inScope)
{ CThrownOSStatus err = ::SetWindowActivationScope(*this,inScope); }

inline RGBColor
AWindow::ContentColor() const
{ RGBColor color;
  CThrownOSStatus err = ::GetWindowContentColor(*this,&color);
  return color; }

inline void
AWindow::SetContentColor(
		const RGBColor &inColor)
{ CThrownOSStatus err = ::SetWindowContentColor(*this,&inColor); }

inline void
AWindow::GetContentPattern(
		PixPatHandle outPattern) const
{ CThrownOSStatus err = ::GetWindowContentPattern(*this,outPattern); }

inline void
AWindow::SetContentPattern(
		PixPatHandle inPattern)
{ CThrownOSStatus err = ::SetWindowContentPattern(*this,inPattern); }

inline void
AWindow::Scroll(
		const Rect &inRect,
		SInt16 inH,
		SInt16 inV,
		ScrollWindowOptions inOptions,
		RgnHandle outExposedRgn)
{ CThrownOSStatus err = ::ScrollWindowRect(*this,&inRect,inH,inV,inOptions,outExposedRgn); }

inline void
AWindow::Scroll(
		RgnHandle inRegion,
		SInt16 inH,
		SInt16 inV,
		ScrollWindowOptions inOptions,
		RgnHandle outExposedRgn)
{ CThrownOSStatus err = ::ScrollWindowRegion(*this,inRegion,inH,inV,inOptions,outExposedRgn); }

inline void
AWindow::BringToFront()
{ ::BringToFront(*this); }

inline void
AWindow::SendBehind(
		WindowRef inBehindWindow)
{ ::SendBehind(*this,inBehindWindow); }

inline void
AWindow::Select()
{ ::SelectWindow(*this); }

inline void
AWindow::SetTitle(
		ConstStr255Param inTitle)
{ ::SetWTitle(*this,inTitle); }

inline void
AWindow::GetTitle(
		Str255 outTitle) const
{ ::GetWTitle(*this,outTitle); }

inline void
AWindow::SetTitle(
		CFStringRef inTitle)
{ CThrownOSStatus err = ::SetWindowTitleWithCFString(*this,inTitle); }

inline CFStringRef
AWindow::CopyTitle() const
{ CFStringRef title;
  CThrownOSStatus err = ::CopyWindowTitleAsCFString(*this,&title);
  return title; }

inline void
AWindow::SetAlternateTitle(
		CFStringRef inTitle)
{ CThrownOSStatus err = ::SetWindowAlternateTitle(*this,inTitle); }

inline CFStringRef
AWindow::CopyAlternateTitle() const
{
	CFStringRef title;
	CThrownOSStatus err = ::CopyWindowAlternateTitle(*this,&title);
	return title;
}

inline void
AWindow::SetProxy(
			const FSSpec &inSpec)
{
	CThrownOSStatus err = ::SetWindowProxyFSSpec(*this,&inSpec);
}

inline void
AWindow::GetProxy(
			FSSpec &outSpec) const
{
	CThrownOSStatus err = ::GetWindowProxyFSSpec(*this,&outSpec);
}

inline void
AWindow::SetProxy(
			AliasHandle inAlias)
{
	CThrownOSStatus err = ::SetWindowProxyAlias(*this,inAlias);
}

inline void
AWindow::GetProxy(
			AliasHandle &outAlias) const
{
	CThrownOSStatus err = ::GetWindowProxyAlias(*this,&outAlias);
}

inline void
AWindow::SetProxy(
			const FSRef &inFSRef)
{
	AliasHandle alias;
	CThrownOSStatus err = ::FSNewAlias(NULL,&inFSRef,&alias);
	err = ::SetWindowProxyAlias(*this,alias);
}

inline void
AWindow::SetProxy(
			OSType inCreator,
			OSType inType,
			SInt16 inVRefNum)
{
	CThrownOSStatus err = ::SetWindowProxyCreatorAndType(*this,inCreator,inType,inVRefNum);
}

inline void
AWindow::SetProxy(
			IconRef inIcon)
{
	CThrownOSStatus err = ::SetWindowProxyIcon(*this,inIcon);
}

inline void
AWindow::GetProxy(
			IconRef &outIcon) const
{
	CThrownOSStatus err = ::GetWindowProxyIcon(*this,&outIcon);
}

inline void
AWindow::RemoveProxy()
{
	CThrownOSStatus err = ::RemoveWindowProxy(*this);
}

inline bool
AWindow::IsModified() const
{
	return ::IsWindowModified(*this);
}

inline void
AWindow::SetModified(
		bool inModified)
{
	CThrownOSStatus err = ::SetWindowModified(*this,inModified);
}

inline ControlRef
AWindow::FocusedControl() const
{
	ControlRef control;
	CThrownOSStatus err = ::GetKeyboardFocus(*this,&control);
	return control;
}

inline void
AWindow::SetFocus(
		ControlRef inControl,
		ControlFocusPart inPart)
{
	CThrownOSStatus err = ::SetKeyboardFocus(*this,inControl,inPart);
}

inline void
AWindow::AdvanceFocus()
{
	CThrownOSStatus err = ::AdvanceKeyboardFocus(*this);
}

inline void
AWindow::ReverseFocus()
{
	CThrownOSStatus err = ReverseKeyboardFocus(*this);
}

inline void
AWindow::ClearFocus()
{
	CThrownOSStatus err = ClearKeyboardFocus(*this);
}

// ---------------------------------------------------------------------------

inline void
AWindow::SetPropertyData(
		OSType inCreator,
		OSType inTag,
		UInt32 inSize,
		const void *inBuffer)
{
	CThrownOSStatus err = ::SetWindowProperty(*this,inCreator,inTag,inSize,const_cast<void*>(inBuffer));
}

inline void
AWindow::GetPropertyData(
		OSType inCreator,
		OSType inTag,
		UInt32 inSize,
		void *inBuffer) const
{
	CThrownOSStatus err = ::GetWindowProperty(*this,inCreator,inTag,inSize,NULL,inBuffer);
}

inline UInt32
AWindow::GetPropertySize(
		OSType inCreator,
		OSType inTag) const
{
	UInt32 propertySize;
	CThrownOSStatus err = ::GetWindowPropertySize(*this,inCreator,inTag,&propertySize);
	return propertySize;
}

inline bool
AWindow::HasProperty(
		OSType inCreator,
		OSType inTag) const
{
	UInt32 attributes;
	return ::GetWindowPropertyAttributes(*this,inCreator,inTag,&attributes) == noErr;
}

inline void
AWindow::RemoveProperty(
		OSType inCreator,
		OSType inTag)
{
	CThrownOSStatus err = ::RemoveWindowProperty(*this,inCreator,inTag);
}

inline void
AWindow::GetPropertyAttributes(
		OSType inCreator,
		OSType inTag,
		UInt32 &outAttributes) const
{
	CThrownOSStatus err = ::GetWindowPropertyAttributes(*this,inCreator,inTag,&outAttributes);
}

inline void
AWindow::ChangePropertyAttributes(
		OSType inCreator,
		OSType inTag,
		UInt32 inSet,
		UInt32 inClear)
{
	CThrownOSStatus err = ::ChangeWindowPropertyAttributes(*this,inCreator,inTag,inSet,inClear);
}

// ---------------------------------------------------------------------------

inline void
XRefCountObject<WindowRef>::Retain()
{ ::RetainWindow(*this); }

inline void
XRefCountObject<WindowRef>::Release()
{ ::ReleaseWindow(*this); }

inline UInt32
XRefCountObject<WindowRef>::GetRetainCount() const
{ return ::GetWindowRetainCount(*this); }
