#pragma once

#include "XRefCountObject.h"

#include "CThrownResult.h"

#include FW(ApplicationServices,CGContext.h)
#include FW(ApplicationServices,Quickdraw.h)

class ACGContext :
		public XRefCountObject<CGContextRef>
{
public:
		ACGContext() {}
		ACGContext(
				GrafPtr inPort);
		ACGContext(
				CGContextRef inContext,
				bool inDoRetain = true)
		: XRefCountObject<CGContextRef>(inContext,inDoRetain) {}
	
	// CTM
	void
		ScaleCTM(
				float inSX,
				float inSY);
	void
		TranslateCTM(
				float inTX,
				float inTY);
	void
		RotateCTM(
				float inRX,
				float inRY);
	void
		ConcatCTM(
				CGAffineTransform inTransform);
	CGAffineTransform
		CTM() const;
	
	// State
	void
		SetLineWidth(
				float inWidth);
	void
		SetLineCap(
				CGLineCap inCap);
	void
		SetLineJoin(
				CGLineJoin inJoin);
	void
		SetMiterLimit(
				float inLimit);
	void
		SetLineDash(
				float inPhase,
				const float inLengths[],
				size_t inCount);
	void
		SetFlatness(
				float inFlatness);
	void
		SetAlpha(
				float inAlpha);
	
	// Paths
	void
		BeginPath();
	void
		ClosePath();
	void
		MoveToPoint(
				float inX,
				float inY);
	void
		AddLineToPoint(
				float inX,
				float inY);
	void
		AddCurveToPoint(
				float cp1x,
				float cp1y,
				float cp2x,
				float cp2y,
				float inX,
				float inY);
	void
		AddQuadCurveToPoint(
				float inCPX,
				float inCPY,
				float inX,
				float inY);
	void
		AddRect(
				const CGRect &inRect);
	void
		AddRects(
				const CGRect &inRects[],
				size_t inCount);
	void
		AddLines(
				const CGPoint &inPoints[],
				size_t inCount);
	void
		AddArc(
				float inX,
				float inY,
				float inRadius,
				float inStartAngle,
				float inEndAngle,
				bool inClockwise);	// int
	void
		AddArcToPoint(
				float inX1,
				float inY1,
				float inX2,
				float inY2,
				float inRadius);
	
	// Path info
	bool
		IsPathEmpty() const;
	CGPoint
		PathCurrentPoint() const;
	CGRect
		PathBoundingBox() const;
	
	// Drawing
	void
		DrawPath(
				CGPathDrawingMode inMode);
	void
		FillPath();
	void
		EOFillPath();
	void
		StrokePath();
	void
		FillRect(
				const CGRect &inRect);
	void
		FillRects(
				const CGRect &inRects[],
				size_t inCount);
	void
		StrokeRect(
				const CGRect &inRect);
	void
		StrokeRect(
				const CGRect &inRect,
				float inWidth);
	void
		ClearRect(
				const CGRect &inRect);
	
	// Clipping
	void
		Clip();
	void
		EOClip();
	void
		ClipToRect(
				const CGRect &inRect);
	void
		ClipToRect(
				const CGRect &inRects[],
				size_t inCount);
	
	// Color state
	void
		SetFillColorSpace(
				CGColorSpaceRef inColorSpace);
	void
		SetFillColor(
				const float inComponents[]);
	void
		SetStrokeColor(
				const float inComponents[]);
	
	// Images
	void
		DrawImage(
				const CGRect &inRect,
				CGImageRef inImage);
	void
		SetInterpolationQuality(
				CGInterpolationQuality inQuality);
	CGInterpolationQuality
		InterpolationQuality();
	
	// Text properties
	void
		SetCharacterSpacing(
				float inSpacing);
	void
		SetTextPosition(
				float inX,
				float inY);
	void
		SetTextMatrix(
				CGAffineTransform inTransform);
	CGAffineTransform
		TextMatrix();
	void
		SetTextDrawingMode(
				CGTextDrawingMode inMode);
	void
		SetFont(
				CGFontRef inFont);
	void
		SetFontSize(
				float inSize);
	void
		SelectFont(
				const char *inName,
				float inSize,
				CGTextEncoding inEncoding = kCGEncodingMacRoman);
	
	// Text drawing
	void
		ShowText(
				const char *inText,
				size_t inLength);
	void
		ShowText(
				const char *inText,
				size_t inLength,
				float inX,
				float inY);
	void
		ShowGlyphs(
				const CGGlyph inGlyphs[],
				size_t inCount);
	void
		ShowGlyphs(
				const CGGlyph inGlyphs[],
				size_t inCount,
				float inX,
				float inY);
	
	// Misc drawing
	void
		Flush();
	void
		Synchronize();
	void
		SetShouldAntialias(
				bool inAntialias);
};

// ---------------------------------------------------------------------------

inline
ACGContext::ACGContext(
		CGrafPtr inPort)
{
	if (CreateCGContextForPort != NULL)
		CThrownOSStatus err = ::CreateCGContextForPort(inPort,&mObjectRef);
	else
		mObjectRef = NULL;
}

/*
inline void
ACGContext::ClearRect(
		const CGRect &inRect)
{ ::CGContextClearRect(mObjectRef,inRect); }
*/

// ---------------------------------------------------------------------------

/*
inline void
XRefCountObject<CGContextRef>::Retain()
{ ::CGContextRetain(mObjectRef); }

inline void
XRefCountObject<CGContextRef>::Release()
{ ::CGContextRelease(mObjectRef); }
*/

inline UInt32
XRefCountObject<CGContextRef>::GetRetainCount() const
{ return 1; }	// there is no CGContextGetRetainCount

// ---------------------------------------------------------------------------

class StSaveCGState
{
public:
		StSaveCGState(
				CGContextRef inContext)
		: mContext(inContext)
		{ Save(); }
		~StSaveCGState()
		{ Restore(); }
	
	void
		Save();
	void
		Restore();
	
protected:
	ACGContext mContext;
};

