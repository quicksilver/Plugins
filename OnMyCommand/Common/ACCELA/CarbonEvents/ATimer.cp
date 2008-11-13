// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ATimer.h"

// ---------------------------------------------------------------------------

ATimer::ATimer(
	  EventTimerInterval inFireDelay,
	  EventTimerInterval inInterval,
		EventLoopRef inEventLoop)
{
	mInterval = inInterval;
	mEventLoop = inEventLoop ? inEventLoop : ::GetMainEventLoop();
	if (inFireDelay == kEventDurationForever)
		mTimerRef = NULL;
	else
		InstallTimer(inFireDelay);
}

// ---------------------------------------------------------------------------

ATimer::~ATimer()
{
	if (mTimerRef)
		::RemoveEventLoopTimer(mTimerRef);
}

// ---------------------------------------------------------------------------

void
ATimer::SetNextFireTime(
		EventTimerInterval inNextFire)
{
	if (mTimerRef)
		::SetEventLoopTimerNextFireTime(mTimerRef,inNextFire);
	else
		InstallTimer(inNextFire);
}

// ---------------------------------------------------------------------------

void
ATimer::Pause()
{
	if (mTimerRef)
		::SetEventLoopTimerNextFireTime(mTimerRef,kEventDurationForever);
}

// ---------------------------------------------------------------------------

void
ATimer::Resume()
{
	if (mTimerRef)
		::SetEventLoopTimerNextFireTime(mTimerRef,kEventDurationNoWait);
	else
		InstallTimer(kEventDurationNoWait);
}

// ---------------------------------------------------------------------------

void
ATimer::InstallTimer(
		EventTimerInterval inFireDelay)
{
	static EventLoopTimerUPP upp = NewEventLoopTimerUPP(TimerCallback);
	
	::InstallEventLoopTimer(mEventLoop,inFireDelay,mInterval,upp,(void*)this,&mTimerRef);
}

// ---------------------------------------------------------------------------

pascal void
ATimer::TimerCallback(
		EventLoopTimerRef inTimer,
		void *inUserData)
{
#pragma unused(inTimer)
	ATimer *timer = static_cast<ATimer*>(inUserData);
	
	timer->Time();
}