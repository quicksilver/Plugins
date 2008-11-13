#include "ACFXMLParser.h"
#include "ACFURL.h"
#include "ACFData.h"

CFXMLParserCallBacks
		ACFXMLParser::sCallbacks = {
				0,	// what's this supposed to be?
				ACFXMLParser::CreateXMLStructureCB,
				ACFXMLParser::AddChildCB,
				ACFXMLParser::EndXMLStructureCB,
				ACFXMLParser::ResolveExternalEntityCB,
				ACFXMLParser::HandleErrorCB };

// ---------------------------------------------------------------------------

void*
ACFXMLParser::CreateXMLStructureCB(
		CFXMLParserRef,
		CFXMLNodeRef inNodeDesc,
		void *inInfo)
{
	// docs say it's not good to retain the given node
	ACFXMLNode node(::CFXMLNodeCreateCopy(kCFAllocatorDefault,inNodeDesc),false);
	
	return ((ACFXMLParser*)inInfo)->CreateXMLStructure(node);
}

// ---------------------------------------------------------------------------

void
ACFXMLParser::AddChildCB(
		CFXMLParserRef,
		void *inParent,
		void *inChild,
		void *inInfo)
{
	((ACFXMLParser*)inInfo)->AddChild(inParent,inChild);
}

// ---------------------------------------------------------------------------

void
ACFXMLParser::EndXMLStructureCB(
		CFXMLParserRef,
		void *inXMLType,
		void *inInfo)
{
	((ACFXMLParser*)inInfo)->EndXMLStructure(inXMLType);
}

// ---------------------------------------------------------------------------

CFDataRef
ACFXMLParser::ResolveExternalEntityCB(
		CFXMLParserRef,
		CFXMLExternalID *inExtID,
		void *inInfo)
{
	return ((ACFXMLParser*)inInfo)->ResolveExternalEntity(inExtID);
}

// ---------------------------------------------------------------------------

Boolean
ACFXMLParser::HandleErrorCB(
		CFXMLParserRef,
		CFXMLParserStatusCode inError,
		void *inInfo)
{
	return ((ACFXMLParser*)inInfo)->HandleError(inError);
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

ACFXMLTree::ACFXMLTree(
		const FSRef &inRef,
		CFOptionFlags inParseOptions,
		CFIndex inVersionOfNodes)
: ACFTree(NULL,false)
{
	SInt32 errorCode;
	CFDataRef dataRef;
	ACFURL fileURL(inRef);
	Boolean result = CFURLCreateDataAndPropertiesFromResource(
			kCFAllocatorDefault,
			fileURL,
			&dataRef,
			NULL,NULL,&errorCode);
	ACFData dataObject(dataRef,false);
	
	if (result)
		mObjectRef = ::CFXMLTreeCreateFromData(
					kCFAllocatorDefault,dataObject,fileURL,
					inParseOptions,inVersionOfNodes);
	else
		throw errorCode;
}

// ---------------------------------------------------------------------------

CFStringRef
ACFXMLTree::ChildText() const
{
	ACFXMLTree child(FirstChild());
	CFStringRef textString = NULL;
	
	for (; child.Get() != NULL; child.Reset(child.NextSibling()))  {
		ACFXMLNode xmlNode(child.Node());
		CFXMLNodeTypeCode nodeType = xmlNode.TypeCode();
		
		if (nodeType == kCFXMLNodeTypeText) {
			textString = ::CFStringCreateCopy(kCFAllocatorDefault,xmlNode.DataString());
			break;
		}
	}
	return textString;
}

// ---------------------------------------------------------------------------
#pragma mark -
// ---------------------------------------------------------------------------

CFStringRef
ACFXMLNode::Attribute(
		CFStringRef inName) const
{
	const CFXMLElementInfo *nodeInfo = (CFXMLElementInfo*)InfoPtr();
	
	return (CFStringRef)::CFDictionaryGetValue(nodeInfo->attributes,inName);
}

// ---------------------------------------------------------------------------
