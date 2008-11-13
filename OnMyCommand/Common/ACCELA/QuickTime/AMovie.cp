#include "AMovie.h"
#include "AFileRef.h"

// ---------------------------------------------------------------------------

AMovie::OpenFile::OpenFile(
		const FSRef &inRef,
		SInt8 inPermission)
{
	OpenSpec(AFileRef(inRef).Spec(),inPermission);
}

// ---------------------------------------------------------------------------

void
AMovie::OpenFile::OpenSpec(
		const FSSpec &inSpec,
		SInt8 inPermission)
{
	CThrownOSErr err = ::OpenMovieFile(&inSpec,&mRefNum,inPermission);
}

// ---------------------------------------------------------------------------

void
AMovie::SetBalance(
		float inBalance)
{
	Track soundTrack = ::GetMovieIndTrackType(*this,1,AudioMediaCharacteristic,movieTrackCharacteristic|movieTrackEnabledOnly);
	Media soundMedia = ::GetTrackMedia(soundTrack);
	MediaHandler soundHandler = ::GetMediaHandler(soundMedia);
	
	::MediaSetSoundBalance(soundHandler,(short)((inBalance * 256) - 128));
}

// ---------------------------------------------------------------------------
