// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "FW.h"

#include FW(ApplicationServices,Icons.h)

class AIconSuite :
		public XWrapper<IconSuiteRef>
{
public:
		AIconSuite();
		AIconSuite(
				SInt16 inID,
				IconSelectorValue inSelector = kSelectorAllAvailableData);
	
	void
		AddIcon(
				Handle inData,
				ResType inType);
	Handle
		CopyIcon(
				ResType inType) const;
	bool
		HasType(
				ResType inType) const;
	
	void
		Plot(
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone,
				IconTransformType inTransform = kTransformNone) const;
	bool
		PointHit(
				Point inTestPoint,
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone) const;
	bool
		RectHit(
				const Rect &inTestRect,
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone) const;
	
	void
		MakeRegion(
				RgnHandle outRegion,
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone) const;
	
	void
		SetLabel(
				SInt16 inlabel);
	SInt16
		GetLabel() const;
	
protected:
	bool mOwnsData;
};

// ---------------------------------------------------------------------------

inline void
XWrapper<IconSuiteRef>::DisposeSelf()
{
	::DisposeIconSuite(mObject,true);	// Dispose of icon data too
}

// ---------------------------------------------------------------------------

inline
AIconSuite::AIconSuite()
: XWrapper(NULL,true)
{
	::NewIconSuite(&mObject);
}

// ---------------------------------------------------------------------------

inline
AIconSuite::AIconSuite(
			SInt16 inID,
			IconSelectorValue inSelector)
: XWrapper(NULL,true)
{
	::GetIconSuite(&mObject,inID,inSelector);
}

// ---------------------------------------------------------------------------

inline void
AIconSuite::AddIcon(
			Handle inData,
			ResType inType)
{
	CThrownOSErr err = ::AddIconToSuite(inData,*this,inType);
}

// ---------------------------------------------------------------------------

inline Handle
AIconSuite::CopyIcon(
			ResType inType) const
{
	Handle iconData = NULL;
	CThrownOSErr err = ::GetIconFromSuite(&iconData,*this,inType);
	return iconData;
}

// ---------------------------------------------------------------------------

inline void
AIconSuite::Plot(
			const Rect &inRect,
			IconAlignmentType inAlign,
			IconTransformType inTransform) const
{
	CThrownOSErr err = ::PlotIconSuite(&inRect,inAlign,inTransform,*this);
}

// ---------------------------------------------------------------------------

inline bool
AIconSuite::PointHit(
			Point inTestPoint,
			const Rect &inRect,
			IconAlignmentType inAlign) const
{
	return ::PtInIconSuite(inTestPoint,&inRect,inAlign,*this);
}

// ---------------------------------------------------------------------------

inline bool
AIconSuite::RectHit(
			const Rect &inTestRect,
			const Rect &inRect,
			IconAlignmentType inAlign) const
{
	return ::RectInIconSuite(&inTestRect,&inRect,inAlign,*this);
}

// ---------------------------------------------------------------------------

inline void
AIconSuite::MakeRegion(
			RgnHandle outRegion,
			const Rect &inRect,
			IconAlignmentType inAlign) const
{
	CThrownOSErr err = ::IconSuiteToRgn(outRegion,&inRect,inAlign,*this);
}

// ---------------------------------------------------------------------------

inline void
AIconSuite::SetLabel(
			SInt16 inLabel)
{
	CThrownOSErr err = ::SetSuiteLabel(*this,inLabel);
}

// ---------------------------------------------------------------------------

inline SInt16
AIconSuite::GetLabel() const
{
	return ::GetSuiteLabel(*this);
}
