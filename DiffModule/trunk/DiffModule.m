//
//  DiffModule.m
//  DiffModule
//
//  Created by Kevin Ballard on 8/4/04.
//  Copyright TildeSoft 2004. All rights reserved.
//

#import "DiffModule.h"

#import <QSCore/QSObject.h>
#import <QSCore/QSObject_FileHandling.h>
#import <QSCore/QSActionProvider.h>
#import <QSCore/QSTypes.h>

#define kDiffModuleAction @"DiffModuleAction"

@implementation DiffModule
- (id) init {
	if (self = [super init]) {
		NSBundle *plugin = [NSBundle bundleForClass:[self class]];
		diffIcon = [[NSImage alloc] initByReferencingFile:[plugin pathForResource:@"FileMerge" ofType:@"icns"]];
	}
	return self;
}

- (void) dealloc {
	[diffIcon release];
	[super dealloc];
}

- (NSArray *) types{
	return [NSArray arrayWithObject:QSFilePathType];
}

- (NSArray *) actions{
	QSAction *action=[QSAction actionWithIdentifier:kDiffModuleAction
											 bundle:[NSBundle bundleForClass:[self class]]];
	[action setIcon:diffIcon];
	[action setProvider:self];
	[action setArgumentCount:2];
	[action setAction:@selector(diffLeft:right:)];
	return [NSArray arrayWithObject:action];
}

- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *dPath = [dObject validSingleFilePath];
	if (dPath && [fm fileExistsAtPath:dPath]) {
		return [NSArray arrayWithObject:kDiffModuleAction];
	} else {
		return nil;
	}
}

- (QSObject *) diffLeft:(QSObject *)dObject right:(QSObject *)iObject {
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *dPath = [dObject validSingleFilePath], *iPath = [iObject validSingleFilePath];
	if (!dPath || !iPath) {
		NSBeep();
		return nil;
	}
	BOOL dDir, iDir;
	if (![fm fileExistsAtPath:dPath isDirectory:&dDir] || ![fm fileExistsAtPath:iPath isDirectory:&iDir]) {
		NSBeep();
		return nil;
	}
	if (dDir ^ iDir) {
		NSBeep();
		return nil;
	}
	NSTask *diff=[NSTask launchedTaskWithLaunchPath:@"/usr/bin/opendiff" arguments:
		[NSArray arrayWithObjects:dPath, iPath]];
	[diff waitUntilExit];
	return nil;
}
@end
