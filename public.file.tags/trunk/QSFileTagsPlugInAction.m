//
//  QSFileTagsPlugInAction.m
//  QSFileTagsPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <QSCore/QSTextProxy.h>

#import "QSMDTagsQueryManager.h"
#import "QSFileTagsPlugInAction.h"

#define kQSFileTagsPlugInAction @"QSFileTagsPlugInAction"

@implementation QSFileTagsPlugInAction

- (NSArray *)tagsFromString:(NSString *)string {
	NSArray *tags = [string componentsSeparatedByString:@" "];
	NSMutableArray *realTags = [NSMutableArray array];
	for(NSString * tag in tags) {
        if ([[QSMDTagsQueryManager sharedInstance] stringByRemovingTagPrefix:tag]) {
			[realTags addObject:tag];
		}
	}
	return realTags;
}

- (NSString *)string:(NSString *)string byAddingTags:(NSArray *)add removingTags:(NSArray *)remove settingTags:(NSArray *)setTags {
	NSMutableArray *mutAdd = [add mutableCopy];
	
	NSMutableArray *array = [[string componentsSeparatedByString:@" "] mutableCopy];
	if (setTags) {
		for(NSString * component in array) {
            if ([[QSMDTagsQueryManager sharedInstance] stringByRemovingTagPrefix:component]) {
				[array removeObject:component];
			}
		}
	}
	[mutAdd removeObjectsInArray:array];
	[array addObjectsFromArray:mutAdd];
	[array removeObjectsInArray:remove];
    [mutAdd release];
	
	[array addObjectsFromArray:setTags];
    NSString *result = [array componentsJoinedByString:@" "];
    [array release];
	return result;
}

- (void)tagFiles:(NSArray *)paths add:(NSArray *)add remove:(NSArray *)remove set:(NSArray *)set {
	NSEnumerator *e = [paths objectEnumerator];
	NSString *path;
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	while(path = [e nextObject]) {
		NSString *comment = [ws commentForFile:path];
		comment = [self string:comment byAddingTags:add removingTags:remove settingTags:set];
	//	NSLog(@"newcomm %@", comment);
		[ws setComment:comment forFile:path];
	}
	return;
	
}

- (QSObject *)addTagsForFile:(QSObject *)dObject tags:(QSObject *)iObject {
	NSArray *newTags = [[iObject stringValue] componentsSeparatedByString:@" "];
	newTags = [[QSMDTagsQueryManager sharedInstance] performSelector:@selector(stringByAddingTagPrefix:) onObjectsInArray:newTags returnValues:YES];
	[self tagFiles:[dObject validPaths] add:newTags remove:nil set:nil];
	return nil;
}

- (QSObject *)removeTagsForFile:(QSObject *)dObject tags:(QSObject *)iObject {
	NSArray *newTags = [[iObject stringValue] componentsSeparatedByString:@" "];
	newTags = [[QSMDTagsQueryManager sharedInstance] performSelector:@selector(stringByAddingTagPrefix:) onObjectsInArray:newTags returnValues:YES];
	[self tagFiles:[dObject validPaths] add:nil remove:newTags set:nil];
	return nil;
}

- (QSObject *)setTagsForFile:(QSObject *)dObject tags:(QSObject *)iObject {
	NSArray *newTags = [[iObject stringValue] componentsSeparatedByString:@" "];
	newTags = [[QSMDTagsQueryManager sharedInstance] performSelector:@selector(stringByAddingTagPrefix:) onObjectsInArray:newTags returnValues:YES];
	[self tagFiles:[dObject validPaths] add:nil remove:nil set:newTags];
	return nil;
}

- (QSObject *)showWindowForTag:(QSObject *)dObject {
//	NSString *string = [dObject stringValue];
	
	return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *comment = [ws commentForFile:[dObject singleFilePath]];
	NSArray *tags = [self tagsFromString:comment];
	tags = [[QSMDTagsQueryManager sharedInstance] performSelector:@selector(stringByRemovingTagPrefix:) onObjectsInArray:tags returnValues:YES];
	
	QSObject *textObject = [QSObject textProxyObjectWithDefaultValue:[tags componentsJoinedByString:@" "]];
	return [NSArray arrayWithObject:textObject]; //[QSLibarrayForType:NSFilenamesPboardType];
}

