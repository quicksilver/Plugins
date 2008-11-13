// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "AAERecord.h"

#include "CThrownResult.h"

class AAppleEvent :
		public AAERecord
{
public:
		AAppleEvent(
				AEEventClass inEventClass,
				AEEventID inEventID,
				const AEAddressDesc &inTarget,
				AEReturnID returnID = kAutoGenerateReturnID,
				AETransactionID transactionID = kAnyTransactionID);
		AAppleEvent(
				AEEventClass inEventClass,
				AEEventID inEventID,
				OSType inTargetSignature,
				AEReturnID returnID = kAutoGenerateReturnID,
				AETransactionID transactionID = kAnyTransactionID);
		AAppleEvent(
				const AEDesc &inEvent,
				bool inDoDispose = false)
		: AAERecord(inEvent,inDoDispose) {}
	
	// map parameter calls to key calls
	void
		PutParamPtr(
				AEKeyword inKey,
				DescType inTypeCode,
				const void *inDataPtr,
				Size inDataSize)
		{
			PutKeyPtr(inKey,inTypeCode,inDataPtr,inDataSize);
		}
	template <class T>
	void
		PutParam(
				AEKeyword inKey,
				DescType inTypeCode,
				const T &inData)
		{
			PutKeyPtr(inKey,inTypeCode,&inData,sizeof(inData));
		}
	void
		PutParam(
				AEKeyword inKey,
				const AEDesc &inDesc)
		{
			PutKeyDesc(inKey,inDesc);
		}
	
	void
		GetParamPtr(
				AEKeyword inKey,
				DescType inDesiredType,
				DescType &outTypeCode,
				void *inDataPtr,
				Size inMaxSize,
				Size &outActualSize) const
		{
			GetKeyPtr(inKey,inDesiredType,outTypeCode,inDataPtr,inMaxSize,outActualSize);
		}
	void
		GetParamPtr(
				AEKeyword inKey,
				DescType inTypeCode,
				void *inDataPtr,
				Size inDataSize) const
		{
			GetKeyPtr(inKey,inTypeCode,inDataPtr,inDataSize);
		}
	template <class T>
	void
		GetParam(
				AEKeyword inKey,
				DescType inTypeCode,
				T &outData) const
		{
			GetKeyPtr(inKey,inTypeCode,&outData,sizeof(outData));
		}
	void
		GetParamDesc(
				AEKeyword inKey,
				AEDesc &outDesc,
				DescType inDesiredType = typeWildCard) const
		{
			GetKeyDesc(inKey,outDesc,inDesiredType);
		}
	AEDesc
		ParamDesc(
				AEKeyword inKey,
				DescType inDesiredType = typeWildCard) const
		{
			AEDesc desc;
			GetParamDesc(inKey,desc,inDesiredType);
			return desc;
		}
	template <class T>
	T
		Param(
				AEKeyword inKey,
				DescType inDesiredType = typeWildCard) const
		{
			return Key<T>(inKey,inDesiredType);
		}
	bool
		HasParam(
				AEKeyword inKey) const
		{
			return HasKey(inKey);
		}
	
	void
		GetAttribute(
				AEKeyword inKeyword,
				DescType inDesiredType,
				AEDesc &outDesc) const;
	void
		GetAttribute(
				AEKeyword inKeyword,
				DescType inDesiredType,
				DescType &outActualType,
				void *outData,
				Size inMaxSize,
				Size &outActualSize) const;
	template <class T>
	void
		GetAttribute(
				AEKeyword inKeyword,
				DescType inDesiredType,
				DescType &outActualType,
				T &outDataObject) const
		{
			Size actualSize;
			GetAttribute(inKeyword,inDesiredType,outActualType,&outDataObject,sizeof(T),actualSize);
		}
	Size
		AttributeSize(
				AEKeyword inKeyword,
				DescType &outType) const;
	void
		PutAttribute(
				AEKeyword inKeyword,
				const AEDesc &inDesc);
	void
		PutAttribute(
				AEKeyword inKeyword,
				DescType inType,
				const void *inData,
				Size inSize);
	template <class T>
	void
		PutAttribute(
				AEKeyword inKeyword,
				DescType inType,
				const T &inDataObject)
		{
			PutAttribute(inKeyword,inType,&inDataObject,sizeof(T));
		}
	
	AEEventClass
		EventClass() const
		{
			AEEventClass eventClass;
			DescType actualType;
			GetAttribute(keyEventClassAttr,typeType,actualType,eventClass);
			return eventClass;
		}
	AEEventID
		EventID() const
		{
			AEEventClass eventClass;
			DescType actualType;
			GetAttribute(keyEventIDAttr,typeType,actualType,eventClass);
			return eventClass;
		}
	
	void
		Send(
				AEDesc &inReply,
				AESendMode inMode = kAEWaitReply,
				AESendPriority inPriority = kAENormalPriority,
				long inTimeOut = kAEDefaultTimeout);
	void
		Send(
				AESendPriority inPriority = kAENormalPriority);
};

