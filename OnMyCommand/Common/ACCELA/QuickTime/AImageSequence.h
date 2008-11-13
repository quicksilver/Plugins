// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "FW.h"
#include "CThrownResult.h"

#include FW(QuickTime,ImageCompression.h)

// ---------------------------------------------------------------------------
#pragma mark AImageSequence

class AImageSequence :
		public XWrapper<ImageSequence>
{
public:
		// ImageSequence
		AImageSequence(
				ImageSequence inSequence,
				bool inOwner = false)
		: XWrapper(inSequence,inOwner) {}

protected:
		AImageSequence() {}
};

// ---------------------------------------------------------------------------

inline void
XWrapper<ImageSequence>::DisposeSelf()
{
	::CDSequenceEnd(mObject);
}

// ---------------------------------------------------------------------------
#pragma mark -
#pragma mark ACompressImageSequence

class ACompressImageSequence :
		public AImageSequence
{
public:
		// ImageSequence
		ACompressImageSequence(
				ImageSequence inSequence,
				bool inOwner = false)
		: AImageSequence(inSequence,inOwner) {}
		// compressing sequence
		ACompressImageSequence(
				PixMapHandle inSrc,
				PixMapHandle inPrev,
				const Rect &inSrcRect,
				const Rect &inPrevRect,
				short inColorDepth,
				CodecType inCodecType,
				CompressorComponent inCodec,
				CodecQ inSpatialQuality,
				CodecQ inTemporalQuality,
				long inKeyFrameRate,
				CTabHandle inCTable,
				CodecFlags inFlags,
				ImageDescriptionHandle inDesc);
};

// ---------------------------------------------------------------------------

inline
ACompressImageSequence::ACompressImageSequence(
		PixMapHandle inSrc,
		PixMapHandle inPrev,
		const Rect &inSrcRect,
		const Rect &inPrevRect,
		short inColorDepth,
		CodecType inCodecType,
		CompressorComponent inCodec,
		CodecQ inSpatialQuality,
		CodecQ inTemporalQuality,
		long inKeyFrameRate,
		CTabHandle inCTable,
		CodecFlags inFlags,
		ImageDescriptionHandle inDesc)
{
	CThrownOSErr err = ::CompressSequenceBegin(
			&mObject,
			inSrc,inPrev,
			&inSrcRect,&inPrevRect,
			inColorDepth,
			inCodecType,inCodec,
			inSpatialQuality,inTemporalQuality,inKeyFrameRate,
			inCTable,inFlags,inDesc);
}

// ---------------------------------------------------------------------------
#pragma mark -
#pragma mark ADecompressImageSequence

class ADecompressImageSequence :
		public AImageSequence
{
public:
		// ImageSequence
		ADecompressImageSequence(
				ImageSequence inSequence,
				bool inOwner = false)
		: AImageSequence(inSequence,inOwner) {}
		// decompressing sequence
		ADecompressImageSequence(
				ImageDescriptionHandle desc,
				Ptr inData,
				long inDataSize,
				CGrafPtr inPort,
				GDHandle inGDH,
				const Rect &inSrcRect,
				MatrixRecord &inMatrix,
				short inMode,
				RgnHandle inMask,
				CodecFlags inFlags,
				CodecQ inAccuracy,
				DecompressorComponent inCodec);
	
	void
		SetMatrix(
				const MatrixRecord &inMatrix);
	void
		SetMatte(
				PixMapHandle inMattePix,
				const Rect &inMatteRect);
	void
		SetMatte(
				PixMapHandle inMattePix);
	void
		SetMask(
				RgnHandle inMask);
	void
		SetTransferMode(
				short inMode);
	void
		SetTransferMode(
				short inMode,
				const RGBColor &inOpColor);
	void
		SetDataProc(
				ICMDataProcRecordPtr inProc,
				long inBufferSize);
	void
		SetAccuracy(
				CodecQ inAccuracy);
	void
		SetSrcRect(
				const Rect &inRect);
	void
		SetFlags(
				long inFlags,
				long inFlagsMask);
	
	void
		DecompressFrame(
				Ptr inData,
				long inDataSize,
				CodecFlags inFlags = 0L,
				CodecFlags *outFlags = NULL,
				ICMCompletionProcRecordPtr inCompletionProc = NULL);
	void
		DecompressFrame(
				PixMapHandle inPix,
				ImageDescriptionHandle inIDH)
		{
			DecompressFrame(::GetPixBaseAddr(inPix),(**inIDH).dataSize);
		}
};

