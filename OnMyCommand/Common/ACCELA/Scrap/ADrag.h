#pragma once

#include "XWrapper.h"
#include "FW.h"
#include "CThrownResult.h"

#include FW(ApplicationServices,ApplicationServices.h)
#include FW(Carbon,Drag.h)

class ADragItem;

// ---------------------------------------------------------------------------
#pragma mark ADrag

class ADrag :
		public XWrapper<DragRef>
{
public:
		ADrag(
				DragRef inDragRef,
				bool inOwner = false)
		: XWrapper<DragRef>(inDragRef,inOwner) {}
	
	UInt16
		CountItems();
	ADragItem
		GetItem(
				UInt16 inIndex);
	void
		GetDropLocation(
				AEDesc &outDropLocation) const;
	Point
		GetOrigin() const;
	
	void
		SetImage(
				PixMapHandle inImagePixMap,
				RgnHandle inImageRegion,
				Point inImageOffset,
				DragImageFlags inFlags = kDragStandardTranslucency);
	void
		SetImage(
				PixMapHandle inImagePixMap,
				PixMapHandle inMaskPixMap,
				RgnHandle inImageRegion,
				Point inImageOffset,
				Point inGlobalOffset,
				DragImageFlags inFlags = kDragStandardTranslucency);
	
	static bool
		IsDragHappening()
		{ return sDragHappening; }
	static bool
		UsesAlphaImage();
	
protected:
	static bool sDragHappening;
	
		ADrag() {}
};

// ---------------------------------------------------------------------------
#pragma mark AIncomingDrag

class AIncomingDrag : public ADrag {
public:
		AIncomingDrag(
				DragRef inDragRef)
		: ADrag(inDragRef,false) {}
	
	DragAttributes
		GetAttributes() const;
	void
		GetMouse(
				Point &outMouse,
				Point &outGlobalPinnedMouse) const;
	Point
		GetMouse() const;
	void
		SetMouse(
				Point inGlobalPinnedMouse);
	void
		GetModifiers(
				SInt16 &outModifiers,
				SInt16 &outMouseDownModifiers,
				SInt16 &outMouseUpModifiers) const;
	void
		GetModifiers(
				SInt16 &outModifiers) const;
	
	void
		ShowHilite(
				RgnHandle inFrame,
				bool inInside);
	void
		HideHilite();
	void
		PreScroll(
				SInt16 inHorizDelta,
				SInt16 inVertDelta);
	void
		PostScroll();
	void
		UpdateHilite(
				RgnHandle inUpdateRgn);
};

// ---------------------------------------------------------------------------
#pragma mark AOutgoingDrag

#pragma warn_unusedarg off

class AOutgoingDrag : public ADrag {
public:
		AOutgoingDrag(
				bool inOwnsDrag = true);
		AOutgoingDrag(
				DragRef inDragRef,
				bool inOwner = false)
		: ADrag(inDragRef,inOwner) {}
	virtual
		~AOutgoingDrag();
		
	void
		Track(
				const EventRecord &inEvent,
				RgnHandle inRegion);
	
	void
		ChangeBehaviors(
				DragBehaviors inSetFlags,
				DragBehaviors inClearFlags);
	void
		DontSnapBack()
		{ ChangeBehaviors(kDragBehaviorNone,kDragBehaviorZoomBackAnimation); }
	
protected:
	static DragSendDataUPP sSendUPP;
	static DragInputUPP sInputUPP;
	
	void
		UseSendProc();
	void
		UseInputProc();
	
	virtual OSErr
		SendData(
				FlavorType inFlavor,
				DragItemRef inItemRef)
		{ return noErr; }
	virtual OSErr
		Input(
				Point &ioMouse,
				SInt16 &ioModifiers)
		{ return noErr; }
	
	static pascal OSErr
		SendDataProc(
				FlavorType inFlavor,
				void *inRefCon,
				DragItemRef inItemRef,
				DragRef inDragRef);
	static pascal OSErr
		InputProc(
				Point *ioMouse,
				SInt16 *ioModifiers,
				void *inRefCon,
				DragRef inDragRef);
};

