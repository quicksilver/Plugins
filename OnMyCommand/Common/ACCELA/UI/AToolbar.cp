#include "AToolbar.h"
#include "ACFArray.h"

#if TARGET_RT_MAC_CFM
#include "GetCarbonFunction.h"
#endif

// ---------------------------------------------------------------------------

AToolbar::Item::Item(
		CFStringRef inIdentifier,
		OptionBits inOptions,
		CFStringRef inText,
		MenuCommand inCommandID,
		IconRef inIcon)
: AView(MakeItemRef(inIdentifier,inOptions),false)
{
	SetLabel(inText);
	SetCommandID(inCommandID);
	SetIconRef(inIcon);
}

// ---------------------------------------------------------------------------

OSStatus
AToolbar::Item::HandleEvent(
		const ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	if (inEvent.Class() == kEventClassToolbarItem)
		switch (inEvent.Kind()) {
			
			case kEventToolbarItemImageChanged:
				outEventHandled = ImageChanged();
				break;
			
			case kEventToolbarItemLabelChanged:
				outEventHandled = LabelChanged();
				break;
			
			case kEventToolbarItemHelpTextChanged:
				outEventHandled = HelpTextChanged();
				break;
			
			case kEventToolbarItemCommandIDChanged:
				outEventHandled = CommandIDChanged();
				break;
			
			case kEventToolbarItemGetPersistentData:
				outEventHandled = GetPersistentData();
				break;
			
			case kEventToolbarItemCreateCustomView:
				outEventHandled = CreateCustomView();
				break;
			
			case kEventToolbarItemEnabledStateChanged:
				outEventHandled = EnabledStateChanged();
				break;
			
			case kEventToolbarItemPerformAction:
				outEventHandled = PerformAction();
				break;
		}
	return noErr;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
AToolbar::Delegate::SetUpHandler()
{
	static const EventTypeSpec kEventTypes[] = {
			{ kEventClassToolbar,kEventToolbarGetDefaultIdentifiers },
			{ kEventClassToolbar,kEventToolbarGetAllowedIdentifiers },
			{ kEventClassToolbar,kEventToolbarCreateItemWithIdentifier },
			{ kEventClassToolbar,kEventToolbarCreateItemFromDrag } };
	
	mTypes.AddTypes(kEventTypes,sizeof(kEventTypes)/sizeof(EventTypeSpec));
}

// ---------------------------------------------------------------------------

OSStatus
AToolbar::Delegate::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	outEventHandled = false;
	if (inEvent.Class() == kEventClassToolbar) {
		switch (inEvent.Kind()) {
			
			case kEventToolbarGetDefaultIdentifiers:
				{
					ACFMutableArray defaults(AEventParameter<CFMutableArrayRef>(inEvent,kEventParamMutableArray));
					
					outEventHandled = GetDefaultIdentifiers(defaults);
				}
				break;
			
			case kEventToolbarGetAllowedIdentifiers:
				{
					ACFMutableArray allowed(AEventParameter<CFMutableArrayRef>(inEvent,kEventParamMutableArray));
					
					outEventHandled = GetAllowedIdentifiers(allowed);
				}
				break;
			
			case kEventToolbarCreateItemWithIdentifier:
				{
					AEventParameter<CFTypeRef>
							configData(inEvent,kEventParamToolbarItemConfigData,typeCFTypeRef);
					AEventParameter<HIToolbarItemRef,AWriteOnly>
							toolbarItem(inEvent,kEventParamToolbarItem,typeHIToolbarItemRef);
					ACFString
							identifier(AEventParameter<CFStringRef>(inEvent,kEventParamToolbarItemIdentifier));
					
					outEventHandled = CreateItemWithIdentifier(
							identifier,configData,toolbarItem);
				}
				break;
			
			case kEventToolbarCreateItemFromDrag:
				outEventHandled = CreateItemFromDrag(AEventParameter<DragRef>(inEvent,kEventParamDragRef));
				break;
		}
	}
	return noErr;
}

// ---------------------------------------------------------------------------
#if TARGET_RT_MAC_CFM

typedef OSStatus (*HITCPtr)(CFStringRef,OptionBits,HIToolbarRef*);

OSStatus 
HIToolbarCreate(
		CFStringRef     inIdentifier,
		OptionBits      inAttributes,
		HIToolbarRef *  outToolbar)
{
	static HITCPtr HITC = (HITCPtr)GetCarbonFunction(CFSTR("HIToolbarCreate"));
	
	if (HITC != NULL)
		return *HITC(inIdentifier,inAttributes,outToolbar);
	else
		return -1;
}

#endif
