// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XWrapper.h"

#include FW(Carbon,IBCarbonRuntime.h)

// ---------------------------------------------------------------------------

class ANib :
		public XWrapper<IBNibRef>
{
public:
		ANib(
				CFStringRef inName);
		ANib(
				CFBundleRef inBundle,
				CFStringRef inName);
		ANib(
				IBNibRef inRef)
		: XWrapper<IBNibRef>(inRef,false) {}
	
	WindowRef
		CreateWindow(
				CFStringRef inName);
	MenuRef
		CreateMenu(
				CFStringRef inName);
	Handle
		CreateMenuBar(
				CFStringRef inName);
	void
		SetMenuBar(
				CFStringRef inName);
};

// ---------------------------------------------------------------------------

inline
ANib::ANib(
		CFStringRef inName)
{ CThrownOSStatus err = ::CreateNibReference(inName,&mObject); }

inline
ANib::ANib(
		CFBundleRef inBundle,
		CFStringRef inName)
{ CThrownOSStatus err = ::CreateNibReferenceWithCFBundle(inBundle,inName,&mObject); }

inline WindowRef
ANib::CreateWindow(
		CFStringRef inName)
{
	WindowRef window;
	CThrownOSStatus err = ::CreateWindowFromNib(mObject,inName,&window);
	return window;
}

inline MenuRef
ANib::CreateMenu(
		CFStringRef inName)
{
	MenuRef menu;
	CThrownOSStatus err = ::CreateMenuFromNib(mObject,inName,&menu);
	return menu;
}

inline Handle
ANib::CreateMenuBar(
		CFStringRef inName)
{
	Handle menuBar;
	CThrownOSStatus err = ::CreateMenuBarFromNib(mObject,inName,&menuBar);
	return menuBar;
}

inline void
ANib::SetMenuBar(
		CFStringRef inName)
{ CThrownOSStatus err = ::SetMenuBarFromNib(mObject,inName); }

inline void
XWrapper<IBNibRef>::DisposeSelf()
{
	::DisposeNibReference(mObject);
}
