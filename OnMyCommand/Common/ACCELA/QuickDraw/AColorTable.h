// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XWrapper.h"
#include "FW.h"

#include FW(ApplicationServices,QuickDraw.h)

class AColorTable :
		public XWrapper<CTabHandle>
{
public:
		AColorTable(
				CTabHandle inCTab,
				bool inOwner = false)
		: XWrapper<CTabHandle>(inCTab,inOwner) {}
		// Resource
		AColorTable(
				ResID inID)
		: XWrapper<CTabHandle>(::GetCTable(inID),true) {}
	
		operator Handle()
		{
			return (Handle)mObject;
		}
	CTabPtr
		operator*()
		{
			return *mObject;
		}
	ColorSpec&
		operator[](
				SInt16 inIndex)
		{
			return (**mObject).ctTable[inIndex];
		}
	
	RGBColor
		GetIndColor(
				SInt16 inIndex) const
		{
			return (**mObject).ctTable[inIndex].rgb;
		}
	SInt16
		Count() const
		{
			// ctSize is documented to be one less than the real count
			return (**mObject).ctSize+1;
		}
	
	RGBColor
		ClosestColor(
				const RGBColor &inColor) const;
};

inline void
XWrapper<CTabHandle>::DisposeSelf()
{
	::DisposeCTable(mObject);
}
