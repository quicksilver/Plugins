#pragma once

#include "ASuspendedEvent.h"
#include "FW.h"

#include FW(Carbon,Navigation.h)

#include <LBroadcaster.h>

#pragma warn_unusedarg off

// ---------------------------------------------------------------------------
#pragma mark ANavDialog

class ANavDialog :
		public PP_PowerPlant::LBroadcaster
{
public:
	virtual
		~ANavDialog();
	
		operator NavDialogRef()
		{ return mDialogRef; }
	
	// Suspending events
	bool
		GetSuspendedEvent(
				AppleEvent &outEvent,
				AppleEvent &outReplyPtr);
	void
		DontResumeSuspendedEvent();
	
	void
		Run();
	
	// Getting
	WindowRef
		GetWindow()
		{ return ::NavDialogGetWindow(mDialogRef); }
	NavUserAction
		GetUserAction()
		{ return ::NavDialogGetUserAction(mDialogRef); }
	void
		GetReply(NavReplyRecord &outReply)
		{ ::NavDialogGetReply(mDialogRef,&outReply); }
	
	// NavCustomControl shortcuts
	OSErr
		ShowDesktop()
		{ return ::NavCustomControl(mDialogRef,kNavCtlShowDesktop,NULL); }
	OSErr
		SortBy(
				NavSortKeyField inField)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSortBy,(void*)inField); }
	OSErr
		SortOrder(
				NavSortOrder inOrder)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSortOrder,(void*)inOrder); }
	OSErr
		ScrollHome()
		{ return ::NavCustomControl(mDialogRef,kNavCtlScrollHome,NULL); }
	OSErr
		ScrollEnd()
		{ return ::NavCustomControl(mDialogRef,kNavCtlScrollEnd,NULL); }
	OSErr
		PageUp()
		{ return ::NavCustomControl(mDialogRef,kNavCtlPageUp,NULL); }
	OSErr
		PageDown()
		{ return ::NavCustomControl(mDialogRef,kNavCtlPageDown,NULL); }
	OSErr
		GetLocation(
				AEDesc &outLocation)
		{ return ::NavCustomControl(mDialogRef,kNavCtlGetLocation,(void*)&outLocation); }
	OSErr
		SetLocation(
				AEDesc &inLocation)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSetLocation,(void*)&inLocation); }
	OSErr
		GetSelection(
				AEDescList &outLocation)
		{ return ::NavCustomControl(mDialogRef,kNavCtlGetSelection,(void*)&outLocation); }
	OSErr
		SetSelection(
				AEDescList &inSelection)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSetSelection,(void*)&inSelection); }
	OSErr
		ShowSelection()
		{ return ::NavCustomControl(mDialogRef,kNavCtlShowSelection,NULL); }
	OSErr
		OpenSelection()
		{ return ::NavCustomControl(mDialogRef,kNavCtlOpenSelection,NULL); }
	OSErr
		EjectVolume(
				short inVRefNum)
		{ return ::NavCustomControl(mDialogRef,kNavCtlEjectVolume,(void*)&inVRefNum); }
	OSErr
		NewFolder(StringPtr inFolderName)
		{ return ::NavCustomControl(mDialogRef,kNavCtlNewFolder,(void*)inFolderName); }
	OSErr
		Cancel()
		{ return ::NavCustomControl(mDialogRef,kNavCtlCancel,NULL); }
	OSErr
		Accept()
		{ return ::NavCustomControl(mDialogRef,kNavCtlAccept,NULL); }
	bool
		IsPreviewShowing();
	OSErr
		AddControl(
				ControlRef inControl)
		{ return ::NavCustomControl(mDialogRef,kNavCtlAddControl,(void*)inControl); }
	OSErr
		AddControlList(
				Handle inDITL)
		{ return ::NavCustomControl(mDialogRef,kNavCtlAddControlList,(void*)inDITL); }
	UInt16
		GetFirstControlID();
	OSErr
		SelectCustomType(
				NavMenuItemSpec &inTypeSpec)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSelectCustomType,(void*)&inTypeSpec); }
	OSErr
		SelectAllType(
				SInt16 inType)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSelectAllType,(void*)&inType); }
	OSErr
		GetEditFileName(
				StringPtr outName)
		{ return ::NavCustomControl(mDialogRef,kNavCtlGetEditFileName,(void*)outName); }
	OSErr
		SetEditFileName(
				StringPtr inName)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSetEditFileName,(void*)inName); }
	OSErr
		SelectEditFileName(
				SInt16 inStart,
				SInt16 inEnd);
	OSErr
		BrowserSelectAll()
		{ return ::NavCustomControl(mDialogRef,kNavCtlBrowserSelectAll,NULL); }
	OSErr
		GotoParent()
		{ return ::NavCustomControl(mDialogRef,kNavCtlGotoParent,NULL); }
	OSErr
		SetActionState(
				NavActionState inState)
		{ return ::NavCustomControl(mDialogRef,kNavCtlSetActionState,(void*)&inState); }
	OSErr
		BrowserRedraw()
		{ return ::NavCustomControl(mDialogRef,kNavCtlBrowserRedraw,NULL); }
	OSErr
		Terminate()
		{ return ::NavCustomControl(mDialogRef,kNavCtlTerminate,NULL); }
	
