#include "ACFAutoBrowser.h"

#include <stdexcept>

// ---------------------------------------------------------------------------

ACFAutoBrowser::ACFAutoBrowser(
		CFStringRef inServiceType,
		bool inRegistrationOnly)
: mServiceType(inServiceType)
{
	bool result = SearchForDomains(inRegistrationOnly);
	
	if (!result)
		throw std::runtime_error("SearchForDomains failed");
}

// ---------------------------------------------------------------------------

ACFAutoBrowser::~ACFAutoBrowser()
{
	ServiceVector::iterator iter = mServiceBrowsers.begin();
	
	for (; iter != mServiceBrowsers.end(); iter++)
		delete *iter;
}

// ---------------------------------------------------------------------------

void
ACFAutoBrowser::DoCallback(
		CFOptionFlags inFlags,
		CFTypeRef inDomain,
		CFStreamError *)
{
	if (inFlags & kCFNetServiceFlagRemove) {
		ServiceVector::iterator iter = std::find_if(
				mServiceBrowsers.begin(),
				mServiceBrowsers.end(),
				MatchServiceRef(inDomain));
		
		if (iter != mServiceBrowsers.end()) {
			delete *iter;
			mServiceBrowsers.erase(iter);
		}
	}
	else
		mServiceBrowsers.push_back(new ServiceBrowser((CFStringRef)inDomain,*this));
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ACFAutoBrowser::ServiceBrowser::ServiceBrowser(
		CFStringRef inDomain,
		ACFAutoBrowser &inAutoBrowser)
: mAutoBrowser(inAutoBrowser)
{
	bool result = SearchForServices(inDomain,mAutoBrowser.ServiceType());
	
	if (!result)
		throw std::runtime_error("SearchForServices failed");
}

// ---------------------------------------------------------------------------

void
ACFAutoBrowser::ServiceBrowser::DoCallback(
		CFOptionFlags inFlags,
		CFTypeRef inService,
		CFStreamError *)
{
	if (inFlags & kCFNetServiceFlagRemove)
		mAutoBrowser.LostService((CFNetServiceRef)inService);
	else
		mAutoBrowser.FoundService((CFNetServiceRef)inService,inFlags & kCFNetServiceFlagMoreComing);
}

// ---------------------------------------------------------------------------
