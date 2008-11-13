// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "XRefCountObject.h"

class ACollection :
		public XRefCountObject<Collection>
{
		ACollection();
	explicit
		ACollection(
				Handle inFlattenedHandle);
	
	Collection
		Copy(
				Collection inDestCollection = NULL);
	
	SInt32
		DefaultAttributes();
	void
		SetDefaultAttributes(
				SInt32 inWhichAttr,
				SInt32 inNewAttr);
	
	// basic items
	SInt32
		ItemCount();
	void
		AddItem(
				CollectionTag inTag,
				SInt32 inID,
				SInt32 inSize,
				const void *inDataPtr);
	template <class T>
	void
		AddItem(
				CollectionTag inTag,
				SInt32 inID,
				const T &inData);
	void
		AddItem(
				CollectionTag inTag,
				SInt32 inID,
				Handle inHandle);
	void
		GetItem(
				CollectionTag inTag,
				SInt32 inID,
				SInt32 &ioSize,
				void *inDataPtr);
	template <class T>
	void
		GetItem(
				CollectionTag inTag,
				SInt32 inID,
				const T &inData);
	void
		GetItem(
				CollectionTag inTag,
				SInt32 inID,
				Handle inHandle);
	void
		RemoveItem(
				CollectionTag inTag,
				SInt32 inID);
	
	// get/set item info
	
	// add/get/info indexed item
	
	// tags
	bool
		TagExists(
				CollectionTag inTag);
	SInt32
		TagCount();
	CollectionTag
		GetIndTag(
				SInt32 inIndex);
	SInt32
		TaggedItemCount(
				CollectionTag inTag);
	
	// tagged items
	void
		GetIndTaggedItem(
				CollectionTag inTag,
				SInt32 inIndex,
				SInt32 &ioSize,
				void *inDataPtr);
	template <class T>
	void
		GetIndTaggedItem(
				CollectionTag inTag,
				SInt32 inIndex,
				const T &inData);
	void
		GetIndTaggedItem(
				CollectionTag inTag,
				SInt32 inIndex,
				Handle inHandle);
	
	// purging and emptying
	void
		Purge(
				SInt32 inWhichAttr,
				SInt32 inMatchAttr);
	void
		PurgeTag(
				CollectionTag inTag);
	void
		Empty();
	
	Handle
		FlattenToHandle();
};

inline void
XRefCountObject<Collection>::Retain()
{ ::RetainCollection(mObjectRef); }

inline void
XRefCountObject<Collection>::Release()
{ ::ReleaseCollection(mObjectRef); }

inline UInt32
XRefCountObject<Collection>::GetRetainCount() const
{ return ::GetCollectionRetainCount(mObjectRef); }