protected:
	NavDialogRef mDialogRef;
	ASuspendedEvent mSuspendedEvent;
	PP_PowerPlant::MessageT mRunResult;
	
	static NavEventUPP sEventUPP;
	static AppleEvent sSuspendedEvent,sSuspendedReply;
	
		ANavDialog(
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL);
	
	void
		BroadcastAction(
				PP_PowerPlant::MessageT inMessage,
				void *ioParam = NULL)
		{
			// When dialogs are app-modal,
			// there are re-entrancy problems
			if (HasSheets())
				BroadcastMessage(inMessage,ioParam);
			else
				mRunResult = inMessage;
		}
	
	// event callback messages
	virtual void
		Event(
				const NavEventData &inEventData) {}
	virtual void
		Customize(
				Rect &inCustomRect) {}
	virtual void
		Start(
				const Rect &inCustomRect) {}
	virtual void
		Terminated() {}
	virtual void
		AdjustRect(
				const Rect &inCustomRect,
				const Rect &inPreviewRect) {}
	virtual void
		NewLocation(
				AEDesc *inLocation) {}
	virtual void
		ShowedDesktop() {}
	virtual void
		SelectEntry(
				AEDescList *inSelection) {}
	virtual void
		PopupMenuSelect(
				NavMenuItemSpec *inMenuItem) {}
	virtual void
		Accepted() {}
	virtual void
		Canceled() {}
	virtual void
		AdjustPreview(
				const Rect &inPreviewRect,
				bool inPreviewVisible) {}
	virtual void
		UserAction(
				NavUserAction inUserAction);
	virtual void
		OpenedSelection() {}
	
	void
		BrandWindow();
	
	static pascal void
		EventProc(
				NavEventCallbackMessage inSelector,
				NavCBRecPtr inParams,
				void *inUserData);
	
	static bool
		HasSheets();
};

// ---------------------------------------------------------------------------
#pragma mark ANavSaveDialog

class ANavSaveDialog :
		public ANavDialog
{
public:
	CFStringRef
		GetSaveFileName();
	OSStatus
		SetSaveFileName(
				CFStringRef inFileName);
	
protected:
	
		ANavSaveDialog(
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL)
		: ANavDialog(inReply,inEvent) {}
	
	virtual void
		UserAction(
				NavUserAction inUserAction);
};

// ---------------------------------------------------------------------------
#pragma mark ANavCreationOptions

class ANavCreationOptions :
		public NavDialogCreationOptions
{
public:
		ANavCreationOptions()
		{ ::NavGetDefaultDialogCreationOptions(this); }
	explicit
		ANavCreationOptions(
				WindowRef inParentWindow,
				CFStringRef inClientName = NULL,
				CFStringRef inFileName = NULL,
				CFStringRef inWindowTitle = NULL,
				CFArrayRef inTypeArray = NULL,
				NavDialogOptionFlags inSetFlags = 0,
				NavDialogOptionFlags inClearFlags = 0);
};

// ---------------------------------------------------------------------------
#pragma mark ANavGetDialog

class ANavGetDialog :
		public ANavDialog
{
protected:
	static NavPreviewUPP sNavPreviewUPP;
	static NavObjectFilterUPP sNavFilterUPP;
	
		ANavGetDialog(
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL)
		: ANavDialog(inReply,inEvent) {}
	
	// ANavDialog
	
	virtual void
		UserAction(
				NavUserAction inUserAction);
	
	// ANavGetDialog
	
	virtual Boolean
		Preview(
				NavCBRecPtr inParams)
		{ return true; }
	virtual Boolean
		Filter(
				AEDesc *inItem,
				void *inInfo,
				NavFilterModes inFilterMode)
		{ return false; }
	
	static pascal Boolean
		PreviewProc(
				NavCBRecPtr inParams,
				void *inUserData);
	static pascal Boolean
		FilterProc(
				AEDesc *inIItem,
				void *inInfo,
				void *inUserData,
				NavFilterModes inFilterMode);
};

