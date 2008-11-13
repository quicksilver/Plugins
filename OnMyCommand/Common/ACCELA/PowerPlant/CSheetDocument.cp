// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "CSheetDocument.h"

#include "AAEDescList.h"
#include "ACarbonEvent.h"
#include "ACFBundle.h"
#include "ACFString.h"

#include "CThrownResult.h"

#if PP_Uses_PowerPlant_Namespace
using namespace PowerPlant;
#endif

// ---------------------------------------------------------------------------

CSheetDocument::CSheetDocument(
		LCommander *inSuper)
: LSingleDoc(inSuper),
  mClosing(false),mQuitting(false),mRecording(RecordAE_No),mNavDialog(NULL)
{
}

// ---------------------------------------------------------------------------

CSheetDocument::~CSheetDocument()
{
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
CSheetDocument::ListenToMessage(
		MessageT inMessage,
		void *)
{
	FSSpec fileSpec = {0, 0, "\p"};
	
	switch (inMessage) {
		
		// Save Changes
		case navSave_Save:
			SheetSaveConfirmed();
			break;
		
		case navSave_DontSave:
			SheetSaveDenied();
			break;
		
		// Revert
		case navDiscard_Discard:
			SheetDiscardedChanges();
			break;
		
		// Save As
		case navPut_Save:
			SheetSaved();
			break;
		
		// Open
		case navGet_Choose:
			SheetOpened();
			break;
		
		case navSave_Cancel:
		case navQuit_Cancel:
		case navDiscard_Cancel:
		case navGet_Cancel:
		case navPut_Cancel:
			SheetCanceled();
			break;
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

Boolean
CSheetDocument::ObeyCommand(
		CommandT inCommand,
		void *ioParam)
{
	bool handled = true;
	
	switch (inCommand) {
		
		case cmd_Revert:
			DoRevertSheet();
			break;
		
		default:
			handled = LSingleDoc::ObeyCommand(inCommand,ioParam);
			break;
	}
	return handled;
}

// ---------------------------------------------------------------------------

void
CSheetDocument::FindCommandStatus(
		CommandT inCommand,
		Boolean &outEnabled,
		Boolean &outUsesMark,
		UInt16 &outMark,
		Str255 outName)
{
	// Handle all the same commands that LDocument does
	switch (inCommand) {
		
		case cmd_Close:
		case cmd_SaveAs:
		case cmd_PageSetup:
		case cmd_Print:
		case cmd_PrintOne:
			outEnabled = (mNavDialog.get() == NULL);
			break;

		case cmd_Save:
			outEnabled = (IsModified() || !IsSpecified()) && (mNavDialog.get() == NULL);
			break;

		case cmd_Revert:
			outEnabled = (IsModified() && IsSpecified() && (mNavDialog.get() == NULL));
			break;

		default:
			LSingleDoc::FindCommandStatus(inCommand,outEnabled,outUsesMark,outMark,outName);
			break;
	}
}

// ---------------------------------------------------------------------------

Boolean
CSheetDocument::AttemptQuitSelf(
		SInt32 inSaveOption)
{
	Boolean allowQuit;
	
	if (IsModified() && (inSaveOption == kAEAsk)) {
		mQuitting = true;
		DoSaveChangesSheet(kNavSaveChangesQuittingApplication);
		allowQuit = false; 
	}
	else
		allowQuit = LSingleDoc::AttemptQuitSelf(inSaveOption);
	
	return allowQuit;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
CSheetDocument::AttemptClose(
		Boolean inRecord)
{
	if (IsModified()) {
		mRecording = inRecord;
		mClosing = true;
		DoSaveChangesSheet(kNavSaveChangesClosingDocument);
	}
	else
		LDocument::AttemptClose(inRecord);
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoAEClose(
		const AppleEvent &inAppleEvent)
{
	OSErr err;
	DescType dataType;
	Size dataSize;
	SInt32 saveOption = kAEAsk;

	err = ::AEGetParamPtr(
			&inAppleEvent,keyAESaveOptions,
			typeEnumeration,&dataType,&saveOption,
			sizeof(saveOption),&dataSize);
	
	// should check for a file parameter too...
	
	// if there was an error, "ask" is the default anyway
	if ((saveOption == kAEAsk) && IsModified()) {
		mClosing = true;
		DoSaveChangesSheet(kNavSaveChangesClosingDocument);
	}
	else
		LSingleDoc::DoAEClose(inAppleEvent);
}

// ---------------------------------------------------------------------------

Boolean
CSheetDocument::AskSaveAs(
		FSSpec&,
		Boolean inRecord)
{
	mRecording = inRecord;
	DoSaveSheet();
	return false;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

CFStringRef
CSheetDocument::CopyName()
{
	CFStringRef titleRef = NULL;
	OSStatus err;
	
	if (mWindow != NULL) {
		err = ::CopyWindowTitleAsCFString(mWindow->GetMacWindow(),&titleRef);
		if (err != noErr) {
			Str255 titleString;
			
			mWindow->GetDescriptor(titleString);
			titleRef = ::CFStringCreateWithPascalString(kCFAllocatorDefault,titleString,kCFStringEncodingMacRoman);
		}
	}
	return titleRef;
}

// ---------------------------------------------------------------------------

OSType
CSheetDocument::GetFileCreator()
{
	ProcessInfoRec info;
	ProcessSerialNumber currentProcess = { 0,kCurrentProcess };
	
	info.processInfoLength = sizeof(info);
	::GetProcessInformation(&currentProcess,&info);
	return info.processSignature;
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoAESaveFSRef(
		const FSRef &,
		CFStringRef,
		OSType)
{
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoOpenFSRef(
		const FSRef &)
{
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoOpenFSSpec(
		const FSSpec &)
{
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DisplayWindow()
{
	WindowPtr window = mWindow->GetMacWindow();
	
	if (::IsWindowCollapsed(window))
		::CollapseWindow(window,false);
	mWindow->Select();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::RunDialog()
{
	PreRunSheet();
	mNavDialog->Run();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoSaveChangesSheet(
		NavAskSaveChangesAction inAction)
{
	ACFString docName(CopyName(),false);
	
	DisplayWindow();
	mNavDialog.reset(NEW ANavAskSaveChangesDialog(
			inAction,
			ANavCreationOptions(
					mWindow->GetMacWindow(),
					ACFBundle::GetAppName(),
					docName),
			this,
			LModelDirector::GetCurrentAEReply()));
	RunDialog();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoRevertSheet()
{
	ACFString docName(CopyName(),false);
	
	DisplayWindow();
	mNavDialog.reset(NEW ANavAskDiscardChangesDialog(
			ANavCreationOptions(
					mWindow->GetMacWindow(),
					ACFBundle::GetAppName(),
					docName),
			this));
	RunDialog();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoSaveSheet()
{
	ACFString docName(CopyName(),false);
	
	DisplayWindow();
	mNavDialog.reset(NEW ANavPutFileDialog(
			ANavCreationOptions(
					mWindow->GetMacWindow(),
					ACFBundle::GetAppName(),
					docName),
			GetFileCreator(),
			GetFileType(),
			this));
	RunDialog();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::DoOpenSheet()
{
	DisplayWindow();
	mNavDialog.reset(NEW ANavChooseObjectDialog(
			ANavCreationOptions(mWindow->GetMacWindow()),
			this));
	RunDialog();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::SheetSaveConfirmed()
{
	mNavDialog.reset(NULL);
	if (IsSpecified()) {
		DoSave();
		ContinueCloseOrQuit();
	}
	else {
		mClosing = true;
		DoSaveSheet();
	}
}

// ---------------------------------------------------------------------------

void
CSheetDocument::SheetSaveDenied()
{
	mNavDialog.reset(NULL);
	if (mRecording) {
		try {
			FSSpec fileSpec = { 0 };
			
			SendAEClose(kAENo,fileSpec,ExecuteAE_No);
		}
		catch (...) {}
	}
	ContinueCloseOrQuit();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::SheetDiscardedChanges()
{
	mNavDialog.reset(NULL);
	SendSelfAE(kAEMiscStandards,kAERevert,ExecuteAE_No);
	DoRevert();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::SheetSaved()
{
	ANavReply reply(*mNavDialog);
	ACFString fileName(reply.saveFileName);
	AAEDesc fsRefDesc;
	CThrownOSStatus err;
	
	err.Allow(errAECoercionFail);
	err = ::AECoerceDesc(&reply.selection,typeFSRef,&fsRefDesc);
	if (err == noErr) {
		FSRef parentRef;
		
		err = ::AEGetDescData(&fsRefDesc,&parentRef,sizeof(parentRef));
		
		if (reply.replacing) {
			FSRef fileRef;
			
			err = ::FSMakeFSRefUnicode(
					&parentRef,fileName.Length(),
					fileName.CharactersPtr(),fileName.FastestEncoding(),
					&fileRef);
			err = ::FSDeleteObject(&fileRef);
		}
		
		DoAESaveFSRef(parentRef,fileName,GetFileType());
	}
	else if (err == errAECoercionFail) {
		FSSpec fileSpec;
		AAEDesc specDesc;
		
		err.Allow(noErr);
		err = ::AECoerceDesc(&reply.selection,typeFSS,&specDesc);
		specDesc.GetDescData(fileSpec);
		fileName.EncodePascalString(fileSpec.name);
		
		if (reply.replacing)
			err = ::FSpDelete(&fileSpec);
		
		DoAESave(fileSpec,GetFileType());
	}
	else
		throw (OSStatus) err;
	
	mNavDialog.reset(NULL);
	ContinueCloseOrQuit();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::SheetOpened()
{
	ANavReply reply(*mNavDialog);
	AAEDescList fileList(reply.selection);
	CThrownOSStatus err;
	const UInt32 fileCount = fileList.Count();
	UInt32 i;
	
	for (i = 1; i <= fileCount; i++) {
		try {
			DoOpenFSRef(fileList.NthItem<FSRef>(i));
		}
		catch (OSStatus &caughtErr) {
			DoOpenFSSpec(fileList.NthItem<FSSpec>(i));
		}
	}
	
	mNavDialog.reset(NULL);
	ContinueCloseOrQuit();
}

// ---------------------------------------------------------------------------

void
CSheetDocument::SheetCanceled()
{
	AppleEvent suspendedEvent,suspendedReply;
	
	if (mNavDialog->GetSuspendedEvent(suspendedEvent,suspendedReply)) {
		OSStatus canceled = userCanceledErr;
		
		::AEPutParamPtr(&suspendedReply,keyErrorNumber,typeLongInteger,&canceled,sizeof(canceled));
	}
	mNavDialog.reset(NULL);
	mClosing = false;
	mQuitting = false;
	mRecording = false;
}

// ---------------------------------------------------------------------------

void
CSheetDocument::ContinueCloseOrQuit()
{
	bool quitting = mQuitting; // save because I'm going to delete myself
	
	if (mClosing || mQuitting)
		Close();
	if (quitting) {
		if (UEnvironment::GetOSVersion() >= 0x1000) {
			LApplication *app = dynamic_cast<LApplication*>(LCommander::GetTopCommander());
			
			if (app != NULL)
				app->DoQuit();
		}
		else {
			// Avoid Nav Svcs reentrancy issues
			ACarbonEvent quitEvent(kEventClassCommand,kEventCommandProcess);
			const HICommand quitCommand = { 0,kHICommandQuit, { 0 } };
			
			quitEvent.SetParameter(kEventParamDirectObject,typeHICommand,quitCommand);
			::PostEventToQueue(::GetMainEventQueue(),quitEvent,kEventPriorityHigh);
		}
	}
	
	mClosing = false;
	mQuitting = false;
	mRecording = false;
}
