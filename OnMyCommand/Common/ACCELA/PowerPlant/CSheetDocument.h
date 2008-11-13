// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include <LSingleDoc.h>
#include <LListener.h>

#include "ANavigation.h"

#include <memory>

class CSheetDocument :
		public PP_PowerPlant::LSingleDoc,
		public PP_PowerPlant::LListener
{
public:
		CSheetDocument(
				LCommander *inSuper);
	virtual
		~CSheetDocument();
	
	// LListener
	
	virtual void
		ListenToMessage(
				PP_PowerPlant::MessageT inMessage,
				void *ioParam = NULL);
	
	// LCommander
	
	virtual Boolean
		ObeyCommand(
				PP_PowerPlant::CommandT inCommand,
				void *ioParam = NULL);
	virtual void
		FindCommandStatus(
				PP_PowerPlant::CommandT inCommand,
				Boolean &outEnabled,
				Boolean &outUsesMark,
				UInt16 &outMark,
				Str255 outName);
	virtual Boolean
		AttemptQuitSelf(
				SInt32 inSaveOption);
	
	// LDocument
	
	virtual void
		DoAEClose(
				const AppleEvent &inAppleEvent);
	virtual void
		AttemptClose(
				Boolean inRecord);
	virtual Boolean
		AskSaveAs(
				FSSpec &outFSSpec,
				Boolean inRecordIt);
	
	// CSheetDocument
	
	virtual void
		DoAESaveFSRef(
				const FSRef &inParentFolder,
				CFStringRef inFileName,
				OSType inFileType);
	virtual void
		DoOpenFSRef(
				const FSRef &inRef);
	virtual void
		DoOpenFSSpec(
				const FSSpec &inSpec);
	
protected:
	std::auto_ptr<ANavDialog> mNavDialog;
	bool mClosing,mQuitting,mRecording;
	
	// CSheetDocuent
	
	void
		RunDialog();
	
	virtual CFStringRef
		CopyName();
	virtual OSType
		GetFileCreator();
	
	virtual void
		DisplayWindow();
	
	virtual void
		DoSaveChangesSheet(
				NavAskSaveChangesAction inAction);
	virtual void
		DoRevertSheet();
	virtual void
		DoSaveSheet();
	virtual void
		DoOpenSheet();
	
	virtual void
		SheetSaveConfirmed();
	virtual void
		SheetSaveDenied();
	virtual void
		SheetDiscardedChanges();
	virtual void
		SheetSaved();
	virtual void
		SheetOpened();
	virtual void
		SheetCanceled();
	
	virtual void
		ContinueCloseOrQuit();
	
	virtual void
		PreRunSheet() {}
};
