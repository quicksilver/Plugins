// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AApplication.h"

#include <LCommander.h>
#include <LModelObject.h>

class APeriodicalTimer;

class APPApplication : public AApplication, public LCommander, public LModelObject {
public:
		APPApplication();
	virtual
		~APPApplication();
	
	// LCommander
	
	virtual Boolean
		ObeyCommand(
				CommandT inCommand,
				void *ioParam);

	virtual void
		FindCommandStatus(
				CommandT inCommand,
				Boolean &outEnabled,
				Boolean &outUsesMark,
				UInt16 &outMark,
				Str255 outName);
	
	// AApplication
	
	virtual void
		Run();
	
protected:
	APeriodicalTimer *mPeriodicalTimer;
	
	// AEventObject
	
	virtual OSStatus
		HandleEvent(
				ACarbonEvent &inEvent,
				bool &outEventHandled);
	
	// LModelObject
	
	virtual void
		HandleAppleEvent(
				const AppleEvent &inAppleEvent,
				AppleEvent &outAEReply,
				AEDesc &outResult,
				SInt32 inAENumber);
	
	// APPApplication
	
	virtual void
		MakeMenuBar();
	virtual void
		MakeModelDirector();
	virtual void
		Initialize() {}
	virtual void
		StartUp() {}
	virtual void
		DoReopenApp() {}
	virtual void
		ShowAboutBox() {}
};
