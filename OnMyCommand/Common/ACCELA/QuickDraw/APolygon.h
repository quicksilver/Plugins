// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#include "XWrapper.h"

class APolygon :
		public XWrapper<PolyHandle>
{
public:
		APolygon(
				PolyHandle inPoly,
				bool inOwnsPoly = false)
		: XWrapper(inPoly,inOwnsPoly) {}
		APolygon();
	virtual
		~APolygon();
	
	PolyPtr
		operator*() const;
	
	void
		Close();
	
	void
		Offset(
				short inH,
				short inV);
	void
		Map(
				const Rect &inSrcRect,
				const Rect &inDestRect);
	void
		Frame() const;
	void
		Paint() const;
	void
		Erase() const;
	void
		Invert() const;
	void
		Fill(
				const Pattern &inPattern) const;
	void
		FillC(
				PixPatHandle inPixPat) const;
	
protected:
	bool mOpen;
};

inline void
XWrapper<PolyHandle>::DisposeSelf()
{ ::KillPoly(mObject); }

inline
APolygon::APolygon()
: XWrapper(::OpenPoly(),true),
  mOpen(true)
{}

inline
APolygon::~APolygon()
{ if (mOpen) Close(); }

inline PolyPtr
APolygon::operator*() const
{ return *mObject; }

inline void
APolygon::Close()
{ ::ClosePoly(); }

inline void
APolygon::Offset(
		short inH,
		short inV)
{ ::OffsetPoly(mObject,inH,inV); }

inline void
APolygon::Map(
		const Rect &inSrcRect,
		const Rect &inDestRect)
{ ::MapPoly(mObject,&inSrcRect,&inDestRect); }

inline void
APolygon::Frame() const
{ ::FramePoly(mObject); }

inline void
APolygon::Paint() const
{ ::PaintPoly(mObject); }

inline void
APolygon::Erase() const
{ ::ErasePoly(mObject); }

inline void
APolygon::Invert() const
{ ::InvertPoly(mObject); }

inline void
APolygon::Fill(
		const Pattern &inPattern) const
{ ::FillPoly(mObject,&inPattern); }

inline void
APolygon::FillC(
		PixPatHandle inPixPat) const
{ ::FillCPoly(mObject,inPixPat); }
