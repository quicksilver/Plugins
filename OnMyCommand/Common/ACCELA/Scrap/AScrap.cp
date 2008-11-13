#include "AScrap.h"


// ---------------------------------------------------------------------------

AScrap::AScrap()
{
	::GetCurrentScrap(&mScrapRef);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

FlavorFlags
AIncomingScrap::GetFlavorFlags(
		ScrapFlavorType inFlavorType)
{
	ScrapFlavorFlags flags;
	
	::GetScrapFlavorFlags(mScrapRef,inFlavorType,&flags);
	return flags;
}

// ---------------------------------------------------------------------------

Size
AIncomingScrap::GetFlavorSize(
		ScrapFlavorType inFlavorType)
{
	Size flavorSize;
	
	::GetScrapFlavorSize(mScrapRef,inFlavorType,&flavorSize);
	return flavorSize;
}

// ---------------------------------------------------------------------------

UInt32
AIncomingScrap::GetFlavorCount()
{
	UInt32 flavorCount;
	
	::GetScrapFlavorCount(mScrapRef,&flavorCount);
	return flavorCount;
}

// ---------------------------------------------------------------------------

ScrapFlavorType
AIncomingScrap::GetIndFlavor(
		UInt32 inFlavorIndex)
{
	if (mFlavorList == NULL) {
		UInt32 realCount;
		
		realCount = mFlavorCount = GetFlavorCount();
		mFlavorList = (ScrapFlavorInfo*)NewPtr(sizeof(ScrapFlavorInfo)*mFlavorCount);
		::GetScrapFlavorInfoList(mScrapRef,&realCount,mFlavorList);
	}
	return mFlavorList[inFlavorIndex].flavorType;
}

// ---------------------------------------------------------------------------

OSStatus
AIncomingScrap::GetFlavorData(
		ScrapFlavorType inFlavorType,
		Size inBufferSize,
		void *outBuffer)
{
	Size dataSize = inBufferSize;
	
	return ::GetScrapFlavorData(mScrapRef,inFlavorType,&dataSize,outBuffer);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

OSStatus
AOutgoingScrap::PutFlavor(
		ScrapFlavorType inFlavorType,
		Size inBufferSize,
		const void *inBuffer,
		ScrapFlavorFlags inFlags)
{
	return ::PutScrapFlavor(mScrapRef,inFlavorType,inFlags,inBufferSize,inBuffer);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

OSStatus
APromiseScrap::PutPromisedFlavor(
		ScrapFlavorType inFlavorType,
		Size inSize,
		ScrapFlavorFlags inFlags)
{
	return ::PutScrapFlavor(mScrapRef,inFlavorType,inFlags,inSize,NULL);
}

// ---------------------------------------------------------------------------

pascal OSStatus
APromiseScrap::PromiseKeeperCallback(
		ScrapRef inScrap,
		ScrapFlavorType inFlavorType,
		void *inUserData)
{
	return reinterpret_cast<APromiseScrap*>(inUserData)->KeepPromise(inFlavorType);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------
/*
AScrapFlavorIterator::AScrapFlavorIterator(
		AScrap *inScrap)
{
}

// ---------------------------------------------------------------------------

AScrapFlavorIterator::operator ScrapFlavorType()
{
}

// ---------------------------------------------------------------------------

AScrapFlavorIterator&
AScrapFlavorIterator::operator++()
{
}
*/
