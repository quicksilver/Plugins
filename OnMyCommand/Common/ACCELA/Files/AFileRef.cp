// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AFileRef.h"
#include "AAEDesc.h"
#include "AAlias.h"
#include "ACFString.h"
#include "AFSIterator.h"
#include "XSystem.h"

#include <stdexcept>

static OSErr
FSpGetDirectoryID(
		const FSSpec *spec,
		long *theDirID,
		Boolean *isDirectory);

// ---------------------------------------------------------------------------

AFileRef::AFileRef(
		const FSSpec &inSpec)
: mFSSpec(inSpec),mHasFSSpec(true),mHasFSRef(false)
{
}

// ---------------------------------------------------------------------------

AFileRef::AFileRef(
		const FSRef &inRef)
: mFSRef(inRef),mHasFSSpec(false),mHasFSRef(true)
{
}

// ---------------------------------------------------------------------------

AFileRef::AFileRef(
		const AAEDesc &inDesc)
: mHasFSSpec(false),mHasFSRef(false)
{
	do {
		try {
			AAEDesc refDesc(inDesc,typeFSRef);
			
			refDesc.GetDescData(mFSRef);
			mHasFSRef = true;
			break;
		}
		catch (...) {}
		
		try {
			AAEDesc refDesc(inDesc,typeFSS);
			
			refDesc.GetDescData(mFSSpec);
			mHasFSSpec = true;
			break;
		}
		catch (...) {}
	} while (false);
}

// ---------------------------------------------------------------------------

AFileRef::AFileRef(
		const AAlias &inAlias)
: mHasFSSpec(false),mHasFSRef(false)
{
	if (FSRefsAvailable()) {
		inAlias.Resolve(mFSRef);
		mHasFSRef = true;
	}
	else {
		inAlias.Resolve(mFSSpec);
		mHasFSSpec = true;
	}
}

// ---------------------------------------------------------------------------

