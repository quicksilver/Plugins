// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AHIView.h"
#include "AEventObject.h"
#include "AEventParameter.h"

class ACFString;
class ACFMutableArray;

class AToolbar :
		public AView
{
public:
		AToolbar(
				HIToolbarRef inToolbar,
				bool inDoRetain = true)
		: AView(inToolbar,inDoRetain) {}
		AToolbar(
				CFStringRef inIdentifier,
				OptionBits inAttributes)
		: AView(MakeToolbarRef(inIdentifier,inAttributes),false) {}
	
	OptionBits
		ToolbarAttributes() const;
	void
		ChangeToolbarAttributes(
				OptionBits inAttrsToSet,
				OptionBits inAttrsToClear);
	
	// display
	HIToolbarDisplayMode
		DisplayMode() const;
	void
		SetDisplayMode(
				HIToolbarDisplayMode inMode);
	HIToolbarDisplaySize
		DisplaySize() const;
	void
		SetDisplaySize(
				HIToolbarDisplaySize inSize);
	
	CFStringRef
		CopyIdentifier() const;
	
	CFArrayRef
		CopyItems() const;
	void
		Append(
				HIToolbarItemRef inItem);
	void
		RemoveItem(
				CFIndex inIndex);
	
	void
		SetDelegate(
				HIObjectRef inDelegate);
	HIObjectRef
		Delegate() const;
	
	// item
	class Item :
			public AView
	{
	public:
			// HIToolbarItemRef
			Item(
					HIToolbarItemRef inItem,
					bool inDoRetain = true)
			: AView(inItem,inDoRetain) {}
			// toolbar
			Item(
					HIToolbarRef inToolbar,
					CFStringRef inIdentifier,
					CFTypeRef inConfigData = NULL)
			: AView(MakeItemRef(inToolbar,inIdentifier,inConfigData),false) {}
			// create for deletage
			Item(
					CFStringRef inIdentifier,
					OptionBits inOptions = kHIToolbarItemNoAttributes)
			: AView(MakeItemRef(inIdentifier,inOptions),false) {}
			// create and equip
			Item(
					CFStringRef inIdentifier,
					OptionBits inOptions,
					CFStringRef inText,
					MenuCommand inCommandID,
					IconRef inIcon);
		
		CFStringRef
			CopyIdentifier() const;
		
		OptionBits
			ItemAttributes() const;
		void
			ChangeItemAttributes(
					OptionBits inSet,
					OptionBits inClear);
		
		void
			SetLabel(
					CFStringRef inLabel);
		CFStringRef
			CopyLabel() const;
		
		void
			SetHelpText(
					CFStringRef inShortText,
					CFStringRef inLongText = NULL);
		void
			CopyHelpText(
					CFStringRef *outShortText,
					CFStringRef *outLongText = NULL);
		
		void
			SetCommandID(
					MenuCommand inCommandID);
		MenuCommand
			CommandID() const;
		
		void
			SetIconRef(
					IconRef inIcon);
		void
			SetImage(
					CGImageRef inImage);
		CGImageRef
			CopyImage() const;
		
		void
			SetMenu(
					MenuRef inMenu);
		MenuRef
			CopyMenu() const;
		
		HIToolbarRef
			Toolbar() const;
		
		bool
			Enabled() const;
		void
			SetEnabled(
					bool inEnabled);
		
	protected:
		// AEventObject
		
		OSStatus
			HandleEvent(
					const ACarbonEvent &inEvent,
					bool &outEventHandled);
		
		// Item
		
		virtual bool
			ImageChanged()
			{ return false; }
		virtual bool
			LabelChanged()
			{ return false; }
		virtual bool
			HelpTextChanged()
			{ return false; }
		virtual bool
			CommandIDChanged()
			{ return false; }
		virtual bool
			EnabledStateChanged()
			{ return false; }
		virtual bool
			GetPersistentData()	// parameters??
			{ return false; }
		virtual bool
			CreateCustomView()
			{ return false; }
		virtual bool
			PerformAction()
			{ return false; }
		
		static HIToolbarItemRef
			MakeItemRef(
					HIToolbarRef inToolbar,
					CFStringRef inIdentifier,
					CFTypeRef inConfigData)
			{
				HIToolbarItemRef itemRef;
				CThrownOSStatus err = ::HIToolbarCreateItemWithIdentifier(
						inToolbar,inIdentifier,inConfigData,&itemRef);
				return itemRef;
			}
		static HIToolbarItemRef
			MakeItemRef(
					CFStringRef inIdentifier,
					OptionBits inOptions)
			{
				HIToolbarItemRef itemRef;
				CThrownOSStatus err = ::HIToolbarItemCreate(
						inIdentifier,inOptions,&itemRef);
				return itemRef;
			}
	};
	
	class Delegate :
			public AEventObject
	{
	public:
		Delegate()
		: mTypes(*this) {}	// subclass calls SetUpHandler
	template <class T>
		Delegate(
				T inObjectRef)
		: AEventObject(inObjectRef),
		  mTypes(*this)
		{
			SetUpHandler();
		}
		
	protected:
		StHandleEventTypes mTypes;
		
		// AEventObject
		
		OSStatus
			HandleEvent(
					ACarbonEvent &inEvent,
					bool &outEventHandled);
		
		// Delegate
		
		void
			SetUpHandler();
		
		virtual bool
			GetDefaultIdentifiers(
					ACFMutableArray &/*ioArray*/)
			{ return false; }
		virtual bool
			GetAllowedIdentifiers(
					ACFMutableArray &/*ioArray*/)
			{ return false; }
		virtual bool
			CreateItemWithIdentifier(
					const ACFString &/*inIdentifier*/,
					const AEventParameter<CFTypeRef> &/*inConfigData*/,
					AEventParameter<HIToolbarItemRef,AWriteOnly> &/*outItem*/)
			{ return false; }
		virtual bool
			CreateItemFromDrag(
					DragRef)
			{ return false; }
	};
	
protected:
	static HIToolbarRef
		MakeToolbarRef(
				CFStringRef inIdentifier,
				OptionBits inAttributes)
		{
			HIToolbarRef toolbarRef;
			CThrownOSStatus err = ::HIToolbarCreate(inIdentifier,inAttributes,&toolbarRef);
			return toolbarRef;
		}

};

