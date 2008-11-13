// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "FW.h"

#include FW(CoreServices,Files.h)

class AFileRef;

// ---------------------------------------------------------------------------
#pragma mark AFileFork

class AFileFork {
public:
	typedef enum {
		fork_Data,
		fork_Resource
	} EFork;
	
	virtual
		~AFileFork() {}
	
	static AFileFork*
		OpenFork(
				const FSRef &inRef,
				SInt8 inPermissions,
				EFork inFork = fork_Data);
	static AFileFork*
		OpenFork(
				const AFileRef &inRef,
				SInt8 inPermissions,
				EFork inFork = fork_Data);
	
	SInt16
		RefNum() const
		{
			return mForkRefNum;
		}
	
	// reading
	virtual ByteCount
		Read(
				ByteCount inCount,
				void *inBuffer,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0) = 0;
	template <class T>
	void
		Read(
				T &outData,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0)
		{
			if (Read(sizeof(outData),&outData,inPosMode,inOffset) != sizeof(outData))
				throw std::length_error("data len mismatch");
		}
	template <class T>
	T
		ReadData(
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0)
		{
			T dataObject;
			Read(dataObject,inPosMode,inOffset);
			return dataObject;
		}
	template <class T>
	AFileFork&
		operator>>(
				T &outData)
		{
			Read(outData);
			return *this;
		}
	
	// writing
	virtual ByteCount
		Write(
				ByteCount inCount,
				const void *inBuffer,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0) = 0;
	template <class T>
	void
		Write(
				const T &inData,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0);
	template <class T>
	AFileFork&
		operator<<(
				T &outData)
		{
			Write(outData);
			return *this;
		}
	
	// position
	virtual SInt64
		Position() const = 0;
	virtual void
		SetPosition(
				SInt64 inOffset,
				UInt16 inMode = fsFromStart) = 0;
	
	// size
	virtual SInt64
		Size() const = 0;
	virtual void
		SetSize(
				SInt64 inSize,
				UInt16 inMode = fsFromStart) = 0;
	virtual UInt64
		Allocate(
				UInt64 inCount,
				FSAllocationFlags inFlags = kFSAllocDefaultFlags) = 0;
	virtual UInt64
		Allocate(
				UInt64 inCount,
				UInt16 inMode,
				SInt64 inOffset,
				FSAllocationFlags inFlags = kFSAllocDefaultFlags) = 0;
	
protected:
	SInt16 mForkRefNum;
};

// ---------------------------------------------------------------------------
#pragma mark ARefFork

class ARefFork
		: public AFileFork
{
public:
		ARefFork(
				const FSRef &inRef,
				SInt8 inPermissions,
				EFork inFork = fork_Data);
		ARefFork(
				const AFileRef &inFileRef,
				SInt8 inPermissions,
				EFork inFork = fork_Data);
	virtual
		~ARefFork();
	
	// reading
	ByteCount
		Read(
				ByteCount inCount,
				void *inBuffer,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0);
	
	// writing
	ByteCount
		Write(
				ByteCount inCount,
				const void *inBuffer,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0);
	
	// position
	SInt64
		Position() const;
	void
		SetPosition(
				SInt64 inOffset,
				UInt16 inMode = fsFromStart);
	
	// size
	SInt64
		Size() const;
	void
		SetSize(
				SInt64 inSize,
				UInt16 inMode = fsFromStart);
	UInt64
		Allocate(
				UInt64 inCount,
				FSAllocationFlags inFlags = kFSAllocDefaultFlags);
	UInt64
		Allocate(
				UInt64 inCount,
				UInt16 inMode,
				SInt64 inOffset,
				FSAllocationFlags inFlags = kFSAllocDefaultFlags);
	
protected:
	void
		Open(
				const FSRef &inRef,
				SInt8 inPermissions,
				EFork inFork);
	
	static void
		GetForkName(
				EFork inFork,
				HFSUniStr255 &outForkName);
};

// ---------------------------------------------------------------------------
#pragma mark ASpecFork

class ASpecFork
		: public AFileFork
{
public:
		ASpecFork(
				const FSSpec &inSpec,
				SInt8 inPermissions,
				EFork inFork = fork_Data);
		ASpecFork(
				const AFileRef &inFileRef,
				SInt8 inPermissions,
				EFork inFork = fork_Data);
	virtual
		~ASpecFork();
	
	// reading
	ByteCount
		Read(
				ByteCount inCount,
				void *inBuffer,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0);
	
	// writing
	ByteCount
		Write(
				ByteCount inCount,
				const void *inBuffer,
				UInt16 inPosMode = fsAtMark,
				SInt64 inOffset = 0);
	
	// position
	SInt64
		Position() const;
	void
		SetPosition(
				SInt64 inOffset,
				UInt16 inMode = fsFromStart);
	
	// size
	SInt64
		Size() const;
	void
		SetSize(
				SInt64 inSize,
				UInt16 inMode = fsFromStart);
	UInt64
		Allocate(
				UInt64 inCount,
				FSAllocationFlags inFlags = kFSAllocDefaultFlags);
	UInt64
		Allocate(
				UInt64 inCount,
				UInt16 inMode,
				SInt64 inOffset,
				FSAllocationFlags inFlags = kFSAllocDefaultFlags);
	
protected:
	void
		Open(
				const FSSpec &inSpec,
				SInt8 inPermissions,
				EFork inFork);
	
	static void
		AssertLongRange(
				SInt64 inValue);
};
