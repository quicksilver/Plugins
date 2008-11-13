// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "FW.h"

#include FW(Carbon,URLAccess.h)

namespace AURLProcs {
	class NoNotify
	{
		static URLNotifyUPP
			GetNotifyProc()
			{
				return NULL;
			}
		static URLEventMask
			GetEventMask()
			{
				return 0L;
			}
	};
	class NoEvents
	{
		static URLSystemEventUPP
			GetEventProc()
			{
				return NULL;
			}
	};
	
	class Nothing : public NoNotify,public NoEvents;
	
	class Notifier :
			public NoEvents
	{
		static URLNotifyUPP
			GetNotifyProc()
			{
				static URLNotifyUPP notifyUPP = NewURLNotifyUPP(EventProc);
				return notifyUPP;
			}
		static OSStatus
			NotifyProc(
					void *inContext,
					URLEvent inEvent,
					URLCallbackInfo *inCallbackInfo)
			{
				Notifier notifier = static_cast<Notifier*>(inContext);
				return notifier->Notify(inEvent,inCallbackInfo);
			}
		virtual
			Notify(
					URLEvent inEvent,
					URLCallbackInfo *inCallbackInfo) = 0;
		virtual URLEventMask
			GetEventMask() = 0;
	};
	class EventHandler :
			public NoNotify
	{
	public:
		static URLSystemEventUPP
			GetEventProc()
			{
				static URLSystemEventUPP eventUPP = NewURLSystemEventUPP(EventProc);
				return eventUPP;
			}
		
		static pascal OSStatus
			EventProc(
					void *inContext,
					EventRecord *inEvent)
			{
				EventHandler handler = static_cast<EventHandler*>(inContext);
				return handler->HandleEvent(event);
			}
		
		virtual OSStatus
			HandleEvent(
					EventRecord *inEvent) = 0;
	};
}

template <class EventPolicy = AURLProcs::Nothing>
class AURL :
		public EventPolicy,
		public XWrapper<URLReference>
{
public:
		AURL(
				const char *inURL);
		AURL(
				URLReference inURL,
				bool inOwner = false)
		: XWrapper(inURL,inOwner) {}
	
	// operations
	void
		Open(
				FSSpec *fileSpec,
				URLOpenFlags inFlags = 0L);
	void
		Upload(
				const FSSpec &source,
				URLOpenFlags inFlags = 0L);
	void
		Download(
				const FSSpec &inDestination,
				URLOpenFlags inFlags = 0L);
	void
		Download(
				Handle destinationHandle,
				URLOpenFlags inFlags = 0L);
	void
		Abort();
	void
		Idle();
	
	// status
	URLState
		CurrentState() const;
	OSStatus
		Error() const;
	
	void
		GetFileInfo(
				StringPtr outName,
				OSType &outType,
				OSType &outCreator);
	
	// data
	Size
		DataAvailable() const;
	void
		GetBuffer(
				void* &outBuffer,
				Size &outSize) const;
	void
		ReleaseBuffer(
				void *inBuffer);
	
	// properties
	void
		GetProperty(
				const char *inProperty,
				void *inBuffer,
				Size bufferSize) const;
	template <class T>
	void
		GetProperty(
				const char *inProperty,
				T &outObject) const
		{
			GetProperty(inProperty,&outObject,sizeof(outObject));
		}
	Size
		PropertySize(
				const char *inProperty) const;
	void
		SetProperty(
				const char *inProperty,
				void *inBuffer,
				Size bufferSize) const;
	template <class T>
	void
		SetProperty(
				const char *inProperty,
				T &outObject) const
		{
			SetProperty(inProperty,&outObject,sizeof(outObject));
		}
};

inline
AURL::AURL(
		const char *inURL)
{
	CThrownOSStatus err = ::URLNewReference(inURL,&mObject);
}

inline void
AURL::Open(
		const FSSpec &inSpec,
		URLOpenFlags inFlags)
{
	CThrownOSStatus err = ::URLOpen(
			*this,const_cast<FSSpec*>(&inSpec),inFlags,
			GetNotifyProc(),GetEventMask(),(void*)this);
}

inline void
AURL::Upload(
		const FSSpec &inSource,
		URLOpenFlags inFlags = 0L)
{
	CThrownOSStatus err = ::URLUpload(
			*this,&inSource,inFlags,
			GetEventProc(),(void*)this);
}

inline void
AURL::Download(
		const FSSpec &inDestination,
		URLOpenFlags inFlags)
{
	CThrownOSStatus err = ::URLDownload(
			*this,const_cast<FSSpec*>(&inDestination),inFlags,NULL,
			GetEventProc(),(void*)this);
}

inline void
AURL::Download(
		Handle inDestination,
		URLOpenFlags inFlags)
{
	CThrownOSStatus err = ::URLDownload(
			*this,NULL,inFlags,inDestination,
			GetEventProc(),(void*)this);
}

inline void
XWrapper<URLReference>::DisposeSelf()
{
	::URLDisposeReference(mObject)
}
