#include "ACFBase.h"

#include FW(CoreServices,CFNetServices.h)

// ---------------------------------------------------------------------------
#pragma warn_unusedarg off

class ACFNetServiceBrowser
		: public ACFType<CFNetServiceBrowserRef>
{
public:
		ACFNetServiceBrowser(
				CFAllocatorRef inAllocator = kCFAllocatorDefault);
	virtual
		~ACFNetServiceBrowser();
	
		// const issue
		operator CFNetServiceBrowserRef()
		{
			return (CFNetServiceBrowserRef)mObjectRef;
		}
	
	void
		Invalidate();
	
	bool
		SearchForDomains(
				bool inRegistrationDomainsOnly);
	bool
		SearchForDomains(
				bool inRegistrationDomainsOnly,
				CFStreamError &outError);
	
	bool
		SearchForServices(
				CFStringRef inDomain,
				CFStringRef inType);
	bool
		SearchForServices(
				CFStringRef inDomain,
				CFStringRef inType,
				CFStreamError &outError);
	
	void
		StopSearch();
	void
		StopSearch(
				CFStreamError &outError);
	
	void
		ScheduleWithRunLoop(
				CFRunLoopRef inLoop,
				CFStringRef inMode);
	void
		UnscheduleFromRunLoop(
				CFRunLoopRef inLoop,
				CFStringRef inMode);
	
protected:
	static void
		Callback(
				CFNetServiceBrowserRef inBrowser,
				CFOptionFlags inFlags,
				CFTypeRef inDomainOrService,
				CFStreamError *inError,
				void *inInfo);
	
	virtual void
		DoCallback(
				CFOptionFlags inFlags,
				CFTypeRef inDomainOrService,
				CFStreamError *inError) {}
};

#pragma warn_unusedarg reset
// ---------------------------------------------------------------------------

inline void
ACFNetServiceBrowser::Invalidate()
{
	::CFNetServiceBrowserInvalidate(*this);
}

inline bool
ACFNetServiceBrowser::SearchForDomains(
		bool inRegistrationDomainsOnly)
{
	return ::CFNetServiceBrowserSearchForDomains(*this,inRegistrationDomainsOnly,NULL);
}

inline bool
ACFNetServiceBrowser::SearchForDomains(
		bool inRegistrationDomainsOnly,
		CFStreamError &outError)
{
	return ::CFNetServiceBrowserSearchForDomains(*this,inRegistrationDomainsOnly,&outError);
}

inline bool
ACFNetServiceBrowser::SearchForServices(
		CFStringRef inDomain,
		CFStringRef inType)
{
	return ::CFNetServiceBrowserSearchForServices(*this,inDomain,inType,NULL);
}

inline bool
ACFNetServiceBrowser::SearchForServices(
		CFStringRef inDomain,
		CFStringRef inType,
		CFStreamError &outError)
{
	return ::CFNetServiceBrowserSearchForServices(*this,inDomain,inType,&outError);
}

inline void
ACFNetServiceBrowser::StopSearch()
{
	::CFNetServiceBrowserStopSearch(*this,NULL);
}

inline void
ACFNetServiceBrowser::StopSearch(
		CFStreamError &outError)
{
	::CFNetServiceBrowserStopSearch(*this,&outError);
}

inline void
ACFNetServiceBrowser::ScheduleWithRunLoop(
		CFRunLoopRef inLoop,
		CFStringRef inMode)
{
	::CFNetServiceBrowserScheduleWithRunLoop(*this,inLoop,inMode);
}

inline void
ACFNetServiceBrowser::UnscheduleFromRunLoop(
		CFRunLoopRef inLoop,
		CFStringRef inMode)
{
	::CFNetServiceBrowserUnscheduleFromRunLoop(*this,inLoop,inMode);
}
