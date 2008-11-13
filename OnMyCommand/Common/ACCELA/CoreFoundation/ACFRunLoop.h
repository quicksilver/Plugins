// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACFBase.h"

#include <CoreFoundation/CFRunLoop.h>

class ACFRunLoop :
		ACFType<CFRunLoopRef>
{
public:
		ACFRunLoop(
				CFRunLoopRef inLoop,
				bool inDoRetain = true)
		: ACFType<CFRunLoopRef>(inLoop,inDoRetain) {}
	
	static CFRunLoopRef
		Current();
	
	CFStringRef
		CopyCurrentMode() const;
	CFArrayRef
		CopyAllModes() const;
	void
		AddCommonMode(
				CFStringRef inMode);
	CFAbsoluteTime
		NextTimerFireDate(
				CFStringRef inMode);
	
	// event source - can be a socket
	class Source :
			ACFType<CFRunLoopSourceRef>
	{
	public:
			Source(
					CFRunLoopSourceRef inSourceRef,
					bool inDoRetain = true)
			: ACFType<CFRunLoopSourceRef>(inSourceRef,inDoRetain) {}
			Source(
					const CFRunLoopSourceContext &inContext)
			: ACFType<CFRunLoopSourceRef>(::CFRunLoopSourceCreate(
					kCFAllocatorDefault,0,
					const_cast<CFRunLoopSourceContext*>(&inContext)),false) {}
		
		CFIndex
			Order() const;
		void
			Invalidate();
		bool
			IsValid() const;
		void
			GetContext(
					CFRunLoopSourceContext &outContext) const;
		void
			Signal();
	};

	class Observer :
			ACFType<CFRunLoopObserverRef>
	{
	public:
			Observer(
					CFRunLoopObserverRef inObserverRef,
					bool inDoRetain = true)
			: ACFType<CFRunLoopObserverRef>(inObserverRef,inDoRetain) {}
			Observer(
					CFOptionFlags inActivities,
					bool inRepeats,
					CFIndex inOrder,
					const CFRunLoopObserverContext &inContext)
			: ACFType<CFRunLoopObserverRef>(::CFRunLoopObserverCreate(
					kCFAllocatorDefault,inActivities,
					inRepeats,inOrder,
					Callback,const_cast<CFRunLoopObserverContext*>(&inContext)),false) {}
		
		CFOptionFlags
			Activities() const;
		bool
			DoesRepeat() const;
		CFIndex
			Order() const;
		void
			Invalidate();
		bool
			IsValid() const;
		void
			GetContext(
					CFRunLoopObserverContext &outContext) const;
		
	protected:
		static void
			Callback(
					CFRunLoopObserverRef inObserver,
					CFRunLoopActivity inActivity,
					void *inInfo);
		
		virtual void
			Observe(
					CFRunLoopActivity inActivity) {}
	};
};

CFRunLoopRef
ACFRunLoop::Current()
{
	return ::CFRunLoopGetCurrent();
}

CFStringRef
ACFRunLoop::CopyCurrentMode() const
{
	return ::CFRunLoopCopyCurrentMode(*this);
}

CFArrayRef
ACFRunLoop::CopyAllModes() const
{
	return ::CFRunLoopCopyAllModes(*this);
}

void
ACFRunLoop::AddCommonMode(
		CFStringRef inMode)
{
	::CFRunLoopAddCommonMode(*this,inMode);
}

CFAbsoluteTime
ACFRunLoop::NextTimerFireDate(
		CFStringRef inMode)
{
	return ::CFRunLoopGetNextTimerFireDate(*this,inMode);
}

inline CFIndex
ACFRunLoop::Source::Order() const
{
	return ::CFRunLoopSourceGetOrder(*this);
}

inline void
ACFRunLoop::Source::Invalidate()
{
	::CFRunLoopSourceInvalidate(*this);
}

inline bool
ACFRunLoop::Source::IsValid() const
{
	return ::CFRunLoopSourceIsValid(*this);
}

inline void
ACFRunLoop::Source::GetContext(
		CFRunLoopSourceContext &outContext) const
{
	::CFRunLoopSourceGetContext(*this,&outContext);
}

inline void
ACFRunLoop::Source::Signal()
{
	::CFRunLoopSourceSignal(*this);
}

inline CFOptionFlags
ACFRunLoop::Observer::Activities() const
{
	return ::CFRunLoopObserverGetActivities(*this);
}

inline bool
ACFRunLoop::Observer::DoesRepeat() const
{
	return ::CFRunLoopObserverDoesRepeat(*this);
}

inline CFIndex
ACFRunLoop::Observer::Order() const
{
	return ::CFRunLoopObserverGetOrder(*this);
}

inline void
ACFRunLoop::Observer::Invalidate()
{
	::CFRunLoopObserverInvalidate(*this);
}

inline bool
ACFRunLoop::Observer::IsValid() const
{
	return ::CFRunLoopObserverIsValid(*this);
}

inline void
ACFRunLoop::Observer::GetContext(
		CFRunLoopObserverContext &outContext) const
{
	::CFRunLoopObserverGetContext(*this,&outContext);
}
