#include "ANavTypeList.h"

// ---------------------------------------------------------------------------

ANavTypeList::ANavTypeList(
		OSType inSignature)
: mTypeList((NavTypeListHandle)::NewHandle(sizeof(NavTypeList)))
{
	if (mTypeList == NULL)
		throw MemError();
	(**mTypeList).componentSignature = inSignature;
	(**mTypeList).reserved = 0;
	(**mTypeList).osTypeCount = 0;
}

// ---------------------------------------------------------------------------

ANavTypeList::ANavTypeList(
		OSType inSignature,
		OSType inType)
: mTypeList((NavTypeListHandle)::NewHandle(sizeof(NavTypeList)))
{
	if (mTypeList == NULL)
		throw MemError();
	(**mTypeList).componentSignature = inSignature;
	(**mTypeList).reserved = 0;
	(**mTypeList).osTypeCount = 1;
	(**mTypeList).osType[0] = inType;
}

// ---------------------------------------------------------------------------

ANavTypeList::ANavTypeList(
		OSType inSignature,
		short inCount,
		OSType *inTypes)
: mTypeList((NavTypeListHandle)::NewHandle(
		sizeof(NavTypeList)+(sizeof(OSType)*(inCount-1)) ))
{
	if (mTypeList == NULL)
		throw MemError();
	(**mTypeList).componentSignature = inSignature;
	(**mTypeList).reserved = 0;
	(**mTypeList).osTypeCount = inCount;
	
	short i;
	
	for (i = 0; i < inCount; i++)
		(**mTypeList).osType[i] = inTypes[i];
}

// ---------------------------------------------------------------------------

ANavTypeList::~ANavTypeList()
{
	::DisposeHandle((Handle)mTypeList);
}

// ---------------------------------------------------------------------------

void
ANavTypeList::AddType(
		OSType inType)
{
	::SetHandleSize(
			(Handle)mTypeList,
			sizeof(NavTypeList) + (sizeof(OSType) * (**mTypeList).osTypeCount));
	(**mTypeList).osType[(**mTypeList).osTypeCount] = inType;
	(**mTypeList).osTypeCount++;
}

// ---------------------------------------------------------------------------

void
ANavTypeList::AddTypes(
		short inCount,
		OSType *inTypes)
{
	::SetHandleSize(
			(Handle)mTypeList,
			sizeof(NavTypeList) + (sizeof(OSType) * ((**mTypeList).osTypeCount+inCount-1)));
	
	short i,oldCount = (**mTypeList).osTypeCount;
	
	for (i = 0; i < inCount; i++)
		(**mTypeList).osType[i+oldCount] = inTypes[i];
	(**mTypeList).osTypeCount += inCount;
}
