// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AControlHandler.h"
#include "AEventParameter.h"

// ---------------------------------------------------------------------------

OSStatus
AControlHandler::HandleEvent(
		ACarbonEvent &inEvent,
		bool &outEventHandled)
{
	OSStatus err = noErr;
	
	if (inEvent.Class() == kEventClassControl)
		switch (inEvent.Kind()) {
			
			case kEventControlInitialize:
				outEventHandled = Initialize(
						AEventParameter<Collection>(inEvent,kEventParamInitCollection),
						ATypeParam<>::UInt32(inEvent,kEventParamControlFeatures));
				break;
			
			case kEventControlDispose:
				outEventHandled = Dispose();
				break;
			
			case kEventControlGetOptimalBounds:
				{
					ATypeParam<AWriteOnly>::Rect optimalBounds(inEvent,kEventParamControlOptimalBounds);
					ATypeParam<AWriteOnly>::SInt16 baseline(inEvent,kEventParamControlOptimalBaselineOffset);
					
					outEventHandled = GetOptimalBounds(
							optimalBounds,
							baseline);
				}
				break;
			
			case kEventControlHit:
				outEventHandled = Hit(
						AParam<>::ControlPart(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventControlSimulateHit:
				outEventHandled = SimulateHit();
				break;
			
			case kEventControlHitTest:
				{
					AParam<AWriteOnly>::ControlPart hitPart(inEvent);
					
					outEventHandled = HitTest(AParam<>::Mouse(inEvent),hitPart);
				}
				break;
			
			case kEventControlDraw:
				outEventHandled = Draw(
						AParam<>::ControlPart(inEvent),
						AParam<>::Port(inEvent));
				break;
			
			case kEventControlApplyBackground:
				outEventHandled = ApplyBackground(
						AParam<>::SubControl(inEvent),
						ATypeParam<>::SInt16(inEvent,kEventParamControlDrawDepth),
						ATypeParam<>::Boolean(inEvent,kEventParamControlDrawInColor),
						AParam<>::Port(inEvent));
				break;
			
			case kEventControlApplyTextColor:
				outEventHandled = ApplyTextColor(
						AParam<>::SubControl(inEvent),
						ATypeParam<>::SInt16(inEvent,kEventParamControlDrawDepth),
						ATypeParam<>::Boolean(inEvent,kEventParamControlDrawInColor),
						AParam<>::Context(inEvent),
						AParam<>::Port(inEvent));
				break;
			
			// Drag events require 10.2

#if UNIVERSAL_INTERFACES_VERSION > 0x0342

			case kEventControlDragEnter:
				outEventHandled = DragEnter(AParam<>::Drag(inEvent));
				break;
			
			case kEventControlDragWithin:
				outEventHandled = DragWithin(AParam<>::Drag(inEvent));
				break;
			
			case kEventControlDragLeave:
				outEventHandled = DragLeave(AParam<>::Drag(inEvent));
				break;
			
			case kEventControlDragReceive:
				outEventHandled = DragReceive(AParam<>::Drag(inEvent));
				break;
#endif

			case kEventControlSetFocusPart:
				{
					AParam<AReadWrite>::ControlPart focusPart(inEvent);
					
					outEventHandled = SetFocusPart(focusPart);
				}
				break;
			
			case kEventControlGetFocusPart:
				{
					AParam<AWriteOnly>::ControlPart focusPart(inEvent);
					
					outEventHandled = GetFocusPart(focusPart);
				}
				break;
			
			case kEventControlActivate:
				outEventHandled = Activate();
				break;
			
			case kEventControlDeactivate:
				outEventHandled = Deactivate();
				break;
			
			case kEventControlSetCursor:
				outEventHandled = SetCursor(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventControlContextualMenuClick:
				outEventHandled = ContextualMenuClick(
						AParam<>::Mouse(inEvent));
				break;
			
			case kEventControlClick:
				outEventHandled = Click(
						AParam<>::Mouse(inEvent),
						AParam<>::Modifiers(inEvent));
				break;
			
			case kEventControlTrack:
				{
					AParam<AReadWrite>::Modifiers trackMods(inEvent);
					AParam<AWriteOnly>::ControlPart trackPart(inEvent);
					
					// Skip the action UPP parameter
					outEventHandled = Track(
							AParam<>::Mouse(inEvent),
							trackMods,
							trackPart);
				}
				break;
			
			case kEventControlGetScrollToHereStartPoint:
				{
					ATypeParam<AReadWrite>::Point startPoint(inEvent,kEventParamMouseLocation);
					
					outEventHandled = GetScrollToHereStartPoint(
							startPoint,
							AParam<>::Modifiers(inEvent));
				}
				break;
			
			case kEventControlGetIndicatorDragConstraint:
				{
					AEventParameter<IndicatorDragConstraint,AWriteOnly>
							constraint(inEvent,kEventParamControlIndicatorDragConstraint);
					
					outEventHandled = GetIndicatorDragConstraint(
							AParam<>::Mouse(inEvent),
							AParam<>::Modifiers(inEvent),
							constraint);
				}
				break;
			
			case kEventControlIndicatorMoved:
				outEventHandled = IndicatorMoved(
						ATypeParam<>::RgnHandle(inEvent,kEventParamControlIndicatorRegion),
						ATypeParam<>::Boolean(inEvent,kEventParamControlIsGhosting));
				break;
			
			case kEventControlGhostingFinished:
				outEventHandled = GhostingFinished(
						ATypeParam<>::Point(inEvent,kEventParamControlIndicatorOffset));
				break;
			
			case kEventControlGetActionProcPart:
				{
					AParam<AReadWrite>::ControlPart actionProcPart(inEvent);
					
					outEventHandled = GetActionProcPart(
							AParam<>::Modifiers(inEvent),
							actionProcPart);
				}
				break;
			
			case kEventControlGetPartRegion:
				outEventHandled = GetPartRegion(
						AParam<>::ControlPart(inEvent),
						ATypeParam<>::RgnHandle(inEvent,kEventParamControlRegion));
				break;
			
			case kEventControlGetPartBounds:
				{
					ATypeParam<AWriteOnly>::Rect partBounds(inEvent,kEventParamControlPartBounds);
					
					outEventHandled = GetPartBounds(
							AParam<>::ControlPart(inEvent),
							partBounds);
				}
				break;
			
			case kEventControlSetData:
				outEventHandled = SetData(
						AParam<>::ControlPart(inEvent),
						ATypeParam<>::Enumeration(inEvent,kEventParamControlDataTag),
						ATypeParam<>::Ptr(inEvent,kEventParamControlDataBuffer),
						ATypeParam<>::SInt32(inEvent,kEventParamControlDataBufferSize));
				break;
			
			case kEventControlGetData:
				{
					ATypeParam<AReadWrite>::SInt32 dataSize(inEvent,kEventParamControlDataBufferSize);
					
					outEventHandled = GetData(
							AParam<>::ControlPart(inEvent),
							ATypeParam<>::Enumeration(inEvent,kEventParamControlDataTag),
							ATypeParam<>::Ptr(inEvent,kEventParamControlDataBuffer),
							dataSize);
				}
				break;
			
			case kEventControlValueFieldChanged:
				outEventHandled = ValueFieldChanged();
				break;
			
			case kEventControlAddedSubControl:
				outEventHandled = AddedSubControl(
						AParam<>::SubControl(inEvent));
				break;
			
			case kEventControlRemovingSubControl:
				outEventHandled = RemovingSubControl(
						AParam<>::SubControl(inEvent));
				break;
			
			case kEventControlBoundsChanged:
				outEventHandled = BoundsChanged(
						AParam<>::Attributes(inEvent),
						ATypeParam<>::Rect(inEvent,kEventParamOriginalBounds),
						ATypeParam<>::Rect(inEvent,kEventParamPreviousBounds),
						ATypeParam<>::Rect(inEvent,kEventParamCurrentBounds));
				break;
			
			case kEventControlOwningWindowChanged:
				outEventHandled = OwningWindowChanged(
						AParam<>::Attributes(inEvent),
						ATypeParam<>::WindowRef(inEvent,kEventParamControlOriginalOwningWindow),
						ATypeParam<>::WindowRef(inEvent,kEventParamControlCurrentOwningWindow));
				break;
			
			case kEventControlArbitraryMessage:
				{
					ATypeParam<AWriteOnly>::SInt32 messageResult(inEvent,kEventParamControlResult);
					
					outEventHandled = ArbitraryMessage(
							ATypeParam<>::SInt16(inEvent,kEventParamControlMessage),
							ATypeParam<>::SInt32(inEvent,kEventParamControlParam),
							messageResult);
				}
				break;
		}
	
	if (!outEventHandled)
		err = AEventObject::HandleEvent(inEvent,outEventHandled);
	
	return err;
}
