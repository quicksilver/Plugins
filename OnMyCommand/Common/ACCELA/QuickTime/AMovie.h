// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"
#include "CThrownResult.h"
#include "FW.h"

#include FW(QuickTime,Movies.h)

// ---------------------------------------------------------------------------

class AMovie :
		public XWrapper<Movie>
{
public:
		AMovie() {}
		AMovie(
				Movie inMovie,
				bool inOwner = true)
		: XWrapper<Movie>(inMovie,inOwner) {}
		AMovie(
				long inFlags);
		AMovie(
				short inResRefNum,
				StringPtr inResName,
				short inFlags);
		AMovie(
				Handle inHandle,
				short inFlags);
	
	// AMovie
	
	// playing
	void
		Start();
	void
		Stop();
	bool
		IsDone();
	void
		GoToBeginning();
	void
		GoToEnd();
	
	void
		Idle(
				long inMaxMillisecs = 0);
	void
		Preroll(
				TimeValue inTime,
				Fixed inRate = fixed1);
	
	TimeValue
		GetDuration();
	
	void
		SetBox(
				const Rect &inBox);
	Rect
		GetBox();
	Rect
		GetNaturalBounds();
	
	// util
	void
		SetBalance(
				float inBalance);
	
	class OpenFile
	{
	public:
			OpenFile(
					const FSSpec &inSpec,
					SInt8 inPermission = fsRdPerm)
			{
				OpenSpec(inSpec,inPermission);
			}
			OpenFile(
					const FSRef &inRef,
					SInt8 inPermission = fsRdPerm);
			~OpenFile()
			{
				::CloseMovieFile(mRefNum);
			}
		
			operator short() const
			{
				return mRefNum;
			}
		
	protected:
		short mRefNum;
		
		void
			OpenSpec(
					const FSSpec &inSpec,
					SInt8 inPermission);
	};
};

// ---------------------------------------------------------------------------

inline void
AMovie::Start()
{
	::StartMovie(*this);
}

inline void
AMovie::Stop()
{
	::StopMovie(*this);
}

inline bool
AMovie::IsDone()
{
	return ::IsMovieDone(*this);
}

inline void
AMovie::GoToBeginning()
{
	::GoToBeginningOfMovie(*this);
}

inline void
AMovie::GoToEnd()
{
	::GoToEndOfMovie(*this);
}

inline void
AMovie::Idle(
		long inMaxMillisecs)
{
	::MoviesTask(*this,inMaxMillisecs);
}

inline void
AMovie::Preroll(
		TimeValue inTime,
		Fixed inRate)
{
	CThrownOSErr err = ::PrerollMovie(*this,inTime,inRate);
}

inline TimeValue
AMovie::GetDuration()
{
	return ::GetMovieDuration(*this);
}

inline void
AMovie::SetBox(
		const Rect &inRect)
{
	::SetMovieBox(*this,&inRect);
}

inline Rect
AMovie::GetBox()
{
	Rect box;
	::GetMovieBox(mObject,&box);
	return box;
}

inline Rect
AMovie::GetNaturalBounds()
{
	Rect box;
	::GetMovieNaturalBoundsRect(*this,&box);
	return box;
}

inline void
XWrapper<Movie>::DisposeSelf()
{
	::DisposeMovie(*this);
}
