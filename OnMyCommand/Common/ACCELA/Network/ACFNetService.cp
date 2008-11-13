#include "ACFNetService.h"

// ---------------------------------------------------------------------------

ACFNetService::ACFNetService(
		CFStringRef inDomain,
		CFStringRef inType,
		CFStringRef inName,
		UInt32 inPort,
		CFAllocatorRef inAllocator)
: ACFType<CFNetServiceRef>(::CFNetServiceCreate(inAllocator,inDomain,inType,inName,inPort))
{
	InitService();
}

// ---------------------------------------------------------------------------

ACFNetService::~ACFNetService()
{
	UnscheduleFromRunLoop(::CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
	::CFNetServiceSetClient(*this,NULL,NULL);
	Cancel();
}

// ---------------------------------------------------------------------------

void
ACFNetService::InitService()
{
	CFNetServiceClientContext context = { 0,this,NULL,NULL,NULL };
	
	SetClient(Callback,context);
	ScheduleWithRunLoop(::CFRunLoopGetCurrent(),kCFRunLoopCommonModes);
}

// ---------------------------------------------------------------------------

bool
ACFNetService::GetFirstAddress(
		sockaddr_in &outAddress) const
{
	CFArrayRef addressArray = Addressing();
	
	if (addressArray != NULL)
		outAddress = *(sockaddr_in*) ::CFDataGetBytePtr((CFDataRef)::CFArrayGetValueAtIndex(addressArray,0));
	return addressArray != NULL;
}

// ---------------------------------------------------------------------------

void
ACFNetService::Callback(
		CFNetServiceRef,
		CFStreamError *inError,
		void *inInfo)
{
	ACFNetService *service = (ACFNetService*) inInfo;
	
	try {
		service->DoCallback(inError);
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------
