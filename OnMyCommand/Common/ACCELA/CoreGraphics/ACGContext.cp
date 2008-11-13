// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

// This file is only intended for CFM targets

#include "ACGContext.h"

#include "GetCGFunction.h"

// ---------------------------------------------------------------------------

void
ACGContext::ClearRect(
	const CGRect &inRect)
{
	typedef void (*ClearRectPtr)(CGContextRef,CGRect);
	static ClearRectPtr clearRect = (ClearRectPtr)GetCGFunction(CFSTR("CGContextClearRect"));
	
	if (clearRect != NULL)
		(*clearRect)(mObjectRef,inRect);
}

// ---------------------------------------------------------------------------

void
ACGContext::FillRect(
	const CGRect &inRect)
{
	typedef void (*FillRectPtr)(CGContextRef,CGRect);
	static FillRectPtr fillRect = (FillRectPtr)GetCGFunction(CFSTR("CGContextFillRect"));
	
	if (fillRect != NULL)
		(*fillRect)(mObjectRef,inRect);
}

// ---------------------------------------------------------------------------

void
ACGContext::SetAlpha(
	float inAlpha)
{
	typedef void (*SetAlphaPtr)(CGContextRef,float);
	static SetAlphaPtr setAlpha = (SetAlphaPtr)GetCGFunction(CFSTR("CGContextSetAlpha"));
	
	if (setAlpha != NULL)
		(*setAlpha)(mObjectRef,inAlpha);
}

// ---------------------------------------------------------------------------

void
ACGContext::Flush()
{
	typedef void (*FlushPtr)(CGContextRef);
	static FlushPtr flush = (FlushPtr)GetCGFunction(CFSTR("CGContextFlush"));
	
	if (flush != NULL)
		(*flush)(mObjectRef);
}

// ---------------------------------------------------------------------------

void
XRefCountObject<CGContextRef>::Retain()
{
	typedef void (*ContextRetainPtr)(CGContextRef);
	static ContextRetainPtr retain = (ContextRetainPtr)GetCGFunction(CFSTR("CGContextRetain"));
	
	if (retain != NULL)
		(*retain)(mObjectRef);
}

// ---------------------------------------------------------------------------

void
XRefCountObject<CGContextRef>::Release()
{
	typedef void (*ContextReleasePtr)(CGContextRef);
	static ContextReleasePtr cgRelease = (ContextReleasePtr)GetCGFunction(CFSTR("CGContextRelease"));
	
	if (cgRelease != NULL)
		(*cgRelease)(mObjectRef);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
StSaveCGState::Save()
{
	::CGContextSaveGState(mContext);
}

// ---------------------------------------------------------------------------

void
StSaveCGState::Restore()
{
	::CGContextRestoreGState(mContext);
}
