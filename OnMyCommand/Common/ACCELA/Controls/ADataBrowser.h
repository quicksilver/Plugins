// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull
#pragma once

#include "AControl.h"

#include FW(Carbon,ControlDefinitions.h)

#pragma warn_unusedarg off

class ADataBrowser :
		public AControl
{
public:
		ADataBrowser(
				ControlRef inControl,
				bool inOwner = false)
		: AControl(inControl,inOwner)
		{
			InstallCallbacks();
		}
		ADataBrowser(
				WindowRef inOwnerWindow,
				const ControlID &inID,
				bool inOwner = false)
		: AControl(inOwnerWindow,inID,inOwner)
		{
			InstallCallbacks();
		}
		ADataBrowser(
				WindowRef inOwnerWindow,
				const Rect &inBounds,
				DataBrowserViewStyle inStyle);
	virtual
		~ADataBrowser();
	
	// Item
	class Item
	{
	public:
			Item()
			: mBrowser(NULL),mID(0) {}
			Item(
					ControlRef inBrowser,
					DataBrowserItemID inID)
			: mBrowser(inBrowser),mID(inID) {}
		
			operator DataBrowserItemID() const
			{
				return mID;
			}
		
		void
			AddItems(
					UInt32 numItems,
					const DataBrowserItemID *items,
					DataBrowserPropertyID inPreSortProperty = kDataBrowserItemNoProperty);
		void
			AddItem(
					DataBrowserItemID inID)
			{
				AddItems(1,&inID);
			}
		void
			RemoveItems(
					UInt32 numItems,
					const DataBrowserItemID *items,
					DataBrowserPropertyID inPreSortProperty = kDataBrowserItemNoProperty);
		void
			RemoveItem(
					DataBrowserItemID inID)
			{
				RemoveItems(1,&inID);
			}
		void
			UpdateItems(
					UInt32 numItems,
					const DataBrowserItemID *items,
					DataBrowserPropertyID inPreSortProperty,
					DataBrowserPropertyID inPropertyID);
		void
			UpdateItem(
					DataBrowserItemID inID,
					DataBrowserPropertyID inPropertyID)
			{
				UpdateItems(1,&inID,kDataBrowserItemNoProperty,inPropertyID);
			}
		
		UInt32
			ItemCount(
					DataBrowserItemState inState = kDataBrowserItemAnyState,
					bool inRecurse = true) const;
		OSStatus
			GetItemIDs(
					Handle inItemHandle,
					DataBrowserItemState inState = kDataBrowserItemAnyState,
					bool inRecurse = true) const;
		
		bool
			IsSelected() const;
		DataBrowserItemState
			State() const;
		DataBrowserTableViewRowIndex
			Row() const;
		
		// container
		void
			Open();
		void
			Close();
		void
			Sort(
				bool inSortChildren);
		void
			Reveal(
					DataBrowserPropertyID inPropertyID,
					DataBrowserRevealOptions inOptions = kDataBrowserRevealOnly);
		
		// geometry
		void
			SetRowHeight(
					UInt16 inHeight);
		UInt16
			RowHeight() const;
		Rect
			PartBounds(
					DataBrowserPropertyID inProperty,
					DataBrowserPropertyPart inPart = kDataBrowserPropertyEnclosingPart) const;
		
		
	protected:
		const ControlRef mBrowser;
		const DataBrowserItemID mID;
	};
	
	// ItemData
	class ItemData
	{
	public:
			ItemData(
					DataBrowserItemDataRef inDataRef)
			: mDataRef(inDataRef) {}
		
			operator DataBrowserItemDataRef() const
			{
				return mDataRef;
			}
		
		bool
			IsValid() const
			{
				return mDataRef != NULL;
			}
		
		void
			SetIcon(
					IconRef inIcon);
		IconRef
			Icon() const;
		void
			SetText(
					CFStringRef inText);
		CFStringRef
			Text() const;
		void
			SetValue(
					SInt32 inValue);
		SInt32
			Value() const;
		void
			SetMinimum(
					SInt32 inValue);
		SInt32
			Minimum() const;
		void
			SetMaximum(
					SInt32 inValue);
		SInt32
			Maximum() const;
		void
			SetBoolValue(
					bool inValue);
		bool
			BoolValue() const;
		void
			SetMenu(
					MenuRef inMenu);
		MenuRef
			Menu() const;
		void
			SetRGBColor(
					const RGBColor &inColor);
		RGBColor
			Color() const;
		void
			SetDrawState(
					ThemeDrawState inState);
		ThemeDrawState
			DrawState() const;
		void
			SetButtonValue(
					ThemeButtonValue inState);
		ThemeButtonValue
			ButtonValue() const;
		void
			SetIconTransform(
					IconTransformType inState);
		IconTransformType
			IconTransform() const;
		void
			SetDateTime(
					long inDateTime);
		long
			DateTime() const;
		void
			SetLongDateTime(
					LongDateTime inDateTime);
		LongDateTime
			LDateTime() const;
		
		// item/property ID
		void
			SetItemID(
					DataBrowserItemID inID);
		DataBrowserItemID
			ItemID() const;
		DataBrowserPropertyID
			PropertyID() const;
		
	protected:
		DataBrowserItemDataRef mDataRef;
	};
	
	class Column
	{
	public:
			Column()
			: mBrowser(NULL),mID(0) {}
			Column(
				ControlRef inBrowser,
				DataBrowserTableViewColumnID inID)
			: mBrowser(inBrowser),mID(inID) {}
		
		void
			Remove();
		
		void
			SetWidth(
					UInt16 inWidth);
		UInt16
			Width() const;
		
		void
			SetPosition(
					DataBrowserTableViewColumnIndex inPosition);
		DataBrowserTableViewColumnIndex
			Position() const;
		
	protected:
		const ControlRef mBrowser;
		DataBrowserTableViewColumnID mID;
	};
	
	// view style
	DataBrowserViewStyle
		ViewStyle() const;
	void
		SetViewStyle(
				DataBrowserViewStyle inStyle);
	
	void
		EnableEditCommand(
				DataBrowserEditCommand inCommand);
	
	// items
	Item
		Root() const;
	Item
		ItemFromRow(
				DataBrowserTableViewRowIndex inRow) const;
	
	// selection
	void
		GetSelectionAnchor(
				Item &outFirst,
				Item &outLast) const;
	void
		MoveSelectionAnchor(
				DataBrowserSelectionAnchorDirection inDirection,
				bool inExtend);
	void
		SetSelectedItems(
				UInt32 inNumItems,
				const DataBrowserItemID *inItems,
				DataBrowserSetOption inOperation = kDataBrowserItemsAssign);
	void
		SetSelectionFlags(
				DataBrowserSelectionFlags inFlags);
	DataBrowserSelectionFlags
		SelectionFlags() const;
	
	// properties
	void
		SetPropertyFlags(
				DataBrowserPropertyID inProperty,
				DataBrowserPropertyFlags inFlags);
	DataBrowserPropertyFlags
		PropertyFlags(
				DataBrowserPropertyID inProperty) const;
	
	// user state
	void
		SetUserState(
				CFDataRef inStateInfo);
	CFDataRef
		UserState() const;
	
	// editing
	void
		SetEditText(
				CFStringRef inText);
	CFStringRef
		CopyEditText() const;
	void
		GetEditText(
				CFMutableStringRef outString) const;
	void
		SetEditItem(
				const Item &inItem,
				DataBrowserPropertyID inProperty);
	void
		GetEditItem(
				Item &outItem,
				DataBrowserPropertyID &outID);
	
	// activation
	void
		SetActiveItems(
				bool inActive);
	bool
		ItemsAreActive() const;
	
	// scrolling
	void
		SetScrollBarInset(
				const Rect &inInset);
	Rect
		ScrollBarInset() const;
	void
		SetScrollPosition(
				UInt32 inTop,
				UInt32 inLeft);
	void
		GetScrollPosition(
				UInt32 &outTop,
				UInt32 &outLeft) const;
	void
		SetHasScrollBars(
				bool inHasHoriz,
				bool inHasVert);
	void
		GetHasScrollBars(
				bool &outHasHoriz,
				bool &outHasVert);
	
	// sorting
	void
		SetSortOrder(
				DataBrowserSortOrder inOrder);
	void
		SortOrder() const;
	void
		SetSortProperty(
				DataBrowserPropertyID inProperty);
	DataBrowserPropertyID
		SortProperty() const;
	
	// table view
	void
		SetGeometry(
				bool inVariableColumns,
				bool inVariableRows);
	void
		GetGeometry(
				bool &outVariableColumns,
				bool &outVariableRows);
	
	void
		RemoveColumn(
				DataBrowserTableViewColumnID inColumnID);
	UInt32
		ColumnCount() const;
	
	void
		SetHiliteStyle(
				DataBrowserTableViewHiliteStyle inStyle);
	DataBrowserTableViewHiliteStyle
		HiliteStyle() const;
	
	void
		SetRowHeight(
				UInt16 inHeight);
	UInt16
		RowHeight() const;
	
	void
		SetColumnWidth(
				UInt16 inWidth);
	UInt16
		ColumnWidth() const;
	
	// list view
	void
		AutoSizeColumns();
	void
		AddColumn(
				const DataBrowserListViewColumnDesc &inColumnDesc,
				DataBrowserTableViewColumnIndex inPosition);
	
	void
		SetHeaderButtonHeight(
				UInt16 inHeight);
	UInt16
		HeaderButtonHeight() const;
	void
		SetUsePlainBackground(
				bool inPlain);
	bool
		UsesPlainBackground() const;
	
	void
		SetDisclosureColumn(
				DataBrowserTableViewColumnID inColumn,
				bool inExpandableRows = true);
	DataBrowserTableViewColumnID
		DisclosureColumn() const;
	void
		GetDisclosureColumn(
				DataBrowserTableViewColumnID &outColumn,
				bool &outExpandableRows);
	
	// column view
	void
		GetPath(
				Handle ioPath) const;
	UInt32
		PathLength() const;
	void
		SetPath(
				UInt32 inLength,
				DataBrowserItemID inPath);	// API takes a const pointer??
	
	void
		SetDisplayType(
				DataBrowserPropertyType inType);
	DataBrowserPropertyType
		DisplayType() const;
	
protected:
	void
		InstallCallbacks();
	
	static pascal void
		ItemProc(
				DataBrowserItemID inItem,
				DataBrowserItemState inState,
				void *inClientData);
	
	static ADataBrowser*
		GetBrowserObject(
				const AControl &inControl);
	
	// item callbacks
	static pascal void
		ItemNotificationWithItemCallback(
				ControlRef inBrowser,
				DataBrowserItemID inItem,
				DataBrowserItemNotification inMessage,
				DataBrowserItemDataRef inItemData);
	static pascal OSStatus
		ItemDataCallback(
				ControlRef inBrowser,
				DataBrowserItemID inItem,
				DataBrowserPropertyID inProperty,
				DataBrowserItemDataRef inItemData,
				Boolean inSetValue);
	static pascal Boolean
		ItemCompareCallback(
				ControlRef inBrowser,
				DataBrowserItemID inItemOneID, 
				DataBrowserItemID inItemTwoID,
				DataBrowserPropertyID inSortProperty);
	
	virtual void
		ItemNotification(
				Item &inItem,
				DataBrowserItemNotification inMessage,
				ItemData &inItemData) {}
	virtual OSStatus
		GetItemData(
				Item &inItem,
				DataBrowserPropertyID inProperty,
				ItemData &inItemData)
		{
			return noErr;
		}
	virtual OSStatus
		SetItemData(
				Item &inItem,
				DataBrowserPropertyID inProperty,
				ItemData &inItemData)
		{
			return noErr;
		}
	virtual bool
		ItemComparison(
				Item &inItemOne, 
				Item &inItemTwo,
				DataBrowserPropertyID inSortProperty)
		{
			return false;
		}
	
	// drag and drop callbacks
	static pascal Boolean
		AddDragItemCallback(
				ControlRef inBrowser,
				DragReference inDragRef,
				DataBrowserItemID inItemID,
				ItemReference *outItemRef);
	static pascal Boolean
		AcceptDragCallback(
				ControlRef inBrowser,
				DragReference inDragRef,
				DataBrowserItemID inItemID);
	static pascal Boolean
		ReceiveDragCallback(
				ControlRef inBrowser,
				DragReference inDragRef,
				DataBrowserItemID inItemID);
	static pascal void
		PostProcessDragCallback(
				ControlRef inBrowser,
				DragReference inDragRef,
				OSStatus inDragResult);
	
	virtual bool
		AddDragItem(
				DragReference inDragRef,
				DataBrowserItemID inItemID,
				ItemReference &outItemRef)
		{
			return false;
		}
	virtual bool
		AcceptDrag(
				DragReference inDragRef,
				DataBrowserItemID inItemID)
		{
			return false;
		}
	virtual bool
		ReceiveDrag(
				DragReference inDragRef,
				DataBrowserItemID inItemID)
		{
			return false;
		}
	virtual void
		PostProcessDrag(
				DragReference inDragRef,
				OSStatus inDragResult) {}
	
	// help callback
	static pascal void
		ItemHelpContentCallback(
				ControlRef inBrowser,
				DataBrowserItemID inItemID,
				DataBrowserPropertyID inProperty,
				HMContentRequest inRequest,
				HMContentProvidedType *outContentProvided,
				HMHelpContentPtr ioHelpContent);
	
	virtual void
		ItemHelpContent(
				DataBrowserItemID inItemID,
				DataBrowserPropertyID inProperty,
				HMContentRequest inRequest,
				HMContentProvidedType &outContentProvided,
				HMHelpContentPtr ioHelpContent) {}
	
	// contextual menu callbacks
	static pascal void
		GetContextualMenuCallback(
				ControlRef inBrowser,
				MenuRef *ioMenu,
				UInt32 *outHelpType,
				CFStringRef *outHelpItemString,
				AEDesc *outSelection);
	static pascal void
		SelectContextualMenuCallback(
				ControlRef inBrowser,
				MenuRef inMenu,
				UInt32 inSelectionType,
				SInt16 inMenuID,
				MenuItemIndex inMenuItem);
	
	virtual void
		GetContextualMenu(
				MenuRef &ioMenu,
				UInt32 &outHelpType,
				CFStringRef &outHelpItemString,
				AEDesc &outSelection) {}
	virtual void
		SelectContextualMenu(
				MenuRef inMenu,
				UInt32 inSelectionType,
				SInt16 inMenuID,
				MenuItemIndex inMenuItem) {}
};

