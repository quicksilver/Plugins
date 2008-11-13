#include "AHIObject.h"

class AView :
		public AHIObject
{
public:
		// HIViewRef
		AView(
				HIViewRef inView,
				bool inDoRetain = true)
		: AHIObject(reinterpret_cast<HIObjectRef>(inView),inDoRetain) {}
		// WindowRef
		AView(
				WindowRef inWindow)
		: AHIObject(reinterpret_cast<HIObjectRef>(::HIViewGetRoot(inWindow))) {}
		// HIObjectRef
		AView(
				HIObjectRef inObject,
				bool inDoRetain = true)
		: AHIObject(inObject,inDoRetain) {}
	
		operator HIViewRef() const
		{
			return (HIViewRef)mObjectRef;
		}
	
	// hierarchy
	void
		AddSubview(
				HIViewRef inNewChild);
	void
		RemoveFromSuperview();
	HIViewRef
		Superview();
	
	// visibility
	void
		SetVisible(
				bool inVisible);
	bool
		IsVisible() const;
	
	// positioning
	void
		GetBounds(
				HIRect &outBounds) const;
	HIRect
		Bounds() const;
	void
		GetFrame(
				HIRect &outFrame) const;
	HIRect
		Frame() const;
	void
		SetFrame(
				const HIRect &inFrame);
	void
		MoveBy(
				float inDX,
				float inDY);
	void
		MoveBy(
				Float32Point inDelta);
	void
		MoveBy(
				Point inDelta);
	void
		PlaceInSuperviewAt(
				float inX,
				float inV);
	void
		PlaceInSuperviewAt(
				Float32Point inPoint);
	void
		PlaceInSuperviewAt(
				Point inPoint);
	void
		SetZOrder(
				HIViewZOrderOp inOp,
				HIViewRef inOther = NULL);
	
	void
		ReshapeStructure();
	
	// events
	HIViewRef
		ViewForMouseEvent(
				EventRef inEvent) const;
	void
		Click(
				EventRef inEvent);
	ControlPartCode
		SimulateClick(
				HIViewPartCode inPartToClick = kControlEntireControl,
				UInt32 inModifiers = 0);
	HIViewPartCode
		PartHit(
				const HIPoint &inPoint) const;
	HIViewRef
		SubviewHit(
				const HIPoint &inPoint,
				bool inDeep) const;
	
	// display
	bool
		NeedsDisplay() const;
	void
		SetNeedsDisplay(
				bool inNeedsDisplay);
	void
		SetNeedsDisplay(
				RgnHandle inRegion,
				bool inNeedsDisplay);
	
	void
		SetDrawingEnabled(
				bool inEnabled);
	bool
		IsDrawingEnabled() const;
	
	void
		GetSizeConstraints(
				HISize &outMinSize,
				HISize &outMaxSize) const;
	
	void
		ScrollRect(
				const HIRect &inRect,
				float inDX,
				float inDY);
	void
		ScrollRect(
				float inDX,
				float inDY);
	
	// coordinates
	void
		ConvertPoint(
				HIPoint &ioPoint,
				HIViewRef inFromView) const;
	void
		ConvertRect(
				HIRect &ioRect,
				HIViewRef inFromView) const;
	void
		ConvertRegion(
				RgnHandle ioRegion,
				HIViewRef inFromView) const;
	
	// focus
	void
		AdvanceFocus(
				EventModifiers inModifiers = 0);
	HIViewPartCode
		FocusPart() const;
	bool
		ContainsFocus() const;
	void
		SetNextFocus(
				HIViewRef inNextFocus);
	void
		SetFirstSubViewFocus(
				HIViewRef inSubView);
	
	// misc
	HIViewRef
		FindViewByID(
				HIViewID inID) const;
	OptionBits
		Attributes() const;
	void
		ChangeAttributes(
				OptionBits inSetAttrs,
				OptionBits inClearAttrs);
	CGImageRef
		CreateOffscreenImage(
				OptionBits inOptions) const;
	CGImageRef
		CreateOffscreenImage(
				OptionBits inOptions,
				HIRect &outFrame) const;
};

// ---------------------------------------------------------------------------

