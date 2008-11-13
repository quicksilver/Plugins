#include "AFlavoredItem.h"

#include <vector>

class ADetachedDragIterator;

class ADetachedDrag
		: public AFlavoredItem
{
public:
		ADetachedDrag(
				ADragItem inDragItem);
	virtual
		~ADetachedDrag();
	
	// AFlavoredItem
	
	AFlavorIterator*
		GetFlavorIterator();
	
	UInt32
		GetFlavorCount()
		{ return mFlavors.size(); }
	void
		GetFlavorData(
				FlavorType inFlavor,
				void *inBuffer,
				Size inBufferSize,
				Size *outDataSize = NULL);
	
	// ADetachedDrag
	
	FlavorType
		GetIndFlavor(
				std::vector<FlavorType>::size_type inIndex)
		{ return mFlavors[inIndex]; }
	
protected:
	std::vector<FlavorType> mFlavors;
	std::vector<Handle> mDataList;
	
	// AFlavoredItem
	
	void
		PutFlavorData(
				FlavorType,
				FlavorFlags,
				Size,
				const void *) {}
	void
		PromiseFlavor(
				FlavorType,
				FlavorFlags,
				Size) {}
};

// ---------------------------------------------------------------------------

class ADetachedDragIterator
		: public AFlavorIterator
{
public:
		ADetachedDragIterator(
				ADetachedDrag *inDrag);
	virtual
		~ADetachedDragIterator();
	
	// AFlavorIterator
	
	bool
		Next(
				FlavorType &ioFlavor);
		operator FlavorType();
	
protected:
	ADetachedDrag *mDrag;
};
