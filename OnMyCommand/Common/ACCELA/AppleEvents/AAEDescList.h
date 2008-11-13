// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AAEDesc.h"
#include "XValueType.h"

class AAEDescList :
		public AAEDesc
{
public:
		AAEDescList();
		AAEDescList(
				bool inIsRecord,
				const void *inFactoringPtr = NULL,
				Size inFactoredSize = 0);
		AAEDescList(
				const AEDesc &inList,
				bool inDoDispose = false)
		: AAEDesc(inList,inDoDispose) {}
	
	long
		Count() const;
	
	void
		Put(
				long inIndex,
				DescType inTypeCode,
				const void *inDataPtr,
				Size inDataSize);
	template <class T>
	void
		Put(
				long inIndex,
				DescType inTypeCode,
				const T &inData)
		{
			Put(inIndex,inTypeCode,&inData,sizeof(inData));
		}
	void
		Put(
				long inIndex,
				const AEDesc &inDesc);
	
	//_tk_: 0-based index
	AEDesc
		operator[](
				long inIndex) const;
	void
		GetNthPtr(
				long inIndex,
				DescType inDesiredType,
				AEKeyword &outAEKeyword,
				DescType &outTypeCode,
				void *inDataPtr,
				Size inMaximumSize,
				Size &outActualSize) const;
	void
		GetNthPtr(
				long inIndex,
				DescType inDesiredType,
				void *inDataPtr,
				Size inMaximumSize) const;
	template <class T>
	void
		GetNthItem(
				long inIndex,
				DescType inDesiredType,
				T &outDataObject) const
		{
			GetNthPtr(inIndex,inDesiredType,&outDataObject,sizeof(T));
		}
	template <class T>
	T
		NthItem(
				long inIndex,
				DescType inDesiredType = XValueType<T>::GetType())
		{
			T item;
			GetNthPtr(inIndex,inDesiredType,&item,sizeof(item));
			return item;
		}
	
	void
		DeleteItem(
				long inIndex);
};

// ---------------------------------------------------------------------------

inline
AAEDescList::AAEDescList()
{
	CThrownOSErr err = ::AECreateList(NULL,0,false,this);
}

inline
AAEDescList::AAEDescList(
		bool inIsRecord,
		const void *inFactoringPtr,
		Size inFactoredSize)
{
	CThrownOSErr err = ::AECreateList(inFactoringPtr,inFactoredSize,inIsRecord,this);
}

inline long
AAEDescList::Count() const
{
	long itemCount;
  CThrownOSErr err = ::AECountItems(this,&itemCount);
  return itemCount;
}

inline void
AAEDescList::Put(
		long inIndex,
		DescType inTypeCode,
		const void *inDataPtr,
		Size inDataSize)
{
	CThrownOSErr err = ::AEPutPtr(this,inIndex,inTypeCode,inDataPtr,inDataSize);
}

inline void
AAEDescList::Put(
		long inIndex,
		const AEDesc &inDesc)
{
	CThrownOSErr err = ::AEPutDesc(this,inIndex,&inDesc);
}

//_tk_ operator [] index is 0-based, we need 1-based index
inline AEDesc
AAEDescList::operator[](
		long inIndex) const
{
	AEDesc desc;
	AEKeyword keyword;
	CThrownOSErr err = ::AEGetNthDesc(this,inIndex+1,typeWildCard,&keyword,&desc);//_tk_
	return desc;
}

inline void
AAEDescList::GetNthPtr(
		long inIndex,
		DescType inDesiredType,
		AEKeyword &outAEKeyword,
		DescType &outTypeCode,
		void *inDataPtr,
		Size inMaximumSize,
		Size &outActualSize) const
{
	CThrownOSErr err = ::AEGetNthPtr(this,inIndex,inDesiredType,&outAEKeyword,&outTypeCode,inDataPtr,inMaximumSize,&outActualSize);
}

inline void
AAEDescList::GetNthPtr(
		long inIndex,
		DescType inDesiredType,
		void *inDataPtr,
		Size inMaximumSize) const
{
	AEKeyword keyword;
	DescType typeCode;
	Size actualSize;
	CThrownOSErr err = ::AEGetNthPtr(this,inIndex,inDesiredType,&keyword,&typeCode,inDataPtr,inMaximumSize,&actualSize);
}

inline void
AAEDescList::DeleteItem(
		long inIndex)
{
	CThrownOSErr err = ::AEDeleteItem(this,inIndex);
}