inline void
AView::AddSubview(
		HIViewRef inNewChild)
{
	CThrownOSStatus err = ::HIViewAddSubview(*this,inNewChild);
}

inline void
AView::RemoveFromSuperview()
{
	CThrownOSStatus err = ::HIViewRemoveFromSuperview(*this);
}

inline HIViewRef
AView::Superview()
{
	return ::HIViewGetSuperview(*this);
}

// visibility
inline void
AView::SetVisible(
		bool inVisible)
{
	CThrownOSStatus err = ::HIViewSetVisible(*this,inVisible);
}

inline bool
AView::IsVisible() const
{
	return ::HIViewIsVisible(*this);
}

// positioning
inline void
AView::GetBounds(
		HIRect &outBounds) const
{
	CThrownOSStatus err = ::HIViewGetBounds(*this,&outBounds);
}

inline HIRect
AView::Bounds() const
{
	HIRect bounds;
	GetBounds(bounds);
	return bounds;
}

inline void
AView::GetFrame(
		HIRect &outFrame) const
{
	CThrownOSStatus err = ::HIViewGetFrame(*this,&outFrame);
}

inline HIRect
AView::Frame() const
{
	HIRect frame;
	GetFrame(frame);
	return frame;
}

inline void
AView::SetFrame(
		const HIRect &inFrame)
{
	CThrownOSStatus err = ::HIViewSetFrame(*this,&inFrame);
}

inline void
AView::MoveBy(
		float inDX,
		float inDY)
{
	CThrownOSStatus err = ::HIViewMoveBy(*this,inDX,inDY);
}

inline void
AView::MoveBy(
		Float32Point inDelta)
{
	CThrownOSStatus err = ::HIViewMoveBy(*this,inDelta.x,inDelta.y);
}

inline void
AView::MoveBy(
		Point inDelta)
{
	CThrownOSStatus err = ::HIViewMoveBy(*this,inDelta.h,inDelta.v);
}

inline void
AView::PlaceInSuperviewAt(
		float inX,
		float inY)
{
	CThrownOSStatus err = ::HIViewPlaceInSuperviewAt(*this,inX,inY);
}

inline void
AView::PlaceInSuperviewAt(
		Float32Point inPoint)
{
	CThrownOSStatus err = ::HIViewPlaceInSuperviewAt(*this,inPoint.x,inPoint.y);
}

inline void
AView::PlaceInSuperviewAt(
		Point inPoint)
{
	CThrownOSStatus err = ::HIViewPlaceInSuperviewAt(*this,inPoint.h,inPoint.v);
}

inline void
AView::SetZOrder(
		HIViewZOrderOp inOp,
		HIViewRef inOther)
{
	CThrownOSStatus err = ::HIViewSetZOrder(*this,inOp,inOther);
}


inline void
AView::ReshapeStructure()
{
	CThrownOSStatus err = ::HIViewReshapeStructure(*this);
}

// events
inline HIViewRef
AView::ViewForMouseEvent(
		EventRef inEvent) const
{
	HIViewRef view;
	CThrownOSStatus err = ::HIViewGetViewForMouseEvent(*this,inEvent,&view);
	return view;
}

inline void
AView::Click(
		EventRef inEvent)
{
	CThrownOSStatus err = ::HIViewClick(*this,inEvent);
}

inline ControlPartCode
AView::SimulateClick(
		HIViewPartCode inPartToClick,
		UInt32 inModifiers)
{
	ControlPartCode partClicked;
	CThrownOSStatus err = ::HIViewSimulateClick(*this,inPartToClick,inModifiers,&partClicked);
	return partClicked;
}

inline HIViewPartCode
AView::PartHit(
		const HIPoint &inPoint) const
{
	ControlPartCode partClicked;
	CThrownOSStatus err = ::HIViewGetPartHit(*this,&inPoint,&partClicked);
	return partClicked;
}

inline HIViewRef
AView::SubviewHit(
		const HIPoint &inPoint,
		bool inDeep) const
{
	HIViewRef subView;
	CThrownOSStatus err = ::HIViewGetSubviewHit(*this,&inPoint,inDeep,&subView);
	return subView;
}

// display
inline bool
AView::NeedsDisplay() const
{
	return ::HIViewGetNeedsDisplay(*this);
}

