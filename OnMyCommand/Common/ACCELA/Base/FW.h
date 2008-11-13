// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

// A little macro to make it easier to compile whether
// framework-style includes are required or not
#if defined(__MWERKS__) && TARGET_RT_MAC_CFM
	#define FW(_framework_,_file_) \
		<_file_>
#else
	#define FW(_framework_,_file_) \
		<_framework_/_framework_.h>
#endif