// ---------------------------------------------------------------------------

inline OptionBits
AToolbar::ToolbarAttributes() const
{
	OptionBits attributes;
	CThrownOSStatus err = ::HIToolbarGetAttributes(*this,&attributes);
	return attributes;
}

inline void
AToolbar::ChangeToolbarAttributes(
		OptionBits inAttrsToSet,
		OptionBits inAttrsToClear)
{
	CThrownOSStatus err = ::HIToolbarChangeAttributes(*this,inAttrsToSet,inAttrsToClear);
}

// display
inline HIToolbarDisplayMode
AToolbar::DisplayMode() const
{
	HIToolbarDisplayMode displayMode;
	CThrownOSStatus err = ::HIToolbarGetDisplayMode(*this,&displayMode);
	return displayMode;
}

inline void
AToolbar::SetDisplayMode(
		HIToolbarDisplayMode inMode)
{
	CThrownOSStatus err = ::HIToolbarSetDisplayMode(*this,inMode);
}

inline HIToolbarDisplaySize
AToolbar::DisplaySize() const
{
	HIToolbarDisplaySize displaySize;
	CThrownOSStatus err = ::HIToolbarGetDisplaySize(*this,&displaySize);
	return displaySize;
}

inline void
AToolbar::SetDisplaySize(
		HIToolbarDisplaySize inSize)
{
	CThrownOSStatus err = ::HIToolbarSetDisplaySize(*this,inSize);
}

inline CFStringRef
AToolbar::CopyIdentifier() const
{
	CFStringRef identifier;
	CThrownOSStatus err = ::HIToolbarCopyIdentifier(*this,&identifier);
	return identifier;
}

inline CFArrayRef
AToolbar::CopyItems() const
{
	CFArrayRef items;
	CThrownOSStatus err = ::HIToolbarCopyItems(*this,&items);
	return items;
}

