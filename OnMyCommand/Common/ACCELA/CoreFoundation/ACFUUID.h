// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

class ACFUUID :
		public ACFType<CFUUIDRef>
{
public:
		// make a new one
		ACFUUID();
		// CFUUIDRef
		ACFUUID(
				CFUUIDRef inRef,
				bool inDoRetain = true)
		: ACFType(inRef,inDoRetain) {}
		// bytes
		ACFUUID(
				UInt8 byte0, UInt8 byte1, UInt8 byte2, UInt8 byte3,
				UInt8 byte4, UInt8 byte5, UInt8 byte6, UInt8 byte7,
				UInt8 byte8, UInt8 byte9, UInt8 byte10,UInt8 byte11,
				UInt8 byte12,UInt8 byte13,UInt8 byte14,UInt8 byte15);
		// string
		ACFUUID(
				CFStringRef inString);
		// bytes struct
		ACFUUID(
				const CFUUIDBytes &inBytes);
	
	CFStringRef
		CreatString() const;
};

inline
ACFUUID::ACFUUID()
: ACFType(::CFUUIDCreate(kCFAllocatorDefault),false)
{
}

inline
ACFUUID::ACFUUID(
		UInt8 byte0, UInt8 byte1, UInt8 byte2, UInt8 byte3,
		UInt8 byte4, UInt8 byte5, UInt8 byte6, UInt8 byte7,
		UInt8 byte8, UInt8 byte9, UInt8 byte10,UInt8 byte11,
		UInt8 byte12,UInt8 byte13,UInt8 byte14,UInt8 byte15);
: ACFType(::CFUUIDCreateWithBytes(
				kCFAllocatorDefault,
				byte0, byte1, byte2, byte3,
				byte4, byte5, byte6, byte7,
				byte8, byte9, byte10,byte11,
				byte12,byte13,byte14,byte15),
		false)
{
}

inline
ACFUUID::ACFUUID(
		CFStringRef inString)
: ACFType(::CFUUIDCreateFromString(inString),false)
{
}

inline
ACFUUID::ACFUUID(
		const CFUUIDBytes &inBytes)
: ACFType(::CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault,inBytes),false)
{
}


