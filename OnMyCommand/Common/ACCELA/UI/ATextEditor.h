// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XWrapper.h"
#include "FW.h"

#include FW(Carbon,MacTextEditor.h)

class ATextEditor :
		public XWrapper<TXNObject>
{
public:
		ATextEditor(
				TXNObject inObject,
				bool inOwner = false)
		: XWrapper<TXNObject>(inObject,inOwner) {}
		ATextEditor(
				WindowRef inWindow,
				const Rect &inFrame,
				TXNFrameOptions inOptions = 0,
				TXNFrameType inFrameType = kTXNTextEditStyleFrameType,
				TXNFileType inFileType = kTXNTextensionFile,
				TXNPermanentTextEncodingType inEncoding = kTXNSystemDefaultEncoding);
	
	// frame
	void
		ResizeFrame(
				UInt32 inWidth,
				UInt32 inHeight);
	void
		SetFrameBounds(
				SInt32 inTop,
				SInt32 inLeft,
				SInt32 inRight,
				SInt32 inBottom);
	void
		SetFrameBounds(
				const Rect &inBounds);
	void
		GetViewRect(
				Rect &outViewRect) const;
	Rect
		ViewRect() const
		{
			Rect viewRect;
			GetViewRect(viewRect);
			return viewRect;
		}
	void
		SetViewRect(
				const Rect &inViewRect);
	void
		SetRectBounds(
				const Rect &inViewRect,
				const TXNLongRect &inDestRect,
				bool inUpdate = true);
	void
		SetDestRect(
				const TXNLongRect &inDestRect,
				bool inUpdate = true);
	void
		GetRectBounds(
				Rect &outViewRect,
				TXNLongRect &outDestRect,
				TXNLongRect &outTextRect) const;
	void
		GetDestRect(
				TXNLongRect &outDestRect) const;
	void
		GetTextRect(
				TXNLongRect &outDestRect) const;
	
	// events
	void
		KeyDown(
				const EventRecord &inEvent);
	void
		AdjustCursor(
				RgnHandle ioCursorRgn);
	void
		Click(
				const EventRecord &inEvent);
	void
		GrowWindow(
				const EventRecord &inEvent);
	void
		ZoomWindow(
				SInt16 inPart);
	UInt32
		SleepTicks();
	void
		Idle();
	
	// selection
	void
		SelectAll();
	void
		GetSelection(
				TXNOffset &outStart,
				TXNOffset &outEnd) const;
	void
		SetSelection(
				TXNOffset inStart,
				TXNOffset inEnd);
	void
		ShowSelection(
				bool inShowEnd);
	bool
		IsSelectionEmpty();
	
	// focus/activation
	void
		Focus(
				bool inBecomingFocused = true);
	void
		Activate(
				TXNScrollBarState inState = kScrollBarsSyncWithFocus);
	
	// drawing
	void
		Update();
	void
		Draw(
				GWorldPtr inDrawPort = NULL);
	void
		ForceUpdate();
	void
		SetBackground(
				const TXNBackground &inBackground);
	void
		EchoMode(
				UniChar inCharacter,
				TextEncoding inEncoding,
				bool inOn = true);
	
	// offsets
	TXNOffset
		PointToOffset(
				Point inPoint);
	Point
		OffsetToPoint(
				TXNOffset inOffset);
	
	// Edit menu
	bool
		CanUndo();
	bool
		CanUndo(
				TXNActionKey &outActionKey);
	void
		Undo();
	bool
		CanRedo();
	bool
		CanRedo(
				TXNActionKey &outActionKey);
	void
		Redo();
	void
		Cut();
	void
		Copy();
	void
		Paste();
	void
		Clear();
	
	// text styles
	void
		GetContinuousTypeAttributes(
				TXNContinuousFlags &outFlags,
				ItemCount inCount,
				TXNTypeAttributes ioTypeAttributes[]);
	void
		SetTypeAttributes(
				ItemCount inCount,
				const TXNTypeAttributes inAttributes[],
				TXNOffset inStart,
				TXNOffset inEnd);
	ItemCount
		CountRunsInRange(
				TXNOffset inStart,
				TXNOffset inEnd);
	void
		GetIndRunInfoFromRange(
				ItemCount inIndex,
				TXNOffset inStart,
				TXNOffset inEnd,
				TXNOffset &outRunStart,
				TXNOffset &outRunEnd,
				TXNDataType &outDataType,
				ItemCount inAttrCount,
				TXNTypeAttributes *ioTypeAttributes);
	
	// controls
	void
		SetControls(
				bool inClearAll,
				ItemCount inCount,
				const TXNControlTag inControlTags[],
				const TXNControlData inControlData[]);
	void
		GetControls(
				ItemCount inCount,
				const TXNControlTag inControlTags[],
				TXNControlData inControlData[]);
	
	// data
	ByteCount
		DataSize();
	void
		GetData(
				TXNOffset inStart,
				TXNOffset inEnd,
				Handle &outDataHandle);
	void
		GetData(
				TXNOffset inStart,
				TXNOffset inEnd,
				Handle &outDataHandle,
				TXNDataType inEncoding);
	void
		SetDataFromFile(
				SInt16 inRefNum,
				OSType inFileType,
				ByteCount inFileLength,
				TXNOffset inStart,
				TXNOffset inEnd);
	void
		SetData(
				TXNDataType inDataType,
				const void *inData,
				ByteCount inDataSize,
				TXNOffset inStart,
				TXNOffset inEnd);
	
	// lines
	ItemCount
		LineCount();
	void
		GetLineMetrics(
				UInt32 inLine,
				Fixed &outWidth,
				Fixed &outHeight);
	
	// saving
	ItemCount
		ChangeCount();
	void
		Save(
				TXNFileType inType,
				OSType inResourceType,
				TXNPermanentTextEncodingType inEncoding,
				const FSSpec &inSpec,
				SInt16 inDataRefNum,
				SInt16 inResRefNum);
	void
		Revert();
	
	// printing
	void
		PageSetup();
	void
		Print();
	
	// font defaults
	void
		SetFontDefaults(
				ItemCount inCount,
				TXNMacOSPreferredFontDescription inDefaults[]);
	void
		GetFontDefaults(
				ItemCount &ioCount,
				TXNMacOSPreferredFontDescription ioDefaults[]);
	
	// window
	void
		AttachToGWorld(
				GWorldPtr inGW);
	void
		AttachToWindow(
				WindowRef inWindow);
	bool
		IsAttachedToWindow();
	bool
		IsAttachedToWindow(
				WindowRef inWindow);
	
	// drags
	void
		DragTracker(
				DragTrackingMessage inMessage,
				WindowRef inWindow,
				DragReference inDrag,
				bool inDifferentObjectSameWindow);
	void
		DragReceiver(
				WindowRef inWindow,
				DragReference inDrag,
				bool inDifferentObjectSameWindow);
	
	// misc
	void
		Find(
				const TXNMatchTextRecord *inMatchTextDataPtr,
				TXNDataType inDataType,
				TXNMatchOptions inMatchOptions,
				TXNOffset inStartSearchOffset,
				TXNOffset inEndSearchOffset,
				TXNFindUPP inFindProc,
				SInt32 inRefCon,
				TXNOffset &outStartMatchOffset,
				TXNOffset &outEndMatchOffset);
	
protected:
	TXNFrameID mFrameID;
};