- (QSObject *)showTags:(QSObject *)dObject {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *comment = [ws commentForFile:[dObject singleFilePath]];
	NSArray *tags = [self tagsFromString:comment];
	NSArray *tagObjects = [self performSelector:@selector(objectForTag:) onObjectsInArray:tags returnValues:YES];
	[[QSReg preferredCommandInterface] showArray:tagObjects];
	return nil;
}

- (QSObject *)objectForTag:(NSString *)tag {
	return [QSObject objectWithType:QSFileTagType value:tag name:[[QSMDTagsQueryManager sharedInstance] stringByRemovingTagPrefix:tag]]; 	
}

- (void)runQuery:(NSString *)query withName:(NSString *)name slices:(NSArray *)slices {
	NSString *trueQuery = query;
	if ([trueQuery rangeOfString:@"kMD"] .location == NSNotFound) {
		trueQuery = [NSString stringWithFormat:@"((kMDItemFSName = '%@*'cd) || kMDItemTextContent = '%@*'cd) && (kMDItemContentType != com.apple.mail.emlx) && (kMDItemContentType != public.vcard) ", query, query];
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"ToolbarVisible"]
			 forKey:@"ViewOptions"];
	[dict setObject:[NSNumber numberWithInt:0]
			 forKey:@"CompatibleVersion"];
	SInt32 macVer;
	if (Gestalt(gestaltSystemVersion, &macVer) == noErr) {
		NSString* version = [NSString stringWithFormat:@"10.%x",((macVer >> 4) & 0xF)];
		[dict setObject:version
                 forKey:@"version"];
	}
	else
		[dict setObject:@"10.4"
                 forKey:@"version"];
        [dict setObject:trueQuery
			 forKey:@"RawQuery"];
    
	if ((Gestalt(gestaltSystemVersion, &macVer) == noErr) && (((macVer >> 4) & 0xF) > 4)) {
		// Saved searches seem to now require an array of paths to search.  Current code uses root as the path.
		[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                         //query, @"AnyAttributeContains",
                         [NSArray arrayWithObjects:@"/", nil], @"FXScopeArrayOfPaths",
                         slices, @"FXCriteriaSlices",
                         nil]
                 forKey:@"SearchCriteria"]; 	
	} else {
		[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                         //query, @"AnyAttributeContains",
                         slices,
                         @"FXCriteriaSlices",
                         nil]
                 forKey:@"SearchCriteria"]; 	
	}
	
	NSMutableString *filename = [[name mutableCopy] autorelease];
	if (!filename) {
		filename = [[query mutableCopy] autorelease];
		[filename replaceOccurrencesOfString:@"/" withString:@"_" options:0 range:NSMakeRange(0, [filename length])];
		if ([filename length] > 242)
			filename = [[[filename substringToIndex:242] mutableCopy] autorelease];
	}
	[filename appendString:@".savedSearch"];
	filename = (NSMutableString*)[NSTemporaryDirectory() stringByAppendingPathComponent:filename];
	[dict writeToFile:filename atomically:NO];
	[[NSFileManager defaultManager] changeFileAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:
                                                          NSFileExtensionHidden] atPath:filename];
	[[NSWorkspace sharedWorkspace] openTempFile:filename];
	
	usleep(500000);
	//[[NSFileManager defaultManager] removeFileAtPath:filename handler:nil];
}

- (QSObject *)showTaggedFilesInFinder:(QSObject *)dObject {
	NSString *string = [[QSMDTagsQueryManager sharedInstance] stringByAddingTagPrefix:[dObject stringValue]];
	
	NSArray *slices = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Othr", @"FXSliceKind", @"kMDItemFinderComment", @"FXAttribute", string, @"Value", @"S:**", @"Operator", nil]];
	NSString *name = [NSString stringWithFormat:@" {%@} ", string];
	NSString *query = [NSString stringWithFormat:@"(kMDItemFinderComment = '%@'cdw) ", string];
	//	NSLog(@"SPURL: %@ - %@", scheme, query);
	
	[self runQuery:query withName:name slices:slices];
	return nil; 	
}

@end
