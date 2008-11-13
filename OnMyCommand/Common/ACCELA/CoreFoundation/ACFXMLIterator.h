#pragma once

#include "ACFXMLParser.h"

class ACFString;

class ACFXMLIterator
{
public:
		ACFXMLIterator(
				const ACFTree &inParentTree,
				bool inElementsOnly);
	
	operator bool()
		{
			return mTree.Get() != NULL;
		}
	ACFXMLIterator&
		operator++()	// prefix
		{
			Increment();
			return *this;
		}
	
	ACFXMLTree&
		Tree()
		{
			return mTree;
		}
	ACFXMLNode&
		Node()
		{
			return mNode;
		}
	
	bool
		IsNodeType(
				const ACFString &inType) const;
	CFXMLNodeTypeCode
		NodeTypeCode() const
		{
			return mNode.TypeCode();
		}
	
public:
	ACFXMLTree mTree;
	ACFXMLNode mNode;
	const bool mElementsOnly;
	
	void
		Increment();
};
