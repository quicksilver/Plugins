// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XWrapper.h"
#include "CThrownResult.h"

#include FW(CoreServices,Aliases.h)

struct AEDesc;

class AAlias :
		public XWrapper<AliasHandle>
{
public:
	typedef enum {
		minimal
	} EMinimal;
	
		AAlias() {}
		AAlias(
				AliasHandle inAlias,
				bool inOwner = false)
		: XWrapper<AliasHandle>(inAlias,inOwner) {}
		// FSSpec
		AAlias(
				const FSSpec &inTarget);
		AAlias(
				const FSSpec &inTarget,
				const FSSpec &inFromSpec);
		AAlias(
				const FSSpec &inTarget,
				EMinimal);
		// FSRef
		AAlias(
				const FSRef &inRef);
		AAlias(
				const FSRef &inRef,
				const FSRef &inFromRef);
		AAlias(
				const FSRef &inRef,
				EMinimal);
		// AEDesc
		AAlias(
				const AEDesc &inDesc);
	
	// return value is the wasChanged parameter
	bool
		Resolve(
				FSSpec &outSpec) const;
	bool
		Resolve(
				FSSpec &outSpec,
				const FSSpec &inFromSpec) const;
	bool
		Resolve(
				FSRef &outRef) const;
	bool
		Resolve(
				FSRef &outSpec,
				const FSRef &inFromRef) const;
	
	bool
		Follow(
				FSSpec &outSpec,
				bool inLogon = true);
	bool
		Follow(
				FSSpec &outSpec,
				const FSSpec &inFromSpec,
				bool inLogon = true);
	bool
		Follow(
				FSRef &outRef,
				bool inLogon = true);
	bool
		Follow(
				FSRef &outRef,
				const FSRef &inFromRef,
				bool inLogon = true);
};

// ---------------------------------------------------------------------------

inline
AAlias::AAlias(
		const FSSpec &inTarget)
: XWrapper<AliasHandle>(NULL,true)
{
	CThrownOSErr err = ::NewAlias(NULL,&inTarget,&mObject);
}

inline
AAlias::AAlias(
		const FSSpec &inTarget,
		const FSSpec &inFromSpec)
: XWrapper<AliasHandle>(NULL,true)
{
	CThrownOSErr err = ::NewAlias(&inFromSpec,&inTarget,&mObject);
}

inline
AAlias::AAlias(
		const FSSpec &inTarget,
		EMinimal)
: XWrapper<AliasHandle>(NULL,true)
{
	CThrownOSErr err = ::NewAliasMinimal(&inTarget,&mObject);
}

inline
AAlias::AAlias(
		const FSRef &inRef)
: XWrapper<AliasHandle>(NULL,true)
{
	CThrownOSErr err = ::FSNewAlias(NULL,&inRef,&mObject);
}

inline
AAlias::AAlias(
		const FSRef &inRef,
		const FSRef &inFromRef)
: XWrapper<AliasHandle>(NULL,true)
{
	CThrownOSErr err = ::FSNewAlias(&inFromRef,&inRef,&mObject);
}

inline
AAlias::AAlias(
		const FSRef &inRef,
		EMinimal)
: XWrapper<AliasHandle>(NULL,true)
{
	CThrownOSErr err = ::FSNewAliasMinimal(&inRef,&mObject);
}

inline bool
AAlias::Resolve(
		FSSpec &outSpec) const
{
	Boolean wasChanged;
	CThrownOSErr err = ::ResolveAlias(NULL,mObject,&outSpec,&wasChanged);
	return wasChanged;
}

inline bool
AAlias::Resolve(
		FSSpec &outSpec,
		const FSSpec &inFromSpec) const
{
	Boolean wasChanged;
	CThrownOSErr err = ::ResolveAlias(&inFromSpec,mObject,&outSpec,&wasChanged);
	return wasChanged;
}

inline bool
AAlias::Resolve(
		FSRef &outRef) const
{
	Boolean wasChanged;
	CThrownOSErr err = ::FSResolveAlias(NULL,mObject,&outRef,&wasChanged);
	return wasChanged;
}

inline bool
AAlias::Resolve(
		FSRef &outRef,
		const FSRef &inFromRef) const
{
	Boolean wasChanged;
	CThrownOSErr err = ::FSResolveAlias(&inFromRef,mObject,&outRef,&wasChanged);
	return wasChanged;
}

inline bool
AAlias::Follow(
		FSSpec &outSpec,
		bool inLogon)
{
	Boolean wasChanged;
	CThrownOSErr err = ::FollowFinderAlias(NULL,mObject,inLogon,&outSpec,&wasChanged);
	return wasChanged;
}

inline bool
AAlias::Follow(
		FSSpec &outSpec,
		const FSSpec &inFromSpec,
		bool inLogon)
{
	Boolean wasChanged;
	CThrownOSErr err = ::FollowFinderAlias(&inFromSpec,mObject,inLogon,&outSpec,&wasChanged);
	return wasChanged;
}

inline bool
AAlias::Follow(
		FSRef &outRef,
		bool inLogon)
{
	Boolean wasChanged;
	CThrownOSErr err = ::FSFollowFinderAlias(NULL,mObject,inLogon,&outRef,&wasChanged);
	return wasChanged;
}

inline bool
AAlias::Follow(
		FSRef &outRef,
		const FSRef &inFromRef,
		bool inLogon)
{
	Boolean wasChanged;
	CThrownOSErr err = ::FSFollowFinderAlias(const_cast<FSRef*>(&inFromRef),mObject,inLogon,&outRef,&wasChanged);
	return wasChanged;
}

// ---------------------------------------------------------------------------

inline void
XWrapper<AliasHandle>::DisposeSelf()
{
	::DisposeHandle((Handle)mObject);
}
