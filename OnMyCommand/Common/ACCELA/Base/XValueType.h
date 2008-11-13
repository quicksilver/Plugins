// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(Carbon,CarbonEvents.h)

template <class T>
class XValueType
{
public:
	static EventParamType
		GetType()
		{ return typeNull; }
};

#define _XValueType(_type_) \
	class XValueType<_type_> \
	{ \
	public: \
		static EventParamType \
		GetType() \
		{ return type ## _type_; } \
	};

#define __XValueType(_name_,_type_) \
	class XValueType<_type_> \
	{ \
	public: \
		static EventParamType \
		GetType() \
		{ return type ## _name_; } \
	};

// ---------------------------------------------------------------------------
#pragma mark Plain

__XValueType(Boolean,bool)
_XValueType(UInt32)

// ---------------------------------------------------------------------------
#pragma mark MacTypes

__XValueType(QDPoint,Point)
__XValueType(QDRectangle,Rect)

// ---------------------------------------------------------------------------
#pragma mark Toolbox

_XValueType(WindowRef)
_XValueType(DragRef)
_XValueType(MenuRef)
_XValueType(ControlRef)
_XValueType(Collection)
_XValueType(CGContextRef)
_XValueType(EventRef)

// GrafPtr and GWorldPtr aren't differentiated by the compiler
//_XValueType(GrafPtr)
//_XValueType(GWorldPtr)

__XValueType(QDRgnHandle,RgnHandle)
_XValueType(RGBColor)

// ---------------------------------------------------------------------------
#pragma mark Core Foundation

_XValueType(CFMutableArrayRef)
_XValueType(CFStringRef)

// ---------------------------------------------------------------------------
#pragma mark Keyboard

_XValueType(EventHotKeyID)

// ---------------------------------------------------------------------------
#pragma mark HICommand

_XValueType(HICommand)

// ---------------------------------------------------------------------------
#pragma mark Window

_XValueType(WindowRegionCode)
_XValueType(WindowDefPartCode)

// ---------------------------------------------------------------------------
#pragma mark Control

_XValueType(ControlActionUPP)
_XValueType(IndicatorDragConstraint)
//_XValueType(ControlPartCode)
//_XValueType(ClickActivationResult)

// ---------------------------------------------------------------------------
#pragma mark Menu

//_XValueType(MenuItemIndex)
//_XValueType(MenuCommand)
//_XValueType(MenuTrackingMode)
//_XValueType(MenuEventOptions)

// ---------------------------------------------------------------------------
#pragma mark Process

_XValueType(ProcessSerialNumber)

// ---------------------------------------------------------------------------
#pragma mark Process

__XValueType(FSS,FSSpec)
_XValueType(FSRef)
