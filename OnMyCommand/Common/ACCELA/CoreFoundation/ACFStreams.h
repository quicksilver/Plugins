// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

#include <CoreFoundation/CFStream.h>

// ---------------------------------------------------------------------------

template <class T>
class ACFStream :
		public ACFType<T>
{
public:
		ACFStream(
				CFReadStreamRef inStreamRef,
				bool inDoRetain = true)
		: ACFBase(inStreamRef,inDoRetain) {}
	
	virtual CFStreamStatus
		Status() const = 0;
	virtual CFStreamError
		Error() const = 0;
	virtual bool
		Open() = 0;
	virtual void
		Close() = 0;
	
	virtual CFTypeRef
		CopyProperty(
				CFStringRef inTag) const = 0;
	
	virtual bool
		SetClient(
				CFOptionFlags inStreamEvents,
				CFReadStreamClientCallBack inClientCB,
				CFStreamClientContext *inClientContext) = 0;
	virtual void
		ScheduleWithRunLoop(
				CFRunLoopRef inLoop,
				CFStringRef inMode = kCFRunLoopGetCommonModes) = 0;
	virtual void
		UnscheduleFromRunLoop(
				CFRunLoop inLoop,
				CFStringRef inMode = kCFRunLoopGetCommonModes) = 0;
	
protected:
		ACFStream()
		: ACFType<T>(NULL,false) {}
}

// ---------------------------------------------------------------------------

class ACFReadStream :
		public ACFStream<CFReadStreamRef>
{
public:
		// CFReadStreamRef
		ACFReadStream(
				CFReadStreamRef inStreamRef,
				bool inDoRetain = true)
		: ACFStream(inStreamRef,inDoRetain) {}
		// Bytes
		ACFReadStream(
				const UInt8 *inBuffer,
				CFIndex inLength)
		: ACFStream(::CFReadStreamCreateWithBytesNoCopy(kCFAllocatorDefault,inBuffer,inLength,NULL),false) {}
		// File
		ACFReadStream(
				CFURLRef inFileURL)
		: ACFStream(::CFReadStreamCreateWithFile(kCFAllocatorDefault,inFileURL),false) {}
		// Socket
		ACFReadStream(
				CFNativeSocketHandle inSocket)
		{
			::CFStreamCreatePairWithSocket(kCFAllocatorDefault,inSocket,&mObjectRef,NULL);
		}
		// Host name & port
		ACFReadStream(
				CFStringRef inHost,
				UInt32 inPort)
		{
			::CFStreamCreatePairWithSocketToHost(kCFAllocatorDefault,inHost,inPort,&mObjectRef,NULL);
		}
	
	// ACFStream
	
	CFStreamStatus
		Status() const;
	CFStreamError
		Error() const;
	bool
		Open();
	void
		Close();
	
	bool
		SetClient(
				CFOptionFlags inStreamEvents,
				CFReadStreamClientCallBack inClientCB,
				CFStreamClientContext *inClientContext);
	void
		ScheduleWithRunLoop(
				CFRunLoopRef inLoop,
				CFStringRef inMode = kCFRunLoopGetCommonModes);
	
	// ACFReadStream
	
	bool
		HasBytesAvailable();
	CFIndex
		Read(
				UInt8 *inBuffer,
				CFIndex inLength);
	const UInt8*
		Buffer(
				CFIndex inMaxBytes,
				CFIndex &outBytesRead) const;
	
	CFTypeRef
		CopyProperty(
				CFStringRef inTag) const;
};

// ---------------------------------------------------------------------------

class ACFWriteStream :
		public ACFStream<CFWriteStreamRef>
{
public:
		// CFWriteStreamRef
		ACFWriteStream(
				CFWriteStreamRef inStreamRef,
				bool inDoRetain = true)
		: ACFStream(inStreamRef,inDoRetain) {}
		// Buffer
		ACFWriteStream(
				UInt8 *inBuffer,
				CFIndex inLength)
		: ACFStream(::CFWriteStreamCreateWithBuffer(kCFAllocatorDefault,inBuffer,inLength),false) {}
		// Allocator
		ACFWriteStream(
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFStream(::CFWriteStreamCreateWithAllocatedBuffers(kCFAllocatorDefault,inAllocator),false) {}
		// File
		ACFWriteStream(
				CFURLRef inFileURL)
		: ACFStream(::CFWriteStreamCreateWithFile(kCFAllocatorDefault,inFileURL),false) {}
		// Socket
		ACFWriteStream(
				CFNativeSocketHandle inSocket)
		{
			::CFStreamCreatePairWithSocket(kCFAllocatorDefault,inSocket,NULL,&mObjectRef);
		}
	
	// ACFStream
	
	CFStreamStatus
		Status() const;
	CFStreamError
		Error() const;
	bool
		Open();
	void
		Close();
	
	bool
		SetClient(
				CFOptionFlags inStreamEvents,
				CFReadStreamClientCallBack inClientCB,
				CFStreamClientContext *inClientContext);
	void
		ScheduleWithRunLoop(
				CFRunLoopRef inLoop,
				CFStringRef inMode = kCFRunLoopGetCommonModes);
	
	// ACFWriteStream
	
	bool
		CanAcceptBytes() const;
	CFIndex
		Write(
				const UInt8 *inBytes,
				CFIndex inLength);
	
	CFTypeRef
		CopyProperty(
				CFStringRef inTag) const;
};
