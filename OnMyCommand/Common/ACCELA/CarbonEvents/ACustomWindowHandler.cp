// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACustomWindowHandler.h"
#include "AEventParameter.h"

// ---------------------------------------------------------------------------

OSStatus
ACustomWindowHandler::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	OSStatus err = noErr;
	
	outEventHandled = false;
	if (inEvent.Class() == kEventClassWindow)
		switch (inEvent.Kind()) {
			
			case kEventWindowInit:
				outEventHandled = Init(
						ATypeParam<>::UInt32(inEvent,kEventParamWindowFeatures));
				break;
			
			case kEventWindowDispose:
				outEventHandled = Dispose();
				break;
			
			case kEventWindowDrawFrame:
				outEventHandled = DrawFrame();
				break;
			
			case kEventWindowDrawPart:
				outEventHandled = DrawPart(
						AParam<>::WindowPart(inEvent));
				break;
			
			case kEventWindowGetRegion:
				outEventHandled = GetRegion(
						AParam<>::WindowRegion(inEvent),
						ATypeParam<>::RgnHandle(inEvent,kEventParamRgnHandle));
				break;
			
			case kEventWindowHitTest:
				{
					AParam<AWriteOnly>::WindowPart hitPart(inEvent);
					
					outEventHandled = HitTest(
							AParam<>::Mouse(inEvent),
							hitPart);
				}
				break;
			
			case kEventWindowDragHilite:
				outEventHandled = DragHilite(
						ATypeParam<>::Boolean(inEvent,kEventParamWindowDragHiliteFlag));
				break;
			
			case kEventWindowModified:
				outEventHandled = Modified(
						ATypeParam<>::Boolean(inEvent,kEventParamWindowModifiedFlag));
				break;
			
			case kEventWindowSetupProxyDragImage:
				{
					ATypeParam<AWriteOnly>::GWorldPtr imageGWorld(inEvent,kEventParamWindowProxyGWorldPtr);
					
					outEventHandled = SetupProxyDragImage(
							ATypeParam<>::RgnHandle(inEvent,kEventParamWindowProxyImageRgn),
							ATypeParam<>::RgnHandle(inEvent,kEventParamWindowProxyOutlineRgn),
							imageGWorld);
				}
				break;
			
			case kEventWindowStateChanged:
				outEventHandled = StateChanged(
						ATypeParam<>::UInt32(inEvent,kEventParamWindowStateChangedFlags));
				break;
			
			case kEventWindowMeasureTitle: {
				{
					ATypeParam<AWriteOnly>::SInt16 fullWidth(inEvent,kEventParamWindowTitleFullWidth);
					ATypeParam<AWriteOnly>::SInt16 textWidth(inEvent,kEventParamWindowTitleTextWidth);
				
					outEventHandled = MeasureTitle(fullWidth,textWidth);
				}
				break;
			}
			
			case kEventWindowDrawGrowBox:
				outEventHandled = DrawGrowBox();
				break;
			
			case kEventWindowGetGrowImageRegion:
				outEventHandled = GetGrowImageRegion(
						ATypeParam<>::Rect(inEvent,kEventParamWindowGrowRect),
						ATypeParam<>::RgnHandle(inEvent,kEventParamRgnHandle));
				break;
			
			case kEventWindowPaint:
				outEventHandled = Paint();
				break;
			
			default:
				err = AWindowHandler::HandleEvent(inEvent,outEventHandled);
				break;
	}
	return err;
}