// ---------------------------------------------------------------------------

inline
ATextEditor::ATextEditor(
		WindowRef inWindow,
		const Rect &inFrame,
		TXNFrameOptions inOptions,
		TXNFrameType inFrameType,
		TXNFileType inFileType,
		TXNPermanentTextEncodingType inEncoding)
{
	CThrownOSStatus err = ::TXNNewObject(NULL,inWindow,&inFrame,inOptions,inFrameType,inFileType,inEncoding,&mObject,&mFrameID,this);
}

// ---------------------------------------------------------------------------
#pragma mark -

inline void
ATextEditor::ResizeFrame(
		UInt32 inWidth,
		UInt32 inHeight)
{
	::TXNResizeFrame(*this,inWidth,inHeight,mFrameID);
}

inline void
ATextEditor::SetFrameBounds(
		SInt32 inTop,
		SInt32 inLeft,
		SInt32 inRight,
		SInt32 inBottom)
{
	::TXNSetFrameBounds(*this,inTop,inLeft,inBottom,inRight,mFrameID);
}

inline void
ATextEditor::SetFrameBounds(
		const Rect &inBounds)
{
	::TXNSetFrameBounds(*this,inBounds.top,inBounds.left,inBounds.bottom,inBounds.right,mFrameID);
}

inline void
ATextEditor::GetViewRect(
		Rect &outViewRect) const
{
	::TXNGetViewRect(*this,&outViewRect);
}

