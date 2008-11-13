// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AGWorld.h"
#include "FW.h"

#include FW(QuickTime,ImageCompression.h)

class AQTGWorld :
		public AGWorld
{
public:
		AQTGWorld(
				OSType inPixelFormat,
				const Rect &inBounds,
				CTabHandle inCTab = NULL,
				GDHandle inDevice = NULL,
				GWorldFlags inFlags = 0L);
		AQTGWorld(
				ImageDescriptionHandle inIDH,
				GWorldFlags inFlags = 0L);
};

inline
AQTGWorld::AQTGWorld(
		OSType inPixelFormat,
		const Rect &inBounds,
		CTabHandle inCTab,
		GDHandle inDevice,
		GWorldFlags inFlags)
: AGWorld(NULL,true)
{
	CThrownOSErr err = ::QTNewGWorld(&mObject,inPixelFormat,&inBounds,inCTab,inDevice,inFlags);
}

inline
AQTGWorld::AQTGWorld(
		ImageDescriptionHandle inIDH,
		GWorldFlags inFlags)
: AGWorld(NULL,true)
{
	CThrownOSErr err = ::NewImageGWorld(&mObject,inIDH,inFlags);
}
