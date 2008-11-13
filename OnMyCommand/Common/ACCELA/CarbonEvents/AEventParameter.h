// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACarbonEvent.h"
#include "XValueType.h"

#include <stdexcept>

#include FW(Carbon,Scrap.h)

// ---------------------------------------------------------------------------
#pragma mark ReadWritePolicy

namespace APrivate {
	class DoRead
	{
	protected:
		template <class T>
		static bool
			ReadParam(
					const ACarbonEvent &inEvent,
					EventParamName inName,
					EventParamType inType,
					T &outParameter)
			{
				OSStatus err = inEvent.GetParameter(inName,inType,outParameter);
				bool exists = true;
				if (err == eventParameterNotFoundErr)
					exists = false;
				else if (err != noErr)
					throw err;
				return exists;
			}
	};

	class DontRead
	{
	protected:
		template <class T>
		static bool
			ReadParam(
					const ACarbonEvent &,
					EventParamName,
					EventParamType,
					T &)
			{
				return false;
			}
	};
	
	class DoWrite
	{
	protected:
		bool mDirty;
		
			DoWrite()
			: mDirty(false) {}
		
		void
			SetDirty()
			{
				mDirty = true;
			}
		template <class T>
		void
			WriteParam(
					ACarbonEvent &inEvent,
					EventParamName inName,
					EventParamType inType,
					const T &inParameter)
			{
				if (mDirty)
					inEvent.SetParameter(inName,inType,inParameter);
			}
	};

	class DontWrite
	{
	protected:
		void
			SetDirty()
			{
				// How do I make this a compile-time error?
				throw std::runtime_error("assignment to read-only parameter");
			}
		template <class T>
		void
			WriteParam(
					ACarbonEvent &,
					EventParamName,
					EventParamType,
					const T &) {}
	};
}

class AReadOnly  : public APrivate::DoRead,  public APrivate::DontWrite {};
class AReadWrite : public APrivate::DoRead,  public APrivate::DoWrite   {};
class AWriteOnly : public APrivate::DontRead,public APrivate::DoWrite   {};

// ---------------------------------------------------------------------------
#pragma mark AEventParameter

template <class T,class ReadWritePolicy = AReadOnly>
class AEventParameter :
		public ReadWritePolicy
{
public:
		AEventParameter(
				EventRef inEvent,
				EventParamName inParamName,
				EventParamType inParamType = XValueType<T>::GetType())
		: mEvent(inEvent),mParamName(inParamName),mParamType(inParamType)
		{
			mExists = ReadParam(mEvent,inParamName,inParamType,mParam);
		}
	virtual
		~AEventParameter()
		{
			WriteParam(mEvent,mParamName,mParamType,mParam);
		}
	
	// Maybe change to:
	//	operator typename Loki::TypeTraits<T>::ParameterType() const
		operator const T&() const
		{
			if (!mExists) throw std::runtime_error("parameter doesn't exist yet");
			return mParam;
		}
	AEventParameter&
		operator=(
				const T &inNewValue)
		{
			SetDirty();
			mParam = inNewValue;
			mExists = true;
			return *this;
		}
	
	bool
		Exists() const
		{
			return mExists;
		}
	
protected:
	ACarbonEvent mEvent;
	T mParam;
	const EventParamName mParamName;
	const EventParamType mParamType;
	bool mExists;
};

// ---------------------------------------------------------------------------
#pragma mark ASpecificParameter

template <
		class T,
		EventParamName tParamName,
		EventParamType tParamType,
		class ReadWritePolicy = AReadOnly>
class ASpecificParameter :
		public AEventParameter<T,ReadWritePolicy>
{
public:
	explicit
		ASpecificParameter(
				EventRef inEvent)
		: AEventParameter<T,ReadWritePolicy>(inEvent,tParamName,tParamType) {}
	
	ASpecificParameter&
		operator=(
				const T &inNewValue)
		{
			AEventParameter<T,ReadWritePolicy>::operator=(inNewValue);
			return *this;
		}
};

template <class ReadWritePolicy = AReadOnly>
class AParam
{
public:
	// General
	typedef ASpecificParameter<Point,kEventParamMouseLocation,typeQDPoint,ReadWritePolicy>
		Mouse;
	typedef ASpecificParameter<UInt32,kEventParamKeyModifiers,typeUInt32,ReadWritePolicy>
		Modifiers;
	typedef ASpecificParameter<ClickActivationResult,kEventParamClickActivation,typeClickActivationResult,ReadWritePolicy>
		ClickActivation;
	typedef ASpecificParameter<UInt32,kEventParamAttributes,typeUInt32,ReadWritePolicy>
		Attributes;
	typedef ASpecificParameter<Point,kEventParamDimensions,typeQDPoint,ReadWritePolicy>
		Dimensions;
	typedef ASpecificParameter<EventRef,kEventParamEventRef,typeEventRef,ReadWritePolicy>
		Event;
	
