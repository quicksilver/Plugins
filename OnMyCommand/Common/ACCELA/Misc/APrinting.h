// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XRefCountObject.h"
#include "FW.h"
#include "CThrownResult.h"

#include FW(ApplicationServices,PMApplication.h)
#include FW(ApplicationServices,PMCore.h)

// ---------------------------------------------------------------------------
#pragma mark =APMBase

class APMBase :
		public XRefCountObject<PMObject>
{
public:
		APMBase(
				PMObject inObject = NULL,
				bool inDoRetain = true)
		: XRefCountObject(inObject,inDoRetain) {}
};

inline void
XRefCountObject<PMObject>::Retain()
{
	CThrownOSStatus err = ::PMRetain(*this);
}

inline void
XRefCountObject<PMObject>::Release()
{
	CThrownOSStatus err = ::PMRelease(*this);
}

// ---------------------------------------------------------------------------
#pragma mark =APMObject

template <class T>
class APMObject :
		public APMBase
{
public:
		operator T() const
		{
			return (T)mObjectRef;
		}
	
protected:
		APMObject(
				T inObject = NULL,
				bool inDoRetain = true)
		: APMBase(inObject,inDoRetain) {}
};

// ---------------------------------------------------------------------------
#pragma mark =APMDialog

class APMDialog :
		public APMObject<PMDialog>
{
protected:
		APMDialog(
				PMDialog inDialog = NULL,
				bool inDoRetain = true)
		: APMObject(inDialog,inDoRetain) {}
	
	DialogRef
		DialogRef() const;
	
	bool
		Accepted() const;
	void
		SetAccepted(
				bool inAccepted);
	bool
		Done() const;
	void
		SetDone(
				bool inDone);
	
protected:
	static pascal void
		ItemProc(
				::DialogRef theDialog,
				short item);
	static pascal Boolean
		ModalFilterProc(
				::DialogRef theDialog,
				EventRecord *theEvent,
				DialogItemIndex *itemHit);
};

inline DialogRef
APMDialog::DialogRef() const
{
	::DialogRef dialog = NULL;
	CThrownOSStatus err = ::PMGetDialogPtr(*this,&dialog);
	return dialog;
}

inline bool
APMDialog::Accepted() const
{
	Boolean accepted = false;
	CThrownOSStatus err = ::PMGetDialogAccepted(*this,&accepted);
	return accepted;
}

inline void
APMDialog::SetAccepted(
bool inAccepted)
{
	CThrownOSStatus err = ::PMSetDialogAccepted(*this,inAccepted);
}

inline bool
APMDialog::Done() const
{
	Boolean done = false;
	CThrownOSStatus err = ::PMGetDialogDone(*this,&done);
	return done;
}

inline void
APMDialog::SetDone(
bool inDone)
{
	CThrownOSStatus err = ::PMSetDialogDone(*this,inDone);
}

// ---------------------------------------------------------------------------
#pragma mark =APrintDialog

class APrintDialog :
		public APMDialog
{
public:
		// PMDialog
		APrintDialog(
				PMDialog inDialog,
				bool inDoRetain = true)
		: APMDialog(inDialog,inDoRetain),
		  mSession(NULL) {}
		// Settings
		APrintDialog(
				PMPrintSession inSession,
				PMPrintSettings inSettings,
				PMPageFormat inFormat = kPMNoPageFormat)
		: mSession(inSession),mSettings(inSettings)
		{
			::PMSessionPrintDialogInit(mSession,mSettings,inFormat,(PMDialog*)&mObjectRef);
		}
	
	bool
		Main(
				const PMPageFormat inFormat);
	
protected:
	PMPrintSession mSession;
	PMPrintSettings mSettings;
	
	static const PMPrintDialogInitUPP sInitUPP;
	
	static pascal void
		DialogInit(
				PMPrintSettings printSettings,
				PMDialog *theDialog);
};

inline bool
APrintDialog::Main(
				const PMPageFormat inFormat)
{
	Boolean accepted = false;
	CThrownOSStatus err = ::PMSessionPrintDialogMain(mSession,mSettings,inFormat,&accepted,sInitUPP);
	return accepted;
}

