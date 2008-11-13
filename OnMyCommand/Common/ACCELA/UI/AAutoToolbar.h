#pragma once

#include "ACFBundle.h"
#include "ACFString.h"
#include "ACFXMLParser.h"
#include "AToolbar.h"

class AAutoToolbarDelegate;
class ACFURL;

// ---------------------------------------------------------------------------
// These classes give you a toolbar that reads its configuration from an xml
// file. See below for example xml. The delegate class actually does all the
// work. If you need to use custom items (like a popup button), you can
// subclass AAutoToolbarDelegate and specify your subclass as a template
// parameter.

template <class Source,class DelegateClass = AAutoToolbarDelegate>
class AAutoToolbar :
		public AToolbar
{
public:
		AAutoToolbar(
				WindowRef inWindow,
				OptionBits inOptions)
		: AToolbar(Source::identifier,inOptions)
		{
			// note that the toolbar id is also the delegate class id
			if (sDelegateClass == NULL)
				sDelegateClass = new AHIObjectClassT<DelegateClass>(Source::identifier);
			if (sDelegate == NULL)
				sDelegate = sDelegateClass->MakeObject(
						(void*)ACFBundle(ACFBundle::bundle_Main).CopyResourceURL(Source::filename,CFSTR("xml")));
			SetDelegate(*sDelegate);
			
			::SetWindowToolbar(inWindow,*this);
		}
	
	
protected:
	static AHIObjectClassT<DelegateClass> *sDelegateClass;
	static DelegateClass *sDelegate;
};

// ---------------------------------------------------------------------------
// AAutoToolbar is a template with static data members, so they need to be
// defined. These macros are provided for convenience.

#define DeclareAutoToolbar_(_name_) \
	class _name_ \
	{ \
	public: \
		static const CFStringRef identifier,filename; \
	};
#define DefineAutoToolbar_(_name_,_id_,_file_) \
	const CFStringRef _name_::identifier = CFSTR(_id_),_name_::filename = CFSTR(_file_); \
	AHIObjectClassT<AAutoToolbarDelegate> *AAutoToolbar<_name_>::sDelegateClass = NULL; \
	AAutoToolbarDelegate *AAutoToolbar<_name_>::sDelegate = NULL;
#define DefineCustomAutoToolbar_(_name_,_delegate_,_id_,_file_) \
	const CFStringRef _name_::identifier = CFSTR(_id_),_name_::filename = CFSTR(_file_); \
	AHIObjectClassT<AAutoToolbarDelegate> *AAutoToolbar<_name_>::sDelegateClass = NULL; \
	_delegate_ *AAutoToolbar<_name_,_delegate_>::sDelegate = NULL;

// ---------------------------------------------------------------------------

class AAutoToolbarDelegate :
		public AToolbar::Delegate,
		public AHICustomObject
{
public:
	
	class ItemSettings
	{
	public:
			ItemSettings(
					const ACFXMLTree &inTree);
		
		const ACFString&
			ID() const
			{
				return mID;
			}
		const ACFString&
			Text() const
			{
				return mText;
			}
		
		UInt32
			CommandID() const
			{
				return mCommandID;
			}
		UInt32
			IconCreator() const
			{
				return mIconCreator;
			}
		UInt32
			IconType() const
			{
				return mIconCreator;
			}
		IconRef
			Icon() const;
		OptionBits
			Options() const
			{
				return mOptions;
			}
		
	protected:
		ACFString mID,mText;
		UInt32 mCommandID,mIconCreator,mIconType;
		OptionBits mOptions;
		
		static void
			GetFourByteValue(
					const ACFString &inString,
					UInt32 &outValue);
	};
	
protected:
	friend class AHIObjectClassT<AAutoToolbarDelegate>;
	
	typedef std::vector<ItemSettings> ItemVector;
	typedef std::vector<ACFString> StringVector;
	
	ItemVector mItems;
	StringVector mDefaults,mAllowed;
	
		AAutoToolbarDelegate(
				HIObjectRef inObject)
		: Delegate(::HIObjectGetEventTarget(inObject)),
		  AHICustomObject(inObject) {}
	
	// Delegate
	
	virtual bool
		GetDefaultIdentifiers(
				ACFMutableArray &ioArray);
	virtual bool
		GetAllowedIdentifiers(
				ACFMutableArray &ioArray);
	virtual bool
		CreateItemWithIdentifier(
				const ACFString &inIdentifier,
				const AEventParameter<CFTypeRef> &inConfigData,
				AEventParameter<HIToolbarItemRef,AWriteOnly> &outItem);
	
	// AHICustomObject
	
	OSStatus
		Initialize(
				const ACarbonEvent &inEvent);
	
	// AutoDelegate
	
	void
		AddIDs(
				const ACFXMLTree &inTree,
				StringVector &inVector);
	static void
		GetIdentifiers(
				const StringVector &inSource,
				ACFMutableArray &ioArray);
};

// ---------------------------------------------------------------------------

/* XML example

<?xml version="1.0" ?>
<!DOCTYPE toolbar SYSTEM "atoolbar.dtd">
<toolbar>
	<item>
		<id>com.uncommonplace.accela.sample</id>
		<text>Sample</text>
		<command>Samp</command>
		<iconcreator>ACEL</iconcreator>
		<icontype>Samp</icontype>
		<attributes>4</attributes>
	</item>
	<default>
		<id>com.uncommonplace.accela.sample</id>
		<id>com.apple.hitoolbox.toolbar.flexiblespace</id>
		<id>com.apple.hitoolbox.toolbar.customize</id>
	</default>
	<allowed>
		<id>com.uncommonplace.accela.sample</id>
		<id>com.apple.hitoolbox.toolbar.separator</id>
		<id>com.apple.hitoolbox.toolbar.space</id>
		<id>com.apple.hitoolbox.toolbar.flexiblespace</id>
		<id>com.apple.hitoolbox.toolbar.customize</id>
		<id>com.apple.hitoolbox.toolbar.print</id>
	</allowed>
</toolbar>

*/
