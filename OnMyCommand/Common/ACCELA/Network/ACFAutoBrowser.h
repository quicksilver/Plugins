#pragma once

#include "ACFNetServiceBrowser.h"
#include "ACFString.h"

#include <vector>

// This class is a self-contained domain- and service-finding
// browser, eliminating the extra step of finding available
// domains.

class ACFAutoBrowser :
		public ACFNetServiceBrowser
{
public:
		ACFAutoBrowser(
				CFStringRef inServiceType,
				bool inRegistrationOnly = true);
	virtual
		~ACFAutoBrowser();
	
	const ACFString&
		ServiceType() const
		{
			return mServiceType;
		}
	
protected:
	friend class ServiceBrowser;
	
	class ServiceBrowser :
			public ACFNetServiceBrowser
	{
	public:
			ServiceBrowser(
					CFStringRef inDomain,
					ACFAutoBrowser &inAutoBrowser);
		
	protected:
		ACFAutoBrowser &mAutoBrowser;
		
		void
			DoCallback(
					CFOptionFlags inFlags,
					CFTypeRef inService,
					CFStreamError *inError);
	};
	
	class MatchServiceRef
	{
	public:
			MatchServiceRef(
					CFTypeRef inRef)
			: mRef((CFNetServiceBrowserRef)inRef) {}
		
		bool
			operator()(
					const ServiceBrowser *inBrowser)
			{
				return mRef == inBrowser->Get();
			}
		
	protected:
		const CFNetServiceBrowserRef mRef;
	};
	
	typedef std::vector<ServiceBrowser*> ServiceVector;
	
	ServiceVector mServiceBrowsers;
	ACFString mServiceType;
	
	void
		DoCallback(
				CFOptionFlags inFlags,
				CFTypeRef inDomain,
				CFStreamError *inError);
	
	virtual void
		FoundService(
				CFNetServiceRef inService,
				bool inMoreComing) = 0;
	virtual void
		LostService(
				CFNetServiceRef inService) = 0;
};