#include "ACFNetServiceBrowser.h"

#include <stdexcept>

// ---------------------------------------------------------------------------

ACFNetServiceBrowser::ACFNetServiceBrowser(
		CFAllocatorRef inAllocator)
: ACFType<CFNetServiceBrowserRef>(NULL,false)
{
	CFNetServiceClientContext context = { 0,this,NULL,NULL };
	
	mObjectRef = ::CFNetServiceBrowserCreate(inAllocator,Callback,&context);
	if (mObjectRef == NULL) throw std::runtime_error("CFNetServiceBrowserCreate failed");
	ScheduleWithRunLoop(::CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
}

// ---------------------------------------------------------------------------

ACFNetServiceBrowser::~ACFNetServiceBrowser()
{
	UnscheduleFromRunLoop(::CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
	StopSearch();
	Invalidate();
}

// ---------------------------------------------------------------------------

void
ACFNetServiceBrowser::Callback(
		CFNetServiceBrowserRef,
		CFOptionFlags inFlags,
		CFTypeRef inDomainOrService,
		CFStreamError *inError,
		void *inInfo)
{
	ACFNetServiceBrowser *browser = (ACFNetServiceBrowser*) inInfo;
	
	try {
		browser->DoCallback(inFlags,inDomainOrService,inError);
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------