inline void
ATextEditor::SetViewRect(
		const Rect &inViewRect)
{
	::TXNSetViewRect(*this,&inViewRect);
}

inline void
ATextEditor::SetRectBounds(
		const Rect &inViewRect,
		const TXNLongRect &inDestRect,
		bool inUpdate)
{
	::TXNSetRectBounds(*this,&inViewRect,&inDestRect,inUpdate);
}

inline void
ATextEditor::SetDestRect(
		const TXNLongRect &inDestRect,
		bool inUpdate)
{
	::TXNSetRectBounds(*this,NULL,&inDestRect,inUpdate);
}

inline void
ATextEditor::GetRectBounds(
		Rect &outViewRect,
		TXNLongRect &outDestRect,
		TXNLongRect &outTextRect) const
{
	CThrownOSStatus err = ::TXNGetRectBounds(*this,&outViewRect,&outDestRect,&outTextRect);
}

inline void
ATextEditor::GetDestRect(
		TXNLongRect &outDestRect) const
{
	CThrownOSStatus err = ::TXNGetRectBounds(*this,NULL,&outDestRect,NULL);
}

inline void
ATextEditor::GetTextRect(
		TXNLongRect &outDestRect) const
{
	CThrownOSStatus err = ::TXNGetRectBounds(*this,NULL,NULL,&outDestRect);
}

// ---------------------------------------------------------------------------
#pragma mark -

inline void
ATextEditor::KeyDown(
		const EventRecord &inEvent)
{
	::TXNKeyDown(*this,&inEvent);
}

inline void
ATextEditor::AdjustCursor(
		RgnHandle ioCursorRgn)
{
	::TXNAdjustCursor(*this,ioCursorRgn);
}

inline void
ATextEditor::Click(
		const EventRecord &inEvent)
{
	::TXNClick(*this,&inEvent);
}

inline void
ATextEditor::GrowWindow(
		const EventRecord &inEvent)
{
	::TXNGrowWindow(*this,&inEvent);
}

inline void
ATextEditor::ZoomWindow(
		SInt16 inPart)
{
	::TXNZoomWindow(*this,inPart);
}

inline UInt32
ATextEditor::SleepTicks()
{
	return ::TXNGetSleepTicks(*this);
}

inline void
ATextEditor::Idle()
{
	::TXNIdle(*this);
}

// ---------------------------------------------------------------------------
#pragma mark -

inline void
ATextEditor::SelectAll()
{
	::TXNSelectAll(*this);
}

inline void
ATextEditor::GetSelection(
		TXNOffset &outStart,
		TXNOffset &outEnd) const
{
	::TXNGetSelection(*this,&outStart,&outEnd);
}

