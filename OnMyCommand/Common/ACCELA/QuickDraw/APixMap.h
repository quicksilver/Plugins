// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "FW.h"
#include "CThrownResult.h"

#include FW(QuickTime,ImageCompression.h)
#include FW(ApplicationServices,QDOffscreen.h)

class APixMap :
		public XWrapper<PixMapHandle>
{
public:
		APixMap(
				PixMapHandle inPix,
				bool inOwner = false)
		: XWrapper<PixMapHandle>(inPix,inOwner) {}
		APixMap(
				const GWorldPtr inGWorld)
		: XWrapper<PixMapHandle>(::GetGWorldPixMap(inGWorld),false) {}
		APixMap()
		: XWrapper<PixMapHandle>(::NewPixMap(),true) {}
	
	PixMapPtr
		operator*()
		{
			return *mObject;
		}
		operator Handle()
		{
			return (Handle) mObject;
		}
		
	
	short
		Depth() const;
	long
		RowBytes() const;
	Ptr
		BaseAddr() const;
	Rect
		Bounds() const;
	void
		GetBounds(
				Rect &outBounds) const;
	bool
		Is32Bit();
	
	// Locked state is not counted toward constness
	bool
		Lock() const;
	void
		Unlock() const;
	bool
		IsLocked() const;
	
	void
		AllowPurge();
	void
		NoPurge();
	bool
		IsPurgeable() const;
	
	GWorldFlags
		State() const;
	void
		SetState(
				GWorldFlags inFlags) const;
	
	ImageDescriptionHandle
		MakeImageDescription();
	
	long
		Pixel(
				short inH,
				short inV) const;
	void
		SetPixel(
				short inH,
				short inV,
				long inValue);
	
	Handle
		CopyData() const;
	
	class Locker
	{
	public:
			Locker(
					const APixMap &inPix)
			: mPixMap(inPix),mSafe(mPixMap.Lock()),
			  mWasLocked(inPix.IsLocked())
			{
				mSafe = mPixMap.Lock();
			}
			~Locker()
			{
				if (!mWasLocked) mPixMap.Unlock();
			}
		
		bool
			Safe()
			{ return mSafe; }
		
	protected:
		const APixMap &mPixMap;
		bool mSafe,mWasLocked;
	};
};

// ---------------------------------------------------------------------------

inline short
APixMap::Depth() const
{ return ::GetPixDepth(mObject); }

inline long
APixMap::RowBytes() const
{ return ::GetPixRowBytes(mObject); }

inline Ptr
APixMap::BaseAddr() const
{ return ::GetPixBaseAddr(mObject); }

inline Rect
APixMap::Bounds() const
{ Rect r;
  return *::GetPixBounds(mObject,&r); }

inline void
APixMap::GetBounds(
		Rect &outBounds) const
{ ::GetPixBounds(mObject,&outBounds); }
  
inline bool
APixMap::Is32Bit()
{ return ::PixMap32Bit(mObject); }

inline bool
APixMap::Lock() const
{ return ::LockPixels(mObject); }

inline void
APixMap::Unlock() const
{ ::UnlockPixels(mObject); }

inline bool
APixMap::IsLocked() const
{ return ::GetPixelsState(mObject) & pixelsLocked; }

inline void
APixMap::AllowPurge()
{ ::AllowPurgePixels(mObject); }

inline void
APixMap::NoPurge()
{ ::NoPurgePixels(mObject); }

inline bool
APixMap::IsPurgeable() const
{ return ::GetPixelsState(mObject) & pixelsPurgeable; }

inline GWorldFlags
APixMap::State() const
{ return ::GetPixelsState(mObject); }

inline void
APixMap::SetState(
		GWorldFlags inFlags) const
{ ::SetPixelsState(mObject,inFlags); }

inline ImageDescriptionHandle
APixMap::MakeImageDescription()
{
	ImageDescriptionHandle imh;
	CThrownOSErr err = ::MakeImageDescriptionForPixMap(mObject,&imh);
	return imh;
}

// ---------------------------------------------------------------------------

inline void
XWrapper<PixMapHandle>::DisposeSelf()
{
	::DisposePixMap(mObject);
}
