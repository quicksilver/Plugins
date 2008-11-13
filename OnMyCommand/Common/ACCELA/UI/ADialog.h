#pragma once

#include "XRefCountObject.h"
#include "FW.h"

#include FW(Carbon,Dialogs.h)

// ---------------------------------------------------------------------------

class ADialog :
		public XRefCountObject<DialogRef> {
public:
		ADialog(
				DialogRef inDialog,
				bool inDoRetain = true)
		: XRefCountObject<DialogRef>(inDialog,inDoRetain) {}
	
	operator
		DialogRef()
		{ return mDialogRef; }
	
protected:
	DialogRef mDialogRef;
	
		ADialog() {}
};

// ---------------------------------------------------------------------------

class AAlert :
		public ADialog
{
public:
		AAlert(
				DialogRef inAlert,
				bool inDoRetain = true)
		: ADialog(inAlert,inDoRetain) {}
		AAlert(
				AlertType inType,
				CFStringRef inError,
				CFStringRef inExplanation,
				const AlertStdCFStringAlertParamRec &inParam);
		
	OSStatus
		Run(
				DialogItemIndex &outItemHit);
	OSStatus
		Run();
	
protected:
	static ModalFilterUPP sModalUPP;
	
	Boolean
		ModalFilter(
				EventRecord *,	// theEvent
				DialogItemIndex *)	// itemHit
		{ return false; }
	
	static pascal Boolean
		ModalFilterProc(
				DialogRef inDialog,
				EventRecord *inEvent,
				DialogItemIndex *inItemHit);
};

// ---------------------------------------------------------------------------

class AStandardSheet :
		public ADialog 
{
public:
		AStandardSheet(
				DialogRef inSheet,
				bool inDoRetain = true)
		: ADialog(inSheet,inDoRetain) {}
		AStandardSheet(
				AlertType inType,
				CFStringRef inError,
				CFStringRef inExplanation,
				const AlertStdCFStringAlertParamRec &inParam,
				EventTargetRef inTarget,
				WindowRef inParentWindow);
	
	OSStatus
		Show();
	
protected:
	WindowRef mParentWindow;
};

// ---------------------------------------------------------------------------

class AAlertParams :
		public AlertStdCFStringAlertParamRec
{
public:
	AAlertParams(
		bool inMovable = true,
		bool inHasHelpButton = false,
		CFStringRef inOKText = (CFStringRef)kAlertDefaultOKText,
		CFStringRef inCancelText = (CFStringRef)kAlertDefaultCancelText,
		CFStringRef inLeftText = (CFStringRef)kAlertDefaultOtherText,
		SInt16 inDefaultButton = kAlertStdAlertOKButton,
		SInt16 inCancelButton = kAlertStdAlertCancelButton,
		UInt16 inPosition = kWindowDefaultPosition,
		OptionBits inFlags = 0);
};

inline
AAlertParams::AAlertParams(
		bool inMovable,
		bool inHasHelpButton,
		CFStringRef inOKText,
		CFStringRef inCancelText,
		CFStringRef inLeftText,
		SInt16 inDefaultButton,
		SInt16 inCancelButton,
		UInt16 inPosition,
		OptionBits inFlags)
{
	version = kStdCFStringAlertVersionOne;
	movable = inMovable;
	helpButton = inHasHelpButton;
	defaultText = inOKText;
	cancelText = inCancelText;
	otherText = inLeftText;
	defaultButton = inDefaultButton;
	cancelButton = inCancelButton;
	position = inPosition;
	flags = inFlags;
}

// ---------------------------------------------------------------------------

inline void
XRefCountObject<DialogRef>::Retain()
{
	::RetainWindow(::GetDialogWindow(mObjectRef));
}

// ---------------------------------------------------------------------------

inline UInt32
XRefCountObject<DialogRef>::GetRetainCount() const
{
	return ::GetWindowRetainCount(::GetDialogWindow(mObjectRef));
}

// ---------------------------------------------------------------------------

inline void
XRefCountObject<DialogRef>::Release()
{
	if (GetRetainCount() == 1)
		::DisposeDialog(mObjectRef);
	else
		::ReleaseWindow(::GetDialogWindow(mObjectRef));
}