inline void
ATextEditor::SetSelection(
		TXNOffset inStart,
		TXNOffset inEnd)
{
	::TXNSetSelection(*this,inStart,inEnd);
}

inline void
ATextEditor::ShowSelection(
		bool inShowEnd)
{
	::TXNShowSelection(*this,inShowEnd);
}

inline bool
ATextEditor::IsSelectionEmpty()
{
	return ::TXNIsSelectionEmpty(*this);
}

// ---------------------------------------------------------------------------
#pragma mark -

// focus/activation
inline void
ATextEditor::Focus(
		bool inBecomingFocused)
{
	::TXNFocus(*this,inBecomingFocused);
}

inline void
ATextEditor::Activate(
		TXNScrollBarState inState)
{
	CThrownOSStatus err = ::TXNActivate(*this,mFrameID,inState);
}

// ---------------------------------------------------------------------------
#pragma mark -

// drawing
inline void
ATextEditor::Update()
{
	::TXNUpdate(*this);
}

inline void
ATextEditor::Draw(
		GWorldPtr inDrawPort)
{
	::TXNDraw(*this,inDrawPort);
}

inline void
ATextEditor::ForceUpdate()
{
	::TXNForceUpdate(*this);
}

inline void
ATextEditor::SetBackground(
		const TXNBackground &inBackground)
{
	CThrownOSStatus err = ::TXNSetBackground(*this,&inBackground);
}

inline void
ATextEditor::EchoMode(
		UniChar inCharacter,
		TextEncoding inEncoding,
		bool inOn)
{
	CThrownOSStatus err = ::TXNEchoMode(*this,inCharacter,inEncoding,inOn);
}

// ---------------------------------------------------------------------------
#pragma mark -

// offsets
inline TXNOffset
ATextEditor::PointToOffset(
		Point inPoint)
{
	TXNOffset offset;
	CThrownOSStatus err = ::TXNPointToOffset(*this,inPoint,&offset);
	return offset;
}

inline Point
ATextEditor::OffsetToPoint(
		TXNOffset inOffset)
{
	Point p;
	CThrownOSStatus err = ::TXNOffsetToPoint(*this,inOffset,&p);
	return p;
}

// ---------------------------------------------------------------------------
#pragma mark -

// Edit menu
inline bool
ATextEditor::CanUndo()
{
	return ::TXNCanUndo(*this,NULL);
}

inline bool
ATextEditor::CanUndo(
		TXNActionKey &outActionKey)
{
	return ::TXNCanUndo(*this,&outActionKey);
}

inline void
ATextEditor::Undo()
{
	::TXNUndo(*this);
}

inline bool
ATextEditor::CanRedo()
{
	return ::TXNCanRedo(*this,NULL);
}

inline bool
ATextEditor::CanRedo(
		TXNActionKey &outActionKey)
{
	return ::TXNCanRedo(*this,&outActionKey);
}

inline void
ATextEditor::Redo()
{
	::TXNRedo(*this);
}

inline void
ATextEditor::Cut()
{
	::TXNCut(*this);
}

inline void
ATextEditor::Copy()
{
	::TXNCopy(*this);
}

inline void
ATextEditor::Paste()
{
	::TXNPaste(*this);
}

inline void
ATextEditor::Clear()
{
	::TXNClear(*this);
}

// ---------------------------------------------------------------------------
#pragma mark -

// text styles
inline void
ATextEditor::GetContinuousTypeAttributes(
		TXNContinuousFlags &outFlags,
		ItemCount inCount,
		TXNTypeAttributes ioTypeAttributes[])
{
	CThrownOSStatus err = ::TXNGetContinuousTypeAttributes(*this,&outFlags,inCount,ioTypeAttributes);
}

inline void
ATextEditor::SetTypeAttributes(
		ItemCount inCount,
		const TXNTypeAttributes inAttributes[],
		TXNOffset inStart,
		TXNOffset inEnd)
{
	CThrownOSStatus err = ::TXNSetTypeAttributes(*this,inCount,inAttributes,inStart,inEnd);
}