#pragma warn_unusedarg reset

inline ADataBrowser::Item
ADataBrowser::Root() const
{
	return ADataBrowser::Item(*this,0);
}

inline void
ADataBrowser::MoveSelectionAnchor(
		DataBrowserSelectionAnchorDirection inDirection,
		bool inExtend)
{
	CThrownOSStatus err = ::MoveDataBrowserSelectionAnchor(*this,inDirection,inExtend);
}

inline void
ADataBrowser::Item::AddItems(
		UInt32 inNumItems,
		const DataBrowserItemID *items,
		DataBrowserPropertyID inPreSortProperty)
{
	CThrownOSStatus err = ::AddDataBrowserItems(mBrowser,mID,inNumItems,items,inPreSortProperty);
}

inline void
ADataBrowser::Item::RemoveItems(
		UInt32 inNumItems,
		const DataBrowserItemID *items,
		DataBrowserPropertyID inPreSortProperty)
{
	CThrownOSStatus err = ::RemoveDataBrowserItems(mBrowser,mID,inNumItems,items,inPreSortProperty);
}

inline void
ADataBrowser::Item::UpdateItems(
		UInt32 inNumItems,
		const DataBrowserItemID *items,
		DataBrowserPropertyID inPreSortProperty,
		DataBrowserPropertyID inPropertyID)
{
	CThrownOSStatus err = ::UpdateDataBrowserItems(mBrowser,mID,inNumItems,items,inPreSortProperty,inPropertyID);
}


