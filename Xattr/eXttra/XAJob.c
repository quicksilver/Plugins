/*
 *  XAJob.c
 *  eXttra
 *
 *  Created by nibs ra on 2/10/05.
 *  Copyright 2005 __MyCompanyName__. All rights reserved.
 *
 */

#include "XAJob.h"
#include <XAOperation.h>
#include <XASetOperation.h>
#include <XAGetOperation.h>
#include <XARemoveOperation.h>
#include <XAListOperation.h>
#include <XAFile.h>
#include <sys/types.h>
#include <sys/stat.h>

//#include <CoreFoundation/CFRuntime.h>
#include <CFRuntime.h>

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>
#include <string.h>

typedef struct __XAJob
{
	CFRuntimeBase		base;
	CFMutableArrayRef	operations;
	CFMutableArrayRef	postOperations;
	CFMutableArrayRef	files;
	XAOperationRef		listOperation;

}XAJob;

static Boolean __XAJobEqual(CFTypeRef cf1, CFTypeRef cf2)
{
    XAJobRef jobRef1 = (XAJobRef)cf1;
    
    XAJobRef jobRef2 = (XAJobRef)cf2;
    
    Boolean bRet = true;
    
    bRet &= jobRef1 == jobRef2;
    
    return(bRet);
}

static CFHashCode __XAJobHash(CFTypeRef cf)
{
    XAJobRef jobRef = (XAJobRef)cf;
    
    return((CFHashCode)((unsigned int)jobRef));
}

static CFStringRef __XAJobCopyFormattingDesc(CFTypeRef cf,
											  CFDictionaryRef fOpts)
{
    XAJobRef jobRef = (XAJobRef)cf;
    
    CFStringRef			format = CFSTR("[XAJob: %010#x]");
    
	unsigned int		data = (unsigned int)jobRef;
    
    return(CFStringCreateWithFormat(CFGetAllocator(jobRef),
									fOpts,
									format,
									data));
}

static CFStringRef __XAJobCopyDebugDesc(CFTypeRef cf)
{
    return(__XAJobCopyFormattingDesc(cf, NULL));
}

static void __XAJobFinalize(CFTypeRef cf)
{
    XAJobRef jobRef = (XAJobRef)cf;
	
	if(jobRef->operations)
	{
		CFRelease(jobRef->operations); jobRef->operations = 0x00;
	}
	
	if(jobRef->files)
	{
		CFRelease(jobRef->files); jobRef->files = 0x00;
	}
	
}

static CFTypeID _kXAJobTypeID = _kCFRuntimeNotATypeID;

static const CFRuntimeClass _kXAJobClass =
{
	0x00,
	"XAJob",
	NULL,
	NULL,
	__XAJobFinalize,
	__XAJobEqual,
	__XAJobHash,
	__XAJobCopyFormattingDesc,
	__XAJobCopyDebugDesc
};

/* Something external to this file is assumed to call this
* before the XAJob class is used.
*/
void __XAJobClassInitialize(void)
{
    _kXAJobTypeID = _CFRuntimeRegisterClass(&_kXAJobClass);
}

XAJobRef _XAJobAllocate(CFAllocatorRef allocator)
{
    XAJobRef jobRef = NULL;
    
    uint32_t extra = sizeof(XAJob) - sizeof(CFRuntimeBase);
    
    jobRef = (XAJobRef)_CFRuntimeCreateInstance(allocator,
												_kXAJobTypeID,
												extra,
												NULL);
    
    memset((unsigned char *)jobRef + sizeof(CFRuntimeBase), 0x00, extra);
	
	jobRef->operations = CFArrayCreateMutable(allocator, 0x00, &kCFTypeArrayCallBacks);
	
	jobRef->postOperations = CFArrayCreateMutable(allocator, 0x00, &kCFTypeArrayCallBacks);
	
	jobRef->files = CFArrayCreateMutable(allocator, 0x00, &kCFTypeArrayCallBacks);
		
    return(jobRef);
}