inline ItemCount
ATextEditor::CountRunsInRange(
		TXNOffset inStart,
		TXNOffset inEnd)
{
	ItemCount runs;
	CThrownOSStatus err = ::TXNCountRunsInRange(*this,inStart,inEnd,&runs);
	return runs;
}

inline void
ATextEditor::GetIndRunInfoFromRange(
		ItemCount inIndex,
		TXNOffset inStart,
		TXNOffset inEnd,
		TXNOffset &outRunStart,
		TXNOffset &outRunEnd,
		TXNDataType &outDataType,
		ItemCount inAttrCount,
		TXNTypeAttributes *ioTypeAttributes)
{
	CThrownOSStatus err = ::TXNGetIndexedRunInfoFromRange(*this,inIndex,inStart,inEnd,&outRunStart,&outRunEnd,&outDataType,inAttrCount,ioTypeAttributes);
}

// ---------------------------------------------------------------------------
#pragma mark -

// controls
inline void
ATextEditor::SetControls(
		bool inClearAll,
		ItemCount inCount,
		const TXNControlTag inControlTags[],
		const TXNControlData inControlData[])
{
	CThrownOSStatus err = ::TXNSetTXNObjectControls(*this,inClearAll,inCount,inControlTags,inControlData);
}

inline void
ATextEditor::GetControls(
		ItemCount inCount,
		const TXNControlTag inControlTags[],
		TXNControlData inControlData[])
{
	CThrownOSStatus err = ::TXNGetTXNObjectControls(*this,inCount,inControlTags,inControlData);
}

#pragma mark -

// data
inline ByteCount
ATextEditor::DataSize()
{
	return ::TXNDataSize(*this);
}

inline void
ATextEditor::GetData(
		TXNOffset inStart,
		TXNOffset inEnd,
		Handle &outDataHandle)
{
	CThrownOSStatus err = ::TXNGetData(*this,inStart,inEnd,&outDataHandle);
}

inline void
ATextEditor::GetData(
		TXNOffset inStart,
		TXNOffset inEnd,
		Handle &outDataHandle,
		TXNDataType inEncoding)
{
	CThrownOSStatus err = ::TXNGetDataEncoded(*this,inStart,inEnd,&outDataHandle,inEncoding);
}

inline void
ATextEditor::SetDataFromFile(
		SInt16 inRefNum,
		OSType inFileType,
		ByteCount inFileLength,
		TXNOffset inStart,
		TXNOffset inEnd)
{
	CThrownOSStatus err = ::TXNSetDataFromFile(*this,inRefNum,inFileType,inFileLength,inStart,inEnd);
}

inline void
ATextEditor::SetData(
		TXNDataType inDataType,
		const void *inData,
		ByteCount inDataSize,
		TXNOffset inStart,
		TXNOffset inEnd)
{
	CThrownOSStatus err = ::TXNSetData(*this,inDataType,inData,inDataSize,inStart,inEnd);
}

// ---------------------------------------------------------------------------
#pragma mark -

// lines
inline ItemCount
ATextEditor::LineCount()
{
	ItemCount lineCount;
	CThrownOSStatus err = ::TXNGetLineCount(*this,&lineCount);
	return lineCount;
}

inline void
ATextEditor::GetLineMetrics(
		UInt32 inLine,
		Fixed &outWidth,
		Fixed &outHeight)
{
	CThrownOSStatus err = ::TXNGetLineMetrics(*this,inLine,&outWidth,&outHeight);
}

// ---------------------------------------------------------------------------
#pragma mark -

// saving
inline ItemCount
ATextEditor::ChangeCount()
{
	return ::TXNGetChangeCount(*this);
}

