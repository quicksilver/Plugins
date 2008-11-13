// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include <CFString.h>

void*
GetCarbonFunction(
		CFStringRef inFunctionName);
void
SetPatternOrigin(
		Point inOrigin);
OSErr
SetDragImageWithAlpha(
		DragRef inDragRef,
		PixMapHandle inImagePix,
		PixMapHandle inMaskPix,
		Point inImageOffset,
		DragImageFlags inImageFlags);
