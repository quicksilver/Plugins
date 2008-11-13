#include "ADetachedDrag.h"

#include <stdexcept>

// ---------------------------------------------------------------------------

ADetachedDrag::ADetachedDrag(
		ADragItem inDragItem)
{
	ADragFlavorIterator iter(inDragItem);
	FlavorType flavor;
	
	while (iter.Next(flavor)) {
		Size dataSize = inDragItem.GetFlavorSize(flavor);
		Handle dataHandle = ::NewHandle(dataSize);
		
		inDragItem.GetFlavorData(flavor,*dataHandle,dataSize);
		mDataList.push_back(dataHandle);
		mFlavors.push_back(flavor);
	}
}

// ---------------------------------------------------------------------------

ADetachedDrag::~ADetachedDrag()
{
	std::vector<Handle>::iterator iter;
	
	for (iter = mDataList.begin(); iter != mDataList.end(); iter++)
		::DisposeHandle(*iter);
}

// ---------------------------------------------------------------------------

AFlavorIterator*
ADetachedDrag::GetFlavorIterator()
{
	return new ADetachedDragIterator(this);
}

// ---------------------------------------------------------------------------

void
ADetachedDrag::GetFlavorData(
		FlavorType inFlavor,
		void *inBuffer,
		Size inBufferSize,
		Size *outDataSize)
{
	std::vector<FlavorType>::iterator iter;
	int i;
	
	for (iter = mFlavors.begin(), i = 0; iter != mFlavors.end(); iter++, i++)
		if (*iter == inFlavor)
			break;
	
	if (iter == mFlavors.end())
		throw std::runtime_error("flavor not found");
	
	Handle dataHandle = mDataList[i];
	Size outputSize = inBufferSize;
	
	outputSize = ::GetHandleSize(dataHandle);
	if (outDataSize != NULL)
		*outDataSize = outputSize;
	if (outputSize > inBufferSize)
		outputSize = inBufferSize;
	::BlockMoveData(*dataHandle,inBuffer,outputSize);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ADetachedDragIterator::ADetachedDragIterator(
		ADetachedDrag *inDrag)
: mDrag(inDrag)
{
	mIndex = 0xFFFFFFFF;	// + 1 = 0
	mFlavorCount = inDrag->GetFlavorCount();
}

// ---------------------------------------------------------------------------

ADetachedDragIterator::~ADetachedDragIterator()
{
}

// ---------------------------------------------------------------------------

bool
ADetachedDragIterator::Next(
		FlavorType &ioFlavor)
{
	bool success = false;
	
	mIndex++;
	if (mIndex <= mDrag->GetFlavorCount()) {
		ioFlavor = mDrag->GetIndFlavor(mIndex);
		success = true;
	}
	return success;
}

// ---------------------------------------------------------------------------

ADetachedDragIterator::operator FlavorType()
{
	return mDrag->GetIndFlavor(mIndex);
}
