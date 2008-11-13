#include "ANavigation.h"
#include "AAEDesc.h"

#include "CThrownResult.h"

#include FW(CoreServices,Files.h)

#include "MoreFilesExtras.h"

#if PP_Uses_PowerPlant_Namespace
using namespace PowerPlant;
#endif

NavEventUPP        ANavDialog::sEventUPP = NewNavEventUPP(ANavDialog::EventProc);
NavPreviewUPP      ANavGetDialog::sNavPreviewUPP = NewNavPreviewUPP(ANavGetDialog::PreviewProc);
NavObjectFilterUPP ANavGetDialog::sNavFilterUPP = NewNavObjectFilterUPP(ANavGetDialog::FilterProc);

// ---------------------------------------------------------------------------

ANavDialog::ANavDialog(
		const AppleEvent *inReply,
		const AppleEvent *inEvent)
: mDialogRef(NULL),mRunResult(msg_Nothing)
{
	if (inReply != NULL) {
		if (inEvent != NULL)
			mSuspendedEvent.Suspend(*inEvent,*inReply);
		else
			mSuspendedEvent.Suspend(*inReply);
	}
}

// ---------------------------------------------------------------------------

ANavDialog::~ANavDialog()
{
	::RemoveWindowProperty(GetWindow(),'ACEL','obj ');
	::NavDialogDispose(mDialogRef);
	
	if (mSuspendedEvent.Suspended())
		mSuspendedEvent.Resume();
}

// ---------------------------------------------------------------------------

bool
ANavDialog::HasSheets()
{
	static bool hasSheets = PP_PowerPlant::UEnvironment::HasGestaltAttribute(gestaltWindowMgrAttr,gestaltSheetsAreWindowModalBit);
	
	return hasSheets;
}

// ---------------------------------------------------------------------------

void
ANavDialog::Run()
{
	mRunResult = msg_Nothing;
	
	CThrownOSStatus err = ::NavDialogRun(mDialogRef);
	
	// If HasSheets returns true, then the result has already been broadcast
	// and the dialog has probably already been deleted
	if (!HasSheets() && (mRunResult != msg_Nothing))
		BroadcastMessage(mRunResult);
}

// ---------------------------------------------------------------------------

bool
ANavDialog::GetSuspendedEvent(
		AppleEvent &outEvent,
		AppleEvent &outReply)
{
	outEvent = mSuspendedEvent.GetEvent();
	outReply = mSuspendedEvent.GetReply();
	return mSuspendedEvent.Suspended();
}

// ---------------------------------------------------------------------------

void
ANavDialog::DontResumeSuspendedEvent()
{
	mSuspendedEvent.DontResume();
}

// ---------------------------------------------------------------------------

bool
ANavDialog::IsPreviewShowing()
{
	Boolean isShowing = false;
	
	::NavCustomControl(mDialogRef,kNavCtlIsPreviewShowing,(void*)&isShowing);
	return isShowing;
}

// ---------------------------------------------------------------------------

UInt16
ANavDialog::GetFirstControlID()
{
	UInt16 controlID = -1;
	
	::NavCustomControl(mDialogRef,kNavCtlGetFirstControlID,(void*)&controlID);
	return controlID;
}

// ---------------------------------------------------------------------------

OSErr
ANavDialog::SelectEditFileName(
		SInt16 inStart,
		SInt16 inEnd)
{
	ControlEditTextSelectionRec selectionRec = { inStart,inEnd };
	
	return ::NavCustomControl(mDialogRef,kNavCtlSelectEditFileName,(void*)&selectionRec);
}

// ---------------------------------------------------------------------------

void
ANavDialog::UserAction(
		NavUserAction inUserAction)
{
	switch (inUserAction) {
		
		case kNavUserActionOpen:
		case kNavUserActionChoose:
			{
				ANavReply openReply(*this);
				
				BroadcastAction(navGet_Choose,&openReply);
			}
			break;
		
		case kNavUserActionSaveAs:
			{
				ANavReply saveReply(*this);
				
				BroadcastAction(navPut_Save,&saveReply);
			}
			break;
		
		case kNavUserActionSaveChanges:
			BroadcastAction(navSave_Save);
			break;
		
		case kNavUserActionDontSaveChanges:
			BroadcastAction(navSave_DontSave);
			break;
		
		case kNavUserActionDiscardChanges:
			BroadcastAction(navDiscard_Discard);
			break;
	}
}

