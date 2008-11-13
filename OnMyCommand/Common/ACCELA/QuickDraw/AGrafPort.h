// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "APixMap.h"
#include "ARegion.h"
#include "FW.h"

#include FW(ApplicationServices,QuickDraw.h)

class AGrafPort :
		public XWrapper<CGrafPtr>
{
public:
		AGrafPort(
				CGrafPtr inPort)
		: XWrapper<CGrafPtr>(inPort,false) {}
		AGrafPort(
				WindowRef inWindow)
		: XWrapper<CGrafPtr>(::GetWindowPort(inWindow),false) {}
	
	virtual APixMap
		PixMap() const;
	const BitMap*
		BitMapPtr() const;
	
	void
		GetBounds(
				Rect &outBounds) const;
	Rect
		Bounds() const;
	
	// Colors
	RGBColor
		ForeColor() const;
	RGBColor
		BackColor() const;
	RGBColor
		OpColor() const;
	RGBColor
		HiliteColor() const;
	void
		SetOpColor(
				const RGBColor &inOpColor);
	
	// Text
	short
		TextFont() const;
	Style
		TextFace() const;
	short
		TextMode() const;
	short
		TextSize() const;
	short
		ChExtra() const;
	void
		SetTextFont(
				short inFont);
	void
		SetTextSize(
				short inSize);
	void
		SetTextFace(
				StyleParameter inStyle);
	void
		SetTextMode(
				short inMode);
	
	// Pen
	
	// Pattern
	
	// Regions
	void
		GetVisibleRegion(
				RgnHandle outVisibleRegion) const;
	void
		GetClipRegion(
				RgnHandle outClipRegion) const;
	void
		SetVisibleRegion(
				RgnHandle inRegion);
	void
		SetClipRegion(
				RgnHandle inRegion);
	
	// Being defined
	bool
		IsRegionBeingDefined() const;
	bool
		IsPolyBeingDefined() const;
	bool
		IsPictureBeingDefined() const;
	Handle
		SwapPicSaveHandle(
				Handle inNewHandle) const;
	
	// Characteristics
	bool
		IsOffscreen() const;
	bool
		IsColor() const;
	
	// Buffering
	bool
		IsBuffered() const;
	bool
		IsBufferDirty() const;
	void
		FlushBuffer(
				RgnHandle inRegion = NULL);
	void
		GetDirtyRegion(
				RgnHandle ioRegion) const;
	void
		SetDirtyRegion(
				RgnHandle inRegion);
	void
		AddRectToDirtyRegion(
				const Rect &inRect);
	void
		AddRegionToDirtyRegion(
				RgnHandle inRegion);
	
	// QD Procs
	CQDProcsPtr
		GrafProcs() const;
	void
		SetGrafProcs(
				CQDProcsPtr inProcs);
protected:
		AGrafPort(
				CGrafPtr inPort,
				bool inOwner)
		: XWrapper<CGrafPtr>(inPort,inOwner) {}
};

class StSetPort
{
public:
		StSetPort(
				CGrafPtr inPort)
		{
			::GetPort(&mSavePort);
			::SetPort(inPort);
		}
		~StSetPort()
		{
			::SetPort(mSavePort);
		}
	
protected:
	CGrafPtr mSavePort;
};

class StSetClip
{
public:
		StSetClip(
				GrafPtr inPort,
				RgnHandle inRegion)
		: mPort(inPort)
		{
			mPort.GetClipRegion(mOldClip);
			mPort.SetClipRegion(inRegion);
		}
		~StSetClip()
		{
			mPort.SetClipRegion(mOldClip);
		}
	
protected:
	AGrafPort mPort;
	ARegion mOldClip;
};

// ---------------------------------------------------------------------------

inline APixMap
AGrafPort::PixMap() const
{
	return ::GetPortPixMap(mObject);
}

// ---------------------------------------------------------------------------

