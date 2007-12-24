//
//  QSAdiumLogSource.m
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on Wed Oct 20 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <QSCore/QSLibrarian.h>
#import "QSAdiumLogSource.h"
#define kAdiumLogsPath @"~/Library/Application Support/Adium 2.0/Users/Default/Logs/"
#define QSAdiumLogType @"QSAdiumLogType"

@implementation QSAdiumLogSource

NSRect rectFromSize (NSSize size) {
	NSRect rect;
	rect.size = size;
	rect.origin.x = rect.origin.y = 0;
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
	[object setChildren:[self logsForContact:object]];
}

- (BOOL)drawIconForObject:(QSObject *)object inRect:(NSRect)rect flipped:(BOOL)flipped{
	return NO;
	if (NSWidth(rect) <= 32) return NO;
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"QSAdiumNoCustomDraw"]) return NO;
	NSString *path = [object singleFilePath];

	NSImage *imageBase = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"AdiumyBase" ofType:@"png"]] autorelease];
	NSImage *imageOverlay = [[[NSImage alloc] initWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"AdiumyOverlay" ofType:@"png"]] autorelease];
	
    [imageBase setSize:[[imageBase bestRepresentationForSize:rect.size] size]];
	[imageOverlay setSize:[[imageOverlay bestRepresentationForSize:rect.size] size]];
	//[image adjustSizeToDrawAtSize:rect.size];
	[imageBase setFlipped:flipped];
	[imageOverlay setFlipped:flipped];
//	[imageBase drawInRect:rect fromRect:rectFromSize([imageBase size])
//				operation:NSCompositeSourceOver fraction:1.0];
//	NSRect imageRect = rectFromSize([imageBase size]);
	[imageBase drawInRect:rect fromRect:rectFromSize([imageBase size])
				operation:NSCompositeSourceOver fraction:1.0];
	
	if ([object iconLoaded]) {
		NSImage *buddyIcon = [object icon];
		//NSLog(@"[buddyIcon size].width = %f", [buddyIcon size].width);
		if ([buddyIcon size].width >= 64) return NO;

		if (buddyIcon != imageBase){
			[buddyIcon setFlipped:flipped];
			
			NSRect iconRect = NSMakeRect((NSWidth(rect) - 32) / 2 + 2 + rect.origin.x,13 + rect.origin.y,32,32);
			NSImageRep *bestIconRep = [buddyIcon bestRepresentationForSize:iconRect.size];
			
			[buddyIcon setSize:[bestIconRep size]];
			
			[[NSColor colorWithDeviceWhite:1.0 alpha:0.8] set];
			
			[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
			[buddyIcon drawInRect:iconRect fromRect:rectFromSize([buddyIcon size])
						operation:NSCompositeSourceOver fraction:1.0];
		}
	}
	[imageOverlay drawInRect:rect fromRect:rectFromSize([imageBase size])
					operation:NSCompositeSourceOver fraction:1.0];
	return YES;
}

- (NSArray *)logsForContact:(QSObject *)contact {
	BOOL dir = NO;
	NSString *logpath = [kAdiumLogsPath stringByExpandingTildeInPath];
	NSDirectoryEnumerator *direnum = [[NSFileManager defaultManager]
			enumeratorAtPath:logpath];
	NSMutableArray *array = [NSMutableArray array];
	
	NSString *path, *service, *accountID;
	
	accountID = [contact objectForType:QSIMAccountType];
	NSArray *components = [accountID componentsSeparatedByString:@":"];
	
	service = [components objectAtIndex:0];
	accountID = [components objectAtIndex:1];
	//NSLog( @"service = \"%@\"  accountID = \"%@\"", service, accountID );
	
	while( path = [direnum nextObject] ) {
		int pathComponentCount = [[path pathComponents] count];
		
		if( pathComponentCount == 1 ) {
			/* one level down has folders of the form 'service.username' */
			if( ![path hasPrefix:service] ) {
				[[NSFileManager defaultManager] fileExistsAtPath:[[logpath stringByAppendingPathComponent:path] stringByExpandingTildeInPath] isDirectory:&dir];
				//NSLog( @"skipping because \"%@\" doesn't start with \"%@\"", path, service );
				if( dir )
					[direnum skipDescendents];
			}
		} else if( pathComponentCount == 2 ) {
			/* two levels down has folders named after the other in the conversation */
			if( ![[[path pathComponents] objectAtIndex:1] isEqualToString:accountID] ) {
				[[NSFileManager defaultManager] fileExistsAtPath:[[logpath stringByAppendingPathComponent:path] stringByExpandingTildeInPath] isDirectory:&dir];
				//NSLog( @"skipping because \"%@\" != \"%@\"", [[path pathComponents] objectAtIndex:1], accountID );
				if( dir )
					[direnum skipDescendents];
			}
		} else {
			//NSLog( @"adding %@", [[logpath stringByAppendingPathComponent:path] stringByExpandingTildeInPath] );
			[array addObject:
				[QSObject fileObjectWithPath:
					[[logpath stringByAppendingPathComponent:path] stringByExpandingTildeInPath]]];
		}
	}
	
	array = [QSLib scoredArrayForString:nil inSet:array];	
	if( ![array count] ) return nil;
	
	return array;
}
@end
