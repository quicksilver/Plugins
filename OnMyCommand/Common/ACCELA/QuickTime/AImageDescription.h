// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "FW.h"
#include "CThrownResult.h"

#include FW(QuickTime,ImageCompression.h)

class AImageDescription :
		public XWrapper<ImageDescriptionHandle>
{
public:
	// The compiler doesn't recognize the difference between
	// GraphicsImportComponent and GraphicsExportComponent
	typedef enum {
		component_Export
	} EExport;
	typedef enum {
		component_Import
	} EImport;
	
		// ImageDescriptionHandle
		AImageDescription(
				ImageDescriptionHandle inHandle,
				bool inOwner = false)
		: XWrapper(inHandle,inOwner) {}
		// PixMap
		AImageDescription(
				PixMapHandle inPix);
		// Effect type
		AImageDescription(
				OSType inEffectType);
		// Graphics import component
		AImageDescription(
				GraphicsImportComponent inGIC,
				EImport);
		// Graphics export component
		AImageDescription(
				GraphicsExportComponent inGIC,
				EExport);
	
	CTabHandle
		CTable() const;
	void
		SetCTable(
				CTabHandle inTable);
	
	Handle
		Extension(
				long inIDType,
				long inIndex = 1) const;
	void
		AddExtension(
				Handle inExtension,
				long IDType);
	void
		RemoveExtension(
				long inIDType,
				long inIndex = 1);
	long
		CountExtensionType(
				long inIDType) const;
	long
		NextExtensionType() const;
	
	long
		DataSize() const
		{
			return (**mObject).dataSize;
		}
};

// ---------------------------------------------------------------------------

inline
AImageDescription::AImageDescription(
		PixMapHandle inPix)
: XWrapper<ImageDescriptionHandle>(NULL,true)
{
	CThrownOSErr err = ::MakeImageDescriptionForPixMap(inPix,&mObject);
}

inline
AImageDescription::AImageDescription(
		OSType inEffectType)
: XWrapper<ImageDescriptionHandle>(NULL,true)
{
	CThrownOSErr err = ::MakeImageDescriptionForEffect(inEffectType,&mObject);
}

inline
AImageDescription::AImageDescription(
		GraphicsImportComponent inGIC,
		EExport)
: XWrapper<ImageDescriptionHandle>(NULL,true)
{
	CThrownResult<ComponentResult> err = ::GraphicsImportGetImageDescription(inGIC,&mObject);
}

inline
AImageDescription::AImageDescription(
		GraphicsExportComponent inGEC,
		EImport)
: XWrapper<ImageDescriptionHandle>(NULL,true)
{
	CThrownResult<ComponentResult> err = ::GraphicsExportGetInputImageDescription(inGEC,&mObject);
}

inline CTabHandle
AImageDescription::CTable() const
{
	CTabHandle ctab;
	CThrownOSErr err = ::GetImageDescriptionCTable(*this,&ctab);
	return ctab;
}

inline void
AImageDescription::SetCTable(
		CTabHandle inTable)
{
	CThrownOSErr err = ::SetImageDescriptionCTable(*this,inTable);
}

inline Handle
AImageDescription::Extension(
		long inIDType,
		long inIndex) const
{
	Handle extension;
	CThrownOSErr err = ::GetImageDescriptionExtension(*this,&extension,inIDType,inIndex);
	return extension;
}

inline void
AImageDescription::AddExtension(
		Handle inExtension,
		long inIDType)
{
	CThrownOSErr err = AddImageDescriptionExtension(*this,inExtension,inIDType);
}

inline void
AImageDescription::RemoveExtension(
		long inIDType,
		long inIndex)
{
	CThrownOSErr err = RemoveImageDescriptionExtension(*this,inIDType,inIndex);
}

inline long
AImageDescription::CountExtensionType(
		long inIDType) const
{
	long typeCount;
	CThrownOSErr err = CountImageDescriptionExtensionType(*this,inIDType,&typeCount);
	return typeCount;
}

inline long
AImageDescription::NextExtensionType() const
{
	long idType;
	CThrownOSErr err = GetNextImageDescriptionExtensionType(*this,&idType);
	return idType;
}

// ---------------------------------------------------------------------------

inline void
XWrapper<ImageDescriptionHandle>::DisposeSelf()
{
	::DisposeHandle((Handle)mObject);
}
