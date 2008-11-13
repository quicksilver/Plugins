// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AGrafPort.h"
#include "FW.h"
#include "CThrownResult.h"

#include FW(ApplicationServices,QDOffscreen.h)

class AGWorld :
		public AGrafPort
{
public:
		AGWorld(
				GWorldPtr inGWorld,
				bool inOwner = false)
		: AGrafPort(inGWorld,inOwner) {}
		// NewGWorld
		AGWorld(
				const Rect &inBounds,
				short inDepth = 0,
				CTabHandle inCTable = NULL,
				GDHandle inDevice = NULL,
				GWorldFlags inFlags = kNilOptions);
		// NewGWorldFromPtr
		AGWorld(
				unsigned long inPixelFormat,
				const Rect &inBounds,
				Ptr inBuffer,
				long inRowBytes,
				CTabHandle inCTab = NULL,
				GDHandle inDevice = NULL,
				GWorldFlags inFlags = kNilOptions);
		~AGWorld();
	
	GWorldFlags
		Update(
				const Rect &inBounds,
				short inDepth = 0,
				CTabHandle inCTable = NULL,
				GDHandle inDevice = NULL,
				GWorldFlags inFlags = kNilOptions);
	
	GDHandle
		Device() const;
	APixMap
		PixMap() const;
	
	CTabHandle
		ColorTable() const
		{
			return (**PixMap()).pmTable;
		}
	
protected:
	void
		DisposeSelf();
};

// ---------------------------------------------------------------------------

inline 
AGWorld::AGWorld(
		const Rect &inBounds,
		short inDepth,
		CTabHandle inCTable,
		GDHandle inDevice,
		GWorldFlags inFlags)
: AGrafPort(NULL,true)
{
	CThrownOSErr err = ::NewGWorld(&mObject,inDepth,&inBounds,inCTable,inDevice,inFlags);
}

inline
AGWorld::AGWorld(
		unsigned long inPixelFormat,
		const Rect &inBounds,
		Ptr inBuffer,
		long inRowBytes,
		CTabHandle inCTab,
		GDHandle inDevice,
		GWorldFlags inFlags)
: AGrafPort(NULL,true)
{
	CThrownResult<QDErr> err = ::NewGWorldFromPtr(
			&mObject,inPixelFormat,&inBounds,
			inCTab,inDevice,inFlags,
			inBuffer,inRowBytes);
}

inline
AGWorld::~AGWorld()
{
	// Don't let the superclass call DisposePort
	if (mOwner && (mObject != NULL)) {
		::DisposeGWorld(mObject);
		mObject = NULL;
	}
}

// Since the compiler doesn't differentiate between CGrafPtr and GWorldPtr,
// we must override instead of specialize
inline void
AGWorld::DisposeSelf()
{
	::DisposeGWorld(mObject);
}

inline GWorldFlags
AGWorld::Update(
		const Rect &inBounds,
		short inDepth,
		CTabHandle inCTable,
		GDHandle inDevice,
		GWorldFlags inFlags)
{
	return ::UpdateGWorld(&mObject,inDepth,&inBounds,inCTable,inDevice,inFlags);
}

inline GDHandle
AGWorld::Device() const
{
	return ::GetGWorldDevice(mObject);
}

inline APixMap
AGWorld::PixMap() const
{
	return APixMap(::GetGWorldPixMap(mObject));
}
