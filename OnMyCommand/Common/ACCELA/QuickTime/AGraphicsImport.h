// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AComponentInstance.h"

class AGraphicsImport :
		public AComponentInstance
{
public:
		// ComponentInstance
		AGraphicsImport(
				ComponentInstance inInstance,
				bool inOwner = false)
		: AComponentInstance(inInstance,inOwner) {}
		// FSSpec
		AGraphicsImport(
				const FSSpec &inFileSpec);
		// FSSpec and flags
		AGraphicsImport(
				const FSSpec &inFileSpec,
				long inFlags);
		// Data ref
		AGraphicsImport(
				Handle inDataRef,
				OSType inDataType);
		// Data ref and flags
		AGraphicsImport(
				Handle inDataRef,
				OSType inDataType,
				long inFlags);
		// PictHandle
		AGraphicsImport(
				PicHandle inPicture);
	
	// Bounds
	Rect
		NaturalBounds() const;
	Rect
		BoundsRect() const;
	void
		SetBoundsRect(
				const Rect &inBounds);
	void
		SetSourceRect(
				const Rect &inSource);
	Rect
		SourceRect() const;
	void
		SetDestRect(
				const Rect &inSource);
	Rect
		DestRect() const;
	
	bool
		Validate() const;
	FSSpec
		DataFile() const;
	void
		GetDataFile(
				FSSpec &outSpec) const;
	
	// Drawing
	void
		Draw() const;
	bool
		DoesDrawAllPixels() const;
	
	// GWorld
	void
		SetGWorld(
				CGrafPtr inGWorld,
				GDHandle inGDH = NULL);
	CGrafPtr
		GWorld() const;
	void
		GetGWorld(
				CGrafPtr &outGWorld,
				GDHandle &outGDH) const;
	
	// Matrix
	void
		SetMatrix(
				const MatrixRecord &inMatrix);
	MatrixRecord
		Matrix() const;
	void
		GetMatrix(
				MatrixRecord &outMatrix) const;
	MatrixRecord
		DefaultMatrix() const;
	void
		GetDefaultMatrix(
				MatrixRecord &outMatrix) const;
	
	// Images
	unsigned long
		ImageCount() const;
	void
		SetImageIndex(
				unsigned long inIndex);
	unsigned long
		ImageIndex() const;
	
	PicHandle
		GetAsPicture() const;
	ImageDescriptionHandle
		ImageDescription() const;
	
	void
		SetDataHandle(
				Handle inHandle);
};

inline
AGraphicsImport::AGraphicsImport(
		const FSSpec &inFileSpec)
: AComponentInstance(NULL,true)
{
	CThrownCR err = ::GetGraphicsImporterForFile(&inFileSpec,&mObject);
}

inline
AGraphicsImport::AGraphicsImport(
		const FSSpec &inFileSpec,
		long inFlags)
: AComponentInstance(NULL,true)
{
	CThrownCR err = ::GetGraphicsImporterForFileWithFlags(&inFileSpec,&mObject,inFlags);
}

inline
AGraphicsImport::AGraphicsImport(
		Handle inDataRef,
		OSType inDataType)
: AComponentInstance(NULL,true)
{
	CThrownCR err = ::GetGraphicsImporterForDataRef(inDataRef,inDataType,&mObject);
}

inline
AGraphicsImport::AGraphicsImport(
		Handle inDataRef,
		OSType inDataType,
		long inFlags)
: AComponentInstance(NULL,true)
{
	CThrownCR err = ::GetGraphicsImporterForDataRefWithFlags(inDataRef,inDataType,&mObject,inFlags);
}

inline Rect
AGraphicsImport::NaturalBounds() const
{
	Rect bounds;
	CThrownCR err = ::GraphicsImportGetNaturalBounds(*this,&bounds);
	return bounds;
}

inline Rect
AGraphicsImport::BoundsRect() const
{
	Rect bounds;
	CThrownCR err = ::GraphicsImportGetBoundsRect(*this,&bounds);
	return bounds;
}

inline void
AGraphicsImport::SetBoundsRect(
		const Rect &inBounds)
{
	CThrownCR err = ::GraphicsImportSetBoundsRect(*this,&inBounds);
}

inline bool
AGraphicsImport::Validate() const
{
	Boolean valid;
	CThrownCR err = ::GraphicsImportValidate(*this,&valid);
	return valid;
}

inline FSSpec
AGraphicsImport::DataFile() const
{
	FSSpec spec;
	CThrownCR err = ::GraphicsImportGetDataFile(*this,&spec);
	return spec;
}

inline void
AGraphicsImport::GetDataFile(
		FSSpec &outSpec) const
{
	CThrownCR err = ::GraphicsImportGetDataFile(*this,&outSpec);
}

inline void
AGraphicsImport::Draw() const
{
	CThrownCR err = ::GraphicsImportDraw(*this);
}

PicHandle
AGraphicsImport::GetAsPicture() const
{
	PicHandle pict;
	CThrownCR err = ::GraphicsImportGetAsPicture(*this,&pict);
	return pict;
}

void
AGraphicsImport::SetDataHandle(
		Handle inHandle)
{
	CThrownCR err = ::GraphicsImportSetDataHandle(*this,inHandle);
}

// ---------------------------------------------------------------------------
#pragma mark APictImport

class APictImport :
		public AGraphicsImport
{
public:
		APictImport(
				PicHandle inPicture);
		~APictImport();
	
protected:
	Handle mHandle;
};

inline
APictImport::APictImport(
		PicHandle inPicture)
: AGraphicsImport(NULL,true),
  mHandle(::NewHandleClear(512))
{
	::HandAndHand((Handle)inPicture,mHandle);
	CThrownCR err = ::OpenADefaultComponent(GraphicsImporterComponentType,'PICT',&mObject);
	SetDataHandle(mHandle);
}

inline
APictImport::~APictImport()
{
	::DisposeHandle(mHandle);
}
