#include "AAutoSizer.h"
#include "ACarbonEvent.h"
#include "AControl.h"
#include "XSystem.h"

// ---------------------------------------------------------------------------

AAutoSizer::AAutoSizer(
		WindowRef inWindow)
: mWindow(inWindow)
{
	InstallHandler(inWindow);
	AddType(kEventClassWindow,kEventWindowBoundsChanged);
}

// ---------------------------------------------------------------------------

bool
AAutoSizer::BoundsChanged(
		UInt32,
		const Rect &,
		const Rect &inPreviousBounds,
		const Rect &inCurrentBounds)
{
	AControl rootControl(mWindow);
	SInt16 heightD = (inCurrentBounds.bottom-inCurrentBounds.top)-(inPreviousBounds.bottom-inPreviousBounds.top);
	SInt16 widthD = (inCurrentBounds.right-inCurrentBounds.left)-(inPreviousBounds.right-inPreviousBounds.left);
	
	AutoSizeControl(rootControl,heightD,widthD);
	return true;
}

// ---------------------------------------------------------------------------

void
AAutoSizer::AutoSizeControl(
		AControl &inControl,
		SInt16 inHeightD,
		SInt16 inWidthD)
{
	AControl::Iterator iter(inControl.SubBegin());
	
	for (; iter != inControl.SubEnd(); ++iter) {
		if (!(*iter).HasProperty('ACEL','bind')) continue;
		
		UInt32 binding = (*iter).Property<UInt32>('ACEL','bind');
		SInt32
				widthD  = 0,
				heightD = 0,
				horizD  = 0,
				vertD   = 0;
		
		if (binding & bind_Right) {
			if (binding & bind_Left)
				widthD = inWidthD;
			else
				horizD = inWidthD;
		}
		if (binding & bind_Bottom) {
			if (binding & bind_Top)
				heightD = inHeightD;
			else
				vertD = inHeightD;
		}
		
		Rect subBounds = (*iter).Bounds();
		bool doResize = false;
		
		if ((horizD != 0) || (vertD != 0)) {
			(*iter).Move(subBounds.left+horizD,subBounds.top+vertD);
			doResize = true;
		}
		if ((widthD != 0) || (heightD != 0)) {
			(*iter).SetSize(
					(subBounds.right-subBounds.left)+widthD,
					(subBounds.bottom-subBounds.top)+heightD);
			doResize = true;
		}
		
		// If we're not in OS X, the bounds changed event
		// needs to be sent manually
		if (doResize && (XSystem::OSVersion() < 0x1000)) {
			ACarbonEvent resizeEvent(kEventClassControl,kEventControlBoundsChanged);
			UInt32 attributes = 0;
			
			if ((horizD != 0) || (vertD != 0))
				attributes += kControlBoundsChangePositionChanged;
			if ((widthD != 0) || (heightD != 0))
				attributes += kControlBoundsChangeSizeChanged;
			
			// too hard to keep track of the original bounds,
			// so just make it the same as the previous bounds
			Rect newBounds = inControl.Bounds();
			
			resizeEvent.SetParameter(kEventParamDirectObject,typeControlRef,inControl.Get());
			resizeEvent.SetParameter(kEventParamAttributes,typeUInt32,attributes);
			resizeEvent.SetParameter(kEventParamOriginalBounds,typeQDRectangle,subBounds);
			resizeEvent.SetParameter(kEventParamPreviousBounds,typeQDRectangle,subBounds);
			resizeEvent.SetParameter(kEventParamCurrentBounds,typeQDRectangle,newBounds);
			resizeEvent.SendTo(inControl);
		}
		
		if (doResize) {
			AControl subControl(*iter);
			
			if (subControl.CountSubControls() > 0)
				AutoSizeControl(subControl,heightD,widthD);
		}
	}
}