// ---------------------------------------------------------------------------

inline
ADecompressImageSequence::ADecompressImageSequence(
		ImageDescriptionHandle inDesc,
		Ptr inData,
		long inDataSize,
		CGrafPtr inPort,
		GDHandle inGDH,
		const Rect &inSrcRect,
		MatrixRecord &inMatrix,
		short inMode,
		RgnHandle inMask,
		CodecFlags inFlags,
		CodecQ inAccuracy,
		DecompressorComponent inCodec)
{
	CThrownOSErr err = ::DecompressSequenceBeginS(
			&mObject,inDesc,inData,inDataSize,
			inPort,inGDH,
			&inSrcRect,&inMatrix,
			inMode,inMask,inFlags,
			inAccuracy,inCodec);
}

inline void
ADecompressImageSequence::SetMatrix(
		const MatrixRecord &inMatrix)
{
	CThrownOSErr err = SetDSequenceMatrix(*this,const_cast<MatrixRecord*>(&inMatrix));
}

inline void
ADecompressImageSequence::SetMatte(
		PixMapHandle inMattePix,
		const Rect &inMatteRect)
{
	CThrownOSErr err = ::SetDSequenceMatte(*this,inMattePix,&inMatteRect);
}

inline void
ADecompressImageSequence::SetMatte(
		PixMapHandle inMattePix)
{
	CThrownOSErr err = ::SetDSequenceMatte(*this,inMattePix,NULL);
}

inline void
ADecompressImageSequence::SetMask(
		RgnHandle inMask)
{
	CThrownOSErr err = ::SetDSequenceMask(*this,inMask);
}

inline void
ADecompressImageSequence::SetTransferMode(
		short inMode)
{
	CThrownOSErr err = ::SetDSequenceTransferMode(*this,inMode,NULL);
}

inline void
ADecompressImageSequence::SetTransferMode(
		short inMode,
		const RGBColor &inOpColor)
{
	CThrownOSErr err = ::SetDSequenceTransferMode(*this,inMode,&inOpColor);
}

inline void
ADecompressImageSequence::SetDataProc(
		ICMDataProcRecordPtr inProc,
		long inBufferSize)
{
	CThrownOSErr err = ::SetDSequenceDataProc(*this,inProc,inBufferSize);
}

inline void
ADecompressImageSequence::SetAccuracy(
		CodecQ inAccuracy)
{
	CThrownOSErr err = ::SetDSequenceAccuracy(*this,inAccuracy);
}

inline void
ADecompressImageSequence::SetSrcRect(
		const Rect &inRect)
{
	CThrownOSErr err = ::SetDSequenceSrcRect(*this,&inRect);
}

inline void
ADecompressImageSequence::SetFlags(
		long inFlags,
		long inFlagsMask)
{
	CThrownOSErr err = ::SetDSequenceFlags(*this,inFlags,inFlagsMask);
}

inline void
ADecompressImageSequence::DecompressFrame(
		Ptr inData,
		long inDataSize,
		CodecFlags inFlags,
		CodecFlags *outFlags,
		ICMCompletionProcRecordPtr inCompletionProc)
{
	CThrownOSErr err = ::DecompressSequenceFrameS(*this,inData,inDataSize,inFlags,outFlags,inCompletionProc);
}