#pragma warn_unusedarg reset

// ---------------------------------------------------------------------------
#pragma mark ADragItem

class ADragItem {
public:
		ADragItem(
			ADrag &inDragObject,
			DragItemRef inItemRef)
		: mDrag(inDragObject), mItemRef(inItemRef) {}
	
	ADrag&
		GetDrag()
		{ return mDrag; }
	
	operator
		ItemReference() const
		{ return mItemRef; }
	
	void
		AddFlavorData(
				FlavorType inFlavor,
				const void *inData,
				Size inSize,
				FlavorFlags inFlags = 0);
	void
		AddFlavorHandle(
				FlavorType inFlavor,
				Handle inDataHandle,
				FlavorFlags inFlags = 0);
	void
		SetFlavorData(
				FlavorType inFlavor,
				const void *inData,
				Size inSize,
				UInt32 inOffset = 0);
	template <class T>
	void
		AddFlavor(
				FlavorType inFlavor,
				const T &inDataObject,
				FlavorFlags inFlags = 0);
	void
		PromiseFlavor(
				FlavorType inFlavor,
				FlavorFlags inFlags = 0);
	template <class T>
	void
		SetFlavorData(
				FlavorType inFlavor,
				const T &inDataObject);
	
	UInt16
		CountFlavors();
	FlavorType
		GetIndFlavor(
				UInt16 inFlavorIndex);
	FlavorFlags
		GetFlavorFlags(
				FlavorType inFlavor);
	Size
		GetFlavorSize(
				FlavorType inFlavor);
	void
		GetFlavorData(
				FlavorType inFlavor,
				void *inBuffer,
				Size &ioSize,
				UInt32 inOffset = 0);
	template <class T>
	void
		GetFlavorData(
				FlavorType inFlavor,
				T &outDataObject)
		{
			Size dataSize = sizeof(T);
			CThrownOSStatus err;
			
			err = ::GetFlavorData(mDrag,mItemRef,inFlavor,&outDataObject,&dataSize,0);
			if (dataSize != sizeof(T))
				err = scrapFlavorSizeMismatchErr;
		}
	bool
		HasFlavor(
				FlavorType inFlavor) const;
	
	void
		GetBounds(
				Rect &outBounds) const;
	Rect
		Bounds() const;
	void
		SetBounds(
				const Rect &inBounds);
	
protected:
	ADrag &mDrag;
	ItemReference mItemRef;
};

// ---------------------------------------------------------------------------

inline void
ADrag::GetDropLocation(
		AEDesc &outDropLocation) const
{
	CThrownOSStatus err = ::GetDropLocation(mObject,&outDropLocation);
}

inline void
ADrag::SetImage(
		PixMapHandle inImagePixMap,
		RgnHandle inImageRegion,
		Point inImageOffset,
		DragImageFlags inFlags)
{
	CThrownOSStatus err = ::SetDragImage(mObject,inImagePixMap,inImageRegion,inImageOffset,inFlags);
}


inline void
AIncomingDrag::GetMouse(
		Point &outMouse,
		Point &outGlobalPinnedMouse) const
{
	CThrownOSStatus err = ::GetDragMouse(mObject,&outMouse,&outGlobalPinnedMouse);
}

inline void
AIncomingDrag::SetMouse(
		Point inGlobalPinnedMouse)
{
	CThrownOSStatus err = ::SetDragMouse(mObject,inGlobalPinnedMouse);
}

inline void
AIncomingDrag::GetModifiers(
		SInt16 &outModifiers,
		SInt16 &outMouseDownModifiers,
		SInt16 &outMouseUpModifiers) const
{
	CThrownOSStatus err = ::GetDragModifiers(mObject,&outModifiers,&outMouseDownModifiers,&outMouseUpModifiers);
}

inline void
AIncomingDrag::GetModifiers(
		SInt16 &outModifiers) const
{
	CThrownOSStatus err = ::GetDragModifiers(mObject,&outModifiers,NULL,NULL);
}