inline void
ATextEditor::Save(
		TXNFileType inType,
		OSType inResourceType,
		TXNPermanentTextEncodingType inEncoding,
		const FSSpec &inSpec,
		SInt16 inDataRefNum,
		SInt16 inResRefNum)
{
	CThrownOSStatus err = ::TXNSave(*this,inType,inResourceType,inEncoding,&inSpec,inDataRefNum,inResRefNum);
}

inline void
ATextEditor::Revert()
{
	CThrownOSStatus err = ::TXNRevert(*this);
}

// ---------------------------------------------------------------------------
#pragma mark -

// printing
inline void
ATextEditor::PageSetup()
{
	CThrownOSStatus err = ::TXNPageSetup(*this);
}

inline void
ATextEditor::Print()
{
	CThrownOSStatus err = ::TXNPrint(*this);
}

// ---------------------------------------------------------------------------
#pragma mark -

// font defaults
inline void
ATextEditor::SetFontDefaults(
		ItemCount inCount,
		TXNMacOSPreferredFontDescription inDefaults[])
{
	CThrownOSStatus err = ::TXNSetFontDefaults(*this,inCount,inDefaults);
}

inline void
ATextEditor::GetFontDefaults(
		ItemCount &ioCount,
		TXNMacOSPreferredFontDescription ioDefaults[])
{
	CThrownOSStatus err = ::TXNGetFontDefaults(*this,&ioCount,ioDefaults);
}

// ---------------------------------------------------------------------------
#pragma mark -

// window
inline void
ATextEditor::AttachToGWorld(
		GWorldPtr inGW)
{
	CThrownOSStatus err = ::TXNAttachObjectToWindow(*this,inGW,true);
}

inline void
ATextEditor::AttachToWindow(
		WindowRef inWindow)
{
	CThrownOSStatus err = ::TXNAttachObjectToWindow(*this,::GetWindowPort(inWindow),true);
}

inline bool
ATextEditor::IsAttachedToWindow()
{
	return ::TXNIsObjectAttachedToWindow(*this);
}

inline bool
ATextEditor::IsAttachedToWindow(
		WindowRef inWindow)
{
	Boolean attached;
	CThrownOSStatus err = ::TXNIsObjectAttachedToSpecificWindow(*this,inWindow,&attached);
	return attached;
}

// ---------------------------------------------------------------------------
#pragma mark -

// drags
inline void
ATextEditor::DragTracker(
		DragTrackingMessage inMessage,
		WindowRef inWindow,
		DragReference inDrag,
		bool inDifferentObjectSameWindow)
{
	// frame iD?
	CThrownOSStatus err = ::TXNDragTracker(*this,0,inMessage,inWindow,inDrag,inDifferentObjectSameWindow);
}

inline void
ATextEditor::DragReceiver(
		WindowRef inWindow,
		DragReference inDrag,
		bool inDifferentObjectSameWindow)
{
	// frame iD?
	CThrownOSStatus err = ::TXNDragReceiver(*this,0,inWindow,inDrag,inDifferentObjectSameWindow);
}


// misc
inline void
ATextEditor::Find(
		const TXNMatchTextRecord *inMatchTextDataPtr,
		TXNDataType inDataType,
		TXNMatchOptions inMatchOptions,
		TXNOffset inStartSearchOffset,
		TXNOffset inEndSearchOffset,
		TXNFindUPP inFindProc,
		SInt32 inRefCon,
		TXNOffset &outStartMatchOffset,
		TXNOffset &outEndMatchOffset)
{
	CThrownOSStatus err = ::TXNFind(
			*this,
			inMatchTextDataPtr,inDataType,
			inMatchOptions,
			inStartSearchOffset,inEndSearchOffset,
			inFindProc,inRefCon,
			&outStartMatchOffset,&outEndMatchOffset);
}

// ---------------------------------------------------------------------------
#pragma mark -

inline void
XWrapper<TXNObject>::DisposeSelf()
{
	::TXNDeleteObject(mObject);
}
