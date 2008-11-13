#pragma once

#include "XRefCountObject.h"
#include "XPropertyHolder.h"
#include "CThrownResult.h"

#include FW(Carbon,CarbonEvents.h)
#include FW(Carbon,IBCarbonRuntime.h)
#include FW(Carbon,Menus.h)

// ---------------------------------------------------------------------------
#pragma mark AMenu

class AMenu :
		public XRefCountObject<MenuRef>,
		public XPropertyHolder
{
public:
		// MenuRef
		AMenu(
				MenuRef inMenuRef,
				bool inDoRetain = true)
		: XRefCountObject<MenuRef>(inMenuRef,inDoRetain) {}
		// ID and title
		AMenu(
				MenuID inMenuID,
				ConstStringPtr inTitle);
		// Resource ID
		AMenu(
				short inResID);
		// ID and attributes
		AMenu(
				MenuID inMenuID,
				MenuAttributes inAttributes);
		// MenuDefSpec
		AMenu(
				const MenuDefSpec *inDefSpec,
				MenuID inMenuID,
				MenuAttributes inMenuAttributes = 0);
		AMenu(
				MenuDefUPP inDefProc,
				MenuID inMenuID,
				MenuAttributes inMenuAttributes = 0);
		// Nib
		AMenu(
				IBNibRef inNib,
				CFStringRef inName);
	
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
	bool
		HasProperty(
				OSType inCreator,
				OSType inTag) const;
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
	void
		RemoveProperty(
				OSType inCreator,
				OSType inTag);
	
	// Item
	class Item :
			public XPropertyHolder {
	public:
			Item(
					MenuRef inMenuRef,
					MenuItemIndex inIndex)
			: mMenu(inMenuRef),mIndex(inIndex) {}
			Item(
					MenuCommand inCommandID,
					MenuRef inMenuRef = NULL,
					UInt32 inIndex = 1);
		
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
		bool
			HasProperty(
					OSType inCreator,
					OSType inTag) const;
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
		void
			RemoveProperty(
					OSType inCreator,
					OSType inTag);
		
		// Item
		
		MenuRef
			Menu() const
			{ return mMenu; }
		MenuItemIndex
			Index() const
			{ return mIndex; }
		
		MenuItemAttributes
			Attributes() const;
		void
			ChangeAttributes(
					MenuItemAttributes inSet,
					MenuItemAttributes inClear);
		
		CFStringRef
			CopyTextString() const;
		MenuCommand
			CommandID() const;
		UniChar
			MarkUniChar() const;
		CharParameter
			MarkChar() const;
		UInt16
			CommandKey() const;
		UInt16
			VirtualKey() const;
		UInt8
			Modifiers() const;
		bool
			HasVirtualKey() const;
		SInt16
			KeyGlyph() const;
		UInt32
			Indent() const;
		
		void
			SetText(
					ConstStr255Param inText);
		void
			SetText(
					CFStringRef inString);
		void
			SetMarkChar(
					CharParameter inMark);
		void
			SetMarkUniChar(
					UniChar inMark);
		void
			SetCommandKey(
					UInt16 inKey,
					bool inIsVirtual = false);
		void
			SetKeyGlyph(
					SInt16 inGlyph);
		
		void
			Enable();
		void
			Disable();
		bool
			IsEnabled() const;
		
	protected:
		MenuRef mMenu;	// Can't use AMenu
		MenuItemIndex mIndex;
	};
	
	
	// AMenu
	
	bool
		IsValid() const
		{
			return ::IsValidMenu(*this);
		}
	
		operator EventTargetRef() const
		{
			return ::GetMenuEventTarget(*this);
		}
	
	MenuID
		ID() const;
	
	// title
	CFStringRef
		CopyTitleString() const;
	void
		SetTitleString(
				CFStringRef inString);
	void
		SetTitleIcon(
				IconRef inIcon);
	void
		SetTitleIcon(
				IconSuiteRef inIcon);
	UInt32
		TitleIconType() const;
	IconRef
		TitleIconRef() const;
	IconSuiteRef
		TitleIconSuite() const;
	
	// items
	short
		ItemCount() const
		{
			return ::CountMenuItems(*this);
		}
	Item
		operator[](
				MenuItemIndex inIndex)
		{ return Item(*this,inIndex); }
	AMenu&
		operator<<(
				ConstStr255Param inText);
	void
		InsertItemText(
				ConstStr255Param inText,
				short inAfterItem);
	MenuItemIndex
		Append(
				CFStringRef inString,
				MenuCommand inCommand = 0,
				MenuItemAttributes inAttributes = 0L);
	void
		Append(
				ConstStr255Param inText);
	void
		DeleteItem(
				short inItemIndex);
	void
		DeleteItems(
				MenuItemIndex inItemIndex,
				::ItemCount inItemCount);
	
	void
		Invalidate()
		{
			::InvalidateMenuEnabling(*this);
		}
};

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline
AMenu::AMenu(
		MenuID inMenuID,
		ConstStringPtr inTitle)
{
	mObjectRef = ::NewMenu(inMenuID,inTitle);
}