CFTypeID XAJobGetTypeID(void)
{
    return(_kXAJobTypeID);
}

void XAJobAddOperation(XAJobRef jobRef, XAOperationRef operation)
{
	if(operation)
	{
		CFArrayAppendValue(jobRef->operations, operation);
	}
	
}

void XAJobAddPostOperation(XAJobRef jobRef, XAOperationRef operation)
{
	if(operation)
	{
		CFArrayAppendValue(jobRef->postOperations, operation);
	}
	
}

void XAJobAddFile(XAJobRef jobRef, XAFileRef file)
{
	CFArrayAppendValue(jobRef->files, file);
}

void XAJobSetListOperation(XAJobRef jobRef, XAOperationRef listOperation)
{
	if(listOperation)
		CFRetain(listOperation);
	
	if(jobRef->listOperation)
		CFRetain(jobRef->listOperation);
	
	jobRef->listOperation = listOperation;
	
}

CFStringRef XACopyFullCFPath(char *file)
{
	CFStringRef path = 0x00;
	
	struct stat sb;
	
	int iRet = stat(file, &sb);

	if(!iRet)
	{
		path = CFStringCreateWithCString(kCFAllocatorDefault, file, kCFStringEncodingUTF8);
	}else
	{
		if(errno == ENOENT)
		{
			char *cwd = getcwd(0x00, 0x00);
			
			char *fPath = calloc(0x02 + strlen(cwd) + strlen(file), sizeof(*fPath));
			
			sprintf(fPath, "%s/%s", cwd, file);
			
			puts(fPath);
			
			path = CFStringCreateWithCString(kCFAllocatorDefault, fPath, kCFStringEncodingUTF8);

		}
		
	}
	
	return(path);
}

