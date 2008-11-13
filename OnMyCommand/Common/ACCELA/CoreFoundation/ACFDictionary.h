#pragma once
#include "ACFBase.h"

class ACFDictionary :
		public ACFType<CFDictionaryRef>
{
public:
		// CFDictionaryRef
		ACFDictionary(
				CFDictionaryRef inDictionary,
				bool inDoRetain = true)
		: ACFType<CFDictionaryRef>(inDictionary,inDoRetain) {}
		// create
		ACFDictionary()
		: ACFType<CFDictionaryRef>(::CFDictionaryCreate(kCFAllocatorDefault,NULL,NULL,0,NULL,NULL),false) {}
		// create with data
		ACFDictionary(
				const void **inKeys,
				const void **inValues,
				CFIndex inNumValues,
				const CFDictionaryKeyCallBacks &inKeyCallbacks,
				const CFDictionaryValueCallBacks &inValueCallbacks)
		: ACFType<CFDictionaryRef>(
				::CFDictionaryCreate(
						kCFAllocatorDefault,
						inKeys,inValues,inNumValues,
						&inKeyCallbacks,&inValueCallbacks),
				false) {}
	
	CFIndex
		Count() const;
	CFIndex
		CountOfKey(
				const void *inKey) const;
	CFIndex
		CountOfValue(
				const void *inValue) const;
	bool
		ContainsKey(
				const void *inKey) const;
	bool
		ContainsValue(
				const void *inValue) const;
	
	const void*
		KeyValue(
				const void *inKey) const;
	bool
		GetValueIfPresent(
				const void *inKey,
				const void *&outValue) const;
	void
		GetKeysAndValues(
				const void *&outKeys,
				const void *&outValue) const;
	
	void
		ApplyFunction(
				CFDictionaryApplierFunction inFunction,
				void *inContext) const;
};

// ---------------------------------------------------------------------------

inline CFIndex
ACFDictionary::Count() const
{
	return ::CFDictionaryGetCount(*this);
}

inline CFIndex
ACFDictionary::CountOfKey(
		const void *inKey) const
{
	return ::CFDictionaryGetCountOfKey(*this,inKey);
}

inline CFIndex
ACFDictionary::CountOfValue(
		const void *inValue) const
{
	return ::CFDictionaryGetCountOfValue(*this,inValue);
}

inline bool
ACFDictionary::ContainsKey(
		const void *inKey) const
{
	return ::CFDictionaryContainsKey(*this,inKey);
}

inline bool
ACFDictionary::ContainsValue(
		const void *inValue) const
{
	return ::CFDictionaryContainsValue(*this,inValue);
}

inline const void*
ACFDictionary::KeyValue(
		const void *inKey) const
{
	return ::CFDictionaryGetValue(*this,inKey);
}

inline bool
ACFDictionary::GetValueIfPresent(
		const void *inKey,
		const void *&outValue) const
{
	 return ::CFDictionaryGetValueIfPresent(*this,inKey,&outValue);
}

inline void
ACFDictionary::GetKeysAndValues(
		const void *&outKeys,
		const void *&outValue) const
{
	 return ::CFDictionaryGetKeysAndValues(*this,&outKeys,&outValue);
}

inline void
ACFDictionary::ApplyFunction(
		CFDictionaryApplierFunction inFunction,
		void *inContext) const
{
	 return ::CFDictionaryApplyFunction(*this,inFunction,inContext);
}
