
#import "QSCommonMusicArtworkPlugIn.h"

#define ARTDOMAIN CFSTR("public.music.artwork")

@implementation QSCommonMusicArtworkPlugIn
- (id)init{
	if (self=[super init]){
		[self loadDefaults];		
	} return self;
}

- (void)loadDefaults{
	[libraryLocation release];
	[preferredImage release];
	[artworkSubdirectory release];
	
	libraryLocation=[[[(NSString *) CFPreferencesCopyValue((CFStringRef) @"LibraryLocation", ARTDOMAIN, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease]stringByStandardizingPath]retain];
	if (!libraryLocation)libraryLocation=[[@"~/Library/Images/Music/" stringByStandardizingPath]retain];
	
	preferredImage=(NSString *) CFPreferencesCopyValue((CFStringRef) @"PreferredImage", ARTDOMAIN, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
	if (!preferredImage)preferredImage=[@"Album" retain];
	
	artworkSubdirectory=(NSString *) CFPreferencesCopyValue((CFStringRef) @"ArtworkSubdirectory", ARTDOMAIN, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
}


-(NSImage *) imageForTrackInfo:(NSDictionary *)info{
	NSString *path=[self imagePathForTrackInfo:(NSDictionary *)info];
	if (path) return [[[NSImage alloc]initWithContentsOfFile:path]autorelease];
	return nil;
}


-(NSImage *) imagePathForTrackInfo:(NSDictionary *)info{
	NSString *artworkPath=[self artworkPathForInfo:info];
	
	NSFileManager *manager=[NSFileManager defaultManager];

	if ([manager fileExistsAtPath:artworkPath]){
		// Return preferred image
		NSEnumerator *e = [[NSArray arrayWithObjects:@"tiff", @"tif", @"png", @"jpeg", @"jpg", @"gif", @"bmp", nil] objectEnumerator];
		NSString *ext;
		while (ext = [e nextObject]) {
			NSString *fullPath = [[artworkPath stringByAppendingPathComponent:preferredImage] stringByAppendingPathExtension:ext];
			if ([manager fileExistsAtPath:fullPath])return fullPath;
		}
		// Return any image found
		NSArray *paths=[[manager directoryContentsAtPath:artworkPath]pathsMatchingExtensions:[NSImage imageUnfilteredFileTypes]];
		if ([paths count])
			return [paths objectAtIndex:0];
	}
	return nil;
}


-(void)storeImageData:(NSData *)data ofType:(NSString *)extension forTrackInfo:(NSDictionary *)info{
	NSString *artworkPath=[self artworkPathForInfo:info];
	[[NSFileManager defaultManager] createDirectoriesForPath:artworkPath];
	artworkPath=[artworkPath stringByAppendingPathComponent:preferredImage];
	artworkPath=[artworkPath stringByAppendingPathExtension:extension];
	
	NSLog(@"artworkStor: %@",artworkPath);
	[data writeToFile:artworkPath atomically:YES];
}

-(NSString *)artworkPathForInfo:(NSDictionary *)info{
	NSString *album=[info objectForKey:@"Album"];
	NSString *artist=[info objectForKey:@"Artist"];
	if (!artist)artist=@"Unknown Artist";
	if (!album)album=@"Unknown Album";
	
	NSString *name=[info objectForKey:@"Name"];
	NSNumber *compilation=[info objectForKey:@"Compilations"];
	
	
	if ([compilation boolValue])artist=@"Compilations";
	
	artist=[artist stringByReplacing:@":" with:@"_"];
	artist=[artist stringByReplacing:@"/" with:@"_"];
	album=[album stringByReplacing:@":" with:@"_"];
	album=[album stringByReplacing:@"/" with:@"_"];
	
	
	NSString *path=libraryLocation;
	path=[path stringByAppendingPathComponent:artist];
	path=[path stringByAppendingPathComponent:album];

	if (artworkSubdirectory)
		path=[path stringByAppendingPathComponent:artworkSubdirectory];
	
	//NSLog(@"artworkPath: %@",path);
	return path;
		
}



-(NSImage *)imageForGenre:(NSString *)genre{
	//NSFileManager *manager=[NSFileManager defaultManager];
	
	NSString *comFile=[NSString stringWithFormat:@"~Genres/%@/Genre.gif",genre];
	NSString *comPath=[libraryLocation stringByAppendingPathComponent:comFile];	
	//NSLog(comPath);
	if ([[NSFileManager defaultManager]fileExistsAtPath:comPath]){
		
		return[[[NSImage alloc]initWithContentsOfFile:comPath]autorelease];
	}
	return nil;
}




@end




