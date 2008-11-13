#pragma once

#include "FW.h"

#include FW(Carbon,Scrap.h)
#include FW(Carbon,Drag.h)

// ---------------------------------------------------------------------------

class AScrap
{
public:
	operator
		ScrapRef()
		{ return mScrapRef; }
	
protected:
	ScrapRef mScrapRef;
	
		AScrap();
		AScrap(
				ScrapRef inScrapRef)
		: mScrapRef(inScrapRef) {};
};

// ---------------------------------------------------------------------------

class AIncomingScrap
		: public AScrap {
public:
		AIncomingScrap(
				ScrapRef inScrapRef)
		: AScrap(inScrapRef),mFlavorList(NULL) {}
	
	FlavorFlags
		GetFlavorFlags(
				ScrapFlavorType inFlavorType);
	Size
		GetFlavorSize(
				ScrapFlavorType inFlavorType);
	UInt32
		GetFlavorCount();
	ScrapFlavorType
		GetIndFlavor(
				UInt32 inFlavorIndex);
	OSStatus
		GetFlavorData(
				ScrapFlavorType inFlavorType,
				Size inBufferSize,
				void *outBuffer);
	template <class T>
	OSStatus
		GetFlavorData(
				ScrapFlavorType inFlavorType,
				T &outDataObject)
		{ return ::GetScrapFlavorData(mScrapRef,inFlavorType,sizeof(T),&outDataObject); }
	
protected:
	UInt32 mFlavorCount;
	ScrapFlavorInfo *mFlavorList;
};

// ---------------------------------------------------------------------------

class AOutgoingScrap :
		public AScrap
{
public:
		AOutgoingScrap() {}
		AOutgoingScrap(
				ScrapRef inScrapRef)
		: AScrap(inScrapRef) {};
	
	OSStatus
		PutFlavor(
				ScrapFlavorType inFlavorType,
				Size inBufferSize,
				const void *inBuffer,
				ScrapFlavorFlags inFlags = kScrapFlavorMaskNone);
	template <class T>
	OSStatus
		PutFlavor(
				ScrapFlavorType inFlavorType,
				const T &inDataObject,
				ScrapFlavorFlags inFlags = kScrapFlavorMaskNone)
		{ return ::PutScrapFlavor(mScrapRef,inFlavorType,inFlags,sizeof(T),&inDataObject); }
};

// ---------------------------------------------------------------------------

class APromiseScrap :
		public AOutgoingScrap
{
public:
		APromiseScrap() {}
		APromiseScrap(
				ScrapRef inScrapRef)
		: AOutgoingScrap(inScrapRef) {};
	
	OSStatus
		PutPromisedFlavor(
				ScrapFlavorType inFlavorType,
				Size inSize = -1,
				ScrapFlavorFlags inFlags = kScrapFlavorMaskNone);
	
	virtual OSStatus
		KeepPromise(
				ScrapFlavorType inFlavor) = 0;
	
protected:
	static ScrapPromiseKeeperUPP sPromiseKeeperUPP;
	
	static pascal OSStatus
		PromiseKeeperCallback(
				ScrapRef inScrap,
				ScrapFlavorType inFlavorType,
				void *inUserData);
};

// ---------------------------------------------------------------------------
// not fully implented

class AScrapFlavorIterator
{
public:
		AScrapFlavorIterator(
				AScrap *inScrap);
	
/*
		operator ScrapFlavorType();
*/
	AScrapFlavorIterator&
		operator++();
	
protected:
	ScrapFlavorInfo *mInfoArray;
	UInt32 mFlavorCount,mCurrentIndex;
};
