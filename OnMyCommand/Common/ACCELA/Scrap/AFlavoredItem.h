#pragma once

#include "ADrag.h"

#include FW(Carbon,Scrap.h)

class AFlavorIterator;
class AScrapFlavorIterator;
class ADragFlavorIterator;

// ---------------------------------------------------------------------------
#pragma mark AFlavoredItem

class AFlavoredItem {
public:
	virtual AFlavorIterator*
		GetFlavorIterator() = 0;
	virtual UInt32
		GetFlavorCount() = 0;
	virtual bool
		HasFlavor(
				FlavorType inFlavor) = 0;
	virtual Size
		GetFlavorSize(
				FlavorType inFlavor) = 0;
	void
		GetFlavorHandle(
				FlavorType inFlavor,
				Handle outFlavorHandle);
	template <class T>
	void
		GetFlavor(
				FlavorType inFlavor,
				T &outDataObject)
		{ GetFlavorData(inFlavor,&outDataObject,sizeof(T)); }
	virtual void
		GetFlavorData(
				FlavorType inFlavor,
				void *inBuffer,
				Size inBufferSize,
				Size *outDataSize = NULL) = 0;
	
	void
		PutFlavorHandle(
				FlavorType inFlavor,
				Handle inDataHandle,
				FlavorFlags inFlags = 0);
	template <class T>
	void
		PutFlavor(
				FlavorType inFlavor,
				FlavorFlags inFlags,
				const T &inDataObject)
		{ PutFlavorData(inFlavor,inFlags,sizeof(T),&inDataObject); }
	virtual void
		PutFlavorData(
				FlavorType inFlavor,
				FlavorFlags inFlags,
				Size inDataSize,
				const void *inData) = 0;
	virtual void
		PromiseFlavor(
				FlavorType inFlavor,
				FlavorFlags inFlags,
				Size inDataSize = kScrapFlavorSizeUnknown) = 0;
};

// ---------------------------------------------------------------------------
#pragma mark APasteScrap

class APasteScrap :
		public AFlavoredItem
{
public:
		APasteScrap(
				ScrapRef inScrapRef = NULL);
	
	AFlavorIterator*
		GetFlavorIterator();
	UInt32
		GetFlavorCount();
	bool
		HasFlavor(
				FlavorType inFlavor);
	Size
		GetFlavorSize(
				FlavorType inFlavor);
	void
		GetFlavorData(
				FlavorType inFlavor,
				void *inBuffer,
				Size inBufferSize,
				Size *outDataSize = NULL);
	
	void
		PutFlavorData(
				FlavorType inFlavor,
				FlavorFlags inFlags,
				Size inDataSize,
				const void *inData);
	void
		PromiseFlavor(
				FlavorType inFlavor,
				FlavorFlags inFlags,
				Size inDataSize = kScrapFlavorSizeUnknown);
	
protected:
	ScrapRef mScrapRef;
	
	virtual void
		KeepPromise(
				ScrapFlavorType)
		{}
	
	static pascal OSStatus
		PromiseKeeperProc(
				ScrapRef inScrapRef,
				ScrapFlavorType inFlavor,
				void *inUserData);
};

// ---------------------------------------------------------------------------
#pragma mark ACopyScrap

class ACopyScrap :
		public APasteScrap
{
public:
		ACopyScrap(
				ScrapRef inScrapRef = NULL);
};

// ---------------------------------------------------------------------------
#pragma mark AFlavoredDrag

class AFlavoredDrag :
		public AFlavoredItem
{
public:
		AFlavoredDrag(
				ADrag &inDragObject);
		AFlavoredDrag(
				ADragItem inItem);
	virtual
		~AFlavoredDrag();
	
	AFlavorIterator*
		GetFlavorIterator();
	UInt32
		GetFlavorCount();
	bool
		HasFlavor(
				FlavorType inFlavor);
	Size
		GetFlavorSize(
				FlavorType inFlavor);
	void
		GetFlavorData(
				FlavorType inFlavor,
				void *inBuffer,
				Size inBufferSize,
				Size *outDataSize = NULL);
	
	void
		PutFlavorData(
				FlavorType inFlavor,
				FlavorFlags inFlags,
				Size inDataSize,
				const void *inData);
	void
		PromiseFlavor(
				FlavorType inFlavor,
				FlavorFlags inFlags,
				Size inDataSize = kScrapFlavorSizeUnknown);
	
protected:
	ADragItem mDragItem;
	bool mOwnsDrag;
};

// ---------------------------------------------------------------------------
#pragma mark AFlavorIterator

class AFlavorIterator {
public:
	UInt32
		GetCurrentIndex()
		{ return mIndex; }
	UInt32
		GetFlavorCount()
		{ return mFlavorCount; }
	virtual bool
		Next(
				FlavorType &ioFlavor) = 0;
	
	virtual
		operator FlavorType() = 0;
	FlavorType
		operator++();
	
protected:
	UInt32 mIndex,mFlavorCount;
	
		AFlavorIterator()
		: mIndex(0) {}
};

// ---------------------------------------------------------------------------
#pragma mark AScrapFlavorIterator

class AScrapFlavorIterator :
		public AFlavorIterator
{
public:
		AScrapFlavorIterator(
				ScrapRef inScrapRef);
	virtual
		~AScrapFlavorIterator();
		
	bool
		Next(
				FlavorType &ioFlavor);
		operator FlavorType();
	
protected:
	ScrapFlavorInfo *mFlavors;
};

// ---------------------------------------------------------------------------
#pragma mark ADragFlavorIterator

class ADragFlavorIterator :
		public AFlavorIterator
{
public:
		ADragFlavorIterator(
				const ADragItem &inDragItem);
		
	bool
		Next(
				FlavorType &ioFlavor);
		operator FlavorType();
	
protected:
	ADragItem mDragItem;
};
