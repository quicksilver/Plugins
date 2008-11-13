// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(CoreServices,FixMath.h)

class AFixed
{
		AFixed(
				Fixed inValue = 0)
		: mValue(inValue);
	
		operator Fixed() const
		{
			return mValue;
		}
		operator short() const
		{
			return ::FixRound(mValue);
		}
	
	AFixed&
		operator=(
				Fixed inValue)
		{
			mValue = inValue;
		}
	
	AFixed
		operator*(
				Fixed inR) const
		{
			return ::FixMul(mValue,inR);
		}
	
protected:
	Fixed mValue;
};