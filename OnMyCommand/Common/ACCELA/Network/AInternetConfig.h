#include "CThrownResult.h"
#include "FW.h"

#include FW(ApplicationServices,InternetConfig.h)

class AInternetConfig
{
public:
		AInternetConfig(
				OSType inSignature);
		~AInternetConfig();
	
	static AInternetConfig*
		Instance()
		{
			return sInstance;
		}
	
		operator ICInstance() const
		{
			return mICInstance;
		}
	
	ICPerm
		AccessPermission() const;
	
	void
		GetPref(
				ConstStr255Param inKey,
				ICAttr &outAttributes,
				void *outBuffer,
				long &outSize) const;
	void
		SetPref(
				ConstStr255Param inKey,
				ICAttr inAttributes,
				const void *inBuffer,
				long inSize);
	void
		GetPref(
				ConstStr255Param inKey,
				ICAttr &outAttributes,
				Handle ioPrefHandle) const;
	void
		SetPref(
				ConstStr255Param inKey,
				ICAttr inAttributes,
				Handle inPrefHandle);
	
	long
		PrefCount() const;
	void
		GetIndPrefKey(
				long inIndex,
				Str255 outKey) const;
	
	void
		DeletePref(
				ConstStr255Param inKey);
	
	class PrefReadWriteSession
	{
	public:
			PrefReadWriteSession(
					ICInstance inInstance,
					ICPerm inPerm = icReadOnlyPerm)
			: mICInstance(inInstance)
			{
				CThrownOSStatus err = ::ICBegin(inInstance,inPerm);
			}
			~PrefReadWriteSession()
			{
				CThrownOSStatus err = ::ICEnd(mICInstance);
			}
		
	protected:
		const ICInstance mICInstance;
	};
	
protected:
	static AInternetConfig *sInstance;
	
	ICInstance mICInstance;
};

// ---------------------------------------------------------------------------

inline
AInternetConfig::AInternetConfig(
		OSType inSignature)
{
	CThrownOSStatus err = ::ICStart(&mICInstance,inSignature);
	sInstance = this;
}

inline
AInternetConfig::~AInternetConfig()
{
	::ICStop(mICInstance);
}

inline ICPerm
AInternetConfig::AccessPermission() const
{
	ICPerm perm;
	CThrownOSStatus err = ::ICGetPerm(mICInstance,&perm);
	return perm;
}

inline void
AInternetConfig::GetPref(
		ConstStr255Param inKey,
		ICAttr &outAttributes,
		void *outBuffer,
		long &outSize) const
{
	CThrownOSStatus err = ::ICGetPref(mICInstance,inKey,&outAttributes,outBuffer,&outSize);
}

inline void
AInternetConfig::SetPref(
		ConstStr255Param inKey,
		ICAttr inAttributes,
		const void *inBuffer,
		long inSize)
{
	CThrownOSStatus err = ::ICSetPref(mICInstance,inKey,inAttributes,inBuffer,inSize);
}

inline void
AInternetConfig::GetPref(
		ConstStr255Param inKey,
		ICAttr &outAttributes,
		Handle ioPrefHandle) const
{
	CThrownOSStatus err = ::ICFindPrefHandle(mICInstance,inKey,&outAttributes,ioPrefHandle);
}

inline void
AInternetConfig::SetPref(
		ConstStr255Param inKey,
		ICAttr inAttributes,
		Handle inPrefHandle)
{
	CThrownOSStatus err = ::ICSetPrefHandle(mICInstance,inKey,inAttributes,inPrefHandle);
}

inline long
AInternetConfig::PrefCount() const
{
	long prefCount;
	CThrownOSStatus err = ::ICCountPref(mICInstance,&prefCount);
	return prefCount;
}

inline void
AInternetConfig::GetIndPrefKey(
		long inIndex,
		Str255 outKey) const
{
	CThrownOSStatus err = ::ICGetIndPref(mICInstance,inIndex,outKey);
}

inline void
AInternetConfig::DeletePref(
		ConstStr255Param inKey)
{
	CThrownOSStatus err = ::ICDeletePref(mICInstance,inKey);
}
