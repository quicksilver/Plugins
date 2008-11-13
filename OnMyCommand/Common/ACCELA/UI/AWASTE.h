#pragma once

#include "XWrapper.h"
#include "CThrownResult.h"

#include "WASTE.h"

#define _WASTE21_ (WASTE_VERSION >= 0x02100000)

class AWASTE :
		public XWrapper<WEReference>
{
public:
		AWASTE(
				WEReference inRef,
				bool inOwner = false)
		: XWrapper(inRef,inOwner) {}
		AWASTE(
				CGrafPtr inPort,
				const LongRect &inDestRect,
				const LongRect &inViewRect,
				OptionBits inOptions)
		{
			CGrafPtr savePort;
			::GetPort(&savePort);
			::SetPort(inPort);
			CThrownOSErr err = ::WENew(&inDestRect,&inViewRect,inOptions,&mObject);
			::SetPort(savePort);
		}
	
	// general text
	SInt16
		GetChar(
				SInt32 inOffset) const;
	SInt32
		TextLength() const;
	
	// selection
	void
		GetSelection(
				SInt32 &outStart,
				SInt32 &outEnd) const;
	SInt32
		SelectionAnchor() const;
	void
		SetSelection(
				SInt32 inStart,
				SInt32 inEnd);
	
	// rectangles
	void
		GetDestRect(
				LongRect &outRect) const;
	void
		GetViewRect(
				LongRect &outRect) const;
	void
		SetDestRect(
				const LongRect &inRect);
	void
		SetViewRect(
				const LongRect &inRect);
	
	// activation
	bool
		IsActive() const;
	void
		Activate();
	void
		Deactivate();
	
#if _WASTE21_
	// tabs
	Fixed
		DefaultTabWidth() const;
	void
		SetDefaultTabWidth(
				Fixed inWidth);
#endif
	
	// styles
	void
		GetAttributes(
				SInt32 inOffset,
				ItemCount inAttributeCount,
				const WESelector inSelectors[],
				void * const outAttrValues[],
				const ByteCount inAttrSizes[]) const;
	void
		GetOneAttribute(
				SInt32 inOffset,
				WESelector inSelector,
				void *outValue,
				ByteCount inValueSize);
	void
		SetAttributes(
				SInt32 inStart,
				SInt32 inEnd,
				ItemCount inAttributeCount,
				const WESelector inSelectors[],
				const void * const inAttrValues[],
				const ByteCount inAttrSizes[]) const;
	void
		SetOneAttribute(
				SInt32 inStart,
				SInt32 inEnd,
				WESelector inSelector,
				const void *inValue,
				ByteCount inSize) const;
	
	// layout
	SInt32
		CountLines() const;
	SInt32
		OffsetToLine(
				SInt32 inOffset) const;
	void
		GetLineRange(
				SInt32 inLineIndex,
				SInt32 &outStart,
				SInt32 &outEnd);
	SInt32
		LineHeight(
				SInt32 inStart,
				SInt32 inEnd);
	SInt16
		LineAscent(
				SInt32 inLineIndex);
	SInt32
		MaxLineWidth();
	
	// offset <-> screen
	void
		OffsetFromPoint(
				const LongPt &inPoint,
				WEEdge &outEdge);
	void
		PointFromOffset(
				SInt32 inOffset,
				SInt16 inDirection,
				LongPt &outPoint,
				SInt16 &outLineHeight);
	
	// find
	void
		Find(
				const char *inKey,
				SInt32 inLength,
				TextEncoding inEncoding,
				OptionBits inOptions,
				SInt32 inStart,
				SInt32 inEnd,
				SInt32 &outMatchStart,
				SInt32 &outMatchEnd);
	
	// drawing
	void
		CalText();
	void
		Update(
				RgnHandle inRegion);
	void
		Scroll(
				SInt32 inH,
				SInt32 inV);
	void
		PinScroll(
				SInt32 inH,
				SInt32 inV);
	void
		ScrollToSelection();
	
	// events
	void
		Key(
				CharParameter inKey,
				EventModifiers inModifiers);
	void
		Click(
				Point inPoint,
				EventModifiers inModifiers,
				UInt32 inClickTime);
	UInt16
		ClickCount() const;
	OSStatus
		ProcessHICommand(
				const HICommand &inCommand);
	bool
		AdjustCursor(
				Point inPoint,
				RgnHandle ioRegion);
	void
		Idle(
				UInt32 &outMaxSleep);
	
	// modifying text
	void
		Put(
				SInt32 inStart,
				SInt32 inEnd,
				const void *inText,
				SInt32 inLength,
				TextEncoding inEncoding,
				OptionBits inOptions,
				ItemCount inFlavorCount = 0,
				const FlavorType *inFlavorTypes = NULL,
				const Handle *inFlavors = NULL);
	void
		Delete();
	void
		UseText(
				Handle inText);
	void
		ChangeCase(
				SInt16 inCase);
	
	// clipboard
	void
		Cut();
	void
		Copy() const;
	void
		CopyToScrap(
				OptionBits inOptions = 0,
				ScrapRef inScrap = NULL,
				const ScrapFlavorType *inFlavors = NULL) const;
	void
		Paste();
	void
		PasteFromScrap(
				ScrapRef inScrap,
				OptionBits inOptions);
	bool
		CanPaste();
	
	// dragging
	RgnHandle
		HiliteRegion(
				SInt32 inStart,
				SInt32 inEnd);
	OSErr
		TrackDrag(
				DragTrackingMessage inMessage,
				DragRef inDragRef);
	OSErr
		ReceiveDrag(
				DragRef inDragRef);
	bool
		CanAcceptDrag(
				DragRef inDragRef);
	
	// filing
	void
		Save(
				SInt32 inStart,
				SInt32 inEnd,
				const FSRef &inRef,
				OSType inFileType,
				TextEncoding inEncoding,
				OptionBits inOptions);
	void
		Load(			
				SInt32 inStart,
				SInt32 inEnd,
				const FSRef &inRef,
				OSType &ioFileType,
				TextEncoding &ioEncoding,
				OptionBits &ioOptions);
	
	// features
	SInt16
		FeatureFlag(
				SInt16 inFeature,
				SInt16 inAction);
	void
		GetInfo(
				WESelector inSelector,
				void *outInfo);
	void
		SetInfo(
				WESelector inSelector,
				const void *inInfo);
};