// ---------------------------------------------------------------------------

void
ANavDialog::BrandWindow()
{
	ANavDialog *me = this;
	WindowRef window = GetWindow();
	
	if (window != NULL)
		::SetWindowProperty(window,'ACEL','obj ',sizeof(me),&me);
}

// ---------------------------------------------------------------------------

pascal void
ANavDialog::EventProc(
		NavEventCallbackMessage inSelector,
		NavCBRecPtr inParams,
		void *inUserData)
{
	try {
		ANavDialog *navDialog = static_cast<ANavDialog*>(inUserData);
		
		switch (inSelector) {
			
			case kNavCBEvent:
				navDialog->Event(inParams->eventData);
				break;
			
			case kNavCBCustomize:
				navDialog->BrandWindow();
				navDialog->Customize(inParams->customRect);
				break;
			
			case kNavCBStart:
				navDialog->Start(inParams->customRect);
				break;
			
			case kNavCBTerminate:
				// The object has probably been deleted, so don't call it
				break;
			
			case kNavCBAdjustRect:
				navDialog->AdjustRect(inParams->customRect,inParams->previewRect);
				break;
			
			case kNavCBNewLocation:
				navDialog->NewLocation(static_cast<AEDesc*>(inParams->eventData.eventDataParms.param));
				break;
			
			case kNavCBShowDesktop:
				navDialog->ShowedDesktop();
				break;
			
			case kNavCBSelectEntry:
				navDialog->SelectEntry(static_cast<AEDescList*>(inParams->eventData.eventDataParms.param));
				break;
			
			case kNavCBPopupMenuSelect:
				navDialog->PopupMenuSelect(static_cast<NavMenuItemSpec*>(inParams->eventData.eventDataParms.param));
				break;
			
			case kNavCBAccept:
				navDialog->Accepted();
				break;
			
			case kNavCBCancel:
				navDialog->Canceled();
				break;
			
			case kNavCBAdjustPreview:
				navDialog->AdjustPreview(inParams->previewRect,*static_cast<Boolean*>(inParams->eventData.eventDataParms.param));
				break;
			
			case kNavCBUserAction:
				if (inParams->userAction != kNavUserActionNone)
				navDialog->UserAction(inParams->userAction);
				break;
			
			case kNavCBOpenSelection:
				navDialog->OpenedSelection();
				break;
		}
	}
	catch (...) {
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

CFStringRef
ANavSaveDialog::GetSaveFileName()
{
	return ::NavDialogGetSaveFileName(mDialogRef);
}

// ---------------------------------------------------------------------------

OSStatus
ANavSaveDialog::SetSaveFileName(
		CFStringRef inFileName)
{
	return ::NavDialogSetSaveFileName(mDialogRef,inFileName);
}

// ---------------------------------------------------------------------------

void
ANavSaveDialog::UserAction(
		NavUserAction inUserAction)
{
	switch (inUserAction) {
		
		case kNavUserActionCancel:
			BroadcastAction(navPut_Cancel);
			break;
		
		case kNavUserActionSaveAs:
			BroadcastAction(navPut_Save);
			break;
		
		default:
			ANavDialog::UserAction(inUserAction);
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
ANavGetDialog::UserAction(
		NavUserAction inUserAction)
{
	switch (inUserAction) {
		
		case kNavUserActionCancel:
			BroadcastAction(navGet_Cancel);
			break;
		
		default:
			ANavDialog::UserAction(inUserAction);
	}
}

// ---------------------------------------------------------------------------

pascal Boolean
ANavGetDialog::PreviewProc(
		NavCBRecPtr inParams,
		void *inUserData)
{
	bool displayed = false;
	
	try {
		ANavGetDialog *getDialog = static_cast<ANavGetDialog*>(inUserData);
		
		displayed = getDialog->Preview(inParams);
	}
	catch (...) {}
	
	return displayed;
}

// ---------------------------------------------------------------------------

pascal Boolean
ANavGetDialog::FilterProc(
		AEDesc *inItem,
		void *inInfo,
		void *inUserData,
		NavFilterModes inFilterMode)
{
	bool filtered = false;
	
	try {
		ANavGetDialog *getDialog = static_cast<ANavGetDialog*>(inUserData);
		
		filtered = getDialog->Filter(inItem,inInfo,inFilterMode);
	}
	catch (...) {}
	
	return filtered;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ANavGetFileDialog::ANavGetFileDialog(
		const NavDialogCreationOptions &inOptions,
		NavTypeListHandle inTypeList,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent,
		bool inUsePreviewProc,
		bool inUseFilterProc)
: ANavGetDialog(inReply,inEvent)
{
	::NavCreateGetFileDialog(
			&inOptions,inTypeList,sEventUPP,
			inUsePreviewProc ? sNavPreviewUPP : NULL,
			inUseFilterProc ? sNavFilterUPP : NULL,
			(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

ANavPutFileDialog::ANavPutFileDialog(
		const NavDialogCreationOptions &inOptions,
		OSType inCreator,
		OSType inType,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent)
: ANavSaveDialog(inReply,inEvent)
{
	::NavCreatePutFileDialog(&inOptions,inType,inCreator,sEventUPP,(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ANavAskReviewDocumentsDialog::ANavAskReviewDocumentsDialog(
		const NavDialogCreationOptions &inOptions,
		UInt32 inDocumentCount,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent)
: ANavDialog(inReply,inEvent)
{
	::NavCreateAskReviewDocumentsDialog(&inOptions,inDocumentCount,sEventUPP,(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

void
ANavAskReviewDocumentsDialog::UserAction(
		NavUserAction inUserAction)
{
	switch (inUserAction) {
		
		case kNavUserActionCancel:
			BroadcastAction(navReview_Cancel);
			break;
		
		case kNavUserActionReviewDocuments:
			BroadcastAction(navReview_Review);
			break;
		
		case kNavUserActionDiscardDocuments:
			BroadcastAction(navReview_Discard);
			break;
		
		default:
			ANavDialog::UserAction(inUserAction);
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ANavAskSaveChangesDialog::ANavAskSaveChangesDialog(
		NavAskSaveChangesAction inAction,
		const NavDialogCreationOptions &inOptions,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent)
: ANavDialog(inReply,inEvent)
{
	::NavCreateAskSaveChangesDialog(&inOptions,inAction,sEventUPP,(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

void
ANavAskSaveChangesDialog::UserAction(
		NavUserAction inUserAction)
{
	switch (inUserAction) {
		
		case kNavUserActionCancel:
			BroadcastAction(navSave_Cancel);
			break;
		
		case kNavUserActionSaveChanges:
			BroadcastAction(navSave_Save);
			break;
		
		case kNavUserActionDontSaveChanges:
			BroadcastAction(navSave_DontSave);
			break;
		
		default:
			ANavDialog::UserAction(inUserAction);
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ANavAskDiscardChangesDialog::ANavAskDiscardChangesDialog(
		const NavDialogCreationOptions &inOptions,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent)
: ANavDialog(inReply,inEvent)
{
	::NavCreateAskDiscardChangesDialog(&inOptions,sEventUPP,(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

void
ANavAskDiscardChangesDialog::UserAction(
		NavUserAction inUserAction)
{
	switch (inUserAction) {
		
		case kNavUserActionCancel:
			BroadcastAction(navDiscard_Cancel);
			break;
		
		default:
			ANavDialog::UserAction(inUserAction);
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ANavChooseFileDialog::ANavChooseFileDialog(
		const NavDialogCreationOptions &inOptions,
		NavTypeListHandle inTypeList,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent,
		bool inUsePreviewProc,
		bool inUseFilterProc)
: ANavGetDialog(inReply,inEvent)
{
	::NavCreateChooseFileDialog(
			&inOptions,inTypeList,sEventUPP,
			inUsePreviewProc ? sNavPreviewUPP : NULL,
			inUseFilterProc ? sNavFilterUPP : NULL,
			(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

ANavChooseFolderDialog::ANavChooseFolderDialog(
		const NavDialogCreationOptions &inOptions,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent,
		bool inUseFilterProc)
: ANavGetDialog(inReply,inEvent)
{
	::NavCreateChooseFolderDialog(
			&inOptions,sEventUPP,
			inUseFilterProc ? sNavFilterUPP : NULL,
			(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

ANavChooseVolumeDialog::ANavChooseVolumeDialog(
		const NavDialogCreationOptions &inOptions,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent,
		bool inUseFilterProc)
: ANavGetDialog(inReply,inEvent)
{
	::NavCreateChooseVolumeDialog(
			&inOptions,sEventUPP,
			inUseFilterProc ? sNavFilterUPP : NULL,
			(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

ANavChooseObjectDialog::ANavChooseObjectDialog(
		const NavDialogCreationOptions &inOptions,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent,
		bool inUsePreviewProc,
		bool inUseFilterProc)
: ANavGetDialog(inReply,inEvent)
{
	::NavCreateChooseObjectDialog(
			&inOptions,sEventUPP,
			inUsePreviewProc ? sNavPreviewUPP : NULL,
			inUseFilterProc ? sNavFilterUPP : NULL,
			(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------

ANavNewFolderDialog::ANavNewFolderDialog(
		const NavDialogCreationOptions &inOptions,
		PP_PowerPlant::LListener *inListener,
		const AppleEvent *inReply,
		const AppleEvent *inEvent)
: ANavSaveDialog(inReply,inEvent)
{
	::NavCreateNewFolderDialog(&inOptions,sEventUPP,(void*)this,&mDialogRef);
	AddListener(inListener);
	BrandWindow();
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ANavReply::ANavReply(
		ANavDialog &inDialog)
{
	inDialog.GetReply(*this);
}

// ---------------------------------------------------------------------------

ANavReply::~ANavReply()
{
	::NavDisposeReply(this);
}

// ---------------------------------------------------------------------------

void
ANavReply::GetSaveSpec(
		FSSpec &outSpec)
{
	AAEDesc fsRefDesc;
	CThrownOSStatus err;
	
	try {
		if (UEnvironment::GetOSVersion() >= 0x0900) {
			FSRef parentRef;
			FSCatalogInfo catalogInfo;
			
			err = ::AECoerceDesc(&selection,typeFSRef,&fsRefDesc);
			err = ::AEGetDescData(&fsRefDesc,&parentRef,sizeof(parentRef));
			err = ::FSGetCatalogInfo(&parentRef,kFSCatInfoNodeID|kFSCatInfoVolume,&catalogInfo,NULL,NULL,NULL);
			outSpec.vRefNum = catalogInfo.volume;
			outSpec.parID = catalogInfo.nodeID;
		}
		else {
			AAEDesc fsSpecDesc(typeFSS,selection);
			FSSpec parentSpec;
			Boolean isDirectory;
			
			fsSpecDesc.GetDescData(parentSpec);
			FSpGetDirectoryID(&parentSpec,&outSpec.parID,&isDirectory);
			outSpec.vRefNum = parentSpec.vRefNum;
		}
		::CFStringGetPascalString(saveFileName,outSpec.name,63,kCFStringEncodingMacRoman);
	}
	catch (...) {
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ANavCreationOptions::ANavCreationOptions(
		WindowRef inParentWindow,
		CFStringRef inClientName,
		CFStringRef inFileName,
		CFStringRef inWindowTitle,
		CFArrayRef inTypeArray,
		NavDialogOptionFlags inSetFlags,
		NavDialogOptionFlags inClearFlags)
{
	::NavGetDefaultDialogCreationOptions(this);
	if (inParentWindow != NULL) {
		modality = kWindowModalityWindowModal;
		parentWindow = inParentWindow;
	}
	clientName = inClientName;
	saveFileName = inFileName;
	windowTitle = inWindowTitle;
	optionFlags |= inSetFlags;
	optionFlags &= ~inClearFlags;
	popupExtension = inTypeArray;
}
