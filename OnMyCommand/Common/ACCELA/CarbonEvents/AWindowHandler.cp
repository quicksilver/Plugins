// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AWindowHandler.h"
#include "AEventParameter.h"

// ---------------------------------------------------------------------------

AWindowHandler::AWindowHandler(
		WindowRef inWindow)
: AEventObject(inWindow)
{
}

// ---------------------------------------------------------------------------

OSStatus
AWindowHandler::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	outEventHandled = false;
	if (inEvent.Class() == kEventClassWindow)
		switch (inEvent.Kind()) {
			
			case kEventWindowUpdate:
				outEventHandled = Update();
				break;
			
			case kEventWindowDrawContent:
				outEventHandled = DrawContent();
				break;
			
			case kEventWindowActivated:
				outEventHandled = Activated();
				break;
			
			case kEventWindowDeactivated:
				outEventHandled = Deactivated();
				break;
			
			case kEventWindowClickDragRgn:
				outEventHandled = ClickDrag(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickCollapseRgn:
				outEventHandled = ClickCollapse(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickCloseRgn:
				outEventHandled = ClickClose(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickZoomRgn:
				outEventHandled = ClickZoom(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickProxyIconRgn:
				outEventHandled = ClickProxyIcon(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickToolbarButtonRgn:
				outEventHandled = ClickToolbarButton(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickStructureRgn:
				outEventHandled = ClickStructure(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickContentRgn:
				outEventHandled = ClickContent(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowClickResizeRgn:
				outEventHandled = ClickResize(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowGetClickActivation:
				{
					AParam<AWriteOnly>::ClickActivation activation(inEvent);
					
					outEventHandled = GetClickActivation(
							AParam<>::Mouse(inEvent),
							AParam<>::Modifiers(inEvent),
							activation);
				}
				break;
			
			case kEventWindowHandleContentClick:
				outEventHandled = ContentClick(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowShown:
				outEventHandled = Shown();
				break;
			
			case kEventWindowHidden:
				outEventHandled = Hidden();
				break;
			
			case kEventWindowBoundsChanging: {
				{
					ATypeParam<AReadWrite>::Rect currentBounds(inEvent,kEventParamCurrentBounds);
					
					outEventHandled = BoundsChanging(
							AParam<>::Attributes(inEvent),
							ATypeParam<>::Rect(inEvent,kEventParamOriginalBounds),
							ATypeParam<>::Rect(inEvent,kEventParamPreviousBounds),
							currentBounds);
				}
				break;
			}
			
			case kEventWindowBoundsChanged:
				outEventHandled = BoundsChanged(
						AParam<>::Attributes(inEvent),
						ATypeParam<>::Rect(inEvent,kEventParamOriginalBounds),
						ATypeParam<>::Rect(inEvent,kEventParamPreviousBounds),
						ATypeParam<>::Rect(inEvent,kEventParamCurrentBounds));
				break;
			
			case kEventWindowResizeStarted:
				outEventHandled = ResizeStarted();
				break;
			
			case kEventWindowResizeCompleted:
				outEventHandled = ResizeCompleted();
				break;
			
			case kEventWindowDragStarted:
				outEventHandled = DragStarted();
				break;
			
			case kEventWindowDragCompleted:
				outEventHandled = DragCompleted();
				break;
			
			case kEventWindowCursorChange:
				outEventHandled = CursorChange(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowCloseAll:
				outEventHandled = CloseAll();
				break;
			
			case kEventWindowZoomAll:
				outEventHandled = ZoomAll();
				break;
			
			case kEventWindowCollapseAll:
				outEventHandled = CollapseAll();
				break;
			
			case kEventWindowCollapse:
				outEventHandled = Collapse();
				break;
			
			case kEventWindowCollapsed:
				outEventHandled = Collapsed();
				break;
			
			case kEventWindowExpand:
				outEventHandled = Expand();
				break;
			
			case kEventWindowExpanded:
				outEventHandled = Expanded();
				break;
			
			case kEventWindowClose:
				outEventHandled = Close();
				break;
			
			case kEventWindowClosed:
				outEventHandled = Closed();
				break;
			
			case kEventWindowZoom:
				outEventHandled = Zoom();
				break;
			
			case kEventWindowZoomed:
				outEventHandled = Zoomed();
				break;
			
			case kEventWindowContextualMenuSelect:
				outEventHandled = ContextualMenuSelect(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventWindowPathSelect:
				outEventHandled = PathSelect();
				break;
			
			case kEventWindowGetIdealSize:
				{
					AParam<AWriteOnly>::Dimensions windowSize(inEvent);
					
					outEventHandled = GetIdealSize(windowSize);
				}
				break;
			
			case kEventWindowGetMinimumSize:
				{
					AParam<AWriteOnly>::Dimensions windowSize(inEvent);
					
					outEventHandled = GetMinimumSize(windowSize);
				}
				break;
			
			case kEventWindowGetMaximumSize:
				{
					AParam<AWriteOnly>::Dimensions windowSize(inEvent);
					
					outEventHandled = GetMaximumSize(windowSize);
				}
				break;
			
			// Gimme some mouse info!
			case kEventWindowProxyBeginDrag:
				outEventHandled = ProxyBeginDrag(AParam<>::Drag(inEvent));
				break;
			
			case kEventWindowProxyEndDrag:
				outEventHandled = ProxyEndDrag();
				break;
			
			case kEventWindowFocusAcquired:
				outEventHandled = FocusAcquired();
				break;
			
			case kEventWindowFocusRelinquish:
				outEventHandled = FocusRelinquish();
				break;
			
			case kEventWindowToolbarSwitchMode:
				outEventHandled = SwitchToolbarMode();
				break;
	}
	return noErr;
}
