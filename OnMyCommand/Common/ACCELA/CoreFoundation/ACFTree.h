// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFBase.h"

#include FW(CoreFoundation,CFTree.h)

class ACFTree :
		public ACFType<CFTreeRef>
{
public:
		// CFTreeRef
		ACFTree(
				CFTreeRef inTree,
				bool inDoRetain = true)
		: ACFType<CFTreeRef>(inTree,inDoRetain) {}
		// create with context
		ACFTree(
				const CFTreeContext *inContext)
		: ACFType<CFTreeRef>(::CFTreeCreate(kCFAllocatorDefault,inContext),false) {}
		// create
		ACFTree();
	
		// CFTreeRef is not const
		operator CFTreeRef() const
		{
			return const_cast<CFTreeRef>((const __CFTree*)mObjectRef);
		}
	
	CFTreeRef
		Parent() const;
	CFTreeRef
		NextSibling() const;
	CFTreeRef
		FirstChild() const;
	CFTreeContext
		Context() const;
	
	CFIndex
		ChildCount() const;
	CFTreeRef
		ChildAtIndex(
				CFIndex inIndex) const;
	void
		GetChildren(
				CFTreeRef *children) const;
	
	CFTreeRef
		Root() const;
	
	void
		PrependChild(
				CFTreeRef inNewChild);
	void
		AppendChild(
				CFTreeRef inNewChild);
	void
		InsertSibling(
				CFTreeRef inNewSibling);
	void
		Remove();
	void
		RemoveAllChildren();
	void
		SortChildren(
				CFComparatorFunction inComparator,
				void *inContext);
};

// ---------------------------------------------------------------------------

inline CFTreeRef
ACFTree::Parent() const
{
	return ::CFTreeGetParent(*this);
}

inline CFTreeRef
ACFTree::NextSibling() const
{
	return ::CFTreeGetNextSibling(*this);
}

inline CFTreeRef
ACFTree::FirstChild() const
{
	return ::CFTreeGetFirstChild(*this);
}

inline CFTreeContext
ACFTree::Context() const
{
	CFTreeContext context;
	::CFTreeGetContext(*this,&context);
	return context;
}

inline CFIndex
ACFTree::ChildCount() const
{
	return ::CFTreeGetChildCount(*this);
}

inline CFTreeRef
ACFTree::ChildAtIndex(
		CFIndex inIndex) const
{
	return ::CFTreeGetChildAtIndex(*this,inIndex);
}

inline void
ACFTree::GetChildren(
		CFTreeRef *children) const
{
	::CFTreeGetChildren(*this,children);
}

inline CFTreeRef
ACFTree::Root() const
{
	return ::CFTreeFindRoot(*this);
}

inline void
ACFTree::PrependChild(
		CFTreeRef inNewChild)
{
	::CFTreePrependChild(*this,inNewChild);
}

inline void
ACFTree::AppendChild(
		CFTreeRef inNewChild)
{
	::CFTreeAppendChild(*this,inNewChild);
}

inline void
ACFTree::InsertSibling(
		CFTreeRef inNewSibling)
{
	::CFTreeInsertSibling(*this,inNewSibling);
}

inline void
ACFTree::Remove()
{
	::CFTreeRemove(*this);
}

inline void
ACFTree::RemoveAllChildren()
{
	::CFTreeRemoveAllChildren(*this);
}

inline void
ACFTree::SortChildren(
		CFComparatorFunction inComparator,
		void *inContext)
{
	::CFTreeSortChildren(*this,inComparator,inContext);
}