inline const BitMap*
AGrafPort::BitMapPtr() const
{
	return ::GetPortBitMapForCopyBits(mObject);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::GetBounds(
		Rect &outBounds) const
{
	::GetPortBounds(mObject,&outBounds);
}

// ---------------------------------------------------------------------------

inline Rect
AGrafPort::Bounds() const
{
	Rect r;
	::GetPortBounds(mObject,&r);
	return r;
}

// ---------------------------------------------------------------------------

inline RGBColor
AGrafPort::ForeColor() const
{
	RGBColor rgb;
	::GetPortForeColor(mObject,&rgb);
	return rgb;
}

// ---------------------------------------------------------------------------

inline RGBColor
AGrafPort::BackColor() const
{
	RGBColor rgb;
	::GetPortBackColor(mObject,&rgb);
	return rgb;
}

// ---------------------------------------------------------------------------

inline RGBColor
AGrafPort::OpColor() const
{
	RGBColor rgb;
	::GetPortOpColor(mObject,&rgb);
	return rgb;
}

// ---------------------------------------------------------------------------

inline RGBColor
AGrafPort::HiliteColor() const
{
	RGBColor rgb;
	::GetPortHiliteColor(mObject,&rgb);
	return rgb;
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetOpColor(
		const RGBColor &inOpColor)
{
	::SetPortOpColor(mObject,&inOpColor);
}

// ---------------------------------------------------------------------------

inline short
AGrafPort::TextFont() const
{
	return ::GetPortTextFont(mObject);
}

// ---------------------------------------------------------------------------

inline Style
AGrafPort::TextFace() const
{
	return ::GetPortTextFace(mObject);
}

// ---------------------------------------------------------------------------

inline short
AGrafPort::TextMode() const
{
	return ::GetPortTextMode(mObject);
}

// ---------------------------------------------------------------------------

inline short
AGrafPort::TextSize() const
{
	return ::GetPortTextSize(mObject);
}

// ---------------------------------------------------------------------------

inline short
AGrafPort::ChExtra() const
{
	return ::GetPortChExtra(mObject);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetTextFont(
		short inFont)
{
	::SetPortTextFont(mObject,inFont);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetTextSize(
		short inSize)
{
	::SetPortTextSize(mObject,inSize);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetTextFace(
		StyleParameter inStyle)
{
	::SetPortTextFace(mObject,inStyle);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetTextMode(
		short inMode)
{
	::SetPortTextMode(mObject,inMode);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::GetVisibleRegion(
		RgnHandle outVisibleRegion) const
{
	::GetPortVisibleRegion(mObject,outVisibleRegion);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::GetClipRegion(
		RgnHandle outClipRegion) const
{
	::GetPortClipRegion(mObject,outClipRegion);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetVisibleRegion(
		RgnHandle inRegion)
{
	::SetPortVisibleRegion(mObject,inRegion);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetClipRegion(
		RgnHandle inRegion)
{
	::SetPortClipRegion(mObject,inRegion);
}

// ---------------------------------------------------------------------------

inline bool
AGrafPort::IsRegionBeingDefined() const
{
	return ::IsPortRegionBeingDefined(mObject);
}

// ---------------------------------------------------------------------------

inline bool
AGrafPort::IsPolyBeingDefined() const
{
	return ::IsPortPolyBeingDefined(mObject);
}

// ---------------------------------------------------------------------------

inline bool
AGrafPort::IsPictureBeingDefined() const
{
	return ::IsPortPictureBeingDefined(mObject);
}

// ---------------------------------------------------------------------------

inline Handle
AGrafPort::SwapPicSaveHandle(
		Handle inNewHandle) const
{
	return ::SwapPortPicSaveHandle(mObject,inNewHandle);
}

// ---------------------------------------------------------------------------

inline bool
AGrafPort::IsOffscreen() const
{
	return ::IsPortOffscreen(mObject);
}

// ---------------------------------------------------------------------------

inline bool
AGrafPort::IsColor() const
{
	return ::IsPortColor(mObject);
}

// ---------------------------------------------------------------------------

inline bool
AGrafPort::IsBuffered() const
{
	return ::QDIsPortBuffered(mObject);
}

// ---------------------------------------------------------------------------

inline bool
AGrafPort::IsBufferDirty() const
{
	return ::QDIsPortBufferDirty(mObject);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::FlushBuffer(
		RgnHandle inRegion)
{
	::QDFlushPortBuffer(mObject,inRegion);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::GetDirtyRegion(
		RgnHandle ioRegion) const
{
	::QDGetDirtyRegion(mObject,ioRegion);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetDirtyRegion(
		RgnHandle inRegion)
{
	::QDSetDirtyRegion(mObject,inRegion);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::AddRectToDirtyRegion(
		const Rect &inRect)
{
	::QDAddRectToDirtyRegion(mObject,&inRect);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::AddRegionToDirtyRegion(
		RgnHandle inRegion)
{
	::QDAddRegionToDirtyRegion(mObject,inRegion);
}

// ---------------------------------------------------------------------------

inline CQDProcsPtr
AGrafPort::GrafProcs() const
{
	return ::GetPortGrafProcs(mObject);
}

// ---------------------------------------------------------------------------

inline void
AGrafPort::SetGrafProcs(
		CQDProcsPtr inProcs)
{
	::SetPortGrafProcs(mObject,inProcs);
}

// ---------------------------------------------------------------------------

inline void
XWrapper<CGrafPtr>::DisposeSelf()
{
	::DisposePort(mObject);
}