inline void
AToolbar::Append(
		HIToolbarItemRef inItem)
{
	CThrownOSStatus err = ::HIToolbarAppendItem(*this,inItem);
}

inline void
AToolbar::RemoveItem(
		CFIndex inIndex)
{
	CThrownOSStatus err = ::HIToolbarRemoveItemAtIndex(*this,inIndex);
}

inline void
AToolbar::SetDelegate(
		HIObjectRef inDelegate)
{
	CThrownOSStatus err = ::HIToolbarSetDelegate(*this,inDelegate);
}

inline HIObjectRef
AToolbar::Delegate() const
{
	return ::HIToolbarGetDelegate(*this);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

inline CFStringRef
AToolbar::Item::CopyIdentifier() const
{
	CFStringRef identifier;
	CThrownOSStatus err = ::HIToolbarCopyIdentifier(*this,&identifier);
	return identifier;
}

inline OptionBits
AToolbar::Item::ItemAttributes() const
{
	OptionBits attributes;
	CThrownOSStatus err = ::HIToolbarItemGetAttributes(*this,&attributes);
	return attributes;
}

inline void
AToolbar::Item::ChangeItemAttributes(
		OptionBits inSet,
		OptionBits inClear)
{
	CThrownOSStatus err = ::HIToolbarItemChangeAttributes(*this,inSet,inClear);
}

inline void
AToolbar::Item::SetLabel(
		CFStringRef inLabel)
{
	CThrownOSStatus err = ::HIToolbarItemSetLabel(*this,inLabel);
}

inline CFStringRef
AToolbar::Item::CopyLabel() const
{
	CFStringRef label;
	CThrownOSStatus err = ::HIToolbarItemCopyLabel(*this,&label);
	return label;
}

inline void
AToolbar::Item::SetHelpText(
		CFStringRef inShortText,
		CFStringRef inLongText)
{
	CThrownOSStatus err = ::HIToolbarItemSetHelpText(*this,inShortText,inLongText);
}

inline void
AToolbar::Item::CopyHelpText(
		CFStringRef *outShortText,
		CFStringRef *outLongText)
{
	CThrownOSStatus err = ::HIToolbarItemCopyHelpText(*this,outShortText,outLongText);
}

inline void
AToolbar::Item::SetCommandID(
		MenuCommand inCommandID)
{
	CThrownOSStatus err = ::HIToolbarItemSetCommandID(*this,inCommandID);
}

inline MenuCommand
AToolbar::Item::CommandID() const
{
	MenuCommand command;
	CThrownOSStatus err = ::HIToolbarItemGetCommandID(*this,&command);
	return command;
}

inline void
AToolbar::Item::SetIconRef(
		IconRef inIcon)
{
	CThrownOSStatus err = ::HIToolbarItemSetIconRef(*this,inIcon);
}

inline void
AToolbar::Item::SetImage(
		CGImageRef inImage)
{
	CThrownOSStatus err = ::HIToolbarItemSetImage(*this,inImage);
}

inline CGImageRef
AToolbar::Item::CopyImage() const
{
	CGImageRef image;
	CThrownOSStatus err = ::HIToolbarItemCopyImage(*this,&image);
	return image;
}

inline void
AToolbar::Item::SetMenu(
		MenuRef inMenu)
{
	CThrownOSStatus err = ::HIToolbarItemSetMenu(*this,inMenu);
}

inline MenuRef
AToolbar::Item::CopyMenu() const
{
	MenuRef menu;
	CThrownOSStatus err = ::HIToolbarItemCopyMenu(*this,&menu);
	return menu;
}

inline HIToolbarRef
AToolbar::Item::Toolbar() const
{
	return ::HIToolbarItemGetToolbar(*this);
}

inline bool
AToolbar::Item::Enabled() const
{
	return ::HIToolbarItemIsEnabled(*this);
}

inline void
AToolbar::Item::SetEnabled(
		bool inEnabled)
{
	CThrownOSStatus err = ::HIToolbarItemSetEnabled(*this,inEnabled);
}
