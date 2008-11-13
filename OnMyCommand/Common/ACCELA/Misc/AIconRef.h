// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once
#include "XRefCountObject.h"

#include "CThrownResult.h"

// ---------------------------------------------------------------------------

const RGBColor kBlackRGB = { 0 };

class AIconRef :
		public XRefCountObject<IconRef>
{
public:
		AIconRef(
				IconRef inIconRef,
				bool inDoRetain = true)
		: XRefCountObject<IconRef>(inIconRef,inDoRetain) {}
		// FSSpec
		AIconRef(
				const FSSpec &inSpec);
		// FSRef
		AIconRef(
				const FSRef &inFSRef);
		// from desktop
		AIconRef(
				OSType inCreator,
				OSType inType,
				SInt16 inVRefNum = kOnSystemDisk);
		// register from family
		AIconRef(
				OSType inCreator,
				OSType inType,
				IconFamilyHandle inIconFamily);
		// register from resource
		AIconRef(
				OSType inCreator,
				OSType inType,
				ResID inID,
				const FSSpec &inSpec);
		// icns file
		AIconRef(
				OSType inCreator,
				OSType inType,
				const FSRef &inFSRef);
		// composite
		AIconRef(
				IconRef inBG,
				IconRef inFG);
	
	void
		Update();
	
	void
		OverrideFromResource(
				const FSSpec &inSpec,
				SInt16 inID);
	void
		OverrideFromIconRef(
				IconRef inIconRef);
	void
		RemoveOverride();
	
	bool
		IsComposite(
				IconRef &outBG,
				IconRef &outFG) const;
	bool
		IsComposite() const;
	
	void
		Plot(
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone,
				IconTransformType inTransform = kTransformNone,
				IconServicesUsageFlags inFlags = kIconServicesNormalUsageFlag) const;
	void
		PlotInContext(
				CGContextRef inContext,
				const CGRect &inRect,
				IconAlignmentType inAlign = kAlignNone,
				IconTransformType inTransform = kTransformNone,
				const RGBColor &inLabelColor = kBlackRGB,
				PlotIconRefFlags inFlags = kPlotIconRefNormalFlags) const;
	bool
		PointHit(
				Point inTestPoint,
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone,
				IconServicesUsageFlags inFlags = kIconServicesNormalUsageFlag) const;
	bool
		RectHit(
				Rect inTestRect,
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone,
				IconServicesUsageFlags inFlags = kIconServicesNormalUsageFlag) const;
	
	void
		MakeRegion(
				RgnHandle outRegion,
				const Rect &inRect,
				IconAlignmentType inAlign = kAlignNone,
				IconServicesUsageFlags inFlags = kIconServicesNormalUsageFlag) const;
	IconFamilyHandle
		MakeIconFamily(
				IconSelectorValue inWhichIcons = kSelectorAllAvailableData) const;
};

// ---------------------------------------------------------------------------

inline
AIconRef::AIconRef(
		const FSSpec &inSpec)
{
	SInt16 label;
 	CThrownOSErr err = ::GetIconRefFromFile(&inSpec,&mObjectRef,&label);
}

inline
AIconRef::AIconRef(
		const FSRef &inFSRef)
{
	SInt16 label;
	CThrownOSStatus err = ::GetIconRefFromFileInfo(
			&inFSRef,0,NULL,kNilOptions,NULL,kIconServicesNormalUsageFlag,&mObjectRef,&label);
}

inline
AIconRef::AIconRef(
		OSType inCreator,
		OSType inType,
		SInt16 inVRefNum)
{
	CThrownOSErr err = ::GetIconRef(inVRefNum,inCreator,inType,&mObjectRef);
}

inline
AIconRef::AIconRef(
		OSType inCreator,
		OSType inType,
		IconFamilyHandle inIconFamily)
{
	CThrownOSErr err = ::RegisterIconRefFromIconFamily(inCreator,inType,inIconFamily,&mObjectRef);
}

inline
AIconRef::AIconRef(
		OSType inCreator,
		OSType inType,
		ResID inID,
		const FSSpec &inSpec)
{
	CThrownOSErr err = ::RegisterIconRefFromResource(inCreator,inType,&inSpec,inID,&mObjectRef);
}

