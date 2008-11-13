// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XWrapper.h"
#include "FW.h"

#include FW(ApplicationServices,Icons.h)

const Size kEmptyFamilySize = sizeof(OSType)+sizeof(Size);

class AIconFamily :
		public XWrapper<IconFamilyHandle>
{
public:
		AIconFamily()
		: XWrapper((IconFamilyHandle)::NewHandle(kEmptyFamilySize),true)
		{
			(**mObject).resourceType = kIconFamilyType;
			(**mObject).resourceSize = kEmptyFamilySize;
		}
		AIconFamily(
				IconFamilyHandle inFamily,
				bool inOwner = false)
		: XWrapper(inFamily,inOwner) {}
		AIconFamily(
				IconRef inIconRef,
				IconSelectorValue inWhichIcons = kSelectorAllAvailableData);
		AIconFamily(
				IconSuiteRef inSuite,
				IconSelectorValue inWhichIcons = kSelectorAllAvailableData);
		AIconFamily(
				const FSSpec &inSpec);
		AIconFamily(
				const FSRef &inFSRef);
	
	void
		SetData(
				OSType inType,
				Handle inData);
	void
		GetData(
				OSType inType,
				Handle outDataHandle) const;
	bool
		HasType(
				OSType inType) const;
	
	void
		WriteFile(
				const FSSpec &inFile) const;
	static bool
		IsIcnsFile(
				const FSSpec &inSpec);
	static bool
		IsIcnsFile(
				const FSRef &inRef);
};

// ---------------------------------------------------------------------------

inline
AIconFamily::AIconFamily(
		IconRef inIconRef,
		IconSelectorValue inWhichIcons)
{
	CThrownOSStatus err = ::IconRefToIconFamily(inIconRef,inWhichIcons,&mObject);
}

inline
AIconFamily::AIconFamily(
		IconSuiteRef inSuite,
		IconSelectorValue inWhichIcons)
{
	CThrownOSStatus err = ::IconSuiteToIconFamily(inSuite,inWhichIcons,&mObject);
}

inline
AIconFamily::AIconFamily(
		const FSSpec &inSpec)
{
	CThrownOSStatus err = ::ReadIconFile(&inSpec,&mObject);
}

inline
AIconFamily::AIconFamily(
		const FSRef &inFSRef)
{
	CThrownOSStatus err = ::ReadIconFromFSRef(&inFSRef,&mObject);
}

inline void
AIconFamily::SetData(
		OSType inType,
		Handle inData)
{
	CThrownOSStatus err = ::SetIconFamilyData(*this,inType,inData);
}

inline void
AIconFamily::GetData(
		OSType inType,
		Handle outDataHandle) const
{
	CThrownOSStatus err = ::GetIconFamilyData(*this,inType,outDataHandle);
}

inline bool
AIconFamily::HasType(
		OSType inType) const
{
	Handle dataHandle = ::NewHandle(0);
	OSStatus err = ::GetIconFamilyData(*this,inType,dataHandle);
	bool hasType = ::GetHandleSize(dataHandle) > 0;
	::DisposeHandle(dataHandle);
	return (err == noErr) && hasType;
}

// ---------------------------------------------------------------------------

inline void
XWrapper<IconFamilyHandle>::DisposeSelf()
{
	::DisposeHandle((Handle)mObject);
}