// ---------------------------------------------------------------------------

inline SInt32
AWASTE::TextLength() const
{
	return ::WEGetTextLength(*this);
}

inline void
AWASTE::GetSelection(
		SInt32 &outStart,
		SInt32 &outEnd) const
{
	::WEGetSelection(&outStart,&outEnd,*this);
}

#if _WASTE21_
inline SInt32
AWASTE::SelectionAnchor() const
{
	return ::WEGetSelectionAnchor(*this);
}
#endif

inline void
AWASTE::SetSelection(
		SInt32 inStart,
		SInt32 inEnd)
{
	::WESetSelection(inStart,inEnd,*this);
}

// rectangles
inline void
AWASTE::GetDestRect(
		LongRect &outRect) const
{
	::WEGetDestRect(&outRect,*this);
}

inline void
AWASTE::GetViewRect(
		LongRect &outRect) const
{
	::WEGetViewRect(&outRect,*this);
}

inline void
AWASTE::SetDestRect(
		const LongRect &inRect)
{
	::WESetDestRect(&inRect,*this);
}

inline void
AWASTE::SetViewRect(
		const LongRect &inRect)
{
	::WESetViewRect(&inRect,*this);
}

// activation
inline bool
AWASTE::IsActive() const
{
	return ::WEIsActive(*this);
}

inline void
AWASTE::Activate()
{
	::WEActivate(*this);
}

inline void
AWASTE::Deactivate()
{
	::WEDeactivate(*this);
}

#if _WASTE21_
// tabs
inline Fixed
AWASTE::DefaultTabWidth() const
{
	return ::WEGetDefaultTabWidth(*this);
}

inline void
AWASTE::SetDefaultTabWidth(
		Fixed inWidth)
{
	::WESetDefaultTabWidth(inWidth,*this);
}
#endif

// styles
inline void
AWASTE::GetAttributes(
		SInt32 inOffset,
		ItemCount inAttributeCount,
		const WESelector inSelectors[],
		void * const outAttrValues[],
		const ByteCount inAttrSizes[]) const
{
	CThrownOSErr err = ::WEGetAttributes(inOffset,inAttributeCount,inSelectors,outAttrValues,inAttrSizes,*this);
}