// ---------------------------------------------------------------------------
#pragma mark =APageFormat

class APageFormat :
		public APMObject<PMPageFormat>
{
public:
		APageFormat(
				PMPageFormat inFormat,
				bool inDoRetain = true)
		: APMObject(inFormat,inDoRetain) {}
		APageFormat()
		{
			CThrownOSStatus err = ::PMCreatePageFormat((PMPageFormat*)&mObjectRef);
		}
};

// ---------------------------------------------------------------------------
#pragma mark =APrintSettings

class APrintSettings :
		public APMObject<PMPrintSettings>
{
public:
		// PMPrintSettings
		APrintSettings(
				PMPrintSettings inSettings,
				bool inDoRetain = true)
		: APMObject(inSettings,inDoRetain) {}
		// create
		APrintSettings()
		{
			CThrownOSStatus err = ::PMCreatePrintSettings((PMPrintSettings*)&mObjectRef);
		}
		// unflatten
		APrintSettings(
				Handle inFlattenedData);
	
	CFStringRef
		GetJobName() const;
	void
		SetJobName(
				CFStringRef inName);
	
	Handle
		Flatten() const;
	
	UInt32
		Copies() const;
	void
		SetCopies(
				UInt32 inCopies,
				bool inLock = false);
	
	UInt32
		FirstPage() const;
	void
		SetFirstPage(
				UInt32 inFirstPage,
				bool inLock = false);
	
	UInt32
		LastPage() const;
	void
		SetLastPage(
				UInt32 inLastPage,
				bool inLock = false);
	
	void
		GetPageRange(
				UInt32 &outMinPage,
				UInt32 &outMaxPage);
	void
		SetPageRange(
				UInt32 inMinPage,
				UInt32 inMaxPage);
};

// ---------------------------------------------------------------------------
#pragma mark =APrintSession

class APrintSession :
		public APMObject<PMPrintSession>
{
public:
		APrintSession(
				PMPrintSession inSession,
				bool inDoRetain = false)
		: APMObject(inSession,inDoRetain) {}
		APrintSession()
		{
			CThrownOSStatus err = ::PMCreateSession((PMPrintSession*)&mObjectRef);
		}
	
	OSStatus
		Error() const;
	void
		SetError(
				OSStatus inError);
	
	void
		UseSheets(
				WindowRef inWindow);
	
	// format
	PMPageFormat
		CreateDefaultFormat();
	void
		SetToDefaultFormat(
				PMPageFormat inFormat);
	bool
		ValidateFormat(
				PMPageFormat inFormat);
	
	// settings
	PMPrintSettings
		CreateDefaultSettings();
	void
		SetToDefaultSettings(
				PMPrintSettings inFormat);
	bool
		ValidateSettings(
				PMPrintSettings inFormat);
	
	// graphics
	void*
		GetGraphicsContext(
				CFStringRef inType);
	GrafPtr
		GrafPtr() const;
	CGContextRef
		CGContext() const;
	
	// format
	CFArrayRef
		FormatGeneration() const;
	void
		SetFormatGeneration(
				CFStringRef inFormat,
				CFArrayRef inContextTypes,
				CFTypeRef inOptions);
	
	
protected:
	PMSheetDoneUPP sDoneUPP;
	PMIdleUPP sIdleUPP;
	
	static pascal void
		IdleProc();
};

inline OSStatus
APrintSession::Error() const
{
	return ::PMSessionError(*this);
}

inline void
APrintSession::SetError(
		OSStatus inError)
{
	CThrownOSStatus err = ::PMSessionSetError(*this,inError);
}

inline void
APrintSession::UseSheets(
		WindowRef inWindow)
{
	CThrownOSStatus err = ::PMSessionUseSheets(*this,inWindow,sDoneUPP);
}

inline PMPageFormat
APrintSession::CreateDefaultFormat()
{
	APageFormat pageFormat;
	CThrownOSStatus err = ::PMSessionDefaultPageFormat(*this,pageFormat);
	pageFormat.Retain();
	return pageFormat;
}