inline
AIconRef::AIconRef(
		OSType inCreator,
		OSType inType,
		const FSRef &inFSRef)
{
	CThrownOSErr err = ::RegisterIconRefFromFSRef(inCreator,inType,&inFSRef,&mObjectRef);
}

inline
AIconRef::AIconRef(
		IconRef inBG,
		IconRef inFG)
{
	CThrownOSErr err = ::CompositeIconRef(inBG,inFG,&mObjectRef);
}

inline void
AIconRef::Update()
{
	CThrownOSErr err = ::UpdateIconRef(mObjectRef);
}

inline void
AIconRef::OverrideFromResource(
		const FSSpec &inSpec,
		SInt16 inID)
{
	CThrownOSErr err = ::OverrideIconRefFromResource(mObjectRef,&inSpec,inID);
}

inline void
AIconRef::OverrideFromIconRef(
		IconRef inIconRef)
{
	CThrownOSErr err = ::OverrideIconRef(mObjectRef,inIconRef);
}

inline void
AIconRef::RemoveOverride()
{
	CThrownOSErr err = ::RemoveIconRefOverride(mObjectRef);
}

inline bool
AIconRef::IsComposite(
		IconRef &outBG,
		IconRef &outFG) const
{
	CThrownOSErr err = ::IsIconRefComposite(mObjectRef,&outBG,&outFG);
	
	return (outBG != NULL) && (outFG != NULL);
}

inline bool
AIconRef::IsComposite() const
{
	IconRef bgRef,fgRef;
	CThrownOSErr err = ::IsIconRefComposite(mObjectRef,&bgRef,&fgRef);
	
	return (bgRef != NULL) && (fgRef != NULL);
}

inline void
AIconRef::Plot(
		const Rect &inRect,
		IconAlignmentType inAlign,
		IconTransformType inTransform,
		IconServicesUsageFlags inFlags) const
{
	CThrownOSErr err = ::PlotIconRef(&inRect,inAlign,inTransform,inFlags,mObjectRef);
}

inline void
AIconRef::PlotInContext(
		CGContextRef inContext,
		const CGRect &inRect,
		IconAlignmentType inAlign,
		IconTransformType inTransform,
		const RGBColor &inLabelColor,
		PlotIconRefFlags inFlags) const
{
	CThrownOSStatus err = ::PlotIconRefInContext(
			inContext,&inRect,inAlign,inTransform,
			&inLabelColor,inFlags,mObjectRef);
}

inline bool
AIconRef::PointHit(
		Point inTestPoint,
		const Rect &inRect,
		IconAlignmentType inAlign,
		IconServicesUsageFlags inFlags) const
{
	return ::PtInIconRef(&inTestPoint,&inRect,inAlign,inFlags,mObjectRef);
}

inline bool
AIconRef::RectHit(
		Rect inTestRect,
		const Rect &inRect,
		IconAlignmentType inAlign,
		IconServicesUsageFlags inFlags) const
{
	return ::RectInIconRef(&inTestRect,&inRect,inAlign,inFlags,mObjectRef);
}

inline void
AIconRef::MakeRegion(
		RgnHandle outRegion,
		const Rect &inRect,
		IconAlignmentType inAlign,
		IconServicesUsageFlags inFlags) const
{
	CThrownOSErr err = ::IconRefToRgn(outRegion,&inRect,inAlign,inFlags,mObjectRef);
}

inline IconFamilyHandle
AIconRef::MakeIconFamily(
		IconSelectorValue inWhichIcons) const
{
	IconFamilyHandle iconFamily;
	CThrownOSErr err = ::IconRefToIconFamily(mObjectRef,inWhichIcons,&iconFamily);
	
	return iconFamily;
}

// ---------------------------------------------------------------------------

inline void
XRefCountObject<IconRef>::Retain()
{ ::AcquireIconRef(mObjectRef); }

inline void
XRefCountObject<IconRef>::Release()
{ ::ReleaseIconRef(mObjectRef); }

inline UInt32
XRefCountObject<IconRef>::GetRetainCount() const
{ UInt16 owners = 0;
  GetIconRefOwners(mObjectRef,&owners);
  return owners; }
