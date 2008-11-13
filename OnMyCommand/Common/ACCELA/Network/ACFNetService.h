#include "ACFBase.h"

#include FW(CoreServices,CFNetServices.h)

#include <netinet/in.h>

#pragma warn_unusedarg off

// ---------------------------------------------------------------------------

class ACFNetService
		: public ACFType<CFNetServiceRef>
{
public:
		ACFNetService(
				CFStringRef inDomain,
				CFStringRef inType,
				CFStringRef inName,
				UInt32 inPort,
				CFAllocatorRef inAllocator = kCFAllocatorDefault);
	virtual
		~ACFNetService();
	
		// const issue
		operator CFNetServiceRef() const
		{
			return (CFNetServiceRef)mObjectRef;
		}
	
	CFStringRef
		Domain() const;
	CFStringRef
		Type() const;
	CFStringRef
		Name() const;
	
	CFArrayRef
		Addressing() const;
	bool
		GetFirstAddress(
				sockaddr_in &outAddress) const;
	CFStringRef
		ProtocolSpecificInformation() const;
	void
		SetProtocolSpecificInformation(
				CFStringRef inInfo);
	
	bool
		Register();
	bool
		Register(
				CFStreamError &outError);
	bool
		Resolve();
	bool
		Resolve(
				CFStreamError &outError);
	void
		Cancel();
	
protected:
		ACFNetService(
				CFNetServiceRef inRef,
				bool inDoRetain = true)
		: ACFType<CFNetServiceRef>(inRef,inDoRetain) {}
	
	void
		InitService();
	
	bool
		SetClient(
				CFNetServiceClientCallBack inCallback,
				CFNetServiceClientContext &inContext);
	void
		ScheduleWithRunLoop(
				CFRunLoopRef inLoop,
				CFStringRef inMode);
	void
		UnscheduleFromRunLoop(
				CFRunLoopRef inLoop,
				CFStringRef inMode);
	static void
		Callback(
				CFNetServiceRef inService,
				CFStreamError *inError,
				void *inInfo);
	
	virtual void
		DoCallback(
				CFStreamError *inError) {}
};

#pragma warn_unusedarg reset

// ---------------------------------------------------------------------------

inline CFStringRef
ACFNetService::Domain() const
{
	return ::CFNetServiceGetDomain(*this);
}

inline CFStringRef
ACFNetService::Type() const
{
	return ::CFNetServiceGetType(*this);
}

inline CFStringRef
ACFNetService::Name() const
{
	return ::CFNetServiceGetName(*this);
}

inline CFArrayRef
ACFNetService::Addressing() const
{
	return ::CFNetServiceGetAddressing(*this);
}

inline CFStringRef
ACFNetService::ProtocolSpecificInformation() const
{
	return ::CFNetServiceGetProtocolSpecificInformation(*this);
}

inline void
ACFNetService::SetProtocolSpecificInformation(
		CFStringRef inInfo)
{
	::CFNetServiceSetProtocolSpecificInformation(*this,inInfo);
}

inline bool
ACFNetService::Register()
{
	return ::CFNetServiceRegister(*this,NULL);
}

inline bool
ACFNetService::Register(
		CFStreamError &outError)
{
	return ::CFNetServiceRegister(*this,&outError);
}

inline bool
ACFNetService::Resolve()
{
	return ::CFNetServiceResolve(*this,NULL);
}

inline bool
ACFNetService::Resolve(
		CFStreamError &outError)
{
	return ::CFNetServiceResolve(*this,&outError);
}

inline void
ACFNetService::Cancel()
{
	::CFNetServiceCancel(*this);
}

inline bool
ACFNetService::SetClient(
		CFNetServiceClientCallBack inCallback,
		CFNetServiceClientContext &inContext)
{
	return ::CFNetServiceSetClient(*this,inCallback,&inContext);
}

inline void
ACFNetService::ScheduleWithRunLoop(
		CFRunLoopRef inLoop,
		CFStringRef inMode)
{
	::CFNetServiceScheduleWithRunLoop(*this,inLoop,inMode);
}

inline void
ACFNetService::UnscheduleFromRunLoop(
		CFRunLoopRef inLoop,
		CFStringRef inMode)
{
	::CFNetServiceUnscheduleFromRunLoop(*this,inLoop,inMode);
}
