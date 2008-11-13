// ACCELA Mac toolbox C++ wrapper library
// Copyright (C) 2002  David Catmull

#pragma once

#include "ACFTree.h"

#include FW(CoreFoundation,CFXMLParser.h)

#pragma warn_unusedarg off

// ---------------------------------------------------------------------------

class ACFXMLNode;

class ACFXMLParserContext :
		public CFXMLParserContext
{
public:
		ACFXMLParserContext(
				void *inInfo)
		{
			version = 0;	// ??
			info = inInfo;
			retain = NULL;
			release = NULL;
			copyDescription = NULL;
		}
};

class ACFXMLParser :
		public ACFType<CFXMLParserRef>
{
public:
		// Parser
		ACFXMLParser(
				CFXMLParserRef inParser,
				bool inDoRetain = true)
		: ACFType<CFXMLParserRef>(inParser,inDoRetain) {}
		// XML data
		ACFXMLParser(
				CFDataRef inXMLData,
				CFURLRef inDataSource = NULL,
				CFOptionFlags inParseOptions = kCFXMLParserNoOptions,
				CFIndex inVersionOfNodes = kCFXMLNodeCurrentVersion)
		: ACFType<CFXMLParserRef>(NULL,false)
		{
			ACFXMLParserContext context(this);
			mObjectRef = ::CFXMLParserCreate(
					kCFAllocatorDefault,inXMLData,inDataSource,
					inParseOptions,inVersionOfNodes,
					&sCallbacks,&context);
		}
	
	CFURLRef
		SourceURL() const;
	
	CFIndex
		Location() const;
	CFIndex
		LineNumber() const;
	void*
		Document() const;
	
	CFXMLParserStatusCode
		StatusCode() const;
	CFStringRef
		CopyErrorDescription() const;
	
	bool
		Parse();
	
protected:
	static CFXMLParserCallBacks sCallbacks;
	
	void
		Abort();
	
	virtual void*
		CreateXMLStructure(
				ACFXMLNode &inNode)
		{
			return NULL;
		}
	virtual void
		AddChild(
				void *inParent,
				void *inChild) {}
	virtual void
		EndXMLStructure(
				void *inXMLType) {}
	virtual CFDataRef
		ResolveExternalEntity(
				CFXMLExternalID *inExtID)
		{
			return NULL;
		}
	virtual bool
		HandleError(
				CFXMLParserStatusCode inError)
		{
			return true;	// attempt to recover
		}
	
	static void*
		CreateXMLStructureCB(
				CFXMLParserRef inParser,
				CFXMLNodeRef inNodeDesc,
				void *inInfo);
	static void
		AddChildCB(
				CFXMLParserRef inParser,
				void *inParent,
				void *inChild,
				void *inInfo);
	static void
		EndXMLStructureCB(
				CFXMLParserRef inParser,
				void *inXMLType,
				void *inInfo);
	static CFDataRef
		ResolveExternalEntityCB(
				CFXMLParserRef inParser,
				CFXMLExternalID *inExtID,
				void *inInfo);
	static Boolean
		HandleErrorCB(
				CFXMLParserRef inParser,
				CFXMLParserStatusCode inError,
				void *inInfo);
};

// ---------------------------------------------------------------------------

class ACFXMLTree :
		public ACFTree
{
public:
		ACFXMLTree(
				CFTreeRef inTree,
				bool inDoRetain = true)
		: ACFTree(inTree,inDoRetain) {}
		ACFXMLTree(
				CFXMLNodeRef inNode)
		: ACFTree(::CFXMLTreeCreateWithNode(kCFAllocatorDefault,inNode),false) {}
		ACFXMLTree(
				CFDataRef inXMLData,
				CFURLRef inDataSource = NULL,
				CFOptionFlags inParseOptions = kCFXMLParserNoOptions,
				CFIndex inVersionOfNodes = kCFXMLNodeCurrentVersion)
		: ACFTree(::CFXMLTreeCreateFromData(kCFAllocatorDefault,inXMLData,inDataSource,inParseOptions,inVersionOfNodes),false) {}
		ACFXMLTree(
				const FSRef &inRef,
				CFOptionFlags inParseOptions = kCFXMLParserNoOptions,
				CFIndex inVersionOfNodes = kCFXMLNodeCurrentVersion);
	
	CFXMLNodeRef
		Node() const;
	CFDataRef
		CreateXMLData() const;
	
	CFStringRef
		ChildText() const;
};

// ---------------------------------------------------------------------------

class ACFXMLNode :
		public ACFType<CFXMLNodeRef>
{
public:
		ACFXMLNode(
				CFXMLNodeRef inNode,
				bool inDoRetain = true)
		: ACFType<CFXMLNodeRef>(inNode,inDoRetain) {}
		ACFXMLNode(
				CFXMLNodeTypeCode inXMLType,
				CFStringRef inDataString,
				const void *inAdditionalInfoPtr = NULL,
				CFIndex inVersion = kCFXMLNodeCurrentVersion)
		: ACFType<CFXMLNodeRef>(::CFXMLNodeCreate(kCFAllocatorDefault,inXMLType,inDataString,inAdditionalInfoPtr,inVersion),false) {}
	
	CFXMLNodeRef
		CreateCopy() const;
	CFXMLNodeTypeCode
		TypeCode() const;
	CFStringRef
		DataString() const;
	const void*
		InfoPtr() const;
	CFIndex
		Version() const;
	
	CFStringRef
		Attribute(
				CFStringRef inName) const;
};

// ---------------------------------------------------------------------------

#pragma warn_unusedarg reset

inline CFXMLNodeRef
ACFXMLTree::Node() const
{
	return ::CFXMLTreeGetNode(*this);
}

inline CFDataRef
ACFXMLTree::CreateXMLData() const
{
	return ::CFXMLTreeCreateXMLData(kCFAllocatorDefault,*this);
}

// ---------------------------------------------------------------------------

inline CFXMLNodeRef
ACFXMLNode::CreateCopy() const
{
	return ::CFXMLNodeCreateCopy(kCFAllocatorDefault,*this);
}

inline CFXMLNodeTypeCode
ACFXMLNode::TypeCode() const
{
	return ::CFXMLNodeGetTypeCode(*this);
}

inline CFStringRef
ACFXMLNode::DataString() const
{
	return ::CFXMLNodeGetString(*this);
}

inline const void*
ACFXMLNode::InfoPtr() const
{
	return ::CFXMLNodeGetInfoPtr(*this);
}

inline CFIndex
ACFXMLNode::Version() const
{
	return ::CFXMLNodeGetVersion(*this);
}
