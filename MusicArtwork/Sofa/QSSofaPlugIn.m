//
//  QSSofaPlugIn.m
//  QSSofaPlugIn
//
//  Created by Nicholas Jitkoff on 9/21/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSofaPlugIn.h"

#define SOFPATH [@"~/Library/Application Support/Sofa/Artworks/" stringByStandardizingPath]

@implementation QSSofaPlugIn

-(NSImage *) imageForTrackInfo:(NSDictionary *)info{
	NSString *album=[info objectForKey:@"Album"];
	NSString *artist=[info objectForKey:@"Artist"];
	BOOL compilation=[[info objectForKey:@"Compilation"]boolValue];
	//if (!album)album=@"Unknown album";
	NSString *fileName=@"*";
	if (compilation)artist=@"Compilation";
	
	NSString *sofaFile=[NSString stringWithFormat:@"%@/%@/%@",artist,album,fileName];
	sofaFile=[sofaFile stringByReplacing:@"." with:@""];
	sofaFile=[sofaFile stringByReplacing:@":" with:@" "];
	sofaFile=[sofaFile stringByReplacing:@"\"" with:@""];
	//	sofaFile=[sofaFile stringByReplacing:@"  " with:@" "];
	
	NSString *sofaPath=[[SOFPATH stringByAppendingPathComponent:sofaFile] stringByResolvingWildcardsInPath];			
	//	 	NSLog(@"Sofa art: %@",sofaPath);
	if ([[NSFileManager defaultManager]fileExistsAtPath:sofaPath]){
		return [[[NSImage alloc]initWithContentsOfFile:sofaPath]autorelease];
	}
	return nil;
}
@end