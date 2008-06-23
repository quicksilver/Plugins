//
//  DesktopPictureAction.m
//  DesktopPictureAction
//
//  Created by Tim Kingman on 8/3/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "DesktopPictureActionProvider.h"
#import <QSFoundation/NDAlias.h>
#import <QSCore/QSLibrarian.h>
#import <QSCore/QSPaths.h>
#import <QSFoundation/NSScreen_BLTRExtensions.h>
#import <CoreFoundation/CoreFoundation.h>

@implementation DesktopPictureActionProvider

- (id) init {
	if (self = [super init]) {
		urlString = @"";
		urlConnection = nil;
		urlData = nil;
        
        BOOL isDir;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        // XXX: put this in a reusable place?
		// TMK 20060906 - added this block to make sure pCacheLocation actually exists before trying to create DPA subdir
        if (![fileManager fileExistsAtPath:pCacheLocation isDirectory:&isDir]) {
            if (![fileManager createDirectoryAtPath:pCacheLocation attributes:nil]) {
                // XXX: could be a problem...
                NSLog(@"failed to create directory at: %@", pCacheLocation);
            }
        } else {
            if (!isDir) {
                // XXX: could be a problem...
                NSLog(@"not a directory: %@", pCacheLocation);
            }
        }
        NSString *pluginCacheLocation = [pCacheLocation stringByAppendingPathComponent:@"Desktop Picture Action"];
        if (![fileManager fileExistsAtPath:pluginCacheLocation isDirectory:&isDir]) {
            if (![fileManager createDirectoryAtPath:pluginCacheLocation attributes:nil]) {
                // XXX: could be a problem...
                NSLog(@"failed to create directory at: %@", pluginCacheLocation);
            }
        } else {
            if (!isDir) {
                // XXX: could be a problem...
                NSLog(@"not a directory: %@", pluginCacheLocation);
            }
        }
	}
	return self;
}

- (void) dealloc {
	[urlString release];
	[urlConnection release];
	[urlData release];
	
	[super dealloc];
}

- (NSString *)urlString {
	return [[urlString retain] autorelease];
}

- (void) setUrlString:(NSString *)string {
	NSString *temp = [string copy];
	[urlString release];
	urlString = temp;
}

/*
// TODO: re-add under the New Way for B35, per Alcor.
// Version under B34 has common types hard-coded in plist
- (NSArray *) types {
	return [NSArray arrayWithObject:NSFilenamesPboardType];
}

- (NSArray *) fileTypes{
	NSMutableArray* fTypes = [NSMutableArray arrayWithArray:[NSImage imageUnfilteredFileTypes]];
	[fTypes insertObject:@"'fold'" atIndex:0];
	return fTypes;
	//return [NSImage imageUnfilteredFileTypes];
}
*/
/*
// Moved to plist for 1.4.0, this can be deleted eventually.
- (NSArray *) actions {
	QSAction *action = [QSAction actionWithIdentifier:@"DesktopPictureAction"
											   bundle:[NSBundle bundleForClass:
												   [DesktopPictureAction class]]];
//	NSLog([[[NSBundle bundleForClass:[DesktopPictureAction class]] resourcePath] stringByAppendingString:@"/setdesktop.png"]);
	NSImage *image = [[NSImage alloc] initByReferencingFile:[[[NSBundle bundleForClass:[DesktopPictureAction class]] resourcePath] stringByAppendingString:@"/SetDesktop.png"]];
	if([image isValid]) {
		[action setIcon:image];
	} //else {
//		NSLog(@"DesktopPictureAction: Couldn't load image:");
//		NSLog([[[NSBundle bundleForClass:[DesktopPictureAction class]] resourcePath] stringByAppendingString:@"/setdesktop.png"]);
//	}

	[image release];
	[action setProvider:self];
	[action setAction:@selector(setDesktop:onScreen:)];
	[action setArgumentCount:2];
	[action setIndirectOptional:TRUE];
	[action setDetails:@"Set Desktop Picture"];
	return [NSArray arrayWithObject:action];
}
*/

- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject {
	return [NSArray arrayWithObject:@"DesktopPictureAction"];
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	NSMutableArray *objects=[QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:@"QSDisplayIDType"]];
	return [NSArray arrayWithObjects:[NSNull null],objects,nil];
}

- (void) notifyDesktopChange:(NSDictionary*)dict {
	//NSLog(@"DesktopPictureAction: Posting notification to change desktop");
	// CF-style
    //CFNotificationCenterRef center = CFNotificationCenterGetDistributedCenter();
    //CFNotificationCenterPostNotification(center, CFSTR("com.apple.desktop"), CFSTR("BackgroundChanged"), (CFDictionaryRef)dict, TRUE);
	
	// NS-style
	// Doesn't seem to work reliably (at all?) with multiple monitors
	//NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
	//[nc postNotificationName:@"com.apple.desktop" object:@"BackgroundChanged" userInfo:dict];
	
	// NS-style, take 2
	NSDistributedNotificationCenter* nc = [NSDistributedNotificationCenter defaultCenter];
	[nc postNotificationName:@"com.apple.desktop" object:@"BackgroundChanged" userInfo:dict deliverImmediately:YES];
	
	
}

