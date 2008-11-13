// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "FW.h"

#include FW(CoreServices,Files.h)

class AFSFork
{
public:
		AFSFork(
				const FSRef &inRef,
				SInt8 inPermissions);
		AFSFork(
				const FSRef &inRef,
				SInt8 inPermissions,
				UniCharCount inNameLength,
				const UniChar *inName);
	
	// reading
	ByteCount
		Read(
				ByteCount inCount,
				void *inBuffer);
	ByteCount
		Read(
				ByteCount inCount,
				void *inBuffer,
				UInt16 inPosMode,
				SInt64 inOffset);
	template <class T>
	void
		Read(
				T &outData);
	template <class T>
	void
		Read(
				T &outData,
				UInt16 inPosMode,
				SInt64 inOffset);
	template <class T>
	T
		ReadData();
	template <class T>
	T
		ReadData(
				UInt16 inPosMode,
				SInt64 inOffset);
	template <class T>
	AFSFork&
		operator>>(
				T &outData)
		{
			Read(outData);
			return *this;
		}
	
	// writing
	ByteCount
		Write(
				ByteCount inCount,
				void *inBuffer);
	ByteCount
		Write(
				ByteCount inCount,
				void *inBuffer,
				UInt16 inPosMode,
				SInt64 inOffset);
	template <class T>
	void
		Write(
				const T &inData);
	template <class T>
	void
		Write(
				const T &inData,
				UInt16 inPosMode,
				SInt64 inOffset);
	template <class T>
	AFSFork&
		operator<<(
				T &outData)
		{
			Write(outData);
			return *this;
		}
	
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
	
	void
		Flush();
	void
		Close();
	
protected:
	SInt16 mForkRefNum;
};
