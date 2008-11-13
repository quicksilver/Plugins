//**************************************************************************************
// Filename:	CShellExecutor.h
//				Part of Contextual Menu Workshop by Abracode Inc.
//				http://free.abracode.com/cmworkshop/
// Copyright © 2002-2003 Abracode, Inc.  All rights reserved.
//
// Description:	
//
//**************************************************************************************
// Revision History:
// Friday, September 13, 2002 - Original
//**************************************************************************************

#pragma once

#include <stdio.h>

#if defined(__MACH__)
	#include <CoreFoundation/CoreFoundation.h>
#else
	#include <CFString.h>
	#include <CFBundle.h>
#endif

// BSD function prototypes

#if TARGET_RT_MAC_CFM
	int	execv( const char *path, char *const argv[] );
#endif

typedef int (*execvFuncPtr)( const char*, char **const );

#if TARGET_RT_MAC_CFM
	FILE *	 popen(const char *command, const char *type);
#endif

typedef FILE *(*BSDpopenFuncPtr)( const char*, const char* );

#if TARGET_RT_MAC_CFM
	int	pclose( FILE *stream );
#endif

typedef int (*BSDpcloseFuncPtr)( FILE* );

typedef int (*BSDfreadFuncPtr)( void *, size_t, size_t, FILE * );

class CShellExecutor
{
public:
						CShellExecutor();
	virtual				~CShellExecutor();
	
	void				Execute(  CFStringRef inCommand );
	void				Execute( char *inCommand );
	
	
	static OSStatus		LoadFrameworkBundle(CFStringRef framework, CFBundleRef *bundlePtr);

protected:
	void				Initialize();
	
	CFBundleRef			mSysBundle;
	
	BSDpopenFuncPtr		BSDpopen;
	BSDfreadFuncPtr		BSDfread;
	BSDpcloseFuncPtr	BSDpclose;

};