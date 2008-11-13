// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "FW.h"

#include FW(ApplicationServices,QuickDraw.h)

class ARegion :
		public XWrapper<RgnHandle>
{
public:
		// empty
		ARegion()
		: XWrapper<RgnHandle>(::NewRgn(),true) {}
		// RgnHandle
		ARegion(
				RgnHandle inRgn,
				bool inOwner = false)
		: XWrapper<RgnHandle>(inRgn,inOwner) {}
		// Rect
		ARegion(
				const Rect &inRect)
		: XWrapper<RgnHandle>(::NewRgn(),true)
		{
			::RectRgn(*this,&inRect);
		}
	
	void
		CopyFrom(
				RgnHandle inSource);
	void
		SetEmpty();
	
	void
		Offset(
				short inX,
				short inY);
	void
		Inset(
				short inX,
				short inY);
	
	// As an XWrapper, should ARegion override operator=?
	
	ARegion&
		operator +=(
				RgnHandle inRgn);
	ARegion&
		operator -=(
				RgnHandle inRgn);
	ARegion&
		operator &=(
				RgnHandle inRgn);
	ARegion&
		operator *=(
				RgnHandle inRgn);
	
	bool
		operator ==(
				RgnHandle inRgn) const;
	bool
		operator !=(
				RgnHandle inRgn) const
		{
			return !(*this == inRgn);
		}
	
	bool
		IsEmpty() const;
	bool
		IsRectangular() const;
	Rect
		Bounds() const;
	bool
		Contains(
				Point inPoint) const;
	
	void
		Frame() const;
	void
		Paint() const;
	void
		Invert() const;
	void
		Erase() const;
	void
		Fill(
				const Pattern &inPat) const;
};

// ---------------------------------------------------------------------------

inline void
ARegion::CopyFrom(
		RgnHandle inSource)
{
	::CopyRgn(inSource,*this);
}

inline void
ARegion::SetEmpty()
{
	::SetEmptyRgn(*this);
}

inline void
ARegion::Offset(
		short inX,
		short inY)
{
	::OffsetRgn(*this,inX,inY);
}

inline void
ARegion::Inset(
		short inX,
		short inY)
{
	::InsetRgn(*this,inX,inY);
}

inline ARegion&
ARegion::operator +=(
		RgnHandle inRgn)
{
	::UnionRgn(*this,inRgn,*this);
	return *this;
}

inline ARegion&
ARegion::operator -=(
		RgnHandle inRgn)
{
	::DiffRgn(*this,inRgn,*this);
	return *this;
}

inline ARegion&
ARegion::operator &=(
		RgnHandle inRgn)
{
	::SectRgn(*this,inRgn,*this);
	return *this;
}

inline ARegion&
ARegion::operator *=(
		RgnHandle inRgn)
{
	::XorRgn(*this,inRgn,*this);
	return *this;
}

inline bool
ARegion::operator ==(
		RgnHandle inRgn) const
{
	return ::EqualRgn(*this,inRgn);
}

inline bool
ARegion::IsEmpty() const
{
	return ::EmptyRgn(*this);
}

inline bool
ARegion::IsRectangular() const
{
	return ::IsRegionRectangular(*this);
}

inline Rect
ARegion::Bounds() const
{
	Rect bounds;
	::GetRegionBounds(*this,&bounds);
	return bounds;
}

inline bool
ARegion::Contains(
		Point inPoint) const
{
	return ::PtInRgn(inPoint,*this);
}

inline void
ARegion::Frame() const
{
	::FrameRgn(*this);
}

inline void
ARegion::Paint() const
{
	::EraseRgn(*this);
}

inline void
ARegion::Invert() const
{
	::InvertRgn(*this);
}

inline void
ARegion::Erase() const
{
	::EraseRgn(*this);
}

inline void
ARegion::Fill(
		const Pattern &inPat) const
{
	::FillRgn(*this,&inPat);
}

// ---------------------------------------------------------------------------

inline void
XWrapper<RgnHandle>::DisposeSelf()
{
	::DisposeRgn(mObject);
}
