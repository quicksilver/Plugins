#pragma once

#include "AEventObject.h"
#include "XPropertyHolder.h"
#include "XWrapper.h"

#include "CThrownResult.h"

#include <stdexcept>

// ---------------------------------------------------------------------------

class AControl :
		public XPropertyHolder,
		public XWrapper<ControlRef>
{
public:
		// ControlRef
		AControl(
				ControlRef inControlRef,
				bool inOwner = false)
		: XWrapper<ControlRef>(inControlRef,inOwner) {}
		// make a control
		AControl(
				WindowRef inOwningWindow,
				const Rect &inBoundsRect,
				ConstStr255Param inControlTitle,
				Boolean inInitiallyVisible,
				SInt16 inInitialValue,
				SInt16 inMinimumValue,
				SInt16 inMaximumValue,
				SInt16 inProcID,
				SInt32 inControlReference)
		: XWrapper<ControlRef>(
				::NewControl(
						inOwningWindow,&inBoundsRect,inControlTitle,inInitiallyVisible,
						inInitialValue,inMinimumValue,inMaximumValue,
						inProcID,inControlReference),
				true) {}
		// ControlDefSpec
		AControl(
				WindowRef inOwningWindow,
				const Rect &inBounds,
				const ControlDefSpec &inDef,
				Collection inData = NULL);
		// CTRL id
		AControl(
				WindowRef inOwningWindow,
				SInt16 inResID)
		: XWrapper<ControlRef>(::GetNewControl(inResID,inOwningWindow),true) {}
		// find by ID
		AControl(
				WindowRef inOwningWindow,
				const ControlID &inID,
				bool inOwner = false);
		// root control
		AControl(
				WindowRef inWindow);
	
	// XPropertyHolder
	
	void
		SetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				const void *inBuffer);
	void
		GetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				void *inBuffer) const;
	void
		GetPropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 &outAttributes) const;
	void
		ChangePropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 inSet,
				UInt32 inClear);
	UInt32
		GetPropertySize(
				OSType inCreator,
				OSType inTag) const;
	bool
		HasProperty(
				OSType inCreator,
				OSType inTag) const;
	void
		RemoveProperty(
				OSType inCreator,
				OSType inTag);
	
	// AControl
	
	void
		Hilite(
				ControlPartCode inHiliteState);
	
	// values
	void
		SetValue(
				SInt16 inValue);
	SInt16
		Value() const;
	void
		Set32BitValue(
				SInt32 inValue);
	SInt32
		Value32Bit() const;
	void
		SetMaxValue(
				SInt16 inValue);
	SInt16
		MaxValue() const;
	void
		Set32BitMaxValue(
				SInt32 inValue);
	SInt32
		MaxValue32Bit() const;
	void
		SetMinValue(
				SInt16 inValue);
	SInt16
		MinValue() const;
	void
		Set32BitMinValue(
				SInt32 inValue);
	SInt32
		MinValue32Bit() const;
	
	void
		GetTitle(
				Str255 outTitle) const;
	void
		SetTitle(
				ConstStr255Param inTitle);
	CFStringRef
		CopyCFTitle() const;
	void
		SetCFTitle(
				CFStringRef inString);
	
	ControlID
		GetID() const;
	void
		SetID(
				const ControlID &inID);
	
	void
		SetData(
				ControlPartCode inPart,
				ResType inTagName,
				Size inSize,
				const void *inData);
	template <class T>
	void
		SetData(
				ControlPartCode inPart,
				ResType inTagName,
				const T &inDataObject)
		{ SetData(inPart,inTagName,sizeof(T),&inDataObject); }
	
	void
		GetData(
				ControlPartCode inPart,
				ResType inTagName,
				Size inBufferSize,
				void *outBuffer,
				Size &outActualSize) const;
	template <class T>
	void
		GetData(
				ControlPartCode inPart,
				ResType inTagName,
				T &outDataObject) const
		{
			Size actualSize;
			GetData(inPart,inTagName,sizeof(T),&outDataObject,actualSize);
			if (actualSize != sizeof(T)) throw std::invalid_argument("wrong size");
		}
	template <class T>
	T
		Data(
				ControlPartCode inPart,
				ResType inTagName) const
		{
			Size actualSize;
			T object;
			GetData(inPart,inTagName,sizeof(T),&object,actualSize);
			if (actualSize != sizeof(T)) throw std::invalid_argument("wrong size");
			return object;
		}
	Size
		GetDataSize(
				ControlPartCode inPart,
				ResType inTagName) const;
	
	// visibility
	void
		Show();
	void
		Hide();
	bool
		IsVisible() const;
	OSErr
		SetVisibility(
				bool inVisibility,
				bool inDoDraw = true);
	
	// activation
	OSErr
		Activate();
	OSErr
		Deactivate();
	bool
		IsActive() const;
	
	// enabling
	OSErr
		Enable();
	OSErr
		Disable();
	bool
		IsEnabled() const;
	
	// drawing
	void
		Draw() const;
	void
		DrawInCurrentPort() const;
	OSErr
		SetUpBackground(
				SInt16 inDepth = 32);
	OSErr
		SetUpTextColor(
				SInt16 inDepth = 32);
	
	OSErr
		SetFontStyle(
				const ControlFontStyleRec &inStyle);
	
	void
		GetBounds(
				Rect &outRect) const;
	Rect
		Bounds() const
		{
			Rect bounds;
			GetBounds(bounds);
			return bounds;
		}
	SInt32
		ViewSize();
	void
		SetViewSize(
				SInt32 inViewSize);
	
	// event handling
	ControlPartCode
		Track(
				Point inStartPoint);
	ControlPartCode
		Test(
				Point inTestPoint) const;
	ControlPartCode
		HandleClick(
				Point inWhere,
				EventModifiers inModifiers);
	OSStatus
		HandleContextualMenuClick(
				Point inWhere,
				bool &outMenuDisplayed);
	ControlPartCode
		HandleKey(
				SInt16 inKeyCode,
				SInt16 inCharCode,
				EventModifiers inModifiers);
	OSStatus
		HandleSetCursor(
				Point inLocalPoint,
				EventModifiers inModifiers,
				bool &outWasSet);
	ClickActivationResult
		GetClickActivation(
				Point inWhere,
				EventModifiers inModifiers) const;
	
	// drags
	bool
		HandleDragTracking(
				DragTrackingMessage inMessage,
				DragReference inDragRef);
	void
		HandleDragReceive(
				DragReference inDragRef);
	void
		SetDragTrackingEnabled(
				bool inTracks);
	bool
		IsDragTrackingEnabled() const;
	
	// size & position
	void
		Move(
				SInt16 inH,
				SInt16 inV);
	void
		SetSize(
				SInt16 inWidth,
				SInt16 inHeight);
	OSErr
		GetBestRect(
				Rect &outRect) const;
	OSErr
		GetBestRect(
				Rect &outRect,
				SInt16 &outBaseLineOffset) const;
	
	// commands
	void
		SetCommandID(
				UInt32 inCommandID);
	UInt32
		CommandID() const;
	
	ControlKind
		GetKind() const;
	
	// hierarchy
	WindowRef
		OwnerWindow() const;
	void
		Embed(
				ControlRef inContainer);
	void
		AutoEmbed(
				WindowRef inWindow);
	ControlRef
		GetSuperControl() const;
	UInt16
		CountSubControls() const;
	ControlRef
		GetIndSubControl(
				UInt16 inIndex) const;
	void
		SetSupervisor(
				ControlRef inBoss);
	
	using XWrapper<ControlRef>::operator=;
	
	class Iterator
	{
	public:
		friend class AControl;
		
			Iterator(
					const AControl &inContainerControl)
			: mIndex(1),mContainer(inContainerControl)
			{
				if (mContainer.CountSubControls() == 0)
					mIndex = 0;
			}
		
		AControl
			operator*()
			{
				return mContainer.GetIndSubControl(mIndex);
			}
		
		Iterator&
			operator++()	// prefix
			{
				mIndex++;
				if (mIndex > mContainer.CountSubControls())
					mIndex = 0;
				return *this;
			}
		AControl
			operator++(int)	// postfix
			{
				ControlRef control = mContainer.GetIndSubControl(mIndex);
				mIndex++;
				return control;
			}
		
		bool
			operator==(
					const Iterator &inIter) const
			{
				return
						(mContainer.Get() == inIter.mContainer.Get()) &&
						(mIndex == inIter.mIndex);
			}
		bool
			operator!=(
					const Iterator &inIter) const
			{
				return !operator==(inIter);
			}
		
	protected:
		UInt16 mIndex;
		const AControl &mContainer;
		
			Iterator(
					const AControl &inContainerControl,
					UInt16 inIndex)
			: mIndex(inIndex),mContainer(inContainerControl) {}
	};
	
	Iterator
		SubBegin()
		{
			return Iterator(*this);
		}
	Iterator
		SubEnd()
		{
			return Iterator(*this,0);
		}
};

