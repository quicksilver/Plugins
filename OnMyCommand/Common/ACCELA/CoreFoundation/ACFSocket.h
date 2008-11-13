// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

#include <CoreFoundation/CFSocket.h>

class ACFSocket :
		public ACFType<CFSocketRef>
{
public:
		// CFSocketRef
		ACFSocket(
				CFSocketRef inSocket,
				bool inDoRetain = true)
		: ACFType(inSocket,inDoRetain) {}
		// new socket
		ACFSocket(
				SInt32 inProtocolFamily,
				SInt32 inSocketType,
				SInt32 inProtocol,
				CFOptionFlags inCallBackTypes,
				CFSocketCallBack inCallout,
				const CFSocketContext *inContext)
		: ACFType(::CFSocketCreate(
				kCFAllocatorDefault,
				inProtocolFamily,inSocketType,inProtocol,
				inCallBackTypes,inCallout,inContext),true) {}
	
	CFSocketError
		SetAddress(
				CFDataRef inAddress);
	CFSocketError
		ConnectToAddress(
				CFDataRef inAddress,
				CFTimeInterval inTimeout);
	
	void
		Invalidate();
	bool
		IsValid() const;
	
	CFDataRef
		CopyAddress() const;
	CFDataRef
		CopyPeerAddress() const;
	void
		GetContext(
				CFSocketContext *outContext) const;
	CFSocketNativeHandle
		NativeHandle() const;
	
	CFRunLoopSourceRef
		CreateRunLoopSource(
				CFIndex inOrder) const;
	
	CFSocketError
		SendData(
				CFDataRef inData,
				CFTimeInterval inTimeout);
	CFSocketError
		SendDataTo(
				CFDataRef inAddress,
				CFDataRef inData,
				CFTimeInterval inTimeout);
};
