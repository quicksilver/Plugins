#include "ADrag.h"
#include "ACGImage.h"
#include "XSystem.h"
#include "XValueChanger.h"

#if TARGET_RT_MAC_CFM
#include "GetCarbonFunction.h"
#endif

bool ADrag::sDragHappening = false;

DragSendDataUPP AOutgoingDrag::sSendUPP = NewDragSendDataUPP(AOutgoingDrag::SendDataProc);
DragInputUPP AOutgoingDrag::sInputUPP = NewDragInputUPP(AOutgoingDrag::InputProc);

// ---------------------------------------------------------------------------

void
XWrapper<DragRef>::DisposeSelf()
{
	::DisposeDrag(mObject);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
ADrag::SetImage(
		PixMapHandle inImagePixMap,
		PixMapHandle inMaskPixMap,
		RgnHandle inImageRegion,
		Point inImageOffset,
		Point inGlobalOffset,
		DragImageFlags inFlags)
{
	if (UsesAlphaImage()) {
		inImageOffset.h -= inGlobalOffset.h;
		inImageOffset.v -= inGlobalOffset.v;
#if TARGET_RT_MAC_CFM
		// this function is in GetCarbonFunction.cp
		SetDragImageWithAlpha(mObject,inImagePixMap,inMaskPixMap,inImageOffset,inFlags);
#else
		HIPoint offset = { inImageOffset.h,inImageOffset.v };
		
		::SetDragImageWithCGImage(mObject,ACGImage(inImagePixMap,inMaskPixMap),&offset,inFlags);
#endif
	}
	else
		SetImage(inImagePixMap,inImageRegion,inImageOffset,inFlags);
}

// ---------------------------------------------------------------------------

UInt16
ADrag::CountItems()
{
	UInt16 itemCount = 0;
	
	::CountDragItems(mObject,&itemCount);
	return itemCount;
}

// ---------------------------------------------------------------------------

ADragItem
ADrag::GetItem(
		UInt16 inIndex)
{
	ItemReference itemRef;
	CThrownOSStatus err;
	
	err = ::GetDragItemReferenceNumber(mObject,inIndex,&itemRef);
	return ADragItem(*this,itemRef);
}

// ---------------------------------------------------------------------------

Point
ADrag::GetOrigin() const
{
	Point origin;
	
	::GetDragOrigin(mObject,&origin);
	return origin;
}

// ---------------------------------------------------------------------------

bool
ADrag::UsesAlphaImage()
{
	const SInt32 sysVersion = XSystem::OSVersion();
	
	return (sysVersion >= 0x1020) || ((sysVersion >= 0x1010) && (sysVersion <= 0x1014));
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

DragAttributes
AIncomingDrag::GetAttributes() const
{
	DragAttributes attributes;
	CThrownOSStatus err;
	
	err = ::GetDragAttributes(mObject,&attributes);
	return attributes;
}

// ---------------------------------------------------------------------------

Point
AIncomingDrag::GetMouse() const
{
	Point mouse,pinned;
	CThrownOSStatus err;
	
	err = ::GetDragMouse(mObject,&mouse,&pinned);
	return mouse;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AOutgoingDrag::AOutgoingDrag(
		bool inOwnsDrag)
: ADrag(NULL,inOwnsDrag)
{
	CThrownOSStatus err = ::NewDrag(&mObject);
}

// ---------------------------------------------------------------------------

AOutgoingDrag::~AOutgoingDrag()
{
}

// ---------------------------------------------------------------------------

void
AOutgoingDrag::Track(
		const EventRecord &inEvent,
		RgnHandle inRegion)
{
	CThrownOSErr result;
	XValueChanger<bool> happening(sDragHappening,true);
	
	result.Allow(userCanceledErr);
	result = ::TrackDrag(mObject,&inEvent,inRegion);
}

// ---------------------------------------------------------------------------

void
AOutgoingDrag::UseSendProc()
{
	CThrownOSStatus err = ::SetDragSendProc(mObject,sSendUPP,(void*)this);
}

// ---------------------------------------------------------------------------

void
AOutgoingDrag::UseInputProc()
{
	CThrownOSStatus err = ::SetDragInputProc(mObject,sInputUPP,(void*)this);
}

// ---------------------------------------------------------------------------

pascal OSErr
AOutgoingDrag::SendDataProc(
		FlavorType inFlavor,
		void *inRefCon,
		DragItemRef inItemRef,
		DragRef inDragRef)
{
#pragma unused(inDragRef)
	AOutgoingDrag *drag = static_cast<AOutgoingDrag*>(inRefCon);
	OSErr err = noErr;
	
	try {
		err = drag->SendData(inFlavor,inItemRef);
	}
	catch (...) {
		err = -1;
	}
	return err;
}

// ---------------------------------------------------------------------------

pascal OSErr
AOutgoingDrag::InputProc(
		Point *ioMouse,
		SInt16 *ioModifiers,
		void *inRefCon,
		DragRef inDragRef)
{
#pragma unused(inDragRef)
	AOutgoingDrag *drag = static_cast<AOutgoingDrag*>(inRefCon);
	OSErr err = noErr;
	
	try {
		err = drag->Input(*ioMouse,*ioModifiers);
	}
	catch (...) {
		err = -1;
	}
	return err;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

UInt16
ADragItem::CountFlavors()
{
	UInt16 flavorCount = 0;
	
	::CountDragItemFlavors(mDrag,mItemRef,&flavorCount);
	return flavorCount;
}

// ---------------------------------------------------------------------------

FlavorType
ADragItem::GetIndFlavor(
		UInt16 inFlavorIndex)
{
	FlavorType flavor = NULL;
	CThrownOSStatus err;
	
	err = ::GetFlavorType(mDrag,mItemRef,inFlavorIndex,&flavor);
	return flavor;
}

// ---------------------------------------------------------------------------

FlavorFlags
ADragItem::GetFlavorFlags(
		FlavorType inFlavor)
{
	FlavorFlags flags = 0;
	CThrownOSStatus err;
	
	err = ::GetFlavorFlags(mDrag,mItemRef,inFlavor,&flags);
	return flags;
}

// ---------------------------------------------------------------------------

Size
ADragItem::GetFlavorSize(
		FlavorType inFlavor)
{
	Size flavorSize = -1;
	CThrownOSStatus err;
	
	err = ::GetFlavorDataSize(mDrag,mItemRef,inFlavor,&flavorSize);
	return flavorSize;
}

// ---------------------------------------------------------------------------

bool
ADragItem::HasFlavor(
		FlavorType inFlavor) const
{
	FlavorFlags flags = 0;
	OSStatus err;
	
	err = ::GetFlavorFlags(mDrag,mItemRef,inFlavor,&flags);
	return (err == noErr);
}
