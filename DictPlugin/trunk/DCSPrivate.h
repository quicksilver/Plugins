//
//  DCSPrivate.h
//  Dictionary
//
//  Created by Nicholas Jitkoff on 3/19/08.
//

#import <CoreServices/CoreServices.h>

DCSDictionaryRef DCSDictionaryCreate(CFURLRef url);
CFArrayRef DCSCopyRecordsForSearchString(DCSDictionaryRef dictionary, CFStringRef string, void *u1, void *u2);
CFDataRef DCSRecordCopyData(CFTypeRef record);
CFStringRef DCSDictionaryGetName(DCSDictionaryRef dictionary);
