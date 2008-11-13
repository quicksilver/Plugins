// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "APixMap.h"

#include FW(CoreServices,ToolUtils.h)

// ---------------------------------------------------------------------------

long
APixMap::Pixel(
		short inH,
		short inV) const
{
	long row_bytes = ::QTGetPixMapHandleRowBytes(mObject);
	UInt8 *src = (UInt8*)BaseAddr();
	long pixel;
	
	if (row_bytes == 0)
		row_bytes = ::QTGetPixMapPtrRowBytes(*mObject);
	
	if (row_bytes == 0) {
		Rect &pixBounds = (**mObject).bounds;
		UInt16 pixelBytes = (**mObject).pixelSize/8;
		
		pixelBytes += pixelBytes%2;
		row_bytes = (pixBounds.right - pixBounds.left)*pixelBytes;
		row_bytes += 16-(row_bytes%16);
	}
	
	switch (Depth()) {
		
		case 1:
			src += ((long) inV) * row_bytes;
			if (::BitTst(src,inH))
				pixel = 1;
			else
				pixel = 0;
			break;
		
		case 2:
			src += ((long) inV) * row_bytes + (((long) inH) >> 2);
			switch (inH&3) {
				case 0:	pixel = (long) (((*src) >> 6) & 0x03);	break;
				case 1:	pixel = (long) (((*src) >> 4) & 0x03);	break;
				case 2:	pixel = (long) (((*src) >> 2) & 0x03);	break;
				case 3:	pixel = (long) ((*src) & 0x03);	break;
			}
			break;
		
		case 4:
			src += ((long) inV) * row_bytes + (((long) inH) >> 1);
			if ((inH&1) == 0)
				pixel = (long) (((*src) >> 4) & 0x0F);
			else
				pixel = (long) ((*src) & 0x0F);
			break;
		
		case 8:
			src += ((long) inV) * row_bytes + ((long) inH);
			pixel = (long) ((*src) & 0x000000FF);
			break;
		
		case 16:
			src += ((long) inV) * row_bytes + (((long) inH) << 1);
			pixel = (long) ((* ((short*) src)) & 0x0000FFFF);
			break;
		
		case 32:
			src += ((long) inV) * row_bytes + (((long) inH) << 2);
			pixel = * ((long*) src);
			break;
	}
	return pixel;
}

// ---------------------------------------------------------------------------

void
APixMap::SetPixel(
		short inH,
		short inV,
		long inValue)
{
	const long row_bytes = RowBytes();
	UInt8 *dst = (UInt8*)BaseAddr();
	
	switch (Depth()) {
		
		case 1:
			dst += ((long) inV) * row_bytes;
			if (inValue != 0)
				::BitSet(dst,inH);
			else
				::BitClr(dst,inH);
			break;
		
		case 2:
			dst += ((long) inV) * row_bytes + ((long) (inH>>2));
			switch (inH & 3) {
				case 0:	*dst = ((*dst) & 0x3F) | (inValue<<6);	break;
				case 1:	*dst = ((*dst) & 0xCF) | ((inValue&0x03)<<4);	break;
				case 2:	*dst = ((*dst) & 0xF3) | ((inValue&0x03)<<2);	break;
				case 3:	*dst = ((*dst) & 0xFC) | (inValue&0x03);	break;
			}
			break;
		
		case 4:
			dst += ((long) inV) * row_bytes + ((long) (inH>>1));
			if ((inH & 1) == 0)
				*dst = ((*dst) & 0x0F) | (inValue<<4);
			else
				*dst = ((*dst) & 0xF0) | (inValue & 0x0F);
			break;
		
		case 8:
			dst += ((long) inV) * row_bytes + ((long) inH);
			*dst = (unsigned char) inValue;
			break;
		
		case 16:
			dst += ((long) inV) * row_bytes + (((long) inH) * 2);
			* ((short*) dst) = (short) inValue;
			break;
		
		case 32:
			dst += ((long) inV) * row_bytes + (((long) inH) * 4);
			* ((long*) dst) = inValue;
			break;
	}
}

// ---------------------------------------------------------------------------

Handle
APixMap::CopyData() const
{
	Locker lockPix(*this);
	
	if (!lockPix.Safe())
		return NULL;
	
	const Ptr pixPtr = BaseAddr();
	const Rect bounds = Bounds();
	const short
			rowBytes = RowBytes(),
			width = bounds.right - bounds.left,
			calcRB = width/8 * Depth();
	short x,y;
	Handle outData = ::NewHandle(calcRB * (bounds.bottom - bounds.top));
	Ptr dataPtr = *outData;
	long pixStart = 0,iconStart = 0;
	
	for (y = 0; y < bounds.bottom; y++) {
		for (x = 0; x < calcRB; x++)
			dataPtr[iconStart+x] = pixPtr[pixStart+x];
		
		iconStart += calcRB;
		pixStart += rowBytes;
	}
	
	return outData;
}