inline UInt32
ADataBrowser::Item::ItemCount(
		DataBrowserItemState inState,
		bool inRecurse) const
{
	UInt32 itemCount = 0;
	CThrownOSStatus err = ::GetDataBrowserItemCount(mBrowser,mID,inRecurse,inState,&itemCount);
	return itemCount;
}

inline OSStatus
ADataBrowser::Item::GetItemIDs(
		Handle inItemHandle,
		DataBrowserItemState inState,
		bool inRecurse) const
{
	return ::GetDataBrowserItems(mBrowser,mID,inRecurse,inState,inItemHandle);
}

inline bool
ADataBrowser::Item::IsSelected() const
{
	return ::IsDataBrowserItemSelected(mBrowser,mID);
}

inline DataBrowserItemState
ADataBrowser::Item::State() const
{
	DataBrowserItemState itemState = kDataBrowserItemNoState;
	CThrownOSStatus err = ::GetDataBrowserItemState(mBrowser,mID,&itemState);
	return itemState;
}

inline DataBrowserTableViewRowIndex
ADataBrowser::Item::Row() const
{
	DataBrowserTableViewRowIndex rowIndex = 0;
	CThrownOSStatus err = ::GetDataBrowserTableViewItemRow(mBrowser,mID,&rowIndex);
	return rowIndex;
}