	// Graphics
	typedef ASpecificParameter<GrafPtr,kEventParamGrafPort,typeGrafPtr,ReadWritePolicy>
		Port;
	typedef ASpecificParameter<CGContextRef,kEventParamCGContextRef,typeCGContextRef,ReadWritePolicy>
		Context;
	
	// Command
	typedef ASpecificParameter<HICommand,kEventParamDirectObject,typeHICommand,ReadWritePolicy>
		Command;
	
	// Controls
	typedef ASpecificParameter<ControlRef,kEventParamControlRef,typeControlRef,ReadWritePolicy>
		Control;
	typedef ASpecificParameter<ControlPartCode,kEventParamControlPart,typeControlPartCode,ReadWritePolicy>
		ControlPart;
	typedef ASpecificParameter<ControlRef,kEventParamControlSubControl,typeControlRef,ReadWritePolicy>
		SubControl;
	
	// Menus
	typedef ASpecificParameter<MenuRef,kEventParamMenuRef,typeMenuRef,ReadWritePolicy>
		Menu;
	typedef ASpecificParameter<MenuItemIndex,kEventParamMenuItemIndex,typeMenuItemIndex,ReadWritePolicy>
		MenuItem;
	typedef ASpecificParameter<UInt32,kEventParamMenuContext,typeUInt32,ReadWritePolicy>
		MenuContext;
	
	// Windows
	typedef ASpecificParameter<WindowRef,kEventParamWindowRef,typeWindowRef,ReadWritePolicy>
		Window;
	typedef ASpecificParameter<WindowPartCode,kEventParamWindowDefPart,typeWindowDefPartCode,ReadWritePolicy>
		WindowPart;
	typedef ASpecificParameter<WindowRegionCode,kEventParamWindowRegionCode,typeWindowRegionCode,ReadWritePolicy>
		WindowRegion;
	
	// Scrap
	typedef ASpecificParameter<ScrapRef,kEventParamScrapRef,typeScrapRef,ReadWritePolicy>
		Scrap;
	typedef ASpecificParameter<DragRef,kEventParamDragRef,typeDragRef,ReadWritePolicy>
		Drag;
};

// ---------------------------------------------------------------------------
#pragma mark AGenericParameter

template <
		class T,
		EventParamType tParamType,
		class ReadWritePolicy = AReadOnly>
class AGenericParameter :
		public AEventParameter<T,ReadWritePolicy>
{
public:
		AGenericParameter(
				EventRef inEvent,
				EventParamName inParamName)
		: AEventParameter<T,ReadWritePolicy>(inEvent,inParamName,tParamType) {}
	
	AGenericParameter&
		operator=(
				const T &inNewValue)
		{
			AEventParameter<T,ReadWritePolicy>::operator=(inNewValue);
			return *this;
		}
};

template <class ReadWritePolicy = AReadOnly>
class ATypeParam
{
public:
	typedef AGenericParameter< ::Rect,typeQDRectangle,ReadWritePolicy>
		Rect;
	typedef AGenericParameter< ::Point,typeQDPoint,ReadWritePolicy>
		Point;
	typedef AGenericParameter< ::Boolean,typeBoolean,ReadWritePolicy>
		Boolean;
	typedef AGenericParameter< ::Ptr,typePtr,ReadWritePolicy>
		Ptr;
	typedef AGenericParameter< ::WindowRef,typeWindowRef,ReadWritePolicy>
		WindowRef;
	typedef AGenericParameter< ::MenuRef,typeMenuRef,ReadWritePolicy>
		MenuRef;
	typedef AGenericParameter< ::MenuItemIndex,typeMenuItemIndex,ReadWritePolicy>
		MenuItemIndex;
	typedef AGenericParameter< ::RgnHandle,typeQDRgnHandle,ReadWritePolicy>
		RgnHandle;
	typedef AGenericParameter<OSType,typeEnumeration,ReadWritePolicy>
		Enumeration;
	typedef AGenericParameter< ::ControlPartCode,typeControlPartCode,ReadWritePolicy>
		ControlPartCode;
	
	typedef AGenericParameter< ::GWorldPtr,typeGWorldPtr,ReadWritePolicy>
		GWorldPtr;
	
	typedef AGenericParameter< ::UInt32,typeUInt32,ReadWritePolicy>
		UInt32;
	typedef AGenericParameter< ::SInt32,typeSInt32,ReadWritePolicy>
		SInt32;
	typedef AGenericParameter< ::SInt16,typeSInt16,ReadWritePolicy>
		SInt16;
};
