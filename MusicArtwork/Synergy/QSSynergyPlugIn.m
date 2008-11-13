//
//  QSSynergyPlugIn.m
//  QSSynergyPlugIn
//
//  Created by Nicholas Jitkoff on 9/21/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSynergyPlugIn.h"

#define SYNPATH [@"~/Library/Application Support/Synergy/Album Covers/" stringByStandardizingPath]


#import <QSFoundation/NSString_BLTRExtensions.h>


@implementation QSSynergyPlugIn
//NSString *artist,NSString *album,NSString *name
-(NSImage *) imageForTrackInfo:(NSDictionary *)info{
	NSString *album=[info objectForKey:@"Album"];
	NSString *artist=[info objectForKey:@"Artist"];
	NSString *name=[info objectForKey:@"Name"];
	
	NSString *synergyFile;
	if([album length]){
		synergyFile=[NSString stringWithFormat:@"Artist-%@,Album-%@.tiff",artist,album];
	}else{
		NSString *song=name;
		synergyFile=[NSString stringWithFormat:@"Artist-%@,Song-%@.tiff",artist,song];
	}
	synergyFile=[synergyFile stringByReplacing:@" " with:@""];
	synergyFile=[synergyFile stringByReplacing:@"/" with:@""];
	synergyFile=[synergyFile stringByReplacing:@":" with:@""];
	NSString *synergyPath=[SYNPATH stringByAppendingPathComponent:synergyFile];
		// 	NSLog(@"Synergy art: %@",synergyPath);
	if ([[NSFileManager defaultManager]fileExistsAtPath:synergyPath]){
		return [[[NSImage alloc]initWithContentsOfFile:synergyPath]autorelease];
	}
	return nil;
}

@end
