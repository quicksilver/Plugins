// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "FW.h"

#include FW(CoreServices,Files.h)

class AAEDesc;
class AAlias;
class ACFString;

class AFileRef
{
public:
		AFileRef(
				const FSSpec &inSpec);
		AFileRef(
				const FSRef &inRef);
		AFileRef(
				const AAEDesc &inDesc);
		AFileRef(
				const AAlias &inAlias);
		// sub-item by name
		AFileRef(
				const AFileRef &inRef,
				const ACFString &inItemName);
	
		operator const FSSpec&() const;
		operator const FSRef&() const;
	const FSSpec&
		Spec() const
		{
			return operator const FSSpec&();
		}
	const FSRef&
		Ref() const
		{
			return operator const FSRef&();
		}
	
	bool
		operator!() const
		{
			return !mHasFSSpec && !mHasFSRef;
		}
	
	// Changing
	void
		Reset(
				const FSRef &inRef);
	void
		Reset(
				const FSSpec &inSpec);
	
	bool
		HasLongFileName() const;
	
	// FSRef stuff
	void
		GetCatalogInfo(
				FSCatalogInfoBitmap whichInfo,
				FSCatalogInfo *outCatalogInfo,
				HFSUniStr255 *outName = NULL,
				FSSpec *outFSSpec = NULL,
				FSRef *outParentRef = NULL) const;
	void
		SetCatalogInfo(
				FSCatalogInfoBitmap inWhichInfo,
				const FSCatalogInfo &inInfo);
	void
		GetUnicodeName(
				HFSUniStr255 &outName) const
		{
			GetCatalogInfo(kFSCatInfoNone,NULL,&outName);
		}
	
	// FSSpec stuff
	void
		GetCatInfo(
				CInfoPBRec &outPB) const;
	void
		SetCatInfo(
				const CInfoPBRec &outPB);
	
	// Folders
	bool
		IsFolder() const;
	ItemCount
		SubItemCount() const;
	
	// Info & icons
	void
		GetFinderInfo(
				FInfo &outInfo) const;
	void
		SetFinderInfo(
				const FInfo &inInfo);
	void
		SetFinderFlags(
				UInt16 inFlags);
	void
		ClearFinderFlags(
				UInt16 inFlags);
	IconFamilyHandle
		ReadIcon() const;
	IconRef
		GetIconRef() const;
	
	bool
		ResolveAlias(
				bool inResolveChains = true);
	
	// Utilities
	static bool
		FSRefsAvailable();
	
protected:
	mutable FSSpec mFSSpec;
	mutable FSRef mFSRef;
	mutable bool mHasFSSpec,mHasFSRef;
	
		AFileRef()
		: mHasFSSpec(false),mHasFSRef(false) {}
	
	void
		MakeFSSpec() const;
	void
		MakeFSRef() const;
};