inline void
APrintSession::SetToDefaultFormat(
		PMPageFormat inFormat)
{
	CThrownOSStatus err = ::PMSessionDefaultPageFormat(*this,inFormat);
}
inline bool
APrintSession::ValidateFormat(
		PMPageFormat inFormat)
{
	Boolean valid = false;
	CThrownOSStatus err = ::PMSessionValidatePageFormat(*this,inFormat,&valid);
	return valid;
}

inline PMPrintSettings
APrintSession::CreateDefaultSettings()
{
	APrintSettings printSettings;
	CThrownOSStatus err = ::PMSessionDefaultPrintSettings(*this,printSettings);
	printSettings.Retain();
	return printSettings;
}

inline void
APrintSession::SetToDefaultSettings(
		PMPrintSettings inFormat)
{
	CThrownOSStatus err = ::PMSessionDefaultPrintSettings(*this,inFormat);
}

inline bool
APrintSession::ValidateSettings(
		PMPrintSettings inFormat)
{
	Boolean valid = false;
	CThrownOSStatus err = ::PMSessionValidatePrintSettings(*this,inFormat,&valid);
	return valid;
}

inline void*
APrintSession::GetGraphicsContext(
		CFStringRef inType)
{
	void *context = NULL;
	CThrownOSStatus err = ::PMSessionGetGraphicsContext(*this,inType,&context);
	return context;
}

inline GrafPtr
APrintSession::GrafPtr() const
{
	::GrafPtr grafPtr = NULL;
	CThrownOSStatus err = ::PMSessionGetGraphicsContext(*this,kPMGraphicsContextQuickdraw,&(void*)grafPtr);
	return grafPtr;
}

inline CGContextRef
APrintSession::CGContext() const
{
	CGContextRef cg = NULL;
	CThrownOSStatus err = ::PMSessionGetGraphicsContext(*this,kPMGraphicsContextCoreGraphics,&(void*)cg);
	return cg;
}

// ---------------------------------------------------------------------------
#pragma mark =APrinter

class APrinter :
		public APMObject<PMPrinter>
{
public:
		APrinter(
				PMPrinter inPrinter,
				bool inDoRetain = true)
		: APMObject(inPrinter,inDoRetain) {}
		APrinter(
				PMPrintSession inSession)
		{
			CThrownOSStatus err = ::PMSessionGetCurrentPrinter(inSession,(PMPrinter*)&mObjectRef);
		}
	
	CFURLRef
		GetDescriptionURL(
				CFStringRef inDescriptionType) const;
	void
		GetLanguageInfo(
				PMLanguageInfo &outLanguageInfo) const;
	OSType
		DriverCreator() const;
	void
		GetReleaseInfo(
				VersRec &outInfo) const;
	UInt32
		ResolutionCount() const;
	void
		GetResolution(
				PMTag inTag,
				PMResolution &outResolution) const;
	void
		GetIndResolution(
				UInt32 inIndex,
				PMResolution &outResolution) const;
};

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------
#pragma mark =StPrintDocument

class StPrintDocument
{
public:
		StPrintDocument(
				PMPrintSession inSession,
				PMPrintSettings inSettings,
				PMPageFormat inFormat)
		: mSession(inSession)
		{
			::PMSessionBeginDocument(mSession,inSettings,inFormat);
		}
	virtual
		~StPrintDocument()
		{
			::PMSessionEndDocument(mSession);
		}
	
protected:
	const PMPrintSession mSession;
};

// ---------------------------------------------------------------------------
#pragma mark =StPrintPage

class StPrintPage
{
public:
		// QD Rect
		StPrintPage(
				PMPrintSession inSession,
				PMPageFormat inFormat,
				const Rect &inFrame)
		: mSession(inSession)
		{
			const PMRect pmFrame = {
					inFrame.top,
					inFrame.left,
					inFrame.bottom,
					inFrame.right };
			::PMSessionBeginPage(mSession,inFormat,&pmFrame);
		}
		// PM Rect
		StPrintPage(
				PMPrintSession inSession,
				PMPageFormat inFormat,
				const PMRect &inFrame)
		: mSession(inSession)
		{
			::PMSessionBeginPage(mSession,inFormat,&inFrame);
		}
	virtual
		~StPrintPage()
		{
			::PMSessionEndPage(mSession);
		}
	
protected:
	const PMPrintSession mSession;
};