inline void
ADataBrowser::Item::Open()
{
	CThrownOSStatus err = ::OpenDataBrowserContainer(mBrowser,mID);
}

inline void
ADataBrowser::Item::Close()
{
	CThrownOSStatus err = ::CloseDataBrowserContainer(mBrowser,mID);
}

inline void
ADataBrowser::Item::Sort(
	bool inSortChildren)
{
	CThrownOSStatus err = ::SortDataBrowserContainer(mBrowser,mID,inSortChildren);
}

inline void
ADataBrowser::Item::Reveal(
		DataBrowserPropertyID inPropertyID,
		DataBrowserRevealOptions inOptions)
{
	CThrownOSStatus err = ::RevealDataBrowserItem(mBrowser,mID,inPropertyID,inOptions);
}

inline void
ADataBrowser::Item::SetRowHeight(
		UInt16 inHeight)
{
	CThrownOSStatus err = ::SetDataBrowserTableViewItemRowHeight(mBrowser,mID,inHeight);
}

inline UInt16
ADataBrowser::Item::RowHeight() const
{
	UInt16 rowHeight = 0;
	CThrownOSStatus err = ::GetDataBrowserTableViewItemRowHeight(mBrowser,mID,&rowHeight);
	return rowHeight;
}

inline Rect
ADataBrowser::Item::PartBounds(
		DataBrowserPropertyID inProperty,
		DataBrowserPropertyPart inPart) const
{
	Rect partBounds;
	CThrownOSStatus err = ::GetDataBrowserItemPartBounds(mBrowser,mID,inProperty,inPart,&partBounds);
	return partBounds;
}