inline
AMenu::AMenu(
		short inResID)
{
	mObjectRef = ::GetMenu(inResID);
}

inline
AMenu::AMenu(
		MenuID inMenuID,
		MenuAttributes inAttributes)
{
	CThrownOSStatus err = ::CreateNewMenu(inMenuID,inAttributes,&mObjectRef);
}

inline
AMenu::AMenu(
		const MenuDefSpec *inDefSpec,
		MenuID inMenuID,
		MenuAttributes inMenuAttributes)
{
	CThrownOSStatus err = ::CreateCustomMenu(inDefSpec,inMenuID,inMenuAttributes,&mObjectRef);
}

inline
AMenu::AMenu(
		MenuDefUPP inDefProc,
		MenuID inMenuID,
		MenuAttributes inMenuAttributes)
{
	MenuDefSpec defSpec;
	defSpec.defType = kMenuDefProcPtr;
	defSpec.u.defProc = inDefProc;
	CThrownOSStatus err = ::CreateCustomMenu(&defSpec,inMenuID,inMenuAttributes,&mObjectRef);
}

inline
AMenu::AMenu(
		IBNibRef inNib,
		CFStringRef inName)
{
	CThrownOSStatus err = ::CreateMenuFromNib(inNib,inName,&mObjectRef);
}

inline MenuID
AMenu::ID() const
{
	return ::GetMenuID(*this);
}

inline void
AMenu::InsertItemText(
		ConstStr255Param inText,
		short inAfterItem)
{
	::InsertMenuItemText(*this,inText,inAfterItem);
}

inline MenuItemIndex
AMenu::Append(
		CFStringRef inString,
		MenuCommand inCommand,
		MenuItemAttributes inAttributes)
{
	MenuItemIndex newItemIndex;
	::AppendMenuItemTextWithCFString(*this,inString,inAttributes,inCommand,&newItemIndex);
	return newItemIndex;
}

inline void
AMenu::Append(
		ConstStr255Param inText)
{
	::AppendMenu(*this,inText);
}

inline void
AMenu::DeleteItem(
		short inItemIndex)
{
	::DeleteMenuItem(*this,inItemIndex);
}

inline void
AMenu::DeleteItems(
		MenuItemIndex inItemIndex,
		::ItemCount inItemCount)
{
	::DeleteMenuItems(*this,inItemIndex,inItemCount);
}

// ---------------------------------------------------------------------------

inline void
AMenu::SetPropertyData(
		OSType inCreator,
		OSType inTag,
		UInt32 inSize,
		const void *inBuffer)
{
	::SetMenuItemProperty(*this,0,inCreator,inTag,inSize,inBuffer);
}

inline void
AMenu::GetPropertyData(
		OSType inCreator,
		OSType inTag,
		UInt32 inSize,
		void *inBuffer) const
{
	UInt32 actualSize;
	::GetMenuItemProperty(*this,0,inCreator,inTag,inSize,&actualSize,inBuffer);
}

