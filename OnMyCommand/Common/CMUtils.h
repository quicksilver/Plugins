//**************************************************************************************
// Filename:	CMUtils.h
//				Part of Contextual Menu Workshop by Abracode Inc.
//				http://free.abracode.com/cmworkshop/
//
// Copyright © 2002-2003 Abracode, Inc.  All rights reserved.
//
// Description:	static utilities for Contextual Menu Plugins
//
//
//**************************************************************************************
#ifndef __CMUtils__
#define __CMUtils__

#pragma once


#include "StResOpen.h"
#include "StBundleResOpen.h"

#if TARGET_RT_MAC_CFM
    #include <Carbon.h>
#else
    #import <Carbon/Carbon.h>
#endif //defined(__MWERKS__)

#pragma export off


typedef OSStatus (*FSSpecHandlerProc)( const FSSpec *inSpec, void *ioData );
typedef OSStatus (*FSRefHandlerProc)( const FSRef *inRef, void *ioData );

enum
{
	kListClear					= 0x00000000,

	kProcDirectiveMask			= 0x00FF0000,
	kProcBreakOnFirst			= 0x00010000,
	
	kListOutFlagsMask			= 0xFF000000,
	kListOutMultipleObjects		= 0x01000000
};

class CMUtils
{
public:


	static OSStatus		AddResCommand( AEDescList* ioCommands,
										short stringsID, short strIndex,
										SInt32 inCommandID,
										MenuItemAttributes attributes = 0,
										UInt32 modifiers = kMenuNoModifiers);
										
	static OSStatus 	AddCommandToAEDescList(	ConstStr255Param inCommandString,
												SInt32 inCommandID,
												AEDescList* ioCommandList,
												MenuItemAttributes attributes = 0,
												UInt32 modifiers = kMenuNoModifiers);

	static OSStatus		AddCommandToAEDescList(	const UniChar *inCommandString,
												UniCharCount inCount,
												SInt32 inCommandID,
												AEDescList* ioCommandList,
												MenuItemAttributes attributes = 0,
												UInt32 modifiers = kMenuNoModifiers);

	static OSStatus		AddCommandToAEDescList(	CFStringRef inCommandString,
												SInt32 inCommandID,
												Boolean putCFString, //available starting with OS 10.2
												AEDescList* ioCommandList,
												MenuItemAttributes attributes = 0,
												UInt32 modifiers = kMenuNoModifiers);

	static OSStatus		AddCommandToAEDescList_Compatible(
												CFStringRef inCommandString,
												SInt32 inCommandID,
												AEDescList* ioCommandList,
												MenuItemAttributes attributes = 0,
												UInt32 modifiers = kMenuNoModifiers);

	static OSStatus		AddSubmenu( AEDescList* ioCommands, short stringsID, short superStrIndex, AEDescList &inSubList );
	static OSStatus		AddSubmenu( AEDescList* ioCommands, CFStringRef inName, AEDescList &inSubList );
	static OSStatus		AddSubmenu( AEDescList* ioCommands, const UniChar *inName, UniCharCount inCount, AEDescList &inSubList );


	static Boolean 		ProcessObjectList( const AEDescList *fileList, UInt32 &ioFlags, FSSpecHandlerProc inProcPtr, void *inProcData = NULL );
	static Boolean		ProcessObjectList( const AEDescList *fileList, UInt32 &ioFlags, FSRefHandlerProc inProcPtr, void *inProcData = NULL );

	static OSErr		GetFSSpec(const AEDesc &inDesc, FSSpec &outSpec);
	static OSErr		GetFSRef(const AEDesc &inDesc, FSRef &outRef);

	static OSStatus		GetPStringName(const FSSpec *inSpec, Str255 outName);
	static OSStatus		GetPStringName(const FSRef *inRef, Str255 outName);
	static CFStringRef	CreateCFStringNameFromFSRef(const FSRef *inRef);
	static OSErr		CreateAliasDesc( const AliasHandle inAliasH, AEDesc *outAliasAEDesc );
	static OSErr		CreateAliasDesc( const FSSpec *inFSSpec, AEDesc *outAliasAEDesc );
	static OSErr		CreateAliasDesc( const FSRef *inFSRef, AEDesc *outAliasAEDesc );
	static OSErr		CreateAliasDesc( const CFURLRef inURL, AEDesc *outAliasAEDesc );

	static OSErr		IsFolder(const FSSpec *inSpec, Boolean &outIsFolder);
	static OSErr		IsFolder(const FSRef *inRef, Boolean &outIsFolder);
	

	static short		OpenBundleResourceMap( CFBundleRef inBundleRef );
	static void			CloseBundleResourceMap( SInt16 &ioFileRefNum, CFBundleRef inBundleRef );

	static OSErr		SendAppleEventToFinder( AEEventClass theAEEventClass, AEEventID theAEEventID,
												const AEDesc &directObjectDesc,
												Boolean waitForReply, Boolean toSelf);
												
	static OSErr		SendAEWithTwoObjToFinder( AEEventClass theAEEventClass, AEEventID theAEEventID,
													AEKeyword keyOne, const AEDesc &objOne,
													AEKeyword keyTwo, const AEDesc &objTwo,
													Boolean waitForReply, Boolean toSelf);

