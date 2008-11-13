// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "FW.h"

#include FW(ApplicationServices,Processes.h)

class AProcess :
		public ProcessSerialNumber
{
public:
		AProcess(
				const ProcessSerialNumber &inPSN);
		AProcess(
				unsigned long inID = kNoProcess)
		{ highLongOfPSN = 0; lowLongOfPSN = inID; }
	
	bool
		IsValid()
		{
			return ((highLongOfPSN != 0) || (lowLongOfPSN != kNoProcess));
		}
	
	void
		SetFront() const;
	void
		WakeUp() const;
	
	bool
		IsVisible() const;
	void
		ShowHide(
				bool inShow) const;
	void
		GetInfo(
				ProcessInfoRec &outInfo) const;
	
	OSType
		Signature() const;
	void
		GetBundleLocation(
				FSRef &outRef) const;
	CFStringRef
		CopyName() const;
};

class ASignatureProcess :
		public AProcess
{
public:
		ASignatureProcess(
				OSType inSignature);
};

// ---------------------------------------------------------------------------

inline bool
operator!(
		const ProcessSerialNumber &inPSN)
{
	return ((inPSN.highLongOfPSN == 0) && (inPSN.lowLongOfPSN == kNoProcess));
}

inline bool
operator==(
		const ProcessSerialNumber &inLeft,
		const ProcessSerialNumber &inRight)
{
	Boolean result;
	::SameProcess(&inLeft,&inRight,&result);
	return result;
}

inline bool
operator!=(
		const ProcessSerialNumber &inLeft,
		const ProcessSerialNumber &inRight)
{
	return !(inLeft == inRight);
}

inline void
AProcess::SetFront() const
{
	::SetFrontProcess(this);
}

inline void
AProcess::WakeUp() const
{
	::WakeUpProcess(this);
}

inline bool
AProcess::IsVisible() const
{
	return ::IsProcessVisible(this);
}

inline void
AProcess::ShowHide(
			bool inShow) const
{
	::ShowHideProcess(this,inShow);
}

inline void
AProcess::GetInfo(
		ProcessInfoRec &outInfo) const
{
	outInfo.processInfoLength = sizeof(ProcessInfoRec);
	::GetProcessInformation(this,&outInfo);
}

inline OSType
AProcess::Signature() const
{
	ProcessInfoRec info;
	info.processInfoLength = sizeof(ProcessInfoRec);
	info.processName = NULL;
	info.processAppSpec = NULL;
	::GetProcessInformation(this,&info);
	return info.processSignature;
}

inline void
AProcess::GetBundleLocation(
		FSRef &outRef) const
{
	::GetProcessBundleLocation(this,&outRef);
}

inline CFStringRef
AProcess::CopyName() const
{
	CFStringRef processName;
	::CopyProcessName(this,&processName);
	return processName;
}