inline void
AWASTE::GetOneAttribute(
		SInt32 inOffset,
		WESelector inSelector,
		void *outValue,
		ByteCount inValueSize)
{
	CThrownOSErr err = ::WEGetOneAttribute(inOffset,inSelector,outValue,inValueSize,*this);
}

inline void
AWASTE::SetAttributes(
		SInt32 inStart,
		SInt32 inEnd,
		ItemCount inAttributeCount,
		const WESelector inSelectors[],
		const void * const inAttrValues[],
		const ByteCount inAttrSizes[]) const
{
	CThrownOSErr err = ::WESetAttributes(inStart,inEnd,inAttributeCount,inSelectors,inAttrValues,inAttrSizes,*this);
}

inline void
AWASTE::SetOneAttribute(
		SInt32 inStart,
		SInt32 inEnd,
		WESelector inSelector,
		const void *inValue,
		ByteCount inSize) const
{
	CThrownOSErr err = ::WESetOneAttribute(inStart,inEnd,inSelector,inValue,inSize,*this);
}


// layout
inline SInt32
AWASTE::CountLines() const
{
	return ::WECountLines(*this);
}

inline SInt32
AWASTE::OffsetToLine(
		SInt32 inOffset) const
{
	return ::WEOffsetToLine(inOffset,*this);
}

inline void
AWASTE::GetLineRange(
		SInt32 inLineIndex,
		SInt32 &outStart,
		SInt32 &outEnd)
{
	::WEGetLineRange(inLineIndex,&outStart,&outEnd,*this);
}

inline SInt32
AWASTE::LineHeight(
		SInt32 inStart,
		SInt32 inEnd)
{
	return ::WEGetHeight(inStart,inEnd,*this);
}

#if _WASTE21_
inline SInt16
AWASTE::LineAscent(
		SInt32 inLineIndex)
{
	return ::WEGetLineAscent(inLineIndex,*this);
}

inline SInt32
AWASTE::MaxLineWidth()
{
	return ::WEGetMaxLineWidth(*this);
}
#endif

// offset <-> screen
inline void
AWASTE::OffsetFromPoint(
		const LongPt &inPoint,
		WEEdge &outEdge)
{
	::WEGetOffset(&inPoint,&outEdge,*this);
}

inline void
AWASTE::PointFromOffset(
		SInt32 inOffset,
		SInt16 inDirection,
		LongPt &outPoint,
		SInt16 &outLineHeight)
{
	::WEGetPoint(inOffset,inDirection,&outPoint,&outLineHeight,*this);
}


// find
inline void
AWASTE::Find(
		const char *inKey,
		SInt32 inLength,
		TextEncoding inEncoding,
		OptionBits inOptions,
		SInt32 inStart,
		SInt32 inEnd,
		SInt32 &outMatchStart,
		SInt32 &outMatchEnd)
{
	::WEFind(inKey,inLength,inEncoding,inOptions,inStart,inEnd,&outMatchStart,&outMatchEnd,*this);
}

// drawing
inline void
AWASTE::CalText()
{
	::WECalText(*this);
}

inline void
AWASTE::Update(
		RgnHandle inRegion)
{
	::WEUpdate(inRegion,*this);
}

inline void
AWASTE::Scroll(
		SInt32 inH,
		SInt32 inV)
{
	::WEScroll(inH,inV,*this);
}

inline void
AWASTE::PinScroll(
		SInt32 inH,
		SInt32 inV)
{
	::WEPinScroll(inH,inV,*this);
}

inline void
AWASTE::ScrollToSelection()
{
	::WESelView(*this);
}

// events
inline void
AWASTE::Key(
		CharParameter inKey,
		EventModifiers inModifiers)
{
	::WEKey(inKey,inModifiers,*this);
}

inline void
AWASTE::Click(
		Point inPoint,
		EventModifiers inModifiers,
		UInt32 inClickTime)
{
	::WEClick(inPoint,inModifiers,inClickTime,*this);
}

inline UInt16
AWASTE::ClickCount() const
{
	return ::WEGetClickCount(*this);
}

#if _WASTE21_
inline OSStatus
AWASTE::ProcessHICommand(
		const HICommand &inCommand)
{
	return ::WEProcessHICommand(&inCommand,*this);
}
#endif

