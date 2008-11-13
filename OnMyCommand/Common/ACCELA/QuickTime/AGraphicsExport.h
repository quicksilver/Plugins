// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AComponentInstance.h"

class AGraphicsExport :
		public AComponentInstance
{
public:
		AGraphicsExport(
				Component inComponent)
		: AComponentInstance(inComponent) {}
	
	unsigned long
		DoExport() const;
	
	// input
	void
		SetInput(
				PicHandle inPicture);
	void
		SetInput(
				GWorldPtr inGWorld);
	void
		SetInput(
				PixMapHandle inPixMap);
	
	// output
	void
		SetOutput(
				const FSSpec &inSpec);
	void
		SetOutput(
				Handle inDataRef,
				OSType inRefType);
	void
		SetOutput(
				Handle inHandle);
	
	// settings
	bool
		RequestSettings(
				ModalFilterYDUPP inFilter = NULL,
				void *inData = NULL);
	void
		SetSettings(
				void *inAtomContainer);
	long
		Depth() const;
	void
		SetDepth(
				long inDepth);
	void
		GetFileTypeAndCreator(
				OSType &outType,
				OSType &outCreator) const;
	void
		SetFileTypeAndCreator(
				OSType inType,
				OSType inCreator);
};

// ---------------------------------------------------------------------------

inline unsigned long
AGraphicsExport::DoExport() const
{
	unsigned long sizeWritten = 0;
	CThrownCR err = ::GraphicsExportDoExport(*this,&sizeWritten);
	return sizeWritten;
}

inline void
AGraphicsExport::SetInput(
		PicHandle inPicture)
{
	CThrownCR err = ::GraphicsExportSetInputPicture(*this,inPicture);
}

inline void
AGraphicsExport::SetInput(
		GWorldPtr inGWorld)
{
	CThrownCR err = ::GraphicsExportSetInputGWorld(*this,inGWorld);
}

inline void
AGraphicsExport::SetInput(
		PixMapHandle inPixMap)
{
	CThrownCR err = ::GraphicsExportSetInputPixmap(*this,inPixMap);
}

inline void
AGraphicsExport::SetOutput(
		const FSSpec &inSpec)
{
	CThrownCR err = ::GraphicsExportSetOutputFile(*this,&inSpec);
}

inline void
AGraphicsExport::SetOutput(
		Handle inDataRef,
		OSType inRefType)
{
	CThrownCR err = ::GraphicsExportSetOutputDataReference(*this,inDataRef,inRefType);
}

inline void
AGraphicsExport::SetOutput(
		Handle inHandle)
{
	CThrownCR err = ::GraphicsExportSetOutputHandle(*this,inHandle);
}

inline bool
AGraphicsExport::RequestSettings(
		ModalFilterYDUPP inFilter,
		void *inData)
{
	bool success = true;
	if (CanDo(kGraphicsExportRequestSettingsSelect)) {
		ComponentResult err = ::GraphicsExportRequestSettings(*this,inFilter,inData);
		if (err == userCanceledErr)
			success = false;
		else if (err != noErr)
			throw err;
	}
	return success;
}

inline void
AGraphicsExport::SetSettings(
		void *inAtomContainer)
{
	CThrownCR err = ::GraphicsExportSetSettingsFromAtomContainer(*this,inAtomContainer);
}

inline long
AGraphicsExport::Depth() const
{
	long depth;
	CThrownCR err = ::GraphicsExportGetDepth(*this,&depth);
	return depth;
}

inline void
AGraphicsExport::SetDepth(
		long inDepth)
{
	CThrownCR err = ::GraphicsExportSetDepth(*this,inDepth);
}

inline void
AGraphicsExport::GetFileTypeAndCreator(
		OSType &outType,
		OSType &outCreator) const
{
	CThrownCR err = ::GraphicsExportGetOutputFileTypeAndCreator(*this,&outType,&outCreator);
}

inline void
AGraphicsExport::SetFileTypeAndCreator(
		OSType inType,
		OSType inCreator)
{
	CThrownCR err = ::GraphicsExportSetOutputFileTypeAndCreator(*this,inType,inCreator);
}
