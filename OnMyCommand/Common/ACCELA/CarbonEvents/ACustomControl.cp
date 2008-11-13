// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACustomControl.h"

const UInt32 kControlEvents[] = {
		kEventControlInitialize,
		kEventControlDispose,
		kEventControlGetOptimalBounds,
		kEventControlDefInitialize,
		kEventControlDefDispose,
		kEventControlHit,
		kEventControlSimulateHit,
		kEventControlHitTest,
		kEventControlDraw,
		kEventControlApplyBackground,
		kEventControlApplyTextColor,
		kEventControlSetFocusPart,
		kEventControlGetFocusPart,
		kEventControlActivate,
		kEventControlDeactivate,
		kEventControlSetCursor,
		kEventControlContextualMenuClick,
		kEventControlClick,
		kEventControlTrack,
		kEventControlGetScrollToHereStartPoint,
		kEventControlGetIndicatorDragConstraint,
		kEventControlIndicatorMoved,
		kEventControlGhostingFinished,
		kEventControlGetActionProcPart,
		kEventControlGetPartRegion,
		kEventControlGetPartBounds,
		kEventControlSetData,
		kEventControlGetData,
		kEventControlValueFieldChanged,
		kEventControlAddedSubControl,
		kEventControlRemovingSubControl,
		kEventControlBoundsChanged,
		kEventControlOwningWindowChanged,
		kEventControlArbitraryMessage };

// ---------------------------------------------------------------------------

ACustomControl::ACustomControl(
	  WindowRef inOwningWindow,
	  const Rect &inBounds,
	  Collection inData)
: AControlHandler(NULL)
{
	ACustomControl *me = this;
	ControlDefSpec defSpec;
	
	MakeObjectClass(sObjectClass);
	
	defSpec.defType = kControlDefObjectClass;
	defSpec.u.classRef = GetObjectClass()->GetClassRef();
	
	::CreateCustomControl(inOwningWindow,&inBounds,&defSpec,inData,&mControlRef);
	::SetControlProperty(mControlRef,'ACEL','obj ',sizeof(me),&me);
	
	// set the event handler for AControlHandler
}

// ---------------------------------------------------------------------------

EventTypeSpec*
ACustomControl::GetEventTypes()
{
	EventTypeSpec *types;
	short i,typeCount;
	
	typeCount = sizeof(kControlEvents)/sizeof(UInt32);
	types = (EventTypeSpec*) ::NewPtr(sizeof(EventTypeSpec) * typeCount);
	for (i = 0; i < typeCount; i++) {
		types[i].eventClass = kEventClassControl;
		types[i].eventKind = kControlEvents[i];
	}
	return types;
}

// ---------------------------------------------------------------------------

EventTargetRef
ACustomControl::GetEventTarget() const
{
	return ::GetControlEventTarget(mControlRef);
}

// ---------------------------------------------------------------------------

