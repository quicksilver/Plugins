// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(Carbon,AEInteraction.h)

class ASuspendedEvent
{
public:
		ASuspendedEvent()
		: mEvent(kBlankEvent),mReply(kBlankEvent),mSuspended(false) {}
		~ASuspendedEvent();
	
	void
		Suspend(
				const AppleEvent &inReply);
	void
		Suspend(
				const AppleEvent &inEvent,
				const AppleEvent &inReply);
	bool
		Resume();
	void
		DontResume();
	
	bool
		Suspended()
		{ return mSuspended; }
	AppleEvent
		GetEvent() const
		{ return mEvent; }
	AppleEvent
		GetReply() const
		{ return mReply; }
	
protected:
	AppleEvent mEvent,mReply;
	bool mSuspended;
	
	static const AppleEvent kBlankEvent;
};