// ---------------------------------------------------------------------------

class AControlID :
		public ControlID
{
public:
		AControlID(
				OSType inSignature = 0L,
				SInt32 inID = 0)
		{
			signature = inSignature;
			id = inID;
		}
};

// ---------------------------------------------------------------------------

inline
AControl::AControl(
		WindowRef inOwningWindow,
		const Rect &inBounds,
		const ControlDefSpec &inDef,
		Collection inData)
: XWrapper<ControlRef>(NULL)
{
	CThrownOSStatus err = ::CreateCustomControl(inOwningWindow,&inBounds,&inDef,inData,&mObject);
}

inline
AControl::AControl(
		WindowRef inWindow,
		const ControlID &inID,
		bool inOwner)
: XWrapper<ControlRef>(NULL)
{
	CThrownOSStatus err = ::GetControlByID(inWindow,&inID,&mObject);
	if (err == noErr)
		mOwner = inOwner;
	else
		throw err;
}

inline
AControl::AControl(
		WindowRef inWindow)
: XWrapper<ControlRef>(NULL,false)
{
	CThrownOSStatus err = ::GetRootControl(inWindow,&mObject);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::SetValue(
		SInt16 inValue)
{
	::SetControlValue(*this,inValue);
}

inline SInt16
AControl::Value() const
{
	return ::GetControlValue(*this);
}

inline void
AControl::Set32BitValue(
		SInt32 inValue)
{
	::SetControl32BitValue(*this,inValue);
}

inline SInt32
AControl::Value32Bit() const
{
	return ::GetControl32BitValue(*this);
}

inline void
AControl::SetMinValue(
		SInt16 inValue)
{
	::SetControlMinimum(*this,inValue);
}

inline SInt16
AControl::MinValue() const
{
	return ::GetControlMinimum(*this);
}

inline void
AControl::Set32BitMinValue(
		SInt32 inValue)
{
	::SetControl32BitMinimum(*this,inValue);
}

inline SInt32
AControl::MinValue32Bit() const
{
	return ::GetControl32BitMinimum(*this);
}

inline void
AControl::SetMaxValue(
		SInt16 inValue)
{
	::SetControlMaximum(*this,inValue);
}

inline SInt16
AControl::MaxValue() const
{
	return ::GetControlMaximum(*this);
}

inline void
AControl::Set32BitMaxValue(
		SInt32 inValue)
{
	::SetControl32BitMaximum(*this,inValue);
}

inline SInt32
AControl::MaxValue32Bit() const
{
	return ::GetControl32BitMaximum(*this);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::GetTitle(
		Str255 outTitle) const
{
	::GetControlTitle(*this,outTitle);
}

inline void
AControl::SetTitle(
		ConstStr255Param inTitle)
{
	::SetControlTitle(*this,inTitle);
}

inline CFStringRef
AControl::CopyCFTitle() const
{
	CFStringRef stringRef = NULL;
	CThrownOSStatus err = ::CopyControlTitleAsCFString(*this,&stringRef);
	return stringRef;
}

inline void
AControl::SetCFTitle(
		CFStringRef inString)
{
	CThrownOSStatus err = ::SetControlTitleWithCFString(*this,inString);
}

inline ControlID
AControl::GetID() const
{
	ControlID id;
	CThrownOSStatus err = ::GetControlID(*this,&id);
	return id;
}

inline void
AControl::SetID(
		const ControlID &inID)
{
	CThrownOSStatus err = ::SetControlID(*this,&inID);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::SetData(
		ControlPartCode inPart,
		ResType inTagName,
		Size inSize,
		const void *inData)
{
	CThrownOSErr err = ::SetControlData(*this,inPart,inTagName,inSize,const_cast<void*>(inData));
}

inline void
AControl::GetData(
		ControlPartCode inPart,
		ResType inTagName,
		Size inSize,
		void *outData,
		Size &outActualSize) const
{
	CThrownOSErr err = ::GetControlData(*this,inPart,inTagName,inSize,outData,&outActualSize);
}

inline Size
AControl::GetDataSize(
		ControlPartCode inPart,
		ResType inTagName) const
{
	Size dataSize = 0;
	CThrownOSErr err = ::GetControlDataSize(*this,inPart,inTagName,&dataSize);
	return dataSize;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::Hilite(
		ControlPartCode inHiliteState)
{
	::HiliteControl(mObject,inHiliteState);
}

inline void
AControl::Show()
{
	::ShowControl(mObject);
}

inline void
AControl::Hide()
{
	::HideControl(mObject);
}

inline OSErr
AControl::SetVisibility(
		bool inVisibility,
		bool inDoDraw)
{
	return ::SetControlVisibility(mObject,inVisibility,inDoDraw);
}

inline bool
AControl::IsVisible() const
{
	return ::IsControlVisible(mObject);
}

inline OSErr
AControl::Activate()
{
	return ::ActivateControl(mObject);
}

inline OSErr
AControl::Deactivate()
{
	return ::DeactivateControl(mObject);
}

inline bool
AControl::IsActive() const
{
	return ::IsControlActive(mObject);
}

inline OSErr
AControl::Enable()
{
	return ::EnableControl(mObject);
}

inline OSErr
AControl::Disable()
{
	return ::DisableControl(mObject);
}

inline bool
AControl::IsEnabled() const
{
	return ::IsControlEnabled(mObject);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::Draw() const
{
	::Draw1Control(*this);
}

inline void
AControl::DrawInCurrentPort() const
{
	::DrawControlInCurrentPort(*this);
}

inline OSErr
AControl::SetUpBackground(
		SInt16 inDepth)
{
	return ::SetUpControlBackground(*this,inDepth,true);
}

inline OSErr
AControl::SetUpTextColor(
		SInt16 inDepth)
{
	return ::SetUpControlTextColor(*this,inDepth,true);
}

inline OSErr
AControl::SetFontStyle(
		const ControlFontStyleRec &inStyle)
{
	return ::SetControlFontStyle(*this,&inStyle);
}

inline void
AControl::GetBounds(
		Rect &outBounds) const
{
	::GetControlBounds(*this,&outBounds);
}

inline SInt32
AControl::ViewSize()
{
	return ::GetControlViewSize(*this);
}

inline void
AControl::SetViewSize(
		SInt32 inViewSize)
{
	::SetControlViewSize(*this,inViewSize);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline ControlPartCode
AControl::Track(
		Point inStartPoint)
{
	return ::TrackControl(*this,inStartPoint,NULL);
}

inline ControlPartCode
AControl::Test(
		Point inTestPoint) const
{
	return ::TestControl(*this,inTestPoint);
}

inline OSStatus
AControl::HandleContextualMenuClick(
		Point inWhere,
		bool &outMenuDisplayed)
{
	Boolean displayed = false;
	OSStatus err = ::HandleControlContextualMenuClick(*this,inWhere,&displayed);
	outMenuDisplayed = displayed;
	return err;
}

inline ClickActivationResult
AControl::GetClickActivation(
		Point inWhere,
		EventModifiers inModifiers) const
{
	ClickActivationResult activation;
	CThrownOSStatus err = ::GetControlClickActivation(*this,inWhere,inModifiers,&activation);
	return activation;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline bool
AControl::HandleDragTracking(
		DragTrackingMessage inMessage,
		DragReference inDragRef)
{
	Boolean likesDrag = false;
	CThrownOSStatus err = ::HandleControlDragTracking(*this,inMessage,inDragRef,&likesDrag);
	return likesDrag;
}

inline void
AControl::HandleDragReceive(
		DragReference inDragRef)
{
	CThrownOSStatus err = ::HandleControlDragReceive(*this,inDragRef);
}

inline void
AControl::SetDragTrackingEnabled(
		bool inTracks)
{
	CThrownOSStatus err = ::SetControlDragTrackingEnabled(*this,inTracks);
}

inline bool
AControl::IsDragTrackingEnabled() const
{
	Boolean enabled;
	CThrownOSStatus err = ::IsControlDragTrackingEnabled(*this,&enabled);
	return enabled;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::Move(
		SInt16 inH,
		SInt16 inV)
{
	::MoveControl(*this,inH,inV);
}

inline void
AControl::SetSize(
		SInt16 inWidth,
		SInt16 inHeight)
{
	::SizeControl(*this,inWidth,inHeight);
}

inline OSErr
AControl::GetBestRect(
		Rect &outRect) const
{
	SInt16 baseline;
	return ::GetBestControlRect(*this,&outRect,&baseline);
}

inline OSErr
AControl::GetBestRect(
		Rect &outRect,
		SInt16 &outBaseLineOffset) const
{
	return ::GetBestControlRect(*this,&outRect,&outBaseLineOffset);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::SetCommandID(
		UInt32 inCommandID)
{
	CThrownOSStatus err = ::SetControlCommandID(*this,inCommandID);
}

inline UInt32
AControl::CommandID() const
{
	UInt32 command;
	CThrownOSStatus err = ::GetControlCommandID(*this,&command);
	return command;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline WindowRef
AControl::OwnerWindow() const
{
	return ::GetControlOwner(*this);
}

inline void
AControl::Embed(
		ControlRef inContainer)
{
	CThrownOSStatus err = ::EmbedControl(*this,inContainer);
}

inline void
AControl::AutoEmbed(
		WindowRef inWindow)
{
	CThrownOSStatus err = ::AutoEmbedControl(*this,inWindow);
}

inline ControlRef
AControl::GetSuperControl() const
{
	ControlRef superControl = NULL;
	CThrownOSStatus err = ::GetSuperControl(*this,&superControl);
	return superControl;
}

inline UInt16
AControl::CountSubControls() const
{
	UInt16 subCount = 0;
	OSStatus err = ::CountSubControls(*this,&subCount);
	if ((err != noErr) && (err != errControlIsNotEmbedder)) throw err;
	return subCount;
}

inline ControlRef
AControl::GetIndSubControl(
		UInt16 inIndex) const
{
	ControlRef subControl = NULL;
	OSStatus err = ::GetIndexedSubControl(*this,inIndex,&subControl);
	if ((err != noErr) && (err != errControlIsNotEmbedder)) throw err;
	return subControl;
}

inline void
AControl::SetSupervisor(
		ControlRef inBoss)
{
	CThrownOSStatus err = ::SetControlSupervisor(*this,inBoss);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
AControl::SetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				const void *inBuffer)
{
	CThrownOSStatus err = ::SetControlProperty(*this,inCreator,inTag,inSize,const_cast<void*>(inBuffer));
}

inline void
AControl::GetPropertyData(
				OSType inCreator,
				OSType inTag,
				UInt32 inSize,
				void *inBuffer) const
{
	UInt32 actualSize;
	CThrownOSStatus err = ::GetControlProperty(*this,inCreator,inTag,inSize,&actualSize,inBuffer);
}

inline bool
AControl::HasProperty(
				OSType inCreator,
				OSType inTag) const
{
	UInt32 atttributes;
	return ::GetControlPropertyAttributes(*this,inCreator,inTag,&atttributes) == noErr;
}

inline void
AControl::GetPropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 &outAttributes) const
{
	CThrownOSStatus err = ::GetControlPropertyAttributes(*this,inCreator,inTag,&outAttributes);
}

inline void
AControl::ChangePropertyAttributes(
				OSType inCreator,
				OSType inTag,
				UInt32 inSet,
				UInt32 inClear)
{
	CThrownOSStatus err = ::ChangeControlPropertyAttributes(*this,inCreator,inTag,inSet,inClear);
}

inline UInt32
AControl::GetPropertySize(
				OSType inCreator,
				OSType inTag) const
{
	UInt32 propertySize;
	CThrownOSStatus err = ::GetControlPropertySize(*this,inCreator,inTag,&propertySize);
	return propertySize;
}

inline void
AControl::RemoveProperty(
				OSType inCreator,
				OSType inTag)
{
	CThrownOSStatus err = ::RemoveControlProperty(*this,inCreator,inTag);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
XWrapper<ControlRef>::DisposeSelf()
{
	::DisposeControl(*this);
}
