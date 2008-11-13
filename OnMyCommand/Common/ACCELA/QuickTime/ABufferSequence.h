// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AImageSequence.h"
#include "AImageDescription.h"
#include "AMatrix.h"
#include "APixMap.h"

// ---------------------------------------------------------------------------

class ABufferSequence :
		public ADecompressImageSequence
{
public:
		ABufferSequence(
				PixMapHandle inSrcPix,
				CGrafPtr inDestPort,
				const Rect &inDestRect);
	
	void
		CopyBuffer()
		{
			DecompressFrame(mSrcPix,mIDH);
		}
	void
		CopyBuffer(
				const MatrixRecord &inNewMatrix)
		{
			SetMatrix(inNewMatrix);
			DecompressFrame(mSrcPix,mIDH);
		}
	void
		CopyBuffer(
				const Rect &inFromRect,
				const Rect &inToRect)
		{
			SetSrcRect(inFromRect);
			SetMatrix(AMatrix(inFromRect,inToRect));
			DecompressFrame(mSrcPix,mIDH);
		}
	
protected:
	APixMap mSrcPix;
	AImageDescription mIDH;
};

// ---------------------------------------------------------------------------

inline
ABufferSequence::ABufferSequence(
		PixMapHandle inSrcPix,
		CGrafPtr inDestPort,
		const Rect &inDestRect)
: ADecompressImageSequence(NULL,true),
  mSrcPix(inSrcPix),mIDH(inSrcPix)
{
	AMatrix matrix(mSrcPix.Bounds(),inDestRect);
	CThrownOSErr err = ::DecompressSequenceBegin(
			&mObject,mIDH,inDestPort,
			NULL,NULL,&matrix,
			srcCopy,NULL,0L,codecNormalQuality,NULL);
}
