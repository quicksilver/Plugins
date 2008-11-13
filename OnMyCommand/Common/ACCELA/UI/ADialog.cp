#include "ADialog.h"
#include "AWindow.h"

ModalFilterUPP AAlert::sModalUPP = NewModalFilterUPP(AAlert::ModalFilterProc);

// ---------------------------------------------------------------------------

AAlert::AAlert(
		AlertType inType,
		CFStringRef inError,
		CFStringRef inExplanation,
		const AlertStdCFStringAlertParamRec &inParam)
{
	OSStatus err;
	
	err = ::CreateStandardAlert(inType,inError,inExplanation,&inParam,&mDialogRef);
	if (err == noErr) {
		AWindow window = ::GetDialogWindow(mDialogRef);
		
		window.SetProperty('ACEL','obj ',this);
	}
}

// ---------------------------------------------------------------------------

OSStatus
AAlert::Run(
		DialogItemIndex &outItemHit)
{
	return ::RunStandardAlert(mDialogRef,sModalUPP,&outItemHit);
}

// ---------------------------------------------------------------------------

OSStatus
AAlert::Run()
{
	DialogItemIndex itemHit;
	
	return ::RunStandardAlert(mDialogRef,sModalUPP,&itemHit);
}

// ---------------------------------------------------------------------------

pascal Boolean
AAlert::ModalFilterProc(
		DialogRef inDialog,
		EventRecord *inEvent,
		DialogItemIndex *inItemHit)
{
	AWindow window = ::GetDialogWindow(inDialog);
	AAlert *alert;
	bool result = false;
	
	try {
		window.GetProperty('ACEL','obj ',alert);
		result = alert->ModalFilter(inEvent,inItemHit);
	}
	catch (...) {
	}
	return result;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AStandardSheet::AStandardSheet(
		AlertType inType,
		CFStringRef inError,
		CFStringRef inExplanation,
		const AlertStdCFStringAlertParamRec &inParam,
		EventTargetRef inTarget,
		WindowRef inParentWindow)
: mParentWindow(inParentWindow)
{
	OSStatus err;
	
	err = ::CreateStandardSheet(inType,inError,inExplanation,&inParam,inTarget,&mDialogRef);
}

// ---------------------------------------------------------------------------

OSStatus
AStandardSheet::Show()
{
	return ::ShowSheetWindow(::GetDialogWindow(mDialogRef),mParentWindow);
}
