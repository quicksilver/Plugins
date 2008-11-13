#pragma once

#include "XRefCountObject.h"
#include "CThrownResult.h"

#include FW(ApplicationServices,CGImage.h)
#include FW(Carbon,MacApplication.h)

class ACGImage :
		public XRefCountObject<CGImageRef>
{
public:
		ACGImage(
				size_t width,
				size_t height,
				size_t bitsPerComponent,
				size_t bitsPerPixel,
				size_t bytesPerRow,
				CGColorSpaceRef colorspace,
				CGDataProviderRef provider,
				const float decode[],
				int shouldInterpolate,
				CGImageAlphaInfo alphaInfo = kCGImageAlphaNone,
				CGColorRenderingIntent intent = kCGRenderingIntentDefault);
		ACGImage(
				size_t width,
				size_t height,
				size_t bitsPerComponent,
				size_t bitsPerPixel,
				size_t bytesPerRow,
				CGDataProviderRef provider,
				const float decode[],
				int shouldInterpolate = true);
		ACGImage(
				PixMapHandle inImagePix,
				PixMapHandle inMaskPix);
	
	bool
		IsMask();
	size_t
		Width();
	size_t
		Height();
};

// ---------------------------------------------------------------------------

inline
ACGImage::ACGImage(
		PixMapHandle inImagePix,
		PixMapHandle inMaskPix)
{
	CThrownOSStatus err = ::CreateCGImageFromPixMaps(inImagePix,inMaskPix,&mObjectRef);
}

// ---------------------------------------------------------------------------

inline void
XRefCountObject<CGImageRef>::Retain()
{
	::CGImageRetain(mObjectRef);
}

inline void
XRefCountObject<CGImageRef>::Release()
{
	::CGImageRelease(mObjectRef);
}

inline UInt32
XRefCountObject<CGImageRef>::GetRetainCount() const
{
	// there is no CGGetImageRetainCount
	return 1;
}