inline void
AMenu::GetPropertyAttributes(
		OSType inCreator,
		OSType inTag,
		UInt32 &outAttributes) const
{
	::GetMenuItemPropertyAttributes(*this,0,inCreator,inTag,&outAttributes);
}

inline bool
AMenu::HasProperty(
		OSType inCreator,
		OSType inTag) const
{
	UInt32 attributes;
	return ::GetMenuItemPropertyAttributes(*this,0,inCreator,inTag,&attributes) == noErr;
}

inline void
AMenu::ChangePropertyAttributes(
		OSType inCreator,
		OSType inTag,
		UInt32 inSet,
		UInt32 inClear)
{
	::ChangeMenuItemPropertyAttributes(*this,0,inCreator,inTag,inSet,inClear);
}

inline UInt32
AMenu::GetPropertySize(
		OSType inCreator,
		OSType inTag) const
{
	UInt32 propertySize;
	::GetMenuItemPropertySize(*this,0,inCreator,inTag,&propertySize);
	return propertySize;
}

inline void
AMenu::RemoveProperty(
		OSType inCreator,
		OSType inTag)
{
	::RemoveMenuItemProperty(*this,0,inCreator,inTag);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline
AMenu::Item::Item(
		MenuCommand inCommandID,
		MenuRef inMenuRef,
		UInt32 inIndex)
: mMenu((MenuRef)NULL)
{
	MenuRef menuRef;
	::GetIndMenuItemWithCommandID(inMenuRef,inCommandID,inIndex,&menuRef,&mIndex);
	mMenu = menuRef;
}

// ---------------------------------------------------------------------------

inline void
AMenu::Item::SetPropertyData(
		OSType inCreator,
		OSType inTag,
		UInt32 inSize,
		const void *inBuffer)
{
	::SetMenuItemProperty(mMenu,mIndex,inCreator,inTag,inSize,inBuffer);
}

inline void
AMenu::Item::GetPropertyData(
		OSType inCreator,
		OSType inTag,
		UInt32 inSize,
		void *inBuffer) const
{
	UInt32 actualSize;
	::GetMenuItemProperty(mMenu,mIndex,inCreator,inTag,inSize,&actualSize,inBuffer);
}

inline void
AMenu::Item::GetPropertyAttributes(
		OSType inCreator,
		OSType inTag,
		UInt32 &outAttributes) const
{
	::GetMenuItemPropertyAttributes(mMenu,mIndex,inCreator,inTag,&outAttributes);
}

inline bool
AMenu::Item::HasProperty(
		OSType inCreator,
		OSType inTag) const
{
	UInt32 attributes;
	return ::GetMenuItemPropertyAttributes(mMenu,mIndex,inCreator,inTag,&attributes) == noErr;
}

inline void
AMenu::Item::ChangePropertyAttributes(
		OSType inCreator,
		OSType inTag,
		UInt32 inSet,
		UInt32 inClear)
{
	::ChangeMenuItemPropertyAttributes(mMenu,mIndex,inCreator,inTag,inSet,inClear);
}

inline UInt32
AMenu::Item::GetPropertySize(
		OSType inCreator,
		OSType inTag) const
{
	UInt32 propertySize;
	::GetMenuItemPropertySize(mMenu,mIndex,inCreator,inTag,&propertySize);
	return propertySize;
}

inline void
AMenu::Item::RemoveProperty(
		OSType inCreator,
		OSType inTag)
{
	::RemoveMenuItemProperty(mMenu,mIndex,inCreator,inTag);
}


// ---------------------------------------------------------------------------

inline MenuItemAttributes
AMenu::Item::Attributes() const
{
	MenuItemAttributes attributes;
	::GetMenuItemAttributes(mMenu,mIndex,&attributes);
	return attributes;
}

inline void
AMenu::Item::ChangeAttributes(
		MenuItemAttributes inSet,
		MenuItemAttributes inClear)
{
	::ChangeMenuItemAttributes(mMenu,mIndex,inSet,inClear);
}

inline CFStringRef
AMenu::Item::CopyTextString() const
{
	CFStringRef textString;
	::CopyMenuItemTextAsCFString(mMenu,mIndex,&textString);
	return textString;
}

inline MenuCommand
AMenu::Item::CommandID() const
{
	MenuCommand commandID;
	::GetMenuItemCommandID(mMenu,mIndex,&commandID);
	return commandID;
}

inline UniChar
AMenu::Item::MarkUniChar() const
{
	UniChar uni;
	::GetMenuCommandMark(mMenu,CommandID(),&uni);
	return uni;
}

inline CharParameter
AMenu::Item::MarkChar() const
{
	CharParameter mark;
	::GetItemMark(mMenu,mIndex,&mark);
	return mark;
}

inline UInt16
AMenu::Item::CommandKey() const
{
	UInt16 key;
	::GetMenuItemCommandKey(mMenu,mIndex,false,&key);
	return key;
}

inline UInt16
AMenu::Item::VirtualKey() const
{
	UInt16 key;
	::GetMenuItemCommandKey(mMenu,mIndex,true,&key);
	return key;
}

inline bool
AMenu::Item::HasVirtualKey() const
{
	return Attributes() & kMenuItemAttrUseVirtualKey;
}

inline UInt8
AMenu::Item::Modifiers() const
{
	UInt8 modifiers;
	::GetMenuItemModifiers(mMenu,mIndex,&modifiers);
	return modifiers;
}

inline SInt16
AMenu::Item::KeyGlyph() const
{
	SInt16 glyph;
	::GetMenuItemKeyGlyph(mMenu,mIndex,&glyph);
	return glyph;
}

inline void
AMenu::Item::SetKeyGlyph(
		SInt16 inGlyph)
{
	::SetMenuItemKeyGlyph(mMenu,mIndex,inGlyph);
}

inline UInt32
AMenu::Item::Indent() const
{
	UInt32 indent;
	::GetMenuItemIndent(mMenu,mIndex,&indent);
	return indent;
}

// ---------------------------------------------------------------------------

inline void
AMenu::Item::SetText(
		ConstStr255Param inText)
{
	::SetMenuItemText(mMenu,mIndex,inText);
}

inline void
AMenu::Item::SetText(
		CFStringRef inString)
{
	::SetMenuItemTextWithCFString(mMenu,mIndex,inString);
}

inline void
AMenu::Item::SetMarkChar(
		CharParameter inMark)
{
	::SetItemMark(mMenu,mIndex,inMark);
}

inline void
AMenu::Item::SetMarkUniChar(
		UniChar inMark)
{
	::SetMenuCommandMark(mMenu,CommandID(),inMark);
}

inline void
AMenu::Item::SetCommandKey(
		UInt16 inKey,
		bool inIsVirtual)
{
	::SetMenuItemCommandKey(mMenu,mIndex,inIsVirtual,inKey);
}

// ---------------------------------------------------------------------------

inline void
AMenu::Item::Enable()
{
	::EnableMenuItem(mMenu,mIndex);
}

inline void
AMenu::Item::Disable()
{
	::DisableMenuItem(mMenu,mIndex);
}

inline bool
AMenu::Item::IsEnabled() const
{
	return ::IsMenuItemEnabled(mMenu,mIndex);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline void
XRefCountObject<MenuRef>::Retain()
{
	::RetainMenu(*this);
}

inline void
XRefCountObject<MenuRef>::Release()
{
	::ReleaseMenu(*this);
}

inline UInt32
XRefCountObject<MenuRef>::GetRetainCount() const
{
	return ::GetMenuRetainCount(*this);
}

// ---------------------------------------------------------------------------
#pragma mark AFontMenu

class AFontMenu : public AMenu {
public:
		AFontMenu(
			MenuRef inMenuRef);
		AFontMenu(
			MenuID inMenuID,
			MenuAttributes inAttributes);
	
protected:
	void
		AddFontItems();
};