// ---------------------------------------------------------------------------
#pragma mark ANavGetFileDialog

class ANavGetFileDialog :
		public ANavGetDialog
{
public:
		ANavGetFileDialog(
				const NavDialogCreationOptions &inOptions,
				NavTypeListHandle inTypeList,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL,
				bool inUsePreviewProc = false,
				bool inUseFilterProc = false);
};

// ---------------------------------------------------------------------------
#pragma mark ANavPutFileDialog

class ANavPutFileDialog :
		public ANavSaveDialog
{
public:
		ANavPutFileDialog(
				const NavDialogCreationOptions &inOptions,
				OSType inCreator,
				OSType inType,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL);
		~ANavPutFileDialog() {}
};

// ---------------------------------------------------------------------------
#pragma mark ANavAskReviewDocumentsDialog

class ANavAskReviewDocumentsDialog :
		public ANavDialog
{
public:
		ANavAskReviewDocumentsDialog(
				const NavDialogCreationOptions &inOptions,
				UInt32 inDocumentCount,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL);
	
protected:
	virtual void
		UserAction(
				NavUserAction inUserAction);
};

// ---------------------------------------------------------------------------
#pragma mark ANavAskSaveChangesDialog

class ANavAskSaveChangesDialog :
		public ANavDialog
{
public:
		ANavAskSaveChangesDialog(
				NavAskSaveChangesAction inAction,
				const NavDialogCreationOptions &inOptions,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL);
	
protected:
	virtual void
		UserAction(
				NavUserAction inUserAction);
};

// ---------------------------------------------------------------------------
#pragma mark ANavAskDiscardChangesDialog

class ANavAskDiscardChangesDialog :
		public ANavDialog
{
public:
		ANavAskDiscardChangesDialog(
				const NavDialogCreationOptions &inOptions,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL);
	
protected:
	virtual void
		UserAction(
				NavUserAction inUserAction);
};

// ---------------------------------------------------------------------------
#pragma mark ANavChooseFileDialog

class ANavChooseFileDialog :
		public ANavGetDialog
{
public:
		ANavChooseFileDialog(
				const NavDialogCreationOptions &inOptions,
				NavTypeListHandle inTypeList,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL,
				bool inUsePreviewProc = false,
				bool inUseFilterProc = false);
};

// ---------------------------------------------------------------------------
#pragma mark ANavChooseFolderDialog

class ANavChooseFolderDialog :
		public ANavGetDialog
{
public:
		ANavChooseFolderDialog(
				const NavDialogCreationOptions &inOptions,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL,
				bool inUseFilterProc = false);
};

// ---------------------------------------------------------------------------
#pragma mark ANavChooseVolumeDialog

class ANavChooseVolumeDialog :
		public ANavGetDialog
{
public:
		ANavChooseVolumeDialog(
				const NavDialogCreationOptions &inOptions,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL,
				bool inUseFilterProc = false);
};

// ---------------------------------------------------------------------------
#pragma mark ANavChooseObjectDialog

class ANavChooseObjectDialog :
		public ANavGetDialog
{
public:
		ANavChooseObjectDialog(
				const NavDialogCreationOptions &inOptions,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL,
				bool inUsePreviewProc = false,
				bool inUseFilterProc = false);
};

// ---------------------------------------------------------------------------
#pragma mark ANavNewFolderDialog

class ANavNewFolderDialog :
		public ANavSaveDialog
{
public:
		ANavNewFolderDialog(
				const NavDialogCreationOptions &inOptions,
				PP_PowerPlant::LListener *inListener,
				const AppleEvent *inReply = NULL,
				const AppleEvent *inEvent = NULL);
};

// ---------------------------------------------------------------------------
#pragma mark ANavReply

class ANavReply :
		public NavReplyRecord {
public:
		ANavReply(ANavDialog &inDialog);
		~ANavReply();
	
	void
		GetSaveSpec(
				FSSpec &outSpec);
};

// ---------------------------------------------------------------------------

enum {
	navSave_Save       = '¤Sav',
	navSave_Cancel     = '¤Can',
	navSave_DontSave   = '¤Don',
	navDiscard_Discard = '¶Dis',
	navDiscard_Cancel  = '¶Can',
	navQuit_Review     = '½Rev',
	navQuit_DontSave   = '½Don',
	navQuit_Cancel     = '½Can',
	navGet_Choose      = '¿Chs',
	navGet_Cancel      = '¿Can',
	navPut_Save        = '¦Sav',
	navPut_Cancel      = '¦Can',
	navReview_Review   = '¨Rev',
	navReview_Discard  = '¨Dis',
	navReview_Cancel   = '¨Can'
};

#pragma warn_unusedarg reset