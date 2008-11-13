// This file is only intended for CFM targets

#include <CGImage.h>

#include "GetCGFunction.h"

#if TARGET_RT_MAC_CFM
CGImageRef
CGImageRetain(
		CGImageRef inImage)
{
	typedef void (*ImageRetainPtr)(CGImageRef);
	static ImageRetainPtr imageRetain = (ImageRetainPtr)GetCGFunction(CFSTR("CGImageRetain"));
	
	if (imageRetain != NULL)
		(*imageRetain)(inImage);
	return inImage;
}

void
CGImageRelease(
		CGImageRef inImage)
{
	typedef void (*ImageReleasePtr)(CGImageRef);
	static ImageReleasePtr imageRelease = (ImageReleasePtr)GetCGFunction(CFSTR("CGImageRelease"));
	
	if (imageRelease != NULL)
		(*imageRelease)(inImage);
}
#endif