class ASelfEvent :
		public AAppleEvent
{
public:
		ASelfEvent(
				AEEventClass inEventClass,
				AEEventID inEventID)
		: AAppleEvent(inEventClass,inEventID,GetAppSignature()) {}
	
protected:
	static OSType
		GetAppSignature();
};

// ---------------------------------------------------------------------------

inline
AAppleEvent::AAppleEvent(
		AEEventClass inEventClass,
		AEEventID inEventID,
		const AEAddressDesc &inTarget,
		AEReturnID inReturnID,
		AETransactionID inTransactionID)
{
	CThrownOSStatus err = ::AECreateAppleEvent(inEventClass,inEventID,&inTarget,inReturnID,inTransactionID,this);
}

inline
AAppleEvent::AAppleEvent(
		AEEventClass inEventClass,
		AEEventID inEventID,
		OSType inTargetSignature,
		AEReturnID inReturnID,
		AETransactionID inTransactionID)
{
	AAEDesc targetDesc(typeApplSignature,inTargetSignature);
	CThrownOSStatus err = ::AECreateAppleEvent(inEventClass,inEventID,&targetDesc,inReturnID,inTransactionID,this);
}

inline void
AAppleEvent::GetAttribute(
		AEKeyword inKeyword,
		DescType inDesiredType,
		AEDesc &outDesc) const
{
	CThrownOSErr err = ::AEGetAttributeDesc(this,inKeyword,inDesiredType,&outDesc);
}

inline void
AAppleEvent::GetAttribute(
		AEKeyword inKeyword,
		DescType inDesiredType,
		DescType &outActualType,
		void *outData,
		Size inMaxSize,
		Size &outActualSize) const
{
	CThrownOSErr err = ::AEGetAttributePtr(this,inKeyword,inDesiredType,&outActualType,outData,inMaxSize,&outActualSize);
}

inline Size
AAppleEvent::AttributeSize(
		AEKeyword inKeyword,
		DescType &outType) const
{
	Size attrSize;
	CThrownOSErr err = ::AESizeOfAttribute(this,inKeyword,&outType,&attrSize);
	return attrSize;
}

inline void
AAppleEvent::PutAttribute(
		AEKeyword inKeyword,
		const AEDesc &inDesc)
{
	CThrownOSErr err = ::AEPutAttributeDesc(this,inKeyword,&inDesc);
}

inline void
AAppleEvent::PutAttribute(
		AEKeyword inKeyword,
		DescType inType,
		const void *inData,
		Size inSize)
{
	CThrownOSErr err = ::AEPutAttributePtr(this,inKeyword,inType,inData,inSize);
}

inline void
AAppleEvent::Send(
		AEDesc &inReply,
		AESendMode inMode,
		AESendPriority inPriority,
		long inTimeOut)
{
	CThrownOSStatus err = ::AESend(this,&inReply,inMode,inPriority,inTimeOut,NULL,NULL);
}

inline void
AAppleEvent::Send(
		AESendPriority inPriority)
{
	AAEDesc reply;
	CThrownOSStatus err = ::AESend(this,&reply,kAENoReply,inPriority,kAEDefaultTimeout,NULL,NULL);
}
