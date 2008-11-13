#include "FontPanelFuncs.h"
#include "GetCarbonFunction.h"

// ---------------------------------------------------------------------------

typedef OSStatus (*FPSHFPPtr)();

OSStatus
FPShowHideFontPanel()
{
	static FPSHFPPtr FPSHFP = (FPSHFPPtr)GetCarbonFunction(CFSTR("FPShowHideFontPanel"));
	
	if (FPSHFP != NULL)
		return (*FPSHFP)();
	else
		return noErr;
}

// ---------------------------------------------------------------------------

typedef Boolean (*FPIFPVPtr)();

Boolean
FPIsFontPanelVisible()
{
	static FPIFPVPtr FPIFPV = (FPIFPVPtr)GetCarbonFunction(CFSTR("FPIsFontPanelVisible"));
	
	if (FPIFPV != NULL)
		return (*FPIFPV)();
	else
		return false;
}

// ---------------------------------------------------------------------------

typedef OSStatus (*SFIFSPtr)(OSType,UInt32,void*,HIObjectRef);

OSStatus
SetFontInfoForSelection(
		OSType inStyleType,
		UInt32 inNumStyles,
		void *inStyles,
		HIObjectRef inFPEventTarget)
{
	static SFIFSPtr SFIFS = (SFIFSPtr)GetCarbonFunction(CFSTR("SetFontInfoForSelection"));
	
	if (SFIFS != NULL)
		return (*SFIFS)(inStyleType,inNumStyles,inStyles,inFPEventTarget);
	else
		return noErr;
}
