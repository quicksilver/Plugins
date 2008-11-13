#include "AAutoToolbar.h"
#include "ACFArray.h"
#include "ACFURL.h"
#include "ACFXMLIterator.h"
#include "AIconRef.h"

// ---------------------------------------------------------------------------

OSStatus
AAutoToolbarDelegate::Initialize(
		const ACarbonEvent &inEvent)
{
	ACFURL fileURL(inEvent.Parameter<CFURLRef>(kEventParamAHIOInitParam,typeVoidPtr));
	ACFXMLTree tree(fileURL.MakeFSRef());
	ACFXMLIterator iter1(tree,true);
	
	for (; iter1; ++iter1)
		if (iter1.IsNodeType(CFSTR("toolbar"))) {
			ACFXMLIterator iter2(iter1.Tree(),true);
			
			for (; iter2; ++iter2) {
				if (iter2.IsNodeType(CFSTR("item")))
					mItems.push_back(ItemSettings(iter2.Tree()));
				else if (iter2.IsNodeType(CFSTR("default")))
					AddIDs(iter2.Tree(),mDefaults);
				else if (iter2.IsNodeType(CFSTR("allowed")))
					AddIDs(iter2.Tree(),mAllowed);
			}
			break;
		}
	return noErr;
}

// ---------------------------------------------------------------------------

void
AAutoToolbarDelegate::AddIDs(
		const ACFXMLTree &inTree,
		StringVector &inVector)
{
	ACFXMLIterator iter(inTree,true);
	
	for (; iter; ++iter) {
		if (iter.IsNodeType(CFSTR("id")))
			inVector.push_back(ACFString(iter.Tree().ChildText()));
	}
}

// ---------------------------------------------------------------------------

bool
AAutoToolbarDelegate::GetDefaultIdentifiers(
		ACFMutableArray &ioArray)
{
	GetIdentifiers(mDefaults,ioArray);
	return true;
}

// ---------------------------------------------------------------------------

bool
AAutoToolbarDelegate::GetAllowedIdentifiers(
		ACFMutableArray &ioArray)
{
	GetIdentifiers(mAllowed,ioArray);
	return true;
}

// ---------------------------------------------------------------------------

class MatchID
{
public:
		MatchID(
				const ACFString &inID)
		: mID(inID) {}
	
	bool
		operator()(
				const AAutoToolbarDelegate::ItemSettings &inItem)
		{
			return inItem.ID() == mID;
		}
	
protected:
	const ACFString &mID;
};


bool
AAutoToolbarDelegate::CreateItemWithIdentifier(
		const ACFString &inIdentifier,
		const AEventParameter<CFTypeRef> &,	// only for custom items
		AEventParameter<HIToolbarItemRef,AWriteOnly> &outItem)
{
	ItemVector::const_iterator iter = std::find_if<ItemVector::iterator,MatchID>(mItems.begin(),mItems.end(),MatchID(inIdentifier));
	bool handled = false;
	
	if (iter != mItems.end()) {
		AToolbar::Item newItem(inIdentifier,iter->Options());
		AIconRef icon(iter->Icon());
		
		newItem.SetLabel(iter->Text());
		newItem.SetCommandID(iter->CommandID());
		if (icon.Get() != NULL)
			newItem.SetIconRef(icon);
		newItem.Retain();
		outItem = (HIToolbarItemRef)newItem.Get();
		
		handled = true;
	}
	return handled;
}

// ---------------------------------------------------------------------------

void
AAutoToolbarDelegate::GetIdentifiers(
		const StringVector &inSource,
		ACFMutableArray &ioArray)
{
	StringVector::const_iterator iter = inSource.begin();
	
	for (; iter != inSource.end(); iter++)
		ioArray.Append(iter->Get());
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AAutoToolbarDelegate::ItemSettings::ItemSettings(
		const ACFXMLTree &inTree)
: mCommandID(0),mIconCreator(0),mIconType(0),mOptions(0)
{
	ACFXMLIterator iter(inTree,true);
	
	for (; iter; ++iter) {
		if (iter.IsNodeType(CFSTR("id")))
			mID.Reset(iter.Tree().ChildText());
		else if (iter.IsNodeType(CFSTR("text")))
			mText.Reset(iter.Tree().ChildText());
		else if (iter.IsNodeType(CFSTR("command")))
			GetFourByteValue(iter.Tree().ChildText(),mCommandID);
		else if (iter.IsNodeType(CFSTR("iconcreator")))
			GetFourByteValue(iter.Tree().ChildText(),mIconCreator);
		else if (iter.IsNodeType(CFSTR("icontype")))
			GetFourByteValue(iter.Tree().ChildText(),mIconType);
		else if (iter.IsNodeType(CFSTR("attributes"))) {
			static const int kAttrCount = 5;
			static const CFStringRef kAttrStrings[kAttrCount] = {
					CFSTR("allowduplicates"),
					CFSTR("cantberemoved"),
					CFSTR("anchoredleft"),
					CFSTR("isseparator"),
					CFSTR("userfocus") };
			static const OptionBits kAttrBits[kAttrCount] = {
					kHIToolbarItemAllowDuplicates,
					kHIToolbarItemCantBeRemoved,
					kHIToolbarItemAnchoredLeft,
					kHIToolbarItemIsSeparator,
					kHIToolbarItemSendCmdToUserFocus };
			ACFXMLIterator iter2(iter.Tree(),true);
			int i;
			
			for (; iter2; ++iter2) {
				for (i = 0; i < kAttrCount; i++)
					if (iter2.IsNodeType(kAttrStrings[i]))
						mOptions += kAttrBits[i];
			}
		}
	}
}

// ---------------------------------------------------------------------------

IconRef
AAutoToolbarDelegate::ItemSettings::Icon() const
{
	IconRef icon = NULL;
	CThrownOSErr err;
	
	if ((mIconCreator != 0) && (mIconType != 0))
		err = ::GetIconRef(kOnSystemDisk,mIconCreator,mIconType,&icon);
	return icon;
}

// ---------------------------------------------------------------------------

void
AAutoToolbarDelegate::ItemSettings::GetFourByteValue(
		const ACFString &inString,
		UInt32 &outValue)
{
	CFIndex usedLen;
	
	inString.GetBytes(
			CFRangeMake(0,4),kCFStringEncodingMacRoman,
			'.',false,
			(UInt8*)&outValue,4,usedLen);
}

// ---------------------------------------------------------------------------
