// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AAEDescList.h"

class AAERecord :
		public AAEDescList
{
public:
		AAERecord();
		AAERecord(
				const AEDesc &inRecord,
				bool inDoDispose = false)
		: AAEDescList(inRecord,inDoDispose) {}
	
	void
		PutKeyPtr(
				AEKeyword inKey,
				DescType inTypeCode,
				const void *inDataPtr,
				Size inDataSize);
	template <class T>
	void
		PutKey(
				AEKeyword inKey,
				DescType inTypeCode,
				const T &inData)
		{
			PutKeyPtr(inKey,inTypeCode,&inData,sizeof(inData));
		}
	void
		PutKeyDesc(
				AEKeyword inKey,
				const AEDesc &inDesc);
	
	void
		GetKeyPtr(
				AEKeyword inKey,
				DescType inDesiredType,
				DescType &outTypeCode,
				const void *inDataPtr,
				Size inMaxSize,
				Size &outActualSize) const;
	void
		GetKeyPtr(
				AEKeyword inKey,
				DescType inTypeCode,
				const void *inDataPtr,
				Size inDataSize) const;
	template <class T>
	void
		GetKey(
				AEKeyword inKey,
				DescType inTypeCode,
				T &outData) const
		{
			GetKeyPtr(inKey,inTypeCode,&outData,sizeof(outData));
		}
	void
		GetKeyDesc(
				AEKeyword inKey,
				AEDesc &outDesc,
				DescType inDesiredType = typeWildCard) const;
	template <class T>
	T
		Key(
				AEKeyword inKey,
				DescType inDesiredType = typeWildCard) const
		{
			T dataObject;
			GetKey(inKey,inDesiredType,dataObject);
			return dataObject;
		}
	
	Size
		SizeOfKey(
				AEKeyword inKey) const;
	bool
		HasKey(
				AEKeyword inKey) const;
	void
		DeleteKey(
				AEKeyword inKey);
};

inline
AAERecord::AAERecord()
: AAEDescList(true) {}

inline void
AAERecord::PutKeyPtr(
				AEKeyword inKey,
				DescType inTypeCode,
				const void *inDataPtr,
				Size inDataSize)
{
	CThrownOSStatus err = ::AEPutKeyPtr(this,inKey,inTypeCode,inDataPtr,inDataSize);
}

inline void
AAERecord::PutKeyDesc(
				AEKeyword inKey,
				const AEDesc &inDesc)
{
	CThrownOSStatus err = ::AEPutKeyDesc(this,inKey,&inDesc);
}
	
inline void
AAERecord::GetKeyPtr(
				AEKeyword inKey,
				DescType inDesiredType,
				DescType &outTypeCode,
				const void *inDataPtr,
				Size inMaxSize,
				Size &outActualSize) const
{
	CThrownOSStatus err = ::AEGetKeyPtr(this,inKey,inDesiredType,&outTypeCode,const_cast<void*>(inDataPtr),inMaxSize,&outActualSize);
}

inline void
AAERecord::GetKeyPtr(
				AEKeyword inKey,
				DescType inTypeCode,
				const void *inDataPtr,
				Size inDataSize) const
{
	Size actualSize = 0;
	DescType typeCode = typeNull;
	CThrownOSStatus err = ::AEGetKeyPtr(this,inKey,inTypeCode,&typeCode,const_cast<void*>(inDataPtr),inDataSize,&actualSize);
}

inline void
AAERecord::GetKeyDesc(
				AEKeyword inKey,
				AEDesc &outDesc,
				DescType inDesiredType) const
{
	CThrownOSStatus err = ::AEGetKeyDesc(this,inKey,inDesiredType,&outDesc);
}

inline Size
AAERecord::SizeOfKey(
				AEKeyword inKey) const
{
	Size keySize = 0;
	DescType keyType;
	CThrownOSStatus err = ::AESizeOfKeyDesc(this,inKey,&keyType,&keySize);
	return keySize;
}

inline bool
AAERecord::HasKey(
				AEKeyword inKey) const
{
	Size keySize = 0;
	DescType keyType;
	return (::AESizeOfKeyDesc(this,inKey,&keyType,&keySize) == noErr);
}

inline void
AAERecord::DeleteKey(
				AEKeyword inKey)
{
	CThrownOSStatus err = ::AEDeleteParam(this,inKey);
}
