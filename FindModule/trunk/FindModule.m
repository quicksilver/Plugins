//
//  FindModule.m
//  FindModule
//
//  Created by Kevin Ballard on 8/5/04.
//  Copyright TildeSoft 2004. All rights reserved.
//

#import "FindModule.h"
#import "NSStringAdditions.h"

#define kFindModuleFindAction @"FindModuleFindAction"
#define kFindModuleLocateAction @"FindModuleLocateAction"
#define kFindModuleTaskID @"FindModule-Search"

static NSArray *validPaths(NSArray *paths);

@implementation FindModule
- (id) init {
	if ((self = [super init])) {
		findTask = nil;
		findStatus = nil;
		incrementalResults = nil;
		buffer = nil;
		findImage = [[QSResourceManager imageNamed:@"Find"] copy];
	}
	return self;
}

- (void) dealloc {
	[findTask release];
	[findStatus release];
	[incrementalResults release];
	[buffer release];
	[findImage release];
	[super dealloc];
}


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
	return [NSArray arrayWithObject:[QSObject textProxyObjectWithDefaultValue:@""]];
}

- (QSObject *) performFind:(QSObject *)dObject withString:(QSObject *)iObject {
	if (findTask != nil) {
		NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Search in progress", QSNotifierTitle,
			@"A Search is already in progress", QSNotifierText,
			findImage, QSNotifierIcon, nil];
		QSShowNotifierWithAttributes(notif);
		return nil;
	}
	
	// Create task
	findStatus = [[NSString alloc] initWithFormat:@"Find: %@",
		[iObject objectForType:QSTextType]];
	[[QSTaskController sharedInstance] updateTask:kFindModuleTaskID status:findStatus progress:0];
	
	findTask = [[NSTask alloc] init];
	[findTask setLaunchPath:@"/usr/bin/find"];
	
	NSMutableArray *args = [NSMutableArray arrayWithObject:[dObject validSingleFilePath]];
	NSString *input = [iObject objectForType:NSStringPboardType];
	switch ([[[NSUserDefaults standardUserDefaults] objectForKey:FindModuleComplexityPref] intValue]) {
		case FindModuleComplexityGlob:
			[args addObject:@"-iname"];
			[args addObject:input];
			break;
		case FindModuleComplexitySimple:
			// Same as default
		default:
			[args addObject:@"-iname"];
			[args addObject:[NSString stringWithFormat:@"*%@*",
				[input stringByEscapingCharactersFromSet:
					[NSCharacterSet characterSetWithCharactersInString:@"*?"]]]];
	}
	if (!args) {
		NSBeep();
		return nil;
	}
	
	[findTask setArguments:args];
	NSPipe *pipe = [NSPipe pipe];
	[findTask setStandardOutput:pipe];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findFinished:)
												 name:NSTaskDidTerminateNotification object:findTask];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findDataAvailable:)
												 name:NSFileHandleDataAvailableNotification
											   object:[pipe fileHandleForReading]];
	incrementalResults = [[NSMutableArray alloc] init];
	buffer = [[NSMutableData alloc] init];
	[findTask launch];
	[[pipe fileHandleForReading] waitForDataInBackgroundAndNotify];
	return nil;
}

- (QSObject *) performLocate:(QSObject *)dObject withString:(QSObject *)iObject {
	if (findTask != nil) {
		NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Search in progress", QSNotifierTitle,
			@"A Search is already in progress", QSNotifierText,
			findImage, QSNotifierIcon, nil];
		QSShowNotifierWithAttributes(notif);
		return nil;
	}
	
	// Create task
	findStatus = [[NSString alloc] initWithFormat:@"Locate: %@",
		[iObject objectForType:QSTextType]];
	[[QSTaskController sharedInstance] updateTask:kFindModuleTaskID status:findStatus progress:0];
	
	findTask = [[NSTask alloc] init];
	//[findTask setLaunchPath:@"/usr/bin/locate"];
	[findTask setLaunchPath:@"/bin/sh"];
	
	// Get valid filepath
	NSString *filepath = [dObject validSingleFilePath];
	if ([filepath hasSuffix:@"/"])
		filepath = [filepath substringToIndex:[filepath length] - 1];
	// Set get path to locate.sh
	NSString *locatepath = [[NSBundle bundleForClass:[self class]]
		pathForResource:@"locate" ofType:@"sh"];
	// Set args
	NSArray *args = [NSArray arrayWithObjects:locatepath, filepath,
		[iObject objectForType:NSStringPboardType], nil];
	[findTask setArguments:args];
	
	// Set up pipe
	NSPipe *pipe = [NSPipe pipe];
	[findTask setStandardOutput:pipe];
	
	// Set up notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findFinished:)
												 name:NSTaskDidTerminateNotification object:findTask];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateDataAvailable:)
												 name:NSFileHandleDataAvailableNotification
											   object:[pipe fileHandleForReading]];
	
	incrementalResults = [[NSMutableArray alloc] init];
	buffer = [[NSMutableData alloc] init];
	[findTask launch];
	[[pipe fileHandleForReading] waitForDataInBackgroundAndNotify];
	return nil;
}

