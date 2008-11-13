// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACFString.h"

#include FW(Carbon,Appearance.h)

// ---------------------------------------------------------------------------

bool
ACFString::Localize()
{
	bool localized = false;
	
	if (mObjectRef != NULL) {
		CFStringRef local = CFCopyLocalizedString(*this,CFSTR("no comment"));
		
		if (local != NULL) {
			if (local != mObjectRef) {
				Reset(local,false);
				localized = true;
			}
			else
				::CFRelease(local);
		}
	}
	return localized;
}

// ---------------------------------------------------------------------------

//_tk_ problematic with interface-less unix code
/*
void
ACFString::EncodePascalString(
		StringPtr outPString) const
{
	ByteCount runLength;
	
	::GetTextAndEncodingFromCFString(*this,&outPString[1],255,&runLength,NULL);
	outPString[0] = runLength;
}
*/

// ---------------------------------------------------------------------------

UInt8*
ACFString::MakeBytesBuffer(
		CFStringEncoding inEncoding,
		CFIndex &outBufferLen,
		UInt8 inLossByte,
		bool inIsExternal) const
{
	outBufferLen = GetBytesLen(inEncoding,inLossByte,inIsExternal);
	
	UInt8 *buffer = new UInt8[outBufferLen];
	
	GetBytes(CFRangeMake(0,Length()),inEncoding,inLossByte,inIsExternal,buffer,outBufferLen,outBufferLen);
	return buffer;
}
