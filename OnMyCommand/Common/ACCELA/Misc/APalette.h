// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"

#include "Palettes.h"

class APalette :
		public XWrapper<PaletteHandle>
{
public:
		// PaletteHandle
		APalette(
				PaletteHandle inPalette,
				bool inDoDispose = false)
		: XWrapper(inPalette,inDoDispose) {}
		// Color table
		APalette(
				short inEntries,
				CTabHandle inSrcColors,
				short inSsrcUsage,
				short inSrcTolerance);
		// Resource
		APalette(
				ResID inPaletteID);
		// Window
		APalette(
				WindowRef inWindow);
	
	RGBColor
		EntryColor(
				short inSourceEntry) const;
	void
		GetEntryColor(
				short inSourceEntry,
				RGBColor &outColor) const;
	void
		SetEntryColor(
				short inSourceEntry,
				const RGBColor &inColor);
	
	UInt16
		Count() const;
};

inline
APalette::APalette(
		short inEntries,
		CTabHandle inSrcColors,
		short inSrcUsage,
		short inSrcTolerance)
: XWrapper(::NewPalette(inEntries,inSrcColors,inSrcUsage,inSrcTolerance),true) {}

inline
APalette::APalette(
		ResID inPaletteID)
: XWrapper(::GetNewPalette(inPaletteID),true) {}

inline
APalette::APalette(
		WindowRef inWindow)
: XWrapper(::GetPalette(inWindow),false) {}

inline RGBColor
APalette::EntryColor(
		short inSourceEntry) const
{
	RGBColor rgb;
	::GetEntryColor(*this,inSourceEntry,&rgb);
	return rgb;
}

inline void
APalette::GetEntryColor(
		short inSourceEntry,
		RGBColor &outColor) const
{
	::GetEntryColor(*this,inSourceEntry,&outColor);
}

inline UInt16
APalette::Count() const
{
	return ::GetHandleSize((Handle)mObject)/16 - 1;
}

inline void
XWrapper<PaletteHandle>::DisposeSelf()
{
	::DisposePalette(mObject);
}