inline void
ADataBrowser::ItemData::SetIcon(
		IconRef inIcon)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataIcon(*this,inIcon);
}

inline IconRef
ADataBrowser::ItemData::Icon() const
{
	IconRef icon;
	CThrownOSStatus err = ::GetDataBrowserItemDataIcon(*this,&icon);
	return icon;
}

inline void
ADataBrowser::ItemData::SetText(
		CFStringRef inText)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataText(*this,inText);
}

inline CFStringRef
ADataBrowser::ItemData::Text() const
{
	CFStringRef text;
	CThrownOSStatus err = ::GetDataBrowserItemDataText(*this,&text);
	return text;
}

inline void
ADataBrowser::ItemData::SetValue(
		SInt32 inValue)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataValue(*this,inValue);
}

inline SInt32
ADataBrowser::ItemData::Value() const
{
	SInt32 value;
	CThrownOSStatus err = ::GetDataBrowserItemDataValue(*this,&value);
	return value;
}

inline void
ADataBrowser::ItemData::SetMinimum(
		SInt32 inValue)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataMinimum(*this,inValue);
}

inline SInt32
ADataBrowser::ItemData::Minimum() const
{
	SInt32 value;
	CThrownOSStatus err = ::GetDataBrowserItemDataMinimum(*this,&value);
	return value;
}

