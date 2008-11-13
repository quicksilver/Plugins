// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

// Utility functions for accessing calls that are not exported for CFM apps

#include "GetCarbonFunction.h"

#include <Drag.h>
#include <CFURL.h>
#include <CFBundle.h>

#include "ACGImage.h"
#include "XSystem.h"

// ---------------------------------------------------------------------------

void*
GetCarbonFunction(
		CFStringRef inFunctionName)
{
	CFBundleRef bundle = ::CFBundleGetBundleWithIdentifier(CFSTR("com.apple.Carbon"));
	
	return CFBundleGetFunctionPointerForName(bundle,inFunctionName);
}

// ---------------------------------------------------------------------------
#if TARGET_RT_MAC_CFM

typedef void  (*QDSPOPtr)(Point);

void
SetPatternOrigin(
		Point inOrigin)
{
	if (XSystem::OSVersion() >= 0x1000) {
		static QDSPOPtr QDSPO = (QDSPOPtr)GetCarbonFunction(CFSTR("QDSetPatternOrigin"));
		
		(*QDSPO)(inOrigin);
	}
	else
		::QDSetPatternOrigin(inOrigin);
}

// ---------------------------------------------------------------------------

typedef OSErr (*SDIWAPtr)(DragRef,PixMapHandle,PixMapHandle,Point,DragImageFlags);
typedef OSErr (*SDIWCGIPtr)(DragRef,CGImageRef,const HIPoint*,DragImageFlags);

OSErr
SetDragImageWithAlpha(
		DragRef inDragRef,
		PixMapHandle inImagePix,
		PixMapHandle inMaskPix,
		Point inImageOffset,
		DragImageFlags inImageFlags)
{
	if (XSystem::OSVersion() >= 0x1020) {
		static SDIWCGIPtr SDIWCGI = (SDIWCGIPtr)GetCarbonFunction(CFSTR("SetDragImageWithCGImage"));
		
		if (SDIWCGI != NULL) {
			HIPoint offset = { inImageOffset.h,inImageOffset.v };
			
			// offset must be modified
			return (*SDIWCGI)(inDragRef,ACGImage(inImagePix,inMaskPix),&offset,inImageFlags);
		}
		else
			return -1;
	}
	else {
		// SetDragImageWithAlpha is undocumented, but I have successfully
		// tested it in OS X 10.1 - 10.1.4
		static SDIWAPtr SDIWA = (SDIWAPtr)GetCarbonFunction(CFSTR("SetDragImageWithAlpha"));
		
		if (SDIWA != NULL)
			return (*SDIWA)(inDragRef,inImagePix,inMaskPix,inImageOffset,inImageFlags);
		else
			return -1;
	}
}
#endif