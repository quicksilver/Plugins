// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "FW.h"

#include FW(QuickTime,ImageCompression.h)

class AMatrix :
		public MatrixRecord
{
public:
		AMatrix();
		AMatrix(
				const MatrixRecord &inMatrix);
		AMatrix(
				const Rect &inFromRect,
				const Rect &inToRect);
	
	AMatrix&
		operator=(
				const MatrixRecord &inMatrix);
	bool
		operator==(
				const MatrixRecord &inMatrix) const;
	AMatrix&
		operator+=(
				const MatrixRecord &inMatrix);
	
	short
		Type() const;
	
	void
		SetIdentity();
	
	bool
		MakeInverse(
				MatrixRecord &outMatrix) const;
	
	// Transformation
	void
		Translate(
				Fixed inH,
				Fixed inV);
	void
		Rotate(
				Fixed inDegrees,
				Fixed inX,
				Fixed inY);
	void
		Rotate(
				Fixed inDegrees,
				const FixedPoint &inCenter);
	void
		Scale(
				Fixed inHScale,
				Fixed inVScale,
				Fixed inX,
				Fixed inY);
	void
		Scale(
				Fixed inHScale,
				Fixed inVScale,
				const FixedPoint &inCenter);
	void
		Skew(
				Fixed inHSkew,
				Fixed inVSkew,
				Fixed inX,
				Fixed inY);
	void
		Skew(
				Fixed inHSkew,
				Fixed inVSkew,
				const FixedPoint &inCenter);
	void
		Map(
				const Rect &inFromRect,
				const Rect &inToRect);
	
	// Transitive transformations
	void
		TransformFixedPoints(
				FixedPoint *inPoints,
				long inCount) const;
	void
		TransformPoints(
				Point *inPoints,
				long inCount) const;
	bool
		TransformFixedRect(
				FixedRect &ioRect) const;
	bool
		TransformFixedRect(
				FixedRect &ioRect,
				FixedPoint *outPoints) const;
	bool
		TransformRect(
				Rect &ioRect) const;
	bool
		TransformRect(
				Rect &ioRect,
				FixedPoint *outPoints) const;
};

// ---------------------------------------------------------------------------

inline
AMatrix::AMatrix()
{
	::SetIdentityMatrix(this);
}

inline
AMatrix::AMatrix(
		const MatrixRecord &inMatrix)
{
	::CopyMatrix(&inMatrix,this);
}

inline
AMatrix::AMatrix(
		const Rect &inFromRect,
		const Rect &inToRect)
{
	::RectMatrix(this,&inFromRect,&inToRect);
}

inline AMatrix&
AMatrix::operator=(
		const MatrixRecord &inMatrix)
{
	::CopyMatrix(&inMatrix,this);
	return *this;
}

inline bool
AMatrix::operator==(
		const MatrixRecord &inMatrix) const
{
	return ::EqualMatrix(this,&inMatrix);
}

inline AMatrix&
AMatrix::operator+=(
		const MatrixRecord &inMatrix)
{
	::ConcatMatrix(&inMatrix,this);
	return *this;
}

inline short
AMatrix::Type() const
{
	return ::GetMatrixType(this);
}

inline void
AMatrix::SetIdentity()
{
	::SetIdentityMatrix(this);
}

inline bool
AMatrix::MakeInverse(
		MatrixRecord &outMatrix) const
{
	return ::InverseMatrix(this,&outMatrix);
}

inline void
AMatrix::Translate(
		Fixed inH,
		Fixed inV)
{
	::TranslateMatrix(this,inH,inV);
}

inline void
AMatrix::Rotate(
				Fixed inDegrees,
				Fixed inX,
				Fixed inY)
{
	::RotateMatrix(this,inDegrees,inX,inY);
}

inline void
AMatrix::Rotate(
		Fixed inDegrees,
		const FixedPoint &inCenter)
{
	::RotateMatrix(this,inDegrees,inCenter.x,inCenter.y);
}

inline void
AMatrix::Scale(
		Fixed inHScale,
		Fixed inVScale,
		Fixed inX,
		Fixed inY)
{
	::ScaleMatrix(this,inHScale,inVScale,inX,inY);
}

inline void
AMatrix::Scale(
		Fixed inHScale,
		Fixed inVScale,
		const FixedPoint &inCenter)
{
	::ScaleMatrix(this,inHScale,inVScale,inCenter.x,inCenter.y);
}

inline void
AMatrix::Skew(
		Fixed inHSkew,
		Fixed inVSkew,
		Fixed inX,
		Fixed inY)
{
	::SkewMatrix(this,inHSkew,inVSkew,inX,inY);
}

inline void
AMatrix::Skew(
		Fixed inHSkew,
		Fixed inVSkew,
		const FixedPoint &inCenter)
{
	::SkewMatrix(this,inHSkew,inVSkew,inCenter.x,inCenter.y);
}

inline void
AMatrix::Map(
		const Rect &inFromRect,
		const Rect &inToRect)
{
	::MapMatrix(this,&inFromRect,&inToRect);
}

inline void
AMatrix::TransformFixedPoints(
		FixedPoint *inPoints,
		long inCount) const
{
	::TransformFixedPoints(this,inPoints,inCount);
}

inline void
AMatrix::TransformPoints(
		Point *inPoints,
		long inCount) const
{
	::TransformPoints(this,inPoints,inCount);
}

inline bool
AMatrix::TransformFixedRect(
		FixedRect &ioRect) const
{
	return ::TransformFixedRect(this,&ioRect,NULL);
}

inline bool
AMatrix::TransformFixedRect(
		FixedRect &ioRect,
		FixedPoint *outPoints) const
{
	return ::TransformFixedRect(this,&ioRect,outPoints);
}

inline bool
AMatrix::TransformRect(
		Rect &ioRect) const
{
	return ::TransformRect(this,&ioRect,NULL);
}

inline bool
AMatrix::TransformRect(
		Rect &ioRect,
		FixedPoint *outPoints) const
{
	return ::TransformRect(this,&ioRect,outPoints);
}