inline void
ADataBrowser::ItemData::SetMaximum(
		SInt32 inValue)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataMaximum(*this,inValue);
}

inline SInt32
ADataBrowser::ItemData::Maximum() const
{
	SInt32 value;
	CThrownOSStatus err = ::GetDataBrowserItemDataMaximum(*this,&value);
	return value;
}

inline void
ADataBrowser::ItemData::SetBoolValue(
		bool inValue)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataBooleanValue(*this,inValue);
}

inline bool
ADataBrowser::ItemData::BoolValue() const
{
	Boolean value;
	CThrownOSStatus err = ::GetDataBrowserItemDataBooleanValue(*this,&value);
	return value;
}

inline void
ADataBrowser::ItemData::SetMenu(
		MenuRef inMenu)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataMenuRef(*this,inMenu);
}

inline MenuRef
ADataBrowser::ItemData::Menu() const
{
	MenuRef menu;
	CThrownOSStatus err = ::GetDataBrowserItemDataMenuRef(*this,&menu);
	return menu;
}

inline void
ADataBrowser::ItemData::SetRGBColor(
		const ::RGBColor &inColor)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataRGBColor(*this,&inColor);
}

inline RGBColor
ADataBrowser::ItemData::Color() const
{
	::RGBColor rgb;
	CThrownOSStatus err = ::GetDataBrowserItemDataRGBColor(*this,&rgb);
	return rgb;
}

inline void
ADataBrowser::ItemData::SetDrawState(
		ThemeDrawState inState)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataDrawState(*this,inState);
}

inline ThemeDrawState
ADataBrowser::ItemData::DrawState() const
{
	ThemeDrawState drawState;
	CThrownOSStatus err = ::GetDataBrowserItemDataDrawState(*this,&drawState);
	return drawState;
}

inline void
ADataBrowser::ItemData::SetButtonValue(
		ThemeButtonValue inValue)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataButtonValue(*this,inValue);
}

inline ThemeButtonValue
ADataBrowser::ItemData::ButtonValue() const
{
	ThemeButtonValue value;
	CThrownOSStatus err = ::GetDataBrowserItemDataButtonValue(*this,&value);
	return value;
}

inline void
ADataBrowser::ItemData::SetIconTransform(
		IconTransformType inTransform)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataIconTransform(*this,inTransform);
}

inline IconTransformType
ADataBrowser::ItemData::IconTransform() const
{
	IconTransformType transform;
	CThrownOSStatus err = ::GetDataBrowserItemDataIconTransform(*this,&transform);
	return transform;
}

inline void
ADataBrowser::ItemData::SetDateTime(
		long inDateTime)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataDateTime(*this,inDateTime);
}

inline long
ADataBrowser::ItemData::DateTime() const
{
	long date;
	CThrownOSStatus err = ::GetDataBrowserItemDataDateTime(*this,&date);
	return date;
}

inline void
ADataBrowser::ItemData::SetLongDateTime(
		::LongDateTime inDateTime)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataLongDateTime(*this,&inDateTime);
}

inline LongDateTime
ADataBrowser::ItemData::LDateTime() const
{
	::LongDateTime date;
	CThrownOSStatus err = ::GetDataBrowserItemDataLongDateTime(*this,&date);
	return date;
}

inline void
ADataBrowser::ItemData::SetItemID(
		DataBrowserItemID inID)
{
	CThrownOSStatus err = ::SetDataBrowserItemDataItemID(*this,inID);
}

inline DataBrowserItemID
ADataBrowser::ItemData::ItemID() const
{
	DataBrowserItemID itemID;
	CThrownOSStatus err = ::GetDataBrowserItemDataItemID(*this,&itemID);
	return itemID;
}

inline DataBrowserPropertyID
ADataBrowser::ItemData::PropertyID() const
{
	DataBrowserPropertyID propID;
	CThrownOSStatus err = ::GetDataBrowserItemDataProperty(*this,&propID);
	return propID;
}

