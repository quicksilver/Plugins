//
//  QSFileTagsPlugInAction.m
//  QSFileTagsPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSFileTagsPlugInAction.h"

#import <QSCore/QSTextProxy.h>

@implementation QSFileTagsPlugInAction

#define gTagPrefix [[NSUserDefaults standardUserDefaults] objectForKey:@"QSTagPrefix"]

#define kQSFileTagsPlugInAction @"QSFileTagsPlugInAction"
- (NSArray *)tagsFromString:(NSString *)string {
	NSArray *tags = [string componentsSeparatedByString:@" "];
	NSMutableArray *realTags = [NSMutableArray array];
	foreach(tag, tags) {
		if ([tag hasPrefix:gTagPrefix]) {
			[realTags addObject:tag];
		}
	}
	return realTags;
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
	return nil;
	
}

- (QSObject *)addTagsForFile:(QSObject *)dObject tags:(QSObject *)iObject {
	NSArray *newTags = [[iObject stringValue] componentsSeparatedByString:@" "];
	newTags = [[self class] performSelector:@selector(stringByAddingTagPrefix:) onObjectsInArray:newTags returnValues:YES];
	[self tagFiles:[dObject validPaths] add:newTags remove:nil set:nil];
	return nil;
}
- (QSObject *)removeTagsForFile:(QSObject *)dObject tags:(QSObject *)iObject {
	NSArray *newTags = [[iObject stringValue] componentsSeparatedByString:@" "];
	newTags = [[self class] performSelector:@selector(stringByAddingTagPrefix:) onObjectsInArray:newTags returnValues:YES];
	[self tagFiles:[dObject validPaths] add:nil remove:newTags set:nil];
	return nil;
}
- (QSObject *)setTagsForFile:(QSObject *)dObject tags:(QSObject *)iObject {
	NSArray *newTags = [[iObject stringValue] componentsSeparatedByString:@" "];
	newTags = [[self class] performSelector:@selector(stringByAddingTagPrefix:) onObjectsInArray:newTags returnValues:YES];
	[self tagFiles:[dObject validPaths] add:nil remove:nil set:newTags];
	return nil;
}

+ (NSString *)stringByAddingTagPrefix:(NSString *)string {
	if (![string hasPrefix:gTagPrefix])
		string = [gTagPrefix stringByAppendingString:string];
	return string;
}
+ (NSString *)stringByRemovingTagPrefix:(NSString *)string {
	if ([string hasPrefix:gTagPrefix])
		string = [string substringFromIndex:[gTagPrefix length]];
	return string;
}
//[self performSelector:@selector(stringByAddingTagPrefix:) onObjectsInArray:add returnValues:yes];

- (NSString *)string:(NSString *)string byAddingTags:(NSArray *)add removingTags:(NSArray *)remove settingTags:(NSArray *)setTags {
	add = [[add mutableCopy] autorelease];
	
	NSMutableArray *array = [[[string componentsSeparatedByString:@" "] mutableCopy] autorelease];
	if (setTags) {
		foreach(component, array) {
			if ([component hasPrefix:gTagPrefix]) {
				[array removeObject:component];
			}
		}
	}
	[add removeObjectsInArray:array];
	[array addObjectsFromArray:add];
	[array removeObjectsInArray:remove];
	
	[array addObjectsFromArray:setTags];
	return [array componentsJoinedByString:@" "];
}


- (QSObject *)showWindowForTag:(QSObject *)dObject {
	NSString *string = [dObject stringValue];
	
	return nil;
}




- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSString *comment = [ws commentForFile:[dObject singleFilePath]];
	NSArray *tags = [self tagsFromString:comment];
	tags = [[self class] performSelector:@selector(stringByRemovingTagPrefix:) onObjectsInArray:tags returnValues:YES];
	
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
	return [QSObject objectWithType:QSFileTagType value:tag name:[[self class] stringByRemovingTagPrefix:tag]]; 	
}


+ (NSString *)queryStringForTag:(NSString *)tag {
	NSString *string = [[self class] stringByAddingTagPrefix:tag];
	return [NSString stringWithFormat:@"(kMDItemFinderComment = '%@'cdw) ", string];
}

- (QSObject *)showTaggedFilesInFinder:(QSObject *)dObject {
	NSString *string = [[self class] stringByAddingTagPrefix:[dObject stringValue]];
	
	NSArray *slices = [NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"Othr", @"FXSliceKind", @"kMDItemFinderComment", @"FXAttribute", string, @"Value", @"S:**", @"Operator", nil]];
	NSString *name = [NSString stringWithFormat:@" {%@} ", string];
	NSString *query = [NSString stringWithFormat:@"(kMDItemFinderComment = '%@'cdw) ", string];
	//	NSLog(@"SPURL: %@ - %@", scheme, query);
	
	
	[self runQuery:query withName:name slices:slices];
	
	
	
	return nil; 	
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
	[dict setObject:@"10.4"
			 forKey:@"version"];
	[dict setObject:trueQuery
			 forKey:@"RawQuery"];
	
	
	[dict setObject:[NSDictionary dictionaryWithObjectsAndKeys:
		//query, @"AnyAttributeContains",
		slices,
		@"FXCriteriaSlices",
		nil]
	forKey:@"SearchCriteria"]; 	
		
	NSMutableString *filename = [[name mutableCopy] autorelease];
	if (!filename) {
		filename = [[query mutableCopy] autorelease];
		[filename replaceOccurrencesOfString:@"/" withString:@"_" options:nil range:NSMakeRange(0, [filename length])];
		if ([filename length] >242)
			filename = [filename substringToIndex:242];
	}
	[filename appendString:@".savedSearch"];
	filename = [NSTemporaryDirectory() stringByAppendingPathComponent:filename];
	[dict writeToFile:filename atomically:NO];
	[[NSFileManager defaultManager] changeFileAttributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:
		NSFileExtensionHidden] atPath:filename];
	[[NSWorkspace sharedWorkspace] openTempFile:filename];
	
	usleep(500000);
	//[[NSFileManager defaultManager] removeFileAtPath:filename handler:nil];
}

@end
