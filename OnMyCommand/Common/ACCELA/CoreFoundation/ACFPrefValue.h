// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "ACFString.h"
#include "ACFNumber.h"

#include FW(CoreFoundation,CFPreferences.h)

template <class T>
class ACFPrefValue
{
public:
		ACFPrefValue(
				const T &inDefault,
				CFStringRef inKey,
				CFStringRef inAppID = kCFPreferencesCurrentApplication)
		: mValue(inDefault),mKey(inKey),mAppID(inAppID)
		{ Read(); }
	virtual
		~ACFPrefValue()
		{ Write(); }
	
		operator T()
		{ return mValue; }
	T&
		Value()
		{ return mValue; }
	ACFPrefValue<T>&
		operator=(
				const T &inNewValue)
		{ 
			mValue = inNewValue;
			return *this;
		}
	
	bool
		Read()
		{ return ReadValue(mKey,mAppID,mValue); }
	void
		Write()
		{ WriteValue(mKey,mAppID,mValue); }
	
protected:
	T mValue;
	ACFString mKey,mAppID;
	
	// Reading
	static bool
		ReadValue(
				CFStringRef inKey,
				CFStringRef inAppID,
				T &outValue);
	
	// Writing
	static void
		WriteValue(
				CFStringRef inKey,
				CFStringRef inAppID,
				const T &inValue);
};

// ---------------------------------------------------------------------------

template <class T>	// T is a subclass of ACFBase
class ACFTypePrefValue :
		public ACFPrefValue<ACFBase>
{
public:
		ACFTypePrefValue(
				const T &inDefault,
				CFStringRef inKey,
				CFStringRef inAppID = kCFPreferencesCurrentApplication)
		: ACFPrefValue<ACFBase>(inDefault,inKey,inAppID) {}
	
		operator T() const
		{
			return (T)mValue.Get();
		}
	ACFTypePrefValue&
		operator=(
				const ACFType<T> &inNewObject)
		{
			mValue.Reset(inNewObject.Get());
			return *this;
		}
};

// ---------------------------------------------------------------------------

class ACFPrefs
{
public:
	static bool
		Synchronize(
				CFStringRef inAppID = kCFPreferencesCurrentApplication)
		{
			return ::CFPreferencesAppSynchronize(inAppID);
		}
	static bool
		KeyExists(
				CFStringRef inKey);
};

// ---------------------------------------------------------------------------

inline bool
ACFPrefValue<bool>::ReadValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		bool &outValue)
{
	Boolean hadValue = false;
	Boolean readValue = ::CFPreferencesGetAppBooleanValue(inKey,inAppID,&hadValue);
	if (hadValue) outValue = readValue;
	return hadValue;
}

inline bool
ACFPrefValue<SInt32>::ReadValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		SInt32 &outValue)
{
	Boolean hadValue = false;
	CFIndex readValue = ::CFPreferencesGetAppIntegerValue(inKey,inAppID,&hadValue);
	if (hadValue) outValue = readValue;
	return hadValue;
}

inline bool
ACFPrefValue<UInt32>::ReadValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		UInt32 &outValue)
{
	ACFNumber readValue((CFNumberRef)::CFPreferencesCopyAppValue(inKey,inAppID),false);
	bool found = false;
	if (readValue.Get() != NULL) {
		long long longValue;
		found = readValue.GetValue(kCFNumberLongLongType,&longValue);
		if (found)
			outValue = longValue;
	}
	return found;
}

inline bool
ACFPrefValue<CFTypeRef>::ReadValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		CFTypeRef &outValue)
{
	CFTypeRef readObject = ::CFPreferencesCopyAppValue(inKey,inAppID);
	if (readObject != NULL) outValue = readObject;
	return (readObject != NULL);
}

inline bool
ACFPrefValue<ACFBase>::ReadValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		ACFBase &outValue)
{
	CFTypeRef readObject = ::CFPreferencesCopyAppValue(inKey,inAppID);
	if (readObject != NULL) outValue.Reset(readObject);
	return (readObject != NULL);
}

inline void
ACFPrefValue<bool>::WriteValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		const bool &inValue)
{
	::CFPreferencesSetAppValue(inKey,inValue ? kCFBooleanTrue : kCFBooleanFalse,inAppID);
}

inline void
ACFPrefValue<SInt32>::WriteValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		const SInt32 &inValue)
{
	::CFPreferencesSetAppValue(inKey,ACFNumber(inValue),inAppID);
}

inline void
ACFPrefValue<UInt32>::WriteValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		const UInt32 &inValue)
{
	::CFPreferencesSetAppValue(inKey,ACFNumber(inValue),inAppID);
}

inline void
ACFPrefValue<CFTypeRef>::WriteValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		const CFTypeRef &inValue)
{
	::CFPreferencesSetAppValue(inKey,inValue,inAppID);
}

inline void
ACFPrefValue<ACFBase>::WriteValue(
		CFStringRef inKey,
		CFStringRef inAppID,
		const ACFBase &inValue)
{
	::CFPreferencesSetAppValue(inKey,inValue.Get(),inAppID);
}
