// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "FW.h"

#include FW(CoreServices,Files.h)

class AFSIterator :
		public XWrapper<FSIterator>
{
public:
		AFSIterator(
				const FSRef &inRef,
				FSIteratorFlags inFlags = kFSIterateFlat);
	
	void
		GetCatalogInfo(
				ItemCount inMaxObjects,
				ItemCount &outActualCount,
				Boolean *outContainerChanged = NULL,
				FSCatalogInfoBitmap inWhichInfo = 0,
				FSCatalogInfo *outCatalogInfos = NULL,
				FSRef *outRefs = NULL,
				FSSpec *outSpecs = NULL,
				HFSUniStr255 *outNames = NULL);
	void
		CatalogSearch(
				const FSSearchParams &inSearchCriteria,
				ItemCount inMaxObjects,
				ItemCount &outActualCount,
				Boolean *outContainerChanged = NULL,
				FSCatalogInfoBitmap inWhichInfo = 0,
				FSCatalogInfo *outCatalogInfos = NULL,
				FSRef *outRefs = NULL,
				FSSpec *outSpecs = NULL,
				HFSUniStr255 *outNames = NULL);
};

// ---------------------------------------------------------------------------

inline
AFSIterator::AFSIterator(
		const FSRef &inRef,
		FSIteratorFlags inFlags)
{
	CThrownOSStatus err = ::FSOpenIterator(&inRef,inFlags,&mObject);
}

inline void
AFSIterator::GetCatalogInfo(
		ItemCount inMaxObjects,
		ItemCount &outActualCount,
		Boolean *outContainerChanged,
		FSCatalogInfoBitmap inWhichInfo,
		FSCatalogInfo *outCatalogInfos,
		FSRef *outRefs,
		FSSpec *outSpecs,
		HFSUniStr255 *outNames)
{
	CThrownOSStatus err = ::FSGetCatalogInfoBulk(
			*this,
			inMaxObjects,&outActualCount,
			outContainerChanged,
			inWhichInfo,outCatalogInfos,
			outRefs,outSpecs,outNames);
}

inline void
AFSIterator::CatalogSearch(
		const FSSearchParams &inSearchCriteria,
		ItemCount inMaxObjects,
		ItemCount &outActualCount,
		Boolean *outContainerChanged,
		FSCatalogInfoBitmap inWhichInfo,
		FSCatalogInfo *outCatalogInfos,
		FSRef *outRefs,
		FSSpec *outSpecs,
		HFSUniStr255 *outNames)
{
	CThrownOSStatus err = ::FSCatalogSearch(
			*this,
			&inSearchCriteria,
			inMaxObjects,&outActualCount,
			outContainerChanged,
			inWhichInfo,outCatalogInfos,
			outRefs,outSpecs,outNames);
}

// ---------------------------------------------------------------------------

inline void
XWrapper<FSIterator>::DisposeSelf()
{
	::FSCloseIterator(mObject);
}
