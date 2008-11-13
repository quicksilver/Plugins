#include "ACFBase.h"

#include FW(CoreFoundation,CFData.h)

// ---------------------------------------------------------------------------

class ACFData :
		public ACFType<CFDataRef>
{
public:
		ACFData(
				CFDataRef inRef,
				bool inDoRetain = true)
		: ACFType<CFDataRef>(inRef,inDoRetain) {}
		ACFData(
				const UInt8 *inData,
				CFIndex inSize,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFType<CFDataRef>(::CFDataCreate(inAllocator,inData,inSize),false) {}
	
	CFIndex
		Length() const;
	const UInt8*
		BytePtr() const;
	void
		GetBytes(
				UInt8 *inBuffer,
				CFRange inRange) const;
};

// ---------------------------------------------------------------------------

class ACFMutableData :
		public ACFData
{
public:
		ACFMutableData(
				CFDataRef inRef,
				bool inDoRetain = true)
		: ACFData(inRef,inDoRetain) {}
		ACFMutableData(
				CFIndex inSize,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFData(::CFDataCreateMutable(inAllocator,inSize),false) {}
		ACFMutableData(
				const UInt8 *inData,
				CFIndex inSize,
				CFAllocatorRef inAllocator = kCFAllocatorDefault)
		: ACFData(::CFDataCreateMutable(inAllocator,inSize),false)
		{
			ReplaceBytes(CFRangeMake(0,inSize),inData,inSize);
		}
	
		operator CFMutableDataRef()
		{
			return (CFMutableDataRef)mObjectRef;
		}
	
	UInt8*
		BytePtr();
	void
		SetLength(
				CFIndex inLength);
	void
		IncreaseLength(
				CFIndex inExtra);
	void
		AppendBytes(
				const UInt8 *inBytes,
				CFIndex inLength);
	void
		ReplaceBytes(
				CFRange inRange,
				const UInt8 *inBytes,
				CFIndex inLength);
	void
		DeleteBytes(
				CFRange inRange);
};

// ---------------------------------------------------------------------------

inline CFIndex
ACFData::Length() const
{
	return ::CFDataGetLength(*this);
}

inline const UInt8*
ACFData::BytePtr() const
{
	return ::CFDataGetBytePtr(*this);
}

inline void
ACFData::GetBytes(
		UInt8 *inBuffer,
		CFRange inRange) const
{
	::CFDataGetBytes(*this,inRange,inBuffer);
}

// ---------------------------------------------------------------------------

inline UInt8*
ACFMutableData::BytePtr()
{
	return ::CFDataGetMutableBytePtr(*this);
}

inline void
ACFMutableData::SetLength(
		CFIndex inLength)
{
	::CFDataSetLength(*this,inLength);
}

inline void
ACFMutableData::IncreaseLength(
		CFIndex inExtra)
{
	::CFDataIncreaseLength(*this,inExtra);
}

inline void
ACFMutableData::AppendBytes(
		const UInt8 *inBytes,
		CFIndex inLength)
{
	::CFDataAppendBytes(*this,inBytes,inLength);
}

inline void
ACFMutableData::ReplaceBytes(
		CFRange inRange,
		const UInt8 *inBytes,
		CFIndex inLength)
{
	::CFDataReplaceBytes(*this,inRange,inBytes,inLength);
}

inline void
ACFMutableData::DeleteBytes(
		CFRange inRange)
{
	::CFDataDeleteBytes(*this,inRange);
}
