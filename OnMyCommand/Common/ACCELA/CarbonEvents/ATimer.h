// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(Carbon,CarbonEvents.h)

class ATimer {
public:
		ATimer(
				EventTimerInterval inFireDelay = kEventDurationForever,
				EventTimerInterval inInterval = kEventDurationNoWait,
				EventLoopRef inEventLoop = NULL);
	virtual
		~ATimer();
	
	void
		SetNextFireTime(
				EventTimerInterval inNextFire);
	void
		Pause();
	void
		Resume();
	
protected:
	EventLoopTimerRef mTimerRef;
	EventTimerInterval mInterval;
	EventLoopRef mEventLoop;
	
	void
		InstallTimer(
				EventTimerInterval inFireDelay);
	
	virtual void
		Time() = 0;
	
	static pascal void
		TimerCallback(
				EventLoopTimerRef inTimer,
				void *inUserData);
};
