#include "ACFXMLIterator.h"
#include "ACFString.h"

// ---------------------------------------------------------------------------

ACFXMLIterator::ACFXMLIterator(
		const ACFTree &inParentTree,
		bool inElementsOnly)
: mTree(inParentTree.FirstChild()),
  mNode(mTree.Get() == NULL ? NULL : mTree.Node()),
  mElementsOnly(inElementsOnly)
{
}

// ---------------------------------------------------------------------------

void
ACFXMLIterator::Increment()
{
	do {
		mTree.Reset(mTree.NextSibling());
		if (mTree.Get() == NULL) {
			mNode.Reset(NULL);
			break;
		}
		mNode.Reset(mTree.Node());
		if (mNode.TypeCode() == kCFXMLNodeTypeElement)
			break;
	} while (mElementsOnly);
}

// ---------------------------------------------------------------------------

bool
ACFXMLIterator::IsNodeType(
		const ACFString &inType) const
{
	const ACFString nodeType(mNode.DataString());
	
	return nodeType == inType;
}