AFileRef::AFileRef(
		const AFileRef &inRef,
		const ACFString &inItemName)
{
	if (FSRefsAvailable()) {
		HFSUniStr255 fileName;
		
		fileName.length = inItemName.Length();
		inItemName.GetCharacters(CFRangeMake(0,fileName.length),fileName.unicode);
		
		CThrownOSErr err = ::FSMakeFSRefUnicode(&inRef.Ref(),fileName.length,fileName.unicode,0,&mFSRef);
		mHasFSRef = true;
	}
	else {
		Boolean isDirectory;
		long dirID;
		
		if (inItemName.Length() > sizeof(StrFileName)-1)
			throw std::overflow_error("name too long");
		FSpGetDirectoryID(&inRef.Spec(),&dirID,&isDirectory);
		if (!isDirectory)
			throw std::runtime_error("not a folder");
		
		mFSSpec.parID = dirID;
		inItemName.GetPascalString(mFSSpec.name);
		mHasFSSpec = true;
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AFileRef::operator const FSSpec&() const
{
	MakeFSSpec();
	return mFSSpec;
}

// ---------------------------------------------------------------------------

AFileRef::operator const FSRef&() const
{
	MakeFSRef();
	return mFSRef;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

bool
AFileRef::HasLongFileName() const
{
	bool longName = false;
	
	if (mHasFSRef) {
		HFSUniStr255 fileName;
		CThrownOSStatus err = ::FSGetCatalogInfo(&mFSRef,kFSCatInfoNone,NULL,&fileName,NULL,NULL);
		
		longName = (fileName.length > sizeof(StrFileName)-1);
	}
	return longName;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
AFileRef::MakeFSSpec() const
{
	if (!mHasFSSpec) {
		CThrownOSStatus err = ::FSGetCatalogInfo(&mFSRef,kFSCatInfoNone,NULL,NULL,&mFSSpec,NULL);
		
		mHasFSSpec = true;
	}
}

// ---------------------------------------------------------------------------

void
AFileRef::MakeFSRef() const
{
	if (!mHasFSRef) {
		CThrownOSStatus err = ::FSpMakeFSRef(&mFSSpec,&mFSRef);
		
		mHasFSRef = true;
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
AFileRef::GetCatalogInfo(
		FSCatalogInfoBitmap inWhichInfo,
		FSCatalogInfo *outCatalogInfo,
		HFSUniStr255 *outName,
		FSSpec *outFSSpec,
		FSRef *outParentRef) const
{
	if (mHasFSRef)
		CThrownOSStatus err = ::FSGetCatalogInfo(&mFSRef,inWhichInfo,outCatalogInfo,outName,outFSSpec,outParentRef);
	else {
		// throw something
	}
}

// ---------------------------------------------------------------------------

void
AFileRef::SetCatalogInfo(
		FSCatalogInfoBitmap inWhichInfo,
		const FSCatalogInfo &inCatalogInfo)
{
	if (mHasFSRef)
		CThrownOSStatus err = ::FSSetCatalogInfo(&mFSRef,inWhichInfo,&inCatalogInfo);
	else {
		// throw something
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
AFileRef::GetCatInfo(
		CInfoPBRec &outPB) const
{
	MakeFSSpec();
	
	outPB.hFileInfo.ioNamePtr = mFSSpec.name;
	outPB.hFileInfo.ioVRefNum = mFSSpec.vRefNum;
	outPB.hFileInfo.ioFlParID = mFSSpec.parID;
	
	CThrownOSErr err = ::PBGetCatInfoSync(&outPB);
}

// ---------------------------------------------------------------------------

void
AFileRef::SetCatInfo(
		const CInfoPBRec &inPB)
{
	MakeFSSpec();
	
	// Why isn't it declared const?
	CThrownOSErr err = ::PBSetCatInfoSync(const_cast<CInfoPBPtr>(&inPB));
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

bool
AFileRef::IsFolder() const
{
	bool isFolder = false;
	
	if (mHasFSRef) {
		FSCatalogInfo info;
		
		GetCatalogInfo(kFSCatInfoNodeFlags,&info);
		isFolder = info.nodeFlags & kFSNodeIsDirectoryMask;
	}
	else if (mHasFSSpec) {
		CInfoPBRec pb;
		
		GetCatInfo(pb);
		isFolder = pb.hFileInfo.ioFlAttrib & kioFlAttribDirMask;
	}
	return isFolder;
}

// ---------------------------------------------------------------------------

ItemCount
AFileRef::SubItemCount() const
{
	ItemCount itemCount = 0;
	
	if (IsFolder()) {
		if (mHasFSRef) {
			AFSIterator iter(mFSRef);
			
			iter.GetCatalogInfo(0,itemCount);
		}
		else if (mHasFSSpec) {
			CInfoPBRec pb;
			
			GetCatInfo(pb);
			itemCount = pb.dirInfo.ioDrNmFls;
		}
	}
	return itemCount;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
AFileRef::GetFinderInfo(
		FInfo &outInfo) const
{
	if (mHasFSRef) {
		FSCatalogInfo info;
		
		GetCatalogInfo(kFSCatInfoFinderInfo,&info);
		outInfo = *(FInfo*)&info.finderInfo;
	}
	else if (mHasFSSpec) {
		CThrownOSErr err = ::FSpGetFInfo(&mFSSpec,&outInfo);
	}
}

// ---------------------------------------------------------------------------

void
AFileRef::SetFinderInfo(
		const FInfo &inInfo)
{
	if (mHasFSRef) {
		FSCatalogInfo info;
		
		*((FInfo*)&info.finderInfo) = inInfo;
		SetCatalogInfo(kFSCatInfoFinderInfo,info);
	}
	else if (mHasFSSpec) {
		CThrownOSErr err = ::FSpSetFInfo(&mFSSpec,&inInfo);
	}
}

// ---------------------------------------------------------------------------

void
AFileRef::SetFinderFlags(
		UInt16 inFlags)
{
	if (mHasFSRef) {
		FSCatalogInfo catInfo;
		FInfo &finderInfo = *(FInfo*)&catInfo.finderInfo;
		
		GetCatalogInfo(kFSCatInfoFinderInfo,&catInfo);;
		finderInfo.fdFlags |= inFlags;
		SetCatalogInfo(kFSCatInfoFinderInfo,catInfo);;
	}
	else {
		FInfo finderInfo;
		
		GetFinderInfo(finderInfo);
		finderInfo.fdFlags |= inFlags;
		SetFinderInfo(finderInfo);
	}
}

// ---------------------------------------------------------------------------

void
AFileRef::ClearFinderFlags(
		UInt16 inFlags)
{
	if (mHasFSRef) {
		FSCatalogInfo catInfo;
		FInfo &finderInfo = *(FInfo*)&catInfo.finderInfo;
		
		GetCatalogInfo(kFSCatInfoFinderInfo,&catInfo);;
		finderInfo.fdFlags &= ~inFlags;
		SetCatalogInfo(kFSCatInfoFinderInfo,catInfo);;
	}
	else {
		FInfo finderInfo;
		
		GetFinderInfo(finderInfo);
		finderInfo.fdFlags &= ~inFlags;
		SetFinderInfo(finderInfo);
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

IconFamilyHandle
AFileRef::ReadIcon() const
{
	IconFamilyHandle iconFamily = NULL;
	CThrownOSStatus err;
	
	// ReadIconFromFSRef is only available in OS X
	if (mHasFSRef && (XSystem::OSVersion() >= 0x1000))
		err = ::ReadIconFromFSRef(&mFSRef,&iconFamily);
	else {
		MakeFSSpec();
		err = ::ReadIconFile(&mFSSpec,&iconFamily);
	}
	return iconFamily;
}

// ---------------------------------------------------------------------------

IconRef
AFileRef::GetIconRef() const
{
	IconRef icon;
	SInt16 label;
	CThrownOSStatus err;
	
	// GetIconRefFromFileInfo is X only
	if (mHasFSRef && (XSystem::OSVersion() >= 0x1000)) {
		FSCatalogInfo info;
		HFSUniStr255 fileName;
		FSCatalogInfoBitmap infoMask = kIconServicesCatalogInfoMask;
		
		if (XSystem::OSVersion() < 0x1000)
			infoMask &= ~kFSCatInfoUserAccess;
		err = ::FSGetCatalogInfo(
				&mFSRef,
				infoMask,&info,
				&fileName,NULL,NULL);
		err = ::GetIconRefFromFileInfo(
				&mFSRef,
				fileName.length,fileName.unicode,
				infoMask,&info,
				kIconServicesNormalUsageFlag,
				&icon,&label);
	}
	else {
		MakeFSSpec();
		err = ::GetIconRefFromFile(&mFSSpec,&icon,&label);
	}
	
	return icon;
}

// ---------------------------------------------------------------------------

bool
AFileRef::ResolveAlias(
		bool inResolveChains)
{
	Boolean isFolder,wasAliased = false;
	
	if (mHasFSRef) {
		::FSResolveAliasFile(&mFSRef,inResolveChains,&isFolder,&wasAliased);
	}
	else {
		MakeFSSpec();
		::ResolveAliasFile(&mFSSpec,inResolveChains,&isFolder,&wasAliased);
	}
	return wasAliased;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

bool
AFileRef::FSRefsAvailable()
{
	static long response = 0;
	static OSErr err = ::Gestalt(gestaltSystemVersion,&response);
	
	return response >= 0x0900;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------
// Adapted from MoreFiles

OSErr
FSpGetDirectoryID(
		const FSSpec *spec,
		long *theDirID,
		Boolean *isDirectory)
{
	CInfoPBRec pb;
	OSErr error;
	Str31 tempName;
	
	/* Protection against File Sharing problem */
	if (spec->name[0] == 0) {
		tempName[0] = 0;
		pb.dirInfo.ioNamePtr = tempName;
		pb.dirInfo.ioFDirIndex = -1;	/* use ioDirID */
	}
	else {
		pb.dirInfo.ioNamePtr = (StringPtr)spec->name;
		pb.dirInfo.ioFDirIndex = 0;	/* use ioNamePtr and ioDirID */
	}
	pb.dirInfo.ioVRefNum = spec->vRefNum;
	pb.dirInfo.ioDrDirID = spec->parID;
	error = PBGetCatInfoSync(&pb);
	pb.dirInfo.ioNamePtr = NULL;

	if ( error == noErr ) {
		*isDirectory = (pb.hFileInfo.ioFlAttrib & kioFlAttribDirMask) != 0;
		if ( *isDirectory )
			*theDirID = pb.dirInfo.ioDrDirID;
		else
			*theDirID = pb.hFileInfo.ioFlParID;
	}
	
	return error;
}
