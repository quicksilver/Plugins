// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XWrapper.h"

class APicture :
		public XWrapper<PicHandle>
{
public:
		APicture(
				const Rect &inFrame);
		APicture(
				PicHandle inPicture,
				bool inOwnsPict = false)
		: XWrapper(inPicture,inOwnsPict) {}
		APicture(
				short inID);
		APicture() {}
	
		operator Handle() const
		{ return (Handle) mObject; }
	PicPtr
		operator*() const
		{ return *mObject; }
	const Rect&
		PicFrame() const
		{ return (**mObject).picFrame; }
	
	void
		Close();
	void
		Draw(
				const Rect &inDestRect) const;
};

// ---------------------------------------------------------------------------

inline
APicture::APicture(
		const Rect &inFrame)
{
	mOwner = true;
	mObject = ::OpenPicture(&inFrame);
}

// ---------------------------------------------------------------------------

inline
APicture::APicture(
		short inID)
{
	mOwner = true;
	mObject = ::GetPicture(inID);
}

// ---------------------------------------------------------------------------

inline void
APicture::Close()
{
	::ClosePicture();
}

// ---------------------------------------------------------------------------

inline void
APicture::Draw(
		const Rect &inDestRect) const
{
	::DrawPicture(mObject,&inDestRect);
}

// ---------------------------------------------------------------------------

inline void
XWrapper<PicHandle>::DisposeSelf()
{
	::KillPicture(mObject);
}
