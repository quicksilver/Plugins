// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "AFileFork.h"
#include "AFileRef.h"

#include "CThrownResult.h"

#include <stdexcept>

// ---------------------------------------------------------------------------

AFileFork*
AFileFork::OpenFork(
				const AFileRef &inRef,
				SInt8 inPermissions,
				EFork inFork)
{
	if (AFileRef::FSRefsAvailable())
		return new ARefFork(inRef.Ref(),inPermissions,inFork);
	else
		return new ASpecFork(inRef.Spec(),inPermissions,inFork);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ARefFork::ARefFork(
		const FSRef &inRef,
		SInt8 inPermissions,
		EFork inFork)
{
	Open(inRef,inPermissions,inFork);
}

// ---------------------------------------------------------------------------

ARefFork::ARefFork(
		const AFileRef &inFileRef,
		SInt8 inPermissions,
		EFork inFork)
{
	Open(inFileRef.Ref(),inPermissions,inFork);
}

// ---------------------------------------------------------------------------

ARefFork::~ARefFork()
{
	::FSCloseFork(mForkRefNum);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
ARefFork::Open(
		const FSRef &inRef,
		SInt8 inPermissions,
		EFork inFork)
{
	HFSUniStr255 forkName;
	CThrownOSStatus err;
	
	GetForkName(inFork,forkName);
	err = ::FSOpenFork(&inRef,forkName.length,forkName.unicode,inPermissions,&mForkRefNum);
}

// ---------------------------------------------------------------------------

void
ARefFork::GetForkName(
		EFork inFork,
		HFSUniStr255 &outForkName)
{
	switch (inFork) {
		
		case fork_Resource:
			::FSGetResourceForkName(&outForkName);
			break;
		
		default:
			::FSGetDataForkName(&outForkName);
			break;
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ByteCount
ARefFork::Read(
		ByteCount inCount,
		void *inBuffer,
		UInt16 inPosMode,
		SInt64 inOffset)
{
	ByteCount readCount;
	CThrownOSStatus err;
	
	err = ::FSReadFork(mForkRefNum,inPosMode,inOffset,inCount,inBuffer,&readCount);
	return readCount;
}

// ---------------------------------------------------------------------------

ByteCount
ARefFork::Write(
		ByteCount inCount,
		const void *inBuffer,
		UInt16 inPosMode,
		SInt64 inOffset)
{
	ByteCount readCount;
	CThrownOSStatus err;
	
	err = ::FSWriteFork(mForkRefNum,inPosMode,inOffset,inCount,inBuffer,&readCount);
	return readCount;
}

// ---------------------------------------------------------------------------

SInt64
ARefFork::Position() const
{
	SInt64 position;
	CThrownOSErr err;
	
	err = ::FSGetForkPosition(mForkRefNum,&position);
	return position;
}

// ---------------------------------------------------------------------------

void
ARefFork::SetPosition(
		SInt64 inOffset,
		UInt16 inMode)
{
	CThrownOSErr err = ::FSSetForkPosition(mForkRefNum,inOffset,inMode);
}

// ---------------------------------------------------------------------------

SInt64
ARefFork::Size() const
{
	SInt64 forkSize;
	CThrownOSErr err;
	
	err = ::FSGetForkSize(mForkRefNum,&forkSize);
	return forkSize;
}

// ---------------------------------------------------------------------------

void
ARefFork::SetSize(
		SInt64 inSize,
		UInt16 inMode)
{
	CThrownOSErr err = ::FSSetForkSize(mForkRefNum,inMode,inSize);
}

// ---------------------------------------------------------------------------

UInt64
ARefFork::Allocate(
		UInt64 inCount,
		FSAllocationFlags inFlags)
{
	UInt64 actualCount;
	CThrownOSErr err;
	
	err = ::FSAllocateFork(mForkRefNum,inFlags,fsAtMark,0,inCount,&actualCount);
	return actualCount;
}

// ---------------------------------------------------------------------------

UInt64
ARefFork::Allocate(
		UInt64 inCount,
		UInt16 inMode,
		SInt64 inOffset,
		FSAllocationFlags inFlags)
{
	UInt64 actualCount;
	CThrownOSErr err;
	
	err = ::FSAllocateFork(mForkRefNum,inFlags,inMode,inOffset,inCount,&actualCount);
	return actualCount;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ASpecFork::ASpecFork(
		const FSSpec &inSpec,
		SInt8 inPermissions,
		EFork inFork)
{
	Open(inSpec,inPermissions,inFork);
}

// ---------------------------------------------------------------------------

ASpecFork::ASpecFork(
		const AFileRef &inRef,
		SInt8 inPermissions,
		EFork inFork)
{
	Open(inRef.Spec(),inPermissions,inFork);
}

// ---------------------------------------------------------------------------

ASpecFork::~ASpecFork()
{
	::FSClose(mForkRefNum);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

void
ASpecFork::Open(
		const FSSpec &inSpec,
		SInt8 inPermissions,
		EFork inFork)
{
	CThrownOSStatus err;
	
	switch (inFork) {
		case fork_Data:
			err = ::FSpOpenDF(&inSpec,inPermissions,&mForkRefNum);	break;
		case fork_Resource:
			err = ::FSpOpenRF(&inSpec,inPermissions,&mForkRefNum);	break;
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ByteCount
ASpecFork::Read(
		ByteCount inCount,
		void *inBuffer,
		UInt16 inPosMode,
		SInt64 inOffset)
{
	long readCount;
	CThrownOSStatus err;
	
	readCount = inCount;
	if ((inPosMode != fsAtMark) || (inOffset != 0))
		err = ::SetFPos(mForkRefNum,inPosMode,inOffset);
	err = ::FSRead(mForkRefNum,&readCount,inBuffer);
	return readCount;
}

// ---------------------------------------------------------------------------

ByteCount
ASpecFork::Write(
		ByteCount inCount,
		const void *inBuffer,
		UInt16 inPosMode,
		SInt64 inOffset)
{
	long readCount;
	CThrownOSStatus err;
	
	readCount = inCount;
	if ((inPosMode != fsAtMark) || (inOffset != 0))
		err = ::SetFPos(mForkRefNum,inPosMode,inOffset);
	err = ::FSWrite(mForkRefNum,&readCount,inBuffer);
	return readCount;
}

// ---------------------------------------------------------------------------

SInt64
ASpecFork::Position() const
{
	long position;
	CThrownOSErr err;
	
	err = ::GetFPos(mForkRefNum,&position);
	return position;
}

// ---------------------------------------------------------------------------

void
ASpecFork::SetPosition(
		SInt64 inOffset,
		UInt16 inMode)
{
	AssertLongRange(inOffset);
	CThrownOSErr err = ::SetFPos(mForkRefNum,inMode,inOffset);
}

// ---------------------------------------------------------------------------

SInt64
ASpecFork::Size() const
{
	long forkSize;
	CThrownOSErr err;
	
	err = ::GetEOF(mForkRefNum,&forkSize);
	return forkSize;
}

// ---------------------------------------------------------------------------

void
ASpecFork::SetSize(
		SInt64 inSize,
		UInt16)	// mode not used in this version
{
	AssertLongRange(inSize);
	CThrownOSErr err = ::SetEOF(mForkRefNum,inSize);
}

// ---------------------------------------------------------------------------

UInt64
ASpecFork::Allocate(
		UInt64 inCount,
		FSAllocationFlags)	// flags not used in this version
{
	AssertLongRange(inCount);
	
	long actualCount = inCount;
	CThrownOSErr err;
	
	err = ::Allocate(mForkRefNum,&actualCount);
	return actualCount;
}

// ---------------------------------------------------------------------------

UInt64
ASpecFork::Allocate(
		UInt64 inCount,
		UInt16,
		SInt64,
		FSAllocationFlags)
{
	AssertLongRange(inCount);
	
	long actualCount = inCount;
	CThrownOSErr err;
	
	err = ::Allocate(mForkRefNum,&actualCount);
	return actualCount;
}

// ---------------------------------------------------------------------------

void
ASpecFork::AssertLongRange(
		SInt64 inValue)
{
	if ((inValue > 0x7FFFFFFF) || (inValue < 0x80000000))
		throw std::range_error("SInt64 too big");
}
