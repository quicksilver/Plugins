#include "AFlavoredItem.h"
#include "AHandle.h"

// ---------------------------------------------------------------------------

void
AFlavoredItem::PutFlavorHandle(
		FlavorType inFlavor,
		Handle inDataHandle,
		FlavorFlags inFlags)
{
	StLockHandle lockData(inDataHandle);
	
	PutFlavorData(inFlavor,inFlags,::GetHandleSize(inDataHandle),*inDataHandle);
}

// ---------------------------------------------------------------------------

void
AFlavoredItem::GetFlavorHandle(
		FlavorType inFlavor,
		Handle outFlavorHandle)
{
	if (HasFlavor(inFlavor)) {
		Size dataSize = GetFlavorSize(inFlavor);
		
		::SetHandleSize(outFlavorHandle,dataSize);
		
		StLockHandle lockHandle(outFlavorHandle);
		
		GetFlavorData(inFlavor,*outFlavorHandle,dataSize);
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

APasteScrap::APasteScrap(
		ScrapRef inScrapRef)
: mScrapRef(inScrapRef)
{
	if (mScrapRef == NULL)
		::GetCurrentScrap(&mScrapRef);
}

// ---------------------------------------------------------------------------

AFlavorIterator*
APasteScrap::GetFlavorIterator()
{
	return new AScrapFlavorIterator(mScrapRef);
}

// ---------------------------------------------------------------------------

UInt32
APasteScrap::GetFlavorCount()
{
	UInt32 flavorCount;
	
	::GetScrapFlavorCount(mScrapRef,&flavorCount);
	return flavorCount;
}

// ---------------------------------------------------------------------------

bool
APasteScrap::HasFlavor(
		FlavorType inFlavor)
{
	OSStatus err;
	ScrapFlavorFlags flags;
	
	err = ::GetScrapFlavorFlags(mScrapRef,inFlavor,&flags);
	if (err == memFullErr)
		err = noErr;
	return err == noErr;
}

// ---------------------------------------------------------------------------

Size
APasteScrap::GetFlavorSize(
		FlavorType inFlavor)
{
	OSStatus err;
	Size flavorSize = 0;
	
	err = ::GetScrapFlavorSize(mScrapRef,inFlavor,&flavorSize);
	return flavorSize;
}

// ---------------------------------------------------------------------------

void
APasteScrap::GetFlavorData(
		FlavorType inFlavor,
		void *inBuffer,
		Size inBufferSize,
		Size *outDataSize)
{
	OSStatus err;
	Size byteCount = inBufferSize;
	
	err = ::GetScrapFlavorData(mScrapRef,inFlavor,&byteCount,inBuffer);
	if ((err == noErr) && outDataSize)
		*outDataSize = byteCount;
}

// ---------------------------------------------------------------------------

void
APasteScrap::PutFlavorData(
		FlavorType inFlavor,
		FlavorFlags inFlags,
		Size inDataSize,
		const void *inData)
{
	// First two flag bits are the same between scrap and drag
	// The other bits are only used by drags
	inFlags &= 0x0000003;
	
	::PutScrapFlavor(mScrapRef,inFlavor,inFlags,inDataSize,inData);
}

// ---------------------------------------------------------------------------

void
APasteScrap::PromiseFlavor(
		FlavorType inFlavor,
		FlavorFlags inFlags,
		Size inDataSize)
{
	static ScrapPromiseKeeperUPP keeperUPP = NewScrapPromiseKeeperUPP(PromiseKeeperProc);
	
	::PutScrapFlavor(mScrapRef,inFlavor,inFlags,inDataSize,NULL);
	::SetScrapPromiseKeeper(mScrapRef,keeperUPP,(void*)this);
}

// ---------------------------------------------------------------------------

pascal OSStatus
APasteScrap::PromiseKeeperProc(
		ScrapRef inScrapRef,
		ScrapFlavorType inFlavor,
		void *inUserData)
{
#pragma unused(inScrapRef)
	OSStatus err = noErr;
	APasteScrap *scrapObject = static_cast<APasteScrap*>(inUserData);
	
	try {
		scrapObject->KeepPromise(inFlavor);
	}
	catch (OSStatus caughtErr) {
		err = caughtErr;
	}
	catch (...) {
		err = -1;
	}
	return err;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ACopyScrap::ACopyScrap(
		ScrapRef inScrapRef)
: APasteScrap(inScrapRef)
{
	if (inScrapRef == NULL) {
		::ClearCurrentScrap();
		::GetCurrentScrap(&mScrapRef);
	}
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AFlavoredDrag::AFlavoredDrag(
		ADrag &inDragObject)
: mDragItem(ADragItem(inDragObject,1))
{
}

// ---------------------------------------------------------------------------

AFlavoredDrag::AFlavoredDrag(
		ADragItem inItem)
: mDragItem(inItem)
{
}

// ---------------------------------------------------------------------------

AFlavoredDrag::~AFlavoredDrag()
{
}

// ---------------------------------------------------------------------------

AFlavorIterator*
AFlavoredDrag::GetFlavorIterator()
{
	return new ADragFlavorIterator(mDragItem);
}

// ---------------------------------------------------------------------------

UInt32
AFlavoredDrag::GetFlavorCount()
{
	return mDragItem.CountFlavors();
}

// ---------------------------------------------------------------------------

bool
AFlavoredDrag::HasFlavor(
		FlavorType inFlavor)
{
	return mDragItem.HasFlavor(inFlavor);
}

// ---------------------------------------------------------------------------

Size
AFlavoredDrag::GetFlavorSize(
		FlavorType inFlavor)
{
	return mDragItem.GetFlavorSize(inFlavor);
}

// ---------------------------------------------------------------------------

void
AFlavoredDrag::GetFlavorData(
		FlavorType inFlavor,
		void *inBuffer,
		Size inBufferSize,
		Size *outDataSize)
{
	Size byteCount = inBufferSize;
	
	mDragItem.GetFlavorData(inFlavor,inBuffer,byteCount);
	if (outDataSize)
		*outDataSize = byteCount;
}

// ---------------------------------------------------------------------------

void
AFlavoredDrag::PutFlavorData(
		FlavorType inFlavor,
		FlavorFlags inFlags,
		Size inDataSize,
		const void *inData)
{
	mDragItem.AddFlavorData(inFlavor,inData,inDataSize,inFlags);
}

// ---------------------------------------------------------------------------

void
AFlavoredDrag::PromiseFlavor(
		FlavorType inFlavor,
		FlavorFlags inFlags,
		Size inDataSize)
{
#pragma unused(inDataSize)
	mDragItem.PromiseFlavor(inFlavor,inFlags);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

FlavorType
AFlavorIterator::operator++()
{
	FlavorType flavor;
	
	if (Next(flavor))
		return flavor;
	else
		return 0L;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

AScrapFlavorIterator::AScrapFlavorIterator(
		ScrapRef inScrapRef)
{
	::GetScrapFlavorCount(inScrapRef,&mFlavorCount);
	mFlavors = (ScrapFlavorInfo*) NewPtr(sizeof(ScrapFlavorInfo)*mFlavorCount);
}

// ---------------------------------------------------------------------------

AScrapFlavorIterator::~AScrapFlavorIterator()
{
	::DisposePtr((Ptr)mFlavors);
}

// ---------------------------------------------------------------------------

bool
AScrapFlavorIterator::Next(
		FlavorType &ioFlavor)
{
	if (mIndex < mFlavorCount) {
		ioFlavor = mFlavors[mIndex].flavorType;
		mIndex++;
		return true;
	}
	else
		return false;
}

// ---------------------------------------------------------------------------

AScrapFlavorIterator::operator FlavorType()
{
	if (mIndex < mFlavorCount)
		return mFlavors[mIndex].flavorType;
	else
		return 0L;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ADragFlavorIterator::ADragFlavorIterator(
		const ADragItem &inDragItem)
: mDragItem(inDragItem)
{
	mFlavorCount = mDragItem.CountFlavors();
}

// ---------------------------------------------------------------------------

bool
ADragFlavorIterator::Next(
		FlavorType &ioFlavor)
{
	if (mIndex <= mFlavorCount) {
		mIndex++;
		ioFlavor = mDragItem.GetIndFlavor(mIndex);
		return true;
	}
	else
		return false;
}

// ---------------------------------------------------------------------------

ADragFlavorIterator::operator FlavorType()
{
	if (mIndex < mFlavorCount)
		return mDragItem.GetIndFlavor(mIndex+1);
	else
		return 0L;
}