OSStatus
ACustomControl::HandleEvent(
		ACarbonEvent inEvent,
		bool &outEventHandled)
{
	ControlPartCode partCode;
	ControlRef subControl;
	Point mouse;
	UInt32 modifiers,attributes;
	RgnHandle region;
	Rect bounds;
	ResType dataTag;
	Ptr buffer;
	Size bufferSize;
	
	outEventHandled = false;
	if (inEvent.Class() == kEventClassControl)
		switch (inEvent.Kind()) {

			case kEventControlInitialize: {
				Collection initCollection;
				
				inEvent.GetParameter(kEventParamInitCollection,typeCollection,initCollection);
				outEventHandled = Initialize(initColletion);
				break;
			}
			
			case kEventControlDispose:
				outEventHandled = Dispose();
				break;
				
			case kEventControlGetOptimalBounds: {
				short baseline;
				bool hasOffset;
				
				outEventHandled = GetOptimalBounds(bounds,baseline,hasOffset);
				if (outEventHandled) {
					inEvent.SetParameter(kEventParamControlOptimalBounds,typeQDRectangle,bounds);
					if (hasOffset)
						inEvent.SetParameter(kEventParamControlOptimalBaselineOffset,typeShortInteger,baseline);
				}
				break;
			}
			
			case kEventControlHit:
				inEvent.GetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				inEvent.GetParameter(kEventParamKeyModifiers,typeUInt32,modifiers);
				outEventHandled = Hit(partCode,modifiers);
				break;
				
			case kEventControlSimulateHit:
				outEventHandled = SimulateHit();
				break;
			
			case kEventControlHitTest:
				inEvent.GetParameter(kEventParamMouseLocation,typeQDPoint,mouse);
				outEventHandled = HitTest(mouse,partCode);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				break;
				
			case kEventControlDraw:
				outEventHandled = Draw();
				break;
			
			case kEventControlApplyBackground: {
				short bgDepth;
				Boolean bgColor;
				
				inEvent.GetParameter(kEventParamControlSubControl,typeControlRef,subControl);
				inEvent.GetParameter(kEventParamControlDrawDepth,typeShortInteger,bgDepth);
				inEvent.GetParameter(kEventParamControlDrawInColor,typeBoolean,bgColor);
				outEventHandled = ApplyBackground(subControl,bgDepth,bgColor);
				break;
			}
			
			case kEventControlApplyTextColor: {
				short bcDepth;
				Boolean bcColor;
				
				inEvent.GetParameter(kEventParamControlSubControl,typeControlRef,subControl);
				inEvent.GetParameter(kEventParamControlDrawDepth,typeShortInteger,bgDepth);
				inEvent.GetParameter(kEventParamControlDrawInColor,typeBoolean,bgColor);
				outEventHandled = ApplyTextColor(subControl,bgDepth,bgColor);
				break;
			}
			
			case kEventControlSetFocusPart:
				inEvent.GetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				outEventHandled = SetFocusPart(partCode);
				break;
			
			case kEventControlGetFocusPart:
				outEventHandled = GetFocusPart(partCode);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				break;
			
			case kEventControlActivate:
				outEventHandled = Activate();
				break;
			
			case kEventControlDeactivate:
				outEventHandled = Deactivate();
				break;
			
			case kEventControlSetCursor:
				inEvent.GetParameter(kEventParamMouseLocation,typeQDPoint,mouse);
				inEvent.GetParameter(kEventParamKeyModifiers,typeUInt32,modifiers);
				outEventHandled = SetCursor(mouse,modifiers);
				break;
				
			case kEventControlContextualMenuClick:
				inEvent.GetParameter(kEventParamMouseLocation,typeQDPoint,mouse);
				outEventHandled = ContextualMenuClick(mouse);
				break;
			
			case kEventControlClick:
				// ?
				break;
			
			case kEventControlTrack:
				inEvent.GetParameter(kEventParamMouseLocation,typeQDPoint,mouse);
				inEvent.GetParameter(kEventParamKeyModifiers,typeUInt32,modifiers);
				outEventHandled = Track(mouse,modifiers,partCode);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				break;
			
			case kEventControlGetScrollToHereStartPoint:
				inEvent.GetParameter(kEventParamMouseLocation,typeQDPoint,mouse);
				inEvent.GetParameter(kEventParamKeyModifiers,typeUInt32,modifiers);
				outEventHandled = GetScrollToHereStartPoint(mouse,modifiers);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamMouseLocation,typeQDPoint,mouse);
				break;
			
			case kEventControlGetIndicatorDragConstraint: {
				IndicatorDragConstraint constraint;
				
				inEvent.GetParameter(kEventParamMouseLocation,typeQDPoint,mouse);
				inEvent.GetParameter(kEventParamKeyModifiers,typeUInt32,modifiers);
				outEventHandled = GetIndicatorDragConstraint(mouse,modifiers,constraint);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlIndicatorDragConstraint,typeIndicatorDragConstraint,constraint);
				break;
			}
			
			case kEventControlIndicatorMoved: {
				Boolean isGhosting;
				
				inEvent.GetParameter(kEventParamControlIndicatorRegion,typeQDRgnHandle,region);
				inEvent.GetParameter(kEventParamControlIsGhosting,typeBoolean,isGhosting);
				outEventHandled = IndicatorMoved(region,isGhosting);
				break;
			}
				
			case kEventControlGhostingFinished:
				inEvent.GetParameter(kEventParamControlIndicatorOffset,typeQDPoint,mouse);
				outEventHandled = GhostingFinished(mouse);
				break;
			
			case kEventControlGetActionProcPart:
				inEvent.GetParameter(kEventParamKeyModifiers,typeUInt32,modifiers);
				inEvent.GetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				outEventHandled = GetActionProcPart(modifiers,partCode);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				break;
			
			case kEventControlGetPartRegion:
				inEvent.GetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				inEvent.GetParameter(kEventParamControlRegion,typeQDRgnHandle,region);
				outEventHandled = GetPartRegion(partCode,region);
				break;
			
			case kEventControlGetPartBounds:
				inEvent.GetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				outEventHandled = GetPartBounds(partCode,bounds);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlPartBounds,typeQDRectangle,bounds);
				break;
			
			case kEventControlSetData:
				inEvent.GetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				inEvent.GetParameter(kEventParamControlDataTag,typeEnumeration,dataTag);
				inEvent.GetParameter(kEventParamControlDataBuffer,typePtr,buffer);
				inEvent.GetParameter(kEventParamControlDataBufferSize,typeLongInteger,bufferSize);
				outEventHandled = SetData(partCode,dataTag,buffer,bufferSize);
				break;
			
			case kEventControlGetData:
				inEvent.GetParameter(kEventParamControlPart,typeControlPartCode,partCode);
				inEvent.GetParameter(kEventParamControlDataTag,typeEnumeration,dataTag);
				inEvent.GetParameter(kEventParamControlDataBuffer,typePtr,buffer);
				inEvent.GetParameter(kEventParamControlDataBufferSize,typeLongInteger,bufferSize);
				outEventHandled = SetData(partCode,dataTag,buffer,bufferSize);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlDataBufferSize,typeLongInteger,bufferSize);
				break;
			
			case kEventControlValueFieldChanged:
				outEventHandled = ValueFieldChanged();
				break;
			
			case kEventControlAddedSubControl:
				inEvent.GetParameter(kEventParamControlSubControl,typeControlRef,subControl);
				outEventHandled = AddedSubControl(subControl);
				break;
			
			case kEventControlRemovingSubControl:
				inEvent.GetParameter(kEventParamControlSubControl,typeControlRef,subControl);
				outEventHandled = RemovingSubControl(subControl);
				break;
			
			case kEventControlBoundsChanged: {
				Rect originalBounds,previousBounds;
				
				inEvent.GetParameter(kEventParamAttributes,typeUInt32,attributes);
				inEvent.GetParameter(kEventParamOriginalBounds,typeQDRectangle,originalBounds);
				inEvent.GetParameter(kEventParamPreviousBounds,typeQDRectangle,previousBounds);
				inEvent.GetParameter(kEventParamCurrentBounds,typeQDRectangle,bounds);
				outEventHandled = BoundsChanged(attributes,originalBounds,previousBounds,bounds);
				break;
			}
			
			case kEventControlOwningWindowChanged: {
				WindowRef originalWindow,currentWindow;
				
				inEvent.GetParameter(kEventParamAttributes,typeUInt32,attributes);
				inEvent.GetParameter(kEventParamControlOriginalOwningWindow,typeWindowRef,originalWindow);
				inEvent.GetParameter(kEventParamControlCurrentOwningWindow,typeWindowRef,currentWindow);
				outEventHandled = OwningWindowChanged(attributes,originalWindow,currentWindow);
				break;
			}
				
			case kEventControlArbitraryMessage: {
				short message;
				long param,messageResult;
				
				inEvent.GetParameter(kEventParamControlMessage,typeShortInteger,message);
				inEvent.GetParameter(kEventParamControlParam,typeLongInteger,param);
				outEventHandled = ArbitraryMessage(message,param,messageResult);
				if (outEventHandled)
					inEvent.SetParameter(kEventParamControlResult,typeLongInteger,messageResult);
				break;
			}
		}
	
	return noErr;
}
