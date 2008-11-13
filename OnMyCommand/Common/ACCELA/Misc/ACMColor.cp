// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACMColor.h"

// ---------------------------------------------------------------------------

RGBColor
ACMColor::MakeRGBColor() const
{
	RGBColor c;
	
	if (mColorSpace == cmRGBSpace) {
		c.red   = rgb.red;
		c.green = rgb.green;
		c.blue  = rgb.blue;
	}
	else {
		CMColor convertedColor;
		
		switch (mColorSpace) {
			
			case cmHSVSpace:
				::CMConvertHSVToRGB(this,&convertedColor,1);
				break;
		}
		c.red   = convertedColor.rgb.red;
		c.green = convertedColor.rgb.green;
		c.blue  = convertedColor.rgb.blue;
	}
	return c;
}

// ---------------------------------------------------------------------------

HSVColor
ACMColor::MakeHSVColor() const
{
	HSVColor c;
	
	if (mColorSpace == cmHSVSpace) {
		c.hue       = hsv.hue;
		c.saturation = hsv.saturation;
		c.value      = hsv.value;
	}
	else {
		CMColor convertedColor;
		
		switch (mColorSpace) {
			
			case cmRGBSpace:
				::CMConvertRGBToHSV(this,&convertedColor,1);
				break;
		}
		c.hue       = convertedColor.hsv.hue;
		c.saturation = convertedColor.hsv.saturation;
		c.value      = convertedColor.hsv.value;
	}
	return c;
}
