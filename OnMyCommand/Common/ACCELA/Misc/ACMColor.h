// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(ApplicationServices,CMApplication.h)
#include FW(Carbon,ColorPicker.h)

class ACMColor :
		public CMColor
{
public:
		ACMColor(
				const RGBColor &inRGB)
		: mColorSpace(cmRGBSpace)
		{
			rgb.red = inRGB.red;
			rgb.green = inRGB.green;
			rgb.blue = inRGB.blue;
		}
		ACMColor(
				const HSVColor &inHSV)
		: mColorSpace(cmHSVSpace)
		{
			hsv.hue = inHSV.hue;
			hsv.saturation = inHSV.saturation;
			hsv.value = inHSV.value;
		}
	
	RGBColor
		MakeRGBColor() const;
	HSVColor
		MakeHSVColor() const;
	
protected:
	UInt16 mColorSpace;
};
