/*
 *  untitled.c
 *  Quicksilver
 *
 *  Created by Nicholas Jitkoff on 7/3/04.
 *  Copyright 2004 __MyCompanyName__. All rights reserved.
 *
 */

#import "QSAlbumArtSources.h"

#import <QSCore/NSString_BLTRExtensions.h>

NSImage * imageForSofaTrack(NSString *artist,NSString *album){
	NSString *sofaFile=[NSString stringWithFormat:@"%@/%@/*",artist,album];
	 NSString *sofaPath=[[SOFPATH stringByAppendingPathComponent:sofaFile] stringByResolvingWildcardsInPath];			
	 if ([[NSFileManager defaultManager]fileExistsAtPath:sofaPath]){
		 return [[[NSImage alloc]initWithContentsOfFile:sofaPath]autorelease];
	 }
	 return nil;
}



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


NSImage *imageForClutterTrack(NSString *artist,NSString *album){
	NSString *cArtist=clutterEncodeComponent(artist);
	NSString *cAlbum=clutterEncodeComponent(album);
	NSString *clutterFile=[NSString stringWithFormat:@"%@/%@.jpg",cArtist,cAlbum];
	NSString *clutterPath=[CLUTPATH stringByAppendingPathComponent:clutterFile];	
	if ([[NSFileManager defaultManager]fileExistsAtPath:clutterPath]){
		
		return[[[NSImage alloc]initWithContentsOfFile:clutterPath]autorelease];
	}
	return nil;
}

NSImage *imageForCommonTrack(NSString *artist,NSString *album,NSNumber *compilation){
	NSString *comBase=  [(NSString *) CFPreferencesCopyValue((CFStringRef) @"LibraryLocation", (CFStringRef) @"public.music.artwork", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
	if (!comBase)comBase=[@"~/Library/Images/Music/" stringByStandardizingPath];
	if ([compilation boolValue])artist=@"Compilation";
	NSString *comFile=[NSString stringWithFormat:@"%@/%@/Cover.jpg",artist,album];
	NSString *comPath=[comBase stringByAppendingPathComponent:comFile];	
	//NSLog(comPath);
	if ([[NSFileManager defaultManager]fileExistsAtPath:comPath]){
		
		return[[[NSImage alloc]initWithContentsOfFile:comPath]autorelease];
	}
	return nil;
}

NSImage *imageForCommonGenre(NSString *genre){
	//NSFileManager *manager=[NSFileManager defaultManager];
	
	NSString *comBase=  [(NSString *) CFPreferencesCopyValue((CFStringRef) @"LibraryLocation", (CFStringRef) @"public.music.artwork", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
	if (!comBase)comBase=[@"~/Library/Images/Music/" stringByStandardizingPath];

	NSString *comFile=[NSString stringWithFormat:@"~Genres/%@/Genre.gif",genre];
	NSString *comPath=[comBase stringByAppendingPathComponent:comFile];	
	//NSLog(comPath);
	if ([[NSFileManager defaultManager]fileExistsAtPath:comPath]){
		
		return[[[NSImage alloc]initWithContentsOfFile:comPath]autorelease];
	}
	return nil;
}


