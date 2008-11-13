// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ASuspendedEvent.h"

const AppleEvent ASuspendedEvent::kBlankEvent = { typeNull,NULL };

// ---------------------------------------------------------------------------

ASuspendedEvent::~ASuspendedEvent()
{
	if (mSuspended) {
		::AEDisposeDesc(&mEvent);
		::AEDisposeDesc(&mReply);
	}
}

// ---------------------------------------------------------------------------

void
ASuspendedEvent::Suspend(
		const AppleEvent &inReply)
{
	if (!mSuspended) {
		::AEGetTheCurrentEvent(&mEvent);
		::AESuspendTheCurrentEvent(&mEvent);
		mReply = inReply;
		mSuspended = true;
	}
}

// ---------------------------------------------------------------------------

void
ASuspendedEvent::Suspend(
		const AppleEvent &inEvent,
		const AppleEvent &inReply)
{
	if (!mSuspended) {
		mEvent = inEvent;
		mReply = inReply;
		mSuspended = true;
	}
}

// ---------------------------------------------------------------------------

bool
ASuspendedEvent::Resume()
{
	bool wasSuspended = mSuspended;
	
	if (mSuspended) {
		::AEResumeTheCurrentEvent(&mEvent,&mReply,(AEEventHandlerUPP)kAENoDispatch,0);
		mSuspended = false;
	}
	return wasSuspended;
}

// ---------------------------------------------------------------------------

void
ASuspendedEvent::DontResume()
{
	mSuspended = false;
}
