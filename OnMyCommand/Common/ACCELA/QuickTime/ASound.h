#pragma once

#include "AMovie.h"

class ASound :
		public AMovie
{
public:
		ASound(
				Movie inMovie,
				bool inOwner = true)
		: AMovie(inMovie,inOwner) {}
		ASound(
				CFStringRef inFileName,
				CFStringRef inFileType = NULL);
	
	void
		Play()
		{
			GoToBeginning();
			Start();
		}
};
