// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(ApplicationServices,AppleEvents.h)
#include FW(ApplicationServices,AEDataModel.h)

#include "CThrownResult.h"

class AAEDesc :
		public AEDesc
{
public:
		AAEDesc();
		AAEDesc(
				const AEDesc &inDesc,
				bool inDoDispose = false);
		AAEDesc(
				DescType inType,
				const void *inDataPtr,
				Size inSize);
		template <class T>
		AAEDesc(
				DescType inType,
				const T &inDataObject);
		AAEDesc(
				DescType inFromType,
				DescType inToType,
				const void *inDataPtr,
				Size inSize);
		AAEDesc(
				DescType inToType,
				const AEDesc &inDesc);
	virtual
		~AAEDesc()
		{
			if (mDoDispose && (descriptorType != typeNull))
				::AEDisposeDesc(this);
		}
		
	void
		GetDescData(
				void *inData,
				Size inDataSize) const;
	template <class T>
	void
		GetDescData(
				T &outDataObject) const
		{
			GetDescData(&outDataObject,sizeof(outDataObject));
		}
	Size
		DataSize() const;
	
	AEDesc
		Coerce(
				DescType inToType);
	AEDesc
		Duplicate();
	
	bool
		IsRecord() const;
	
	void
		Detach()
		{
			mDoDispose = false;
		}
	
protected:
	bool mDoDispose;
};

// ---------------------------------------------------------------------------

inline
AAEDesc::AAEDesc()
: mDoDispose(true)
{
	::AEInitializeDesc(this);
}

inline
AAEDesc::AAEDesc(
		const AEDesc &inDesc,
		bool inDoDispose)
: AEDesc(inDesc), mDoDispose(inDoDispose)
{
}

inline
AAEDesc::AAEDesc(
		DescType inType,
		const void *inDataPtr,
		Size inSize)
: mDoDispose(true)
{
	CThrownOSStatus err = ::AECreateDesc(inType,inDataPtr,inSize,this);
}

template <class T>
inline
AAEDesc::AAEDesc(
		DescType inType,
		const T &inDataObject)
: mDoDispose(true)
{
	CThrownOSStatus err = ::AECreateDesc(inType,&inDataObject,sizeof(T),this);
}

inline
AAEDesc::AAEDesc(
		DescType inFromType,
		DescType inToType,
		const void *inDataPtr,
		Size inSize)
: mDoDispose(true)
{
	CThrownOSStatus err = ::AECoercePtr(inFromType,inDataPtr,inSize,inToType,this);
}

inline
AAEDesc::AAEDesc(
		DescType inToType,
		const AEDesc &inDesc)
: mDoDispose(true)
{
	CThrownOSStatus err = ::AECoerceDesc(&inDesc,inToType,this);
}

inline void
AAEDesc::GetDescData(
		void *inData,
		Size inDataSize) const
{
	CThrownOSStatus err = ::AEGetDescData(this,inData,inDataSize);
}

inline Size
AAEDesc::DataSize() const
{
	return ::AEGetDescDataSize(this);
}

inline bool
AAEDesc::IsRecord() const
{
	return ::AECheckIsRecord(this);
}
