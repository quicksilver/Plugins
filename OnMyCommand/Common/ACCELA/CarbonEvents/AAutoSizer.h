#pragma once

#include "AWindowHandler.h"
#include "AWindow.h"
#include "AControl.h"

class AAutoSizer :
		public AWindowHandler
{
public:
	enum {
		bind_Top    = 0x01,
		bind_Bottom = 0x02,
		bind_Left   = 0x04,
		bind_Right  = 0x08,
		
		bind_TopBottom = bind_Top | bind_Bottom,
		bind_LeftRight = bind_Left | bind_Right,
		bind_All  = bind_TopBottom | bind_LeftRight,
		bind_None = 0
	};
	
		AAutoSizer(
				WindowRef inWindow);
	
	static void
		SetBindings(
				AControl &inControl,
				UInt32 inBindings)
		{
			inControl.SetProperty('ACEL','bind',inBindings);
		}
	
protected:
	AWindow mWindow;
	
	// AWindowHandler
	
	virtual bool
		BoundsChanged(
				UInt32,
				const Rect &inOriginalBounds,
				const Rect &inPreviousBounds,
				const Rect &inCurrentBounds);
	
	// AAutoSizer
	
	static void
		AutoSizeControl(
				AControl &inControl,
				SInt16 inHeightD,
				SInt16 inWidthD);
};