- (QSObject *) setDesktop:(QSObject *)dObject onScreen:(QSObject *)iObject {
	// TMK 20060906 - test for URL type first, pass to setDesktopViaURL if so
    NSString *aUrlString = [dObject objectForType:@"Apple URL pasteboard type"];
    if (aUrlString)
    {
		NSLog([NSString stringWithFormat:@"DesktopPictureAction: got apparent URL String %@",aUrlString]);
        [self setDesktopViaURL:dObject onScreen:iObject];
		return nil;
    } else {
		//NSLog(@"DesktopPictureViaURLAction: failed to extract url string from direct object, assume it's a file: %@", [dObject identifier]);
        //return nil;
    }


	NSString* filePath = [dObject identifier];
	CFStringRef appName = CFSTR("com.apple.desktop");
    CFStringRef backgroundKey = CFSTR("Background");
	int displayNumber;
	if(iObject) {
		//NSLog([NSString stringWithFormat:@"DesktopPictureAction: Using display ID %i or %@",[[iObject objectForType:@"QSDisplayIDType"]intValue],[iObject objectForType:@"QSDisplayIDType"]]);
		displayNumber = [[iObject objectForType:@"QSDisplayIDType"]intValue];
	} else {
		NSLog(@"DesktopPictureAction: Using default display");
		//NSLog([NSString stringWithFormat:@"DesktopPictureAction: main screen is %i",[[NSScreen mainScreen]screenNumber]]);
		displayNumber = [[NSScreen mainScreen] screenNumber];
	}
	NSString* displayName = [NSString stringWithFormat:@"%i", displayNumber];
	
	NSLog([NSString stringWithFormat:@"DesktopPictureAction: Using displayName '%@'",displayName]);
	NSMutableDictionary *backgroundsDict = [[[(NSDictionary *) CFPreferencesCopyAppValue(backgroundKey, appName) autorelease] mutableCopy] autorelease];
	if(backgroundsDict && [backgroundsDict objectForKey:displayName]) {
		BOOL isDir=FALSE;
		NSFileManager* fm = [NSFileManager defaultManager];
		if([fm fileExistsAtPath:filePath isDirectory:&isDir]) {
			NSMutableDictionary *thisDisplayDict = [[[backgroundsDict objectForKey:displayName] mutableCopy] autorelease];
			NSDictionary *defaultDisplayDict = [backgroundsDict objectForKey:@"default"];
			NSArray* useDefaultsFor;
			// XXX: Sometimes leaves Desktop Pref Pane settings slightly confused, there may be additional keys that need to be set/unset below
			if(isDir) {
				NSLog([NSString stringWithFormat:@"DesktopPictureAction: Is directory: %@",filePath]);

				[thisDisplayDict setValue:filePath forKey:@"ChooseFolderPath"];
				[thisDisplayDict setValue:filePath forKey:@"ChangePath"];
				[thisDisplayDict setValue:[filePath lastPathComponent] forKey:@"CollectionString"];
				[thisDisplayDict setValue:@"TimeInterval" forKey:@"Change"];
				//[thisDisplayDict setValue:[[NDAlias aliasWithPath:filePath]data] forKey:@"ImageFileAlias"];
				useDefaultsFor = [NSArray arrayWithObjects:@"Random",@"ChangeTime",@"TimerPopUpTag",@"Placement",@"PlacementKeyTag",@"BackgroundColor",nil]; // also add ImageFilePath/Alias here? (see XXX above)
			} else {
				NSLog([NSString stringWithFormat:@"DesktopPictureAction: Is file: %@",filePath]);

				[thisDisplayDict setValue:filePath forKey:@"ImageFilePath"];
				[thisDisplayDict setValue:[[NDAlias aliasWithPath:filePath]data] forKey:@"ImageFileAlias"];
				[thisDisplayDict setValue:@"Never" forKey:@"Change"];
				useDefaultsFor = [NSArray arrayWithObjects:@"Random",@"ChangeTime",@"TimerPopUpTag",@"ChooseFolderPath",@"ChangePath",@"CollectionString",@"Placement",@"PlacementKeyTag",@"BackgroundColor",nil];
			}
			int i;
			int len=[useDefaultsFor count];
			NSString* udf;
			for(i=0;i<len;i++) {
				udf = [useDefaultsFor objectAtIndex:i];
				if([defaultDisplayDict objectForKey:udf]) {
					[thisDisplayDict setValue:[defaultDisplayDict objectForKey:udf] forKey:udf];
				} else {
					[thisDisplayDict removeObjectForKey:udf];
				}
			}
			[backgroundsDict setObject:thisDisplayDict forKey:displayName];
			CFPreferencesSetAppValue(backgroundKey, (CFDictionaryRef)backgroundsDict, appName);
			(void)CFPreferencesAppSynchronize(appName);

			[self notifyDesktopChange:backgroundsDict];
		} else {
			NSLog([NSString stringWithFormat:@"DesktopPictureAction: Cannot find direct object %@",filePath]);
		}

	} else {
		NSLog([NSString stringWithFormat:@"DesktopPictureAction: Either couldn't get Backgrounds or dictionary for display %@",displayName]);
	}
	return nil;
}