inline void
AIncomingDrag::ShowHilite(
		RgnHandle inFrame,
		bool inInside)
{
	CThrownOSStatus err = ::ShowDragHilite(mObject,inFrame,inInside);
}

inline void
AIncomingDrag::HideHilite()
{
	CThrownOSStatus err = ::HideDragHilite(mObject);
}

inline void
AIncomingDrag::PreScroll(
		SInt16 inHorizDelta,
		SInt16 inVertDelta)
{
	CThrownOSStatus err = ::DragPreScroll(mObject,inHorizDelta,inVertDelta);
}

inline void
AIncomingDrag::PostScroll()
{
	CThrownOSStatus err = ::DragPostScroll(mObject);
}

inline void
AIncomingDrag::UpdateHilite(
		RgnHandle inUpdateRgn)
{
	CThrownOSStatus err = ::UpdateDragHilite(mObject,inUpdateRgn);
}


inline void
AOutgoingDrag::ChangeBehaviors(
		DragBehaviors inSetFlags,
		DragBehaviors inClearFlags)
{
	CThrownOSStatus err = ::ChangeDragBehaviors(mObject,inSetFlags,inClearFlags);
}

inline void
ADragItem::AddFlavorData(
		FlavorType inFlavor,
		const void *inData,
		Size inSize,
		FlavorFlags inFlags)
{
	CThrownOSStatus err = ::AddDragItemFlavor(mDrag,mItemRef,inFlavor,inData,inSize,inFlags);
}

inline void
ADragItem::AddFlavorHandle(
		FlavorType inFlavor,
		Handle inDataHandle,
		FlavorFlags inFlags)
{
	CThrownOSStatus err = ::AddDragItemFlavor(mDrag,mItemRef,inFlavor,*inDataHandle,::GetHandleSize(inDataHandle),inFlags);
}

inline void
ADragItem::PromiseFlavor(
		FlavorType inFlavor,
		FlavorFlags inFlags)
{
	CThrownOSStatus err = ::AddDragItemFlavor(mDrag,mItemRef,inFlavor,NULL,0,inFlags);
}

inline void
ADragItem::SetFlavorData(
		FlavorType inFlavor,
		const void *inData,
		Size inSize,
		UInt32 inOffset)
{
	CThrownOSStatus err = ::SetDragItemFlavorData(mDrag,mItemRef,inFlavor,inData,inSize,inOffset);
}

template <class T>
inline void
ADragItem::AddFlavor(
		FlavorType inFlavor,
		const T &inDataObject,
		FlavorFlags inFlags)
{
	CThrownOSStatus err = ::AddDragItemFlavor(mDrag,mItemRef,inFlavor,&inDataObject,sizeof(T),inFlags);
}

template <class T>
inline void
ADragItem::SetFlavorData(
		FlavorType inFlavor,
		const T &inDataObject)
{
	CThrownOSStatus err = ::SetDragItemFlavorData(mDrag,mItemRef,inFlavor,&inDataObject,sizeof(T),0);
}

inline void
ADragItem::GetFlavorData(
		FlavorType inFlavor,
		void *inBuffer,
		Size &ioSize,
		UInt32 inOffset)
{
	CThrownOSStatus err = ::GetFlavorData(mDrag,mItemRef,inFlavor,inBuffer,&ioSize,inOffset);
}

inline void
ADragItem::GetBounds(
		Rect &outBounds) const
{
	CThrownOSStatus err = ::GetDragItemBounds(mDrag,mItemRef,&outBounds);
}

inline Rect
ADragItem::Bounds() const
{
	Rect bounds;
	CThrownOSStatus err = ::GetDragItemBounds(mDrag,mItemRef,&bounds);
	return bounds;
}

inline void
ADragItem::SetBounds(
		const Rect &inBounds)
{
	CThrownOSStatus err = ::SetDragItemBounds(mDrag,mItemRef,&inBounds);
}