	static OSErr		SendAEWithThreeObjToFinder( AEEventClass theAEEventClass, AEEventID theAEEventID,
													AEKeyword keyOne, const AEDesc &objOne,
													AEKeyword keyTwo, const AEDesc &objTwo,
													AEKeyword keyThree, const AEDesc &objThree,
													Boolean waitForReply, Boolean toSelf);

	static OSErr		SendAppleEventToRunningApplication( FourCharCode appSig, AEEventClass theAEEventClass,
															AEEventID theAEEventID, const AEDesc &directObjectDesc, Boolean waitForReply = false);

	static OSErr		SendAEWithObjToRunningApp( FourCharCode appSig, AEEventClass theAEEventClass, AEEventID theAEEventID,
													AEKeyword keyOne, const AEDesc &objOne, Boolean waitForReply = false  );

	static OSErr		SendAEWithTwoObjToRunningApp( FourCharCode appSig, AEEventClass theAEEventClass, AEEventID theAEEventID,
														AEKeyword keyOne, const AEDesc &objOne,
														AEKeyword keyTwo, const AEDesc &objTwo, Boolean waitForReply = false);

	static OSErr		SendAEWithThreeObjToRunningApp( FourCharCode appSig, AEEventClass theAEEventClass, AEEventID theAEEventID,
														AEKeyword keyOne, const AEDesc &objOne,
														AEKeyword keyTwo, const AEDesc &objTwo,
														AEKeyword keyThree, const AEDesc &objThree, Boolean waitForReply = false);

	static OSErr		SendAppleEventToSelf(AEEventClass theAEEventClass, AEEventID theAEEventID, const AEDesc &directObjectDesc);
	static OSErr		SendAppleEventWithObjToSelf(AEEventClass theAEEventClass, AEEventID theAEEventID,
													AEKeyword keyOne, const AEDesc &objOne);

	static OSErr		SendAEWithTwoObjToSelf(AEEventClass theAEEventClass, AEEventID theAEEventID,
													AEKeyword keyOne, const AEDesc &objOne,
													AEKeyword keyTwo, const AEDesc &objTwo);

	static OSErr		SendAEWithThreeObjToSelf(AEEventClass theAEEventClass, AEEventID theAEEventID,
													AEKeyword keyOne, const AEDesc &objOne,
													AEKeyword keyTwo, const AEDesc &objTwo,
													AEKeyword keyThree, const AEDesc &objThree);

	static OSErr		SendAppleEventWithObjToSelfWithReply(AEEventClass theAEEventClass, AEEventID theAEEventID,
														AEDesc &outReply,
														AEKeyword keyOne, const AEDesc &objOne);

//	static OSErr		SendServicesQueryToSelf();
	static OSErr		GetHostName(Str255 outName);

	static void			PutFinderObjectToTrash(const AEDesc &directObjectDesc, Boolean waitForReply, Boolean toSelf);
	static void			PutFinderObjectToTrash(const FSRef *inRef, Boolean waitForReply, Boolean toSelf);
	static void			PutFinderObjectToTrash(const FSSpec *inSpec, Boolean waitForReply, Boolean toSelf);


	static void			UpdateFinderObject(const AEDesc &directObjectDesc, Boolean waitForReply, Boolean toSelf);
	static void			UpdateFinderObject(const FSRef *inRef, Boolean waitForReply, Boolean toSelf);
	static void			UpdateFinderObject(const FSSpec *inSpec, Boolean waitForReply, Boolean toSelf);

	static void			MoveFinderObjectToFolder(const AEDesc &directObjectDesc, const FSRef *inFolderRef, Boolean waitForReply, Boolean toSelf);
	static void			MoveFinderObjectToFolder(const AEDesc &directObjectDesc, const FSSpec *inFolderSpec, Boolean waitForReply, Boolean toSelf);
	static void			MoveFinderObjectToFolder(const FSRef *inFileRef, const FSRef *inFolderRef, Boolean waitForReply, Boolean toSelf);
	static void			MoveFinderObjectToFolder(const FSSpec *inFileSpec, const FSSpec *inFolderSpec, Boolean waitForReply, Boolean toSelf);

	static OSStatus		GetInsertionLocationAsAliasDesc(AEDesc &outAliasDesc, AEDesc &outFinderObj, Boolean toSelf);
	static Boolean		IsClickInOpenFinderWindow(const AEDesc *inContext, Boolean doCheckIfFolder);
	static OSErr		GetFinderWindowViewType(AEDesc &finderObjDesc, FourCharCode &outViewType, Boolean toSelf);

	static OSErr		DeleteObject(const FSRef *inRef);
	static OSErr		DeleteObject(const FSSpec *inSpec);

	static Boolean		AEDescHasTextData(const AEDesc &inDesc);
	static CFStringRef	CreateCFStringFromAEDesc(const AEDesc &inDesc);
	static OSStatus		CreateUniTextDescFromCFString(CFStringRef inStringRef, AEDesc &outDesc);

	static CFStringRef	CreateCFStringFromResourceText(short stringsID, short strIndex);

	static void			BufToHex( const unsigned char* src, char *dest, ByteCount srcLen, ByteCount &destLen, UInt8 clumpSize = 0);
	static void			DebugCFString(CFStringRef inStr);
	static void			DebugLongNumber(long inNum);
};



#pragma export reset


#endif //__CMUtils__