inline void
AView::SetNeedsDisplay(
		bool inNeedsDisplay)
{
	CThrownOSStatus err = ::HIViewSetNeedsDisplay(*this,inNeedsDisplay);
}

inline void
AView::SetNeedsDisplay(
		RgnHandle inRegion,
		bool inNeedsDisplay)
{
	CThrownOSStatus err = ::HIViewSetNeedsDisplayInRegion(*this,inRegion,inNeedsDisplay);
}

inline void
AView::SetDrawingEnabled(
		bool inEnabled)
{
	CThrownOSStatus err = ::HIViewSetDrawingEnabled(*this,inEnabled);
}

inline bool
AView::IsDrawingEnabled() const
{
	return ::HIViewIsDrawingEnabled(*this);
}

inline void
AView::GetSizeConstraints(
		HISize &outMinSize,
		HISize &outMaxSize) const
{
	CThrownOSStatus err = ::HIViewGetSizeConstraints(*this,&outMinSize,&outMaxSize);
}

inline void
AView::ScrollRect(
		const HIRect &inRect,
		float inDX,
		float inDY)
{
	CThrownOSStatus err = ::HIViewScrollRect(*this,&inRect,inDX,inDY);
}

inline void
AView::ScrollRect(
		float inDX,
		float inDY)
{
	CThrownOSStatus err = ::HIViewScrollRect(*this,NULL,inDX,inDY);
}

// coordinates
inline void
AView::ConvertPoint(
		HIPoint &ioPoint,
		HIViewRef inFromView) const
{
	CThrownOSStatus err = ::HIViewConvertPoint(&ioPoint,inFromView,*this);
}

inline void
AView::ConvertRect(
		HIRect &ioRect,
		HIViewRef inFromView) const
{
	CThrownOSStatus err = ::HIViewConvertRect(&ioRect,inFromView,*this);
}

inline void
AView::ConvertRegion(
		RgnHandle ioRegion,
		HIViewRef inFromView) const
{
	CThrownOSStatus err = ::HIViewConvertRegion(ioRegion,inFromView,*this);
}

// focus
inline void
AView::AdvanceFocus(
		EventModifiers inModifiers)
{
	CThrownOSStatus err = ::HIViewAdvanceFocus(*this,inModifiers);
}

inline HIViewPartCode
AView::FocusPart() const
{
	HIViewPartCode part;
	CThrownOSStatus err = ::HIViewGetFocusPart(*this,&part);
	return part;
}

inline bool
AView::ContainsFocus() const
{
	return ::HIViewSubtreeContainsFocus(*this);
}

inline void
AView::SetNextFocus(
		HIViewRef inNextFocus)
{
	CThrownOSStatus err = ::HIViewSetNextFocus(*this,inNextFocus);
}

inline void
AView::SetFirstSubViewFocus(
		HIViewRef inSubView)
{
	CThrownOSStatus err = ::HIViewSetFirstSubViewFocus(*this,inSubView);
}

// misc
inline HIViewRef
AView::FindViewByID(
		HIViewID inID) const
{
	HIViewRef subView;
	CThrownOSStatus err = ::HIViewFindByID(*this,inID,&subView);
	return subView;
}

inline OptionBits
AView::Attributes() const
{
	OptionBits attributes;
	CThrownOSStatus err = ::HIViewGetAttributes(*this,&attributes);
	return attributes;
}

inline void
AView::ChangeAttributes(
		OptionBits inSetAttrs,
		OptionBits inClearAttrs)
{
	CThrownOSStatus err = ::HIViewChangeAttributes(*this,inSetAttrs,inClearAttrs);
}

inline CGImageRef
AView::CreateOffscreenImage(
		OptionBits inOptions) const
{
	CGImageRef image;
	CThrownOSStatus err = ::HIViewCreateOffscreenImage(*this,inOptions,NULL,&image);
	return image;
}

inline CGImageRef
AView::CreateOffscreenImage(
		OptionBits inOptions,
		HIRect &outFrame) const
{
	CGImageRef image;
	CThrownOSStatus err = ::HIViewCreateOffscreenImage(*this,inOptions,&outFrame,&image);
	return image;
}
