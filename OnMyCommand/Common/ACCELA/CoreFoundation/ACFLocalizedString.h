// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFString.h"

class ACFLocalizedString :
		public ACFString
{
public:
		ACFLocalizedString(
				CFStringRef inString,
				bool inDoRetain = true)
		: ACFString(inString,inDoRetain)
		{ Localize(); }
		ACFLocalizedString(
				ConstStr255Param inPString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFString(inPString,inEncoding,inAllocator)
		{ Localize(); }
		ACFLocalizedString(
				const char *inCString,
				CFStringEncoding inEncoding = kCFStringEncodingMacRoman,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFString(inCString,inEncoding,inAllocator)
		{ Localize(); }
		ACFLocalizedString(
				const UniChar *inCharacters,
				CFIndex inNumChars,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFString(inCharacters,inNumChars,inAllocator)
		{ Localize(); }
};