- (void) findFinished:(NSNotification *)aNotification {
	NSFileHandle *handle = [[findTask standardOutput] fileHandleForReading];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSFileHandleDataAvailableNotification
												  object:handle];
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:NSTaskDidTerminateNotification
												  object:findTask];
	[buffer appendData:[handle availableData]];
	NSString *output = [[[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding] autorelease];
	[buffer release];
	buffer = nil;
	output = [output stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSMutableArray *filePaths = [[output componentsSeparatedByString:@"\n"] mutableCopy];
	[filePaths removeObject:@""];
	[[QSTaskController sharedInstance] removeTask:kFindModuleTaskID];
	NSArray *validFilePaths;
	if ([[findTask launchPath] isEqualToString:@"/usr/bin/find"]) {
		// Don't validate paths - they're correct already
		validFilePaths = filePaths;
	} else {
		validFilePaths = validPaths(filePaths);
	}
	NSArray *resultPaths = [incrementalResults arrayByAddingObjectsFromArray:validFilePaths];
	[filePaths release];
	[findTask release];
	findTask = nil;
	[findStatus release];
	findStatus = nil;
	if ([resultPaths count] > 0) {
		QSObject *result = [QSObject fileObjectWithArray:resultPaths];
		[[NSApp delegate] performSelector:@selector(receiveObject:) withObject:result];
	} else {
		NSDictionary *notif = [NSDictionary dictionaryWithObjectsAndKeys:
			@"Search complete", QSNotifierTitle,
			@"No files found", QSNotifierText,
			findImage, QSNotifierIcon, nil];
		QSShowNotifierWithAttributes(notif);
	}
}

- (void) findDataAvailable:(NSNotification *)aNotification {
	NSFileHandle *handle = [aNotification object];
	[buffer appendData:[handle availableData]];
	NSString *data = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
	NSMutableArray *lines = [[data componentsSeparatedByString:@"\n"] mutableCopy];
	[data release];
	[lines removeObject:@""];
	if ([lines count]) {
		[buffer setData:[[lines lastObject] dataUsingEncoding:NSUTF8StringEncoding]];
	} else {
		[buffer setLength:0];
	}
	[lines removeLastObject];
	[incrementalResults addObjectsFromArray:lines];
	[lines release];
	NSString *status = [findStatus stringByAppendingFormat:@" (%i)", [incrementalResults count]];
	[[QSTaskController sharedInstance] updateTask:kFindModuleTaskID status:status progress:0];
	[handle waitForDataInBackgroundAndNotify];
}

- (void) locateDataAvailable:(NSNotification *)aNotification {
	NSFileHandle *handle = [aNotification object];
	[buffer appendData:[handle availableData]];
	NSString *data = [[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding];
	NSMutableArray *lines = [[data componentsSeparatedByString:@"\n"] mutableCopy];
	[data release];
	[lines removeObject:@""];
	if ([lines count]) {
		[buffer setData:[[lines lastObject] dataUsingEncoding:NSUTF8StringEncoding]];
	} else {
		[buffer setLength:0];
	}
	[lines removeLastObject];
	[incrementalResults addObjectsFromArray:validPaths(lines)];
	[lines release];
	NSString *status = [findStatus stringByAppendingFormat:@" (%i)", [incrementalResults count]];
	[[QSTaskController sharedInstance] updateTask:kFindModuleTaskID status:status progress:0];
	[handle waitForDataInBackgroundAndNotify];
}
@end

static NSArray *validPaths(NSArray *paths) {
	NSMutableArray *validPaths = [NSMutableArray arrayWithCapacity:[paths count]];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSEnumerator *e = [paths objectEnumerator];
	NSString *item;
	while ((item = [e nextObject])) {
		if ([fileManager fileExistsAtPath:item]) {
			[validPaths addObject:item];
		}
	}
	return validPaths;
}