- (QSObject *) setDesktopViaURL:(QSObject *)dObject onScreen:(QSObject *)iObject {
    // XXX: store away screen for use later and initiate download
    // XXX: be a bit more careful when doing this?
    NSString *aUrlString = [dObject objectForType:@"Apple URL pasteboard type"];
    if (aUrlString)
    {
		//NSLog([NSString stringWithFormat:@"DesktopPictureViaURLAction: got String %@",aUrlString]);
        [self setUrlString:aUrlString];
    } else {
		NSLog(@"DesktopPictureViaURLAction: failed to extract url string from direct object");
        return nil;
    }
    
	if(iObject) {
		//NSLog([NSString stringWithFormat:@"DesktopPictureAction: Using display ID %i or %@",[[iObject objectForType:@"QSDisplayIDType"]intValue],[iObject objectForType:@"QSDisplayIDType"]]);
		targetDisplayNumber = [[iObject objectForType:@"QSDisplayIDType"]intValue];
	} else {
		NSLog(@"DesktopPictureViaURLAction: Using default display");
		//NSLog([NSString stringWithFormat:@"DesktopPictureAction: main screen is %i",[[NSScreen mainScreen]screenNumber]]);
		targetDisplayNumber = [[NSScreen mainScreen]screenNumber];
	}
    
	NSURL *url = [NSURL URLWithString:urlString];
	if (!url) {
		[self stopQuery:self];
		NSLog(@"DesktopPictureViaURLAction: failed to initialize NSURL for %@", urlString);
		return nil;
	}
	
	[urlData release];
	urlData = [[NSMutableData alloc] init];
    
	NSURLRequest *request = [NSURLRequest requestWithURL:url
											 cachePolicy:NSURLRequestReloadIgnoringCacheData
										 timeoutInterval:60];
    if (!request) {
        [self stopQuery:self];
        NSLog(@"DesktopPictureViaURLAction: failed to initialize NSURLRequest for url: %@", urlString);
        return nil;
    }
    
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	if (!urlConnection) {
		[self stopQuery:self];
		NSLog(@"DesktopPictureViaURLAction: failed to initialize NSURLConnection for request: %@", request);
        return nil;
	}
    
    return nil;
}

- (IBAction) stopQuery:(id)sender {
	[urlConnection cancel];
	[urlConnection release];
	urlConnection = nil;	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // XXX: notify?
	NSLog([NSString stringWithFormat:@"DesktopPicture:connection Error: %@", [error localizedDescription]]);
	[self stopQuery:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[urlData appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self stopQuery:self];
    if ([urlString characterAtIndex: ([urlString length] - 1)] == [[NSString stringWithString: @"/"] characterAtIndex: 0]) {
        NSLog(@"DesktopPicture:connectionDidFinishLoading: URL ends in slash, punting: %@", urlString);
        return;
    }
    NSURL *url = [NSURL URLWithString: urlString];
    // XXX: put this in a reusable place?
    NSString *pluginCacheLocation = [pCacheLocation stringByAppendingPathComponent:@"Desktop Picture Action"];
    NSString *filepath = [pluginCacheLocation stringByAppendingPathComponent: [[url path] lastPathComponent]];
    if (![urlData writeToFile: filepath atomically: YES]) {
        NSLog(@"DesktopPicture:connectionDidFinishLoading: failed to write %@ to %@", urlString, filepath);
        return;
    }

    QSObject *dObject = [[[QSObject fileObjectWithPath: filepath] retain] autorelease];
    if (!dObject) {
        NSLog(@"DesktopPicture:connectionDidFinishLoading: failed to initialize QSObject for: %@", filepath);
        return;
    }
    QSObject *iObject = [[[QSObject objectWithName:@"display"] retain] autorelease];
    if (!iObject) {
        NSLog(@"DesktopPicture:connectionDidFinishLoading: failed to initialize QSObject for display");
        return;
    }
    [iObject setObject: [[[[NSNumber numberWithInt: targetDisplayNumber] stringValue] retain] autorelease] forType: @"QSDisplayIDType"];
    //[iObject setObject: [[NSNumber numberWithInt: targetDisplayNumber] stringValue] forType: @"QSDisplayIDType"];
    [iObject setPrimaryType: @"QSDisplayIDType"];

    [self setDesktop:dObject onScreen:iObject];
    
    return;
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection
				 willCacheResponse:(NSCachedURLResponse *)cachedResponse {
	return nil;
}

@end