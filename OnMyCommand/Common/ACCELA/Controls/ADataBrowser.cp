// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ADataBrowser.h"
#include "XSystem.h"

// ---------------------------------------------------------------------------

ADataBrowser::~ADataBrowser()
{
	// prevent callbacks from going through
	try {
		RemoveProperty('ACEL','obj ');
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------

#define DBUPP_(_name_) \
	static DataBrowser##_name_##UPP _name_##UPP = NewDataBrowser##_name_##UPP(_name_##Callback);

void
ADataBrowser::InstallCallbacks()
{
	DataBrowserCallbacks callbacks;
	
	callbacks.version = kDataBrowserLatestCallbacks;
	
	DBUPP_(ItemData);
	DBUPP_(ItemCompare);
	DBUPP_(ItemNotificationWithItem);
	DBUPP_(AddDragItem);
	DBUPP_(AcceptDrag);
	DBUPP_(ReceiveDrag);
	DBUPP_(PostProcessDrag);
	DBUPP_(ItemHelpContent);
	DBUPP_(GetContextualMenu);
	DBUPP_(SelectContextualMenu);
	
	// if only macros could deal with capitalization...
	callbacks.u.v1.itemDataCallback = ItemDataUPP;
	callbacks.u.v1.itemCompareCallback = ItemCompareUPP;
	callbacks.u.v1.itemNotificationCallback = (DataBrowserItemNotificationUPP)ItemNotificationWithItemUPP;
	callbacks.u.v1.addDragItemCallback = AddDragItemUPP;
	callbacks.u.v1.acceptDragCallback = AcceptDragUPP;
	callbacks.u.v1.receiveDragCallback = ReceiveDragUPP;
	callbacks.u.v1.postProcessDragCallback = PostProcessDragUPP;
	callbacks.u.v1.itemHelpContentCallback = ItemHelpContentUPP;
	callbacks.u.v1.getContextualMenuCallback = GetContextualMenuUPP;
	callbacks.u.v1.selectContextualMenuCallback = SelectContextualMenuUPP;
	
	::SetDataBrowserCallbacks(*this,&callbacks);
	SetProperty('ACEL','obj ',this);
}

// ---------------------------------------------------------------------------

ADataBrowser*
ADataBrowser::GetBrowserObject(
		const AControl &inControl)
{
	ADataBrowser *browserObject = NULL;
	
	if (inControl.HasProperty('ACEL','obj '))
		inControl.GetProperty('ACEL','obj ',browserObject);
	
	return browserObject;
}

// ---------------------------------------------------------------------------

pascal void
ADataBrowser::ItemNotificationWithItemCallback(
		ControlRef inBrowser,
		DataBrowserItemID inItem,
		DataBrowserItemNotification inMessage,
		DataBrowserItemDataRef inItemData)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	
	if (browserObject != NULL) try {
		if (XSystem::OSVersion() < 0x1000)
			inItemData = NULL;
		
		Item item(*browserObject,inItem);
		ItemData itemData(inItemData);
		
		browserObject->ItemNotification(item,inMessage,itemData);
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------

pascal OSStatus
ADataBrowser::ItemDataCallback(
		ControlRef inBrowser,
		DataBrowserItemID inItem,
		DataBrowserPropertyID inProperty,
		DataBrowserItemDataRef inItemData,
		Boolean inSetValue)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	OSStatus err = noErr;
	
	if (browserObject != NULL) try {
		Item item(*browserObject,inItem);
		ItemData itemData(inItemData);
		
		if (inSetValue)
			err = browserObject->SetItemData(item,inProperty,itemData);
		else
			err = browserObject->GetItemData(item,inProperty,itemData);
	}
	catch (OSStatus caughtErr) {
		err = caughtErr;
	}
	catch (...) {
		err = -1;
	}
	return err;
}

// ---------------------------------------------------------------------------

pascal Boolean
ADataBrowser::ItemCompareCallback(
		ControlRef inBrowser,
		DataBrowserItemID inItemOneID, 
		DataBrowserItemID inItemTwoID,
		DataBrowserPropertyID inSortProperty)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	bool result = false;
	
	if (browserObject != NULL) try {
		Item itemOne(*browserObject,inItemOneID);
		Item itemTwo(*browserObject,inItemTwoID);
		
		result = browserObject->ItemComparison(itemOne,itemTwo,inSortProperty);
	}
	catch (...) {}
	
	return result;
}

// ---------------------------------------------------------------------------

pascal Boolean
ADataBrowser::AddDragItemCallback(
		ControlRef inBrowser,
		DragReference inDragRef,
		DataBrowserItemID inItemID,
		ItemReference *outItemRef)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	bool result = false;
	
	if (browserObject != NULL) try {
		result = browserObject->AddDragItem(inDragRef,inItemID,*outItemRef);
	}
	catch (...) {}
	
	return result;
}

// ---------------------------------------------------------------------------

pascal Boolean
ADataBrowser::AcceptDragCallback(
		ControlRef inBrowser,
		DragReference inDragRef,
		DataBrowserItemID inItemID)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	bool result = false;
	
	if (browserObject != NULL) try {
		result = browserObject->AcceptDrag(inDragRef,inItemID);
	}
	catch (...) {}
	
	return result;
}

// ---------------------------------------------------------------------------

pascal Boolean
ADataBrowser::ReceiveDragCallback(
		ControlRef inBrowser,
		DragReference inDragRef,
		DataBrowserItemID inItemID)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	bool result = false;
	
	if (browserObject != NULL) try {
		result = browserObject->ReceiveDrag(inDragRef,inItemID);
	}
	catch (...) {}
	
	return result;
}

// ---------------------------------------------------------------------------

pascal void
ADataBrowser::PostProcessDragCallback(
		ControlRef inBrowser,
		DragReference inDragRef,
		OSStatus inDragResult)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	
	if (browserObject != NULL) try {
		browserObject->PostProcessDrag(inDragRef,inDragResult);
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------

pascal void
ADataBrowser::ItemHelpContentCallback(
		ControlRef inBrowser,
		DataBrowserItemID inItemID,
		DataBrowserPropertyID inProperty,
		HMContentRequest inRequest,
		HMContentProvidedType *outContentProvided,
		HMHelpContentPtr ioHelpContent)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	
	if (browserObject != NULL) try {
		browserObject->ItemHelpContent(inItemID,inProperty,inRequest,*outContentProvided,ioHelpContent);
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------


pascal void
ADataBrowser::GetContextualMenuCallback(
		ControlRef inBrowser,
		MenuRef *ioMenu,
		UInt32 *outHelpType,
		CFStringRef *outHelpItemString,
		AEDesc *outSelection)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	
	if (browserObject != NULL) try {
		browserObject->GetContextualMenu(*ioMenu,*outHelpType,*outHelpItemString,*outSelection);
	}
	catch (...) {}
}

// ---------------------------------------------------------------------------

pascal void
ADataBrowser::SelectContextualMenuCallback(
		ControlRef inBrowser,
		MenuRef inMenu,
		UInt32 inSelectionType,
		SInt16 inMenuID,
		MenuItemIndex inMenuItem)
{
	ADataBrowser *browserObject = GetBrowserObject(inBrowser);
	
	if (browserObject != NULL) try {
		browserObject->SelectContextualMenu(inMenu,inSelectionType,inMenuID,inMenuItem);
	}
	catch (...) {}
}