// arguments look like --set <key> <value> 
int XAJobParseSetArgs(XAJobRef jobRef, int argc, char **argv)
{
	int consumption = 0x00;
	
	UInt8 valid = 0x00;
	
	if(!strcmp(argv[0x00], "--set"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-s"))
	{
		valid = 0x01;
	}
	
	if(valid)
	{
		if(argc > 0x02)
		{
			XAOperationRef operation = 0x00;
			
			char *key = argv[0x01]; char *value = argv[0x02];
			
			operation = XASetOperationCreate(CFGetAllocator(jobRef), key, value);
			
			XAJobAddOperation(jobRef, operation);
			
			CFRelease(operation);
			
			consumption = 0x03;
		}else
		{
			consumption = -1;
		}
		
	}
	
	return(consumption);
}

// arguments look like --set-data <key> <path> 
int XAJobParseSetDataArgs(XAJobRef jobRef, int argc, char **argv)
{
	int consumption = 0x00;
	
	UInt8 valid = 0x00;
	
	if(!strcmp(argv[0x00], "--set-data"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-sd"))
	{
		valid = 0x01;
	}
	
	if(valid)
	{
		if(argc > 0x02)
		{
			XAOperationRef operation = 0x00;
			
			char *key = argv[0x01]; char *path = argv[0x02];
			
			CFAllocatorRef allocator = CFGetAllocator(jobRef);
			
			CFStringRef kPath = XACopyFullCFPath(path);
						
			operation = XASetDataOperationCreate(allocator, key, kPath);
			
			if(operation)
			{
				XAJobAddOperation(jobRef, operation);
				
				CFRelease(operation);
			}
			
			consumption = 0x03;
		}else
		{
			consumption = -1;
		}
		
	}
	
	return(consumption);
}

// arguments look like --delete <key> 
int XAJobParseDeleteArgs(XAJobRef jobRef, int argc, char **argv)
{
	int consumption = 0x00;
	
	UInt8 valid = 0x00;
	
	if(!strcmp(argv[0x00], "--delete"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-d"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-rm"))
	{
		valid = 0x01;
	}
	
	if(valid)
	{
		if(argc > 0x01)
		{
			XAOperationRef operation = 0x00;
			
			char *key = argv[0x01];
			
			operation = XARemoveOperationCreate(CFGetAllocator(jobRef), key);
			
			XAJobAddOperation(jobRef, operation);
			
			CFRelease(operation);
			
			consumption = 0x02;
		}else
		{
			consumption = -1;
		}
		
	}
	
	return(consumption);
}

// arguments look like --copy <key> <path>
int XAJobParseCopyArgs(XAJobRef jobRef, int argc, char **argv)
{
	int consumption = 0x00;
	
	UInt8 valid = 0x00;
	
	if(!strcmp(argv[0x00], "--copy"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-c"))
	{
		valid = 0x01;
	}
	
	if(valid)
	{
		if(argc > 0x02)
		{
			XAOperationRef operation = 0x00;
			
			char *key = argv[0x01]; char *path = argv[0x02];
			
			CFAllocatorRef allocator = CFGetAllocator(jobRef);
			
			CFStringRef kPath = XACopyFullCFPath(path);

			operation = XASetOperationCreateWithPath(allocator, key, kPath);
			
			CFRelease(kPath);
			
			if(operation)
			{
				XAJobAddOperation(jobRef, operation);
				
				CFRelease(operation);
			}else
			{
				
			}
			consumption = 0x03;
		}else
		{
			consumption = -1;
		}
		
	}
	
	return(consumption);
}

// arguments look like --list 
int XAJobParseListArgs(XAJobRef jobRef, int argc, char **argv)
{
	int consumption = 0x00;
	
	UInt8 valid = 0x00;
	
	XAListStyle style = XADefaultListStyle;
	
	if(!strcmp(argv[0x00], "--list"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-ls"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-l"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "--list-parseable"))
	{
		valid = 0x01;
		style = XAParseableListStyle;
	}else if(!strcmp(argv[0x00], "-lsp"))
	{
		valid = 0x01;
		style = XAParseableListStyle;
	}else if(!strcmp(argv[0x00], "-lp"))
	{
		valid = 0x01;
		style = XAParseableListStyle;
	}
	
	if(valid)
	{
		if(argc > 0x00)
		{
			XAOperationRef operation = 0x00;
			
			operation = XAListOperationCreate(CFGetAllocator(jobRef));
			
			XAListOperationSetListStyle((XAListOperationRef)operation, style);
			
			//XAJobAddOperation(jobRef, operation);
			XAJobSetListOperation(jobRef, operation);
			
			CFRelease(operation);
			
			consumption = 0x01;
		}else
		{
			consumption = -1;
		}
		
	}
	
	return(consumption);
}

// arguments look like --get 
int XAJobParseGetArgs(XAJobRef jobRef, int argc, char **argv)
{
	int consumption = 0x00;
	
	UInt8 valid = 0x00;
	
	XAListStyle style = XADefaultListStyle;
	
	if(!strcmp(argv[0x00], "--get"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "-g"))
	{
		valid = 0x01;
	}else if(!strcmp(argv[0x00], "--get-parseable"))
	{
		valid = 0x01;
		style = XAParseableListStyle;
	}else if(!strcmp(argv[0x00], "-gp"))
	{
		valid = 0x01;
		style = XAParseableListStyle;
	}
	
	if(valid)
	{
		if(argc > 0x01)
		{
			XAOperationRef operation = 0x00;
			
			char *key = argv[0x01]; 
			
			operation = XAGetOperationCreate(CFGetAllocator(jobRef), key);
			
			XAGetOperationSetListStyle((XAGetOperationRef)operation, style);
			
			XAJobAddOperation(jobRef, operation);
			//XAJobSetListOperation(jobRef, operation);
			
			CFRelease(operation);
			
			consumption = 0x02;
		}else
		{
			consumption = -1;
		}
		
	}
	
	return(consumption);
}

// arguments look like <file, ...> 
int XAJobParseFileArgs(XAJobRef jobRef, int argc, char **argv)
{
	int consumption = 0x00;
	
	int index = 0x00;
	
	CFAllocatorRef allocator = CFGetAllocator(jobRef);

	for(index = 0x00; index < argc; index++)
	{
		CFStringRef path = XACopyFullCFPath(argv[index]);
	
		if(path)
		{
			XAFileRef file = XAFileCreateWithPath(allocator, path);

			XAJobAddFile(jobRef, file);
				
			CFRelease(file);
		}else
		{
			fprintf(stderr, "invalid file: %s\n", argv[index]);
		}
		
		consumption = consumption + 0x01;
	}
	
	return(consumption);
}

Boolean XAJobParseArguments(XAJobRef jobRef, int argc, char **argv)
{
	Boolean bRet = 0x01;
	
	int aIndex = 0x01;
	
	int oCount = 0x00; int fCount = 0x00;
	
	while(aIndex < argc)
	{
		int consumption = 0x00;
	
		int kArgc = argc - aIndex;
		
		char **kArgv = &argv[aIndex];
		
		if(consumption = XAJobParseSetArgs(jobRef, kArgc, kArgv))
		{
			if(consumption < 0x00)
			{
				bRet = 0x01;
				break;
			}
			oCount++;

		}else if(consumption = XAJobParseSetDataArgs(jobRef, kArgc, kArgv))
		{
			if(consumption < 0x00)
			{
				bRet = 0x01;
				break;
			}
			oCount++;

		}else if(consumption = XAJobParseCopyArgs(jobRef, kArgc, kArgv))
		{
			if(consumption < 0x00)
			{
				bRet = 0x01;
				break;
			}
			oCount++;

		}else if(consumption = XAJobParseListArgs(jobRef, kArgc, kArgv))
		{
			if(consumption < 0x00)
			{
				bRet = 0x01;
				break;
			}
			oCount++;
			
		}else if(consumption = XAJobParseGetArgs(jobRef, kArgc, kArgv))
		{
			if(consumption < 0x00)
			{
				bRet = 0x01;
				break;
			}
			oCount++;
			
		}else if(consumption = XAJobParseDeleteArgs(jobRef, kArgc, kArgv))
		{
			if(consumption < 0x00)
			{
				bRet = 0x01;
				break;
			}
			oCount++;
	
		}else // must be files
		{
			consumption = XAJobParseFileArgs(jobRef, kArgc, kArgv);
			
			if(consumption < 0x00)
			{
				bRet = 0x01; 
				break;
			}
			fCount++;
		}
		
		aIndex += consumption;

	}
	
	bRet &= (oCount > 0x00) && (fCount > 0x00);
	
	return(bRet);
}

XAJobRef XAJobCreateWithArguments(CFAllocatorRef allocator, int argc, char **argv)
{
	XAJobRef jobRef = _XAJobAllocate(allocator);
	
	if(!XAJobParseArguments(jobRef, argc, argv))
	{
		CFRelease(jobRef); jobRef = 0x00;
	}
	
    return(jobRef);
}

void XAJobExecute(XAJobRef jobRef)
{
	CFIndex fIndex = 0x00;
	CFIndex fCount = CFArrayGetCount(jobRef->files);
	
	if(CFArrayGetCount(jobRef->postOperations))
	{
		CFRange range = CFRangeMake(0x00, CFArrayGetCount(jobRef->postOperations));
		
		CFArrayAppendArray(jobRef->operations, jobRef->postOperations, range);
	}
	
	XAJobAddOperation(jobRef, jobRef->listOperation);

	for(fIndex = 0x00; fIndex < fCount; fIndex++)
	{
		XAFileRef file = 0x00;

		file = (XAFileRef)CFArrayGetValueAtIndex(jobRef->files, fIndex);
		
		XAFileExecuteOperations(file, jobRef->operations);
	}
	
}

