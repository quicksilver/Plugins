//
//  QSClutterPlugIn.m
//  QSClutterPlugIn
//
//  Created by Nicholas Jitkoff on 9/21/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSClutterPlugIn.h"

#define CLUTPATH [@"~/Library/Images/com.sprote.clutter/CDs/" stringByStandardizingPath]


// Clutter -----------------
static NSString* trim( NSString *str )
{
	return [str stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
}
static NSString* clutterEncodeComponent( NSString* str )
{
	str = trim([str lowercaseString]);
	if( [str hasPrefix: @"the "] )
		str = trim([str substringFromIndex: 4]);
	if( [str length]==0 )
		return nil;
	else {
		NSMutableString *encoded = [str mutableCopy];
		[encoded replaceOccurrencesOfString: @"/" withString: @"\\"
									options: 0 range: NSMakeRange(0,[encoded length])];
		if( [encoded characterAtIndex: 0] == '.' )
			[encoded insertString: @"_" atIndex: 0];	// leading "."s are dangerous
		if( [encoded length] > 200 )
			[encoded deleteCharactersInRange: NSMakeRange(200,[encoded length]-200)];
		return encoded;
	}
}

@implementation QSClutterPlugIn
-(NSImage *) imageForTrackInfo:(NSDictionary *)info{
	NSString *album=[info objectForKey:@"Album"];
	NSString *artist=[info objectForKey:@"Artist"];
	
	NSString *cArtist=clutterEncodeComponent(artist);
	NSString *cAlbum=clutterEncodeComponent(album);
	NSString *clutterFile=[NSString stringWithFormat:@"%@/%@.jpg",cArtist,cAlbum];
	NSString *clutterPath=[CLUTPATH stringByAppendingPathComponent:clutterFile];	
		//NSLog(@"Clutter art: %@",clutterPath);
	if ([[NSFileManager defaultManager]fileExistsAtPath:clutterPath]){
		
		return[[[NSImage alloc]initWithContentsOfFile:clutterPath]autorelease];
	}
	return nil;
}

@end
