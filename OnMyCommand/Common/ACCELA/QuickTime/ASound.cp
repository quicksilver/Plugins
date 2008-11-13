#include "ASound.h"
#include "ACFBundle.h"
#include "ACFURL.h"
#include "AFileFork.h"

#include <memory>

// ---------------------------------------------------------------------------

ASound::ASound(
		CFStringRef inFileName,
		CFStringRef inFileType)
{
	ACFBundle appBundle(ACFBundle::bundle_Main);
	ACFURL fileURL(appBundle.CopyResourceURL(inFileName,inFileType),false);
	AMovie::OpenFile movieFile(fileURL.FSRef());
	CThrownOSErr err;
	Boolean wasChanged;
	
	err = ::NewMovieFromFile(&mObject,movieFile,NULL,NULL,kNilOptions,&wasChanged);
}

// ---------------------------------------------------------------------------