inline bool
AWASTE::AdjustCursor(
		Point inPoint,
		RgnHandle ioRegion)
{
	return ::WEAdjustCursor(inPoint,ioRegion,*this);
}

inline void
AWASTE::Idle(
		UInt32 &outMaxSleep)
{
	::WEIdle(&outMaxSleep,*this);
}

// modifying text
inline void
AWASTE::Put(
		SInt32 inStart,
		SInt32 inEnd,
		const void *inText,
		SInt32 inLength,
		TextEncoding inEncoding,
		OptionBits inOptions,
		ItemCount inFlavorCount,
		const FlavorType *inFlavorTypes,
		const Handle *inFlavors)
{
	CThrownOSErr err = ::WEPut(
			inStart,inEnd,
			inText,inLength,
			inEncoding,inOptions,
			inFlavorCount,inFlavorTypes,inFlavors,
			*this);
}

inline void
AWASTE::Delete()
{
	::WEDelete(*this);
}

inline void
AWASTE::UseText(
		Handle inText)
{
	::WEUseText(inText,*this);
}

inline void
AWASTE::ChangeCase(
		SInt16 inCase)
{
	::WEChangeCase(inCase,*this);
}

// clipboard
inline void
AWASTE::Cut()
{
	::WECut(*this);
}

inline void
AWASTE::Copy() const
{
	::WECopy(*this);
}

inline void
AWASTE::Paste()
{
	::WEPaste(*this);
}

#if _WASTE21_
inline void
AWASTE::CopyToScrap(
		OptionBits inOptions,
		ScrapRef inScrap,
		const ScrapFlavorType *inFlavors) const
{
	CThrownOSStatus err = ::WECopyToScrap(inScrap,inFlavors,inOptions,*this);
}

inline void
AWASTE::PasteFromScrap(
		ScrapRef inScrap,
		OptionBits inOptions)
{
	::WEPasteFromScrap(inScrap,inOptions,*this);
}
#endif

inline bool
AWASTE::CanPaste()
{
	return ::WECanPaste(*this);
}

// dragging
inline RgnHandle
AWASTE::HiliteRegion(
		SInt32 inStart,
		SInt32 inEnd)
{
	return ::WEGetHiliteRgn(inStart,inEnd,*this);
}

inline OSErr
AWASTE::TrackDrag(
		DragTrackingMessage inMessage,
		DragRef inDragRef)
{
	return ::WETrackDrag(inMessage,inDragRef,*this);
}

inline OSErr
AWASTE::ReceiveDrag(
		DragRef inDragRef)
{
	return ::WEReceiveDrag(inDragRef,*this);
}

inline bool
AWASTE::CanAcceptDrag(
		DragRef inDragRef)
{
	return ::WECanAcceptDrag(inDragRef,*this);
}

#if _WASTE21_
// filing
inline void
AWASTE::Save(
		SInt32 inStart,
		SInt32 inEnd,
		const FSRef &inRef,
		OSType inFileType,
		TextEncoding inEncoding,
		OptionBits inOptions)
{
	CThrownOSStatus err = ::WESave(inStart,inEnd,&inRef,inFileType,inEncoding,inOptions,*this);
}

inline void
AWASTE::Load(			
		SInt32 inStart,
		SInt32 inEnd,
		const FSRef &inRef,
		OSType &ioFileType,
		TextEncoding &ioEncoding,
		OptionBits &ioOptions)
{
	CThrownOSStatus err = ::WELoad(inStart,inEnd,&inRef,&ioFileType,&ioEncoding,&ioOptions,*this);
}
#endif

// features
inline SInt16
AWASTE::FeatureFlag(
		SInt16 inFeature,
		SInt16 inAction)
{
	return ::WEFeatureFlag(inFeature,inAction,*this);
}

inline void
AWASTE::GetInfo(
		WESelector inSelector,
		void *outInfo)
{
	CThrownOSErr err = ::WEGetInfo(inSelector,outInfo,*this);
}

inline void
AWASTE::SetInfo(
		WESelector inSelector,
		const void *inInfo)
{
	CThrownOSErr err = ::WESetInfo(inSelector,inInfo,*this);
}


// ---------------------------------------------------------------------------

inline void
XWrapper<WEReference>::DisposeSelf()
{
	::WEDispose(mObject);
}
