// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "CFBase.h"

class ACFDate :
		ACFType<CFDateRef>
{
public:
		ACFDate(
				CFDateRef inDateRef,
				bool inDoRetain = true)
		: ACFType(inDateRef,inDoRetain) {}
		ACFDate(
				CFAbsoluteTime inTime)
		: ACFType(::CFDateCreate(kCFAllocatorDefault,inTime),false) {}
	
	CFAbsoluteTime
		AbsoluteTime() const;
	CFTimeInterval
		Interval(
				CFDateRef inOtherDate) const;
	
	bool
		operator<(
				CFDateRef inDate) const;
	bool
		operator>(
				CFDateRef inDate) const;
	bool
		operator==(
				CFDateRef inDate) const;
	bool
		operator>=(
				CFDateRef inDate) const;
	bool
		operator<=(
				CFDateRef inDate) const;
	bool
		operator!=(
				CFDateRef inDate) const;
};

CFAbsoluteTime
ACFDate::AbsoluteTime() const
{
	return ::CFDateGetAbsoluteTime(*this);
}

CFTimeInterval
ACFDate::Interval(
		CFDateRef inOtherDate) const
{
	return ::CFDateGetTimeIntervalSinceDate(*this,inOtherDate);
}

bool
ACFDate::operator<(
		CFDateRef inDate) const
{
	return ::CFDateCompare(*this,inDate,NULL) == kCFCompareLessThan;
}

bool
ACFDate::operator>(
		CFDateRef inDate) const
{
	return ::CFDateCompare(*this,inDate,NULL) == kCFCompareGreaterThan;
}

bool
ACFDate::operator==(
		CFDateRef inDate) const
{
	return ::CFDateCompare(*this,inDate,NULL) == kCFCompareEqualTo;
}

bool
ACFDate::operator>=(
		CFDateRef inDate) const
{
	return ::CFDateCompare(*this,inDate,NULL) != kCFCompareLessThan;
}

bool
ACFDate::operator<=(
		CFDateRef inDate) const
{
	return ::CFDateCompare(*this,inDate,NULL) != kCFCompareGreaterThan;
}

bool
ACFDate::operator!=(
		CFDateRef inDate) const
{
	return ::CFDateCompare(*this,inDate,NULL) != kCFCompareEqualTo;
}

