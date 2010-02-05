

#import "QSiPhotoSource.h"
#import <QSCore/QSCore.h>

#import <QSCore/QSMacros.h>

#pragma mark Object Source
@implementation QSiPhotoObjectSource

+ (void)registerInstance{
    QSiPhotoObjectSource *source=[[[QSiPhotoObjectSource alloc]init]autorelease];
    [QSReg registerSource:source];
    [QSReg registerHandler:source forType:QSiPhotoAlbumPboardType];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    NSString *libraryPath=[(NSString *)CFPreferencesCopyValue((CFStringRef) @"RootDirectory", (CFStringRef) @"com.apple.iPhoto", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
	libraryPath=[libraryPath stringByAppendingPathComponent:@"AlbumData.xml"];
	
	if (![[NSFileManager defaultManager]fileExistsAtPath:libraryPath]) return YES;
    NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:libraryPath traverseLink:YES]fileModificationDate];
	
	return [modDate compare:indexDate]==NSOrderedAscending;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"iPhotoIcon"];
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	
    QSObject *newObject;
    
    //Albums
    NSArray *albums=[[self iPhotoLibrary] objectForKey:@"List of Albums"];
    for (NSDictionary *thisAlbum in albums){
        newObject=[QSObject objectWithName:[thisAlbum objectForKey:@"AlbumName"]];
        [newObject setObject:thisAlbum forType:QSiPhotoAlbumPboardType];
        [newObject setPrimaryType:QSiPhotoAlbumPboardType];
        [objects addObject:newObject];
    }
    return objects;
}



#pragma mark Object Handler

- (BOOL)loadIconForObject:(QSObject *)object{
    if ([[object primaryType]isEqualToString:QSiPhotoAlbumPboardType]){
		NSString *type=nil;
        NSDictionary *albumDict=[object primaryObject];
        if ([[albumDict objectForKey:@"Master"]boolValue])
            [object setIcon:[QSResourceManager imageNamed:@"iPhotoLibraryIcon"]];
        else if ([(type=[albumDict objectForKey:@"Album Type"])isEqualToString:@"Smart"])
			[object setIcon:[QSResourceManager imageNamed:@"iPhotoSmartAlbumIcon"]];
		else if ([type isEqualToString:@"Special Month"])
			[object setIcon:[QSResourceManager imageNamed:@"iPhotoSpecialMonthIcon"]];
		else if ([type isEqualToString:@"Special Roll"])
			[object setIcon:[QSResourceManager imageNamed:@"iPhotoSpecialRollIcon"]];
		else if ([type isEqualToString:@"Folder"])
			[object setIcon:[QSResourceManager imageNamed:@"GenericFolderIcon"]];
		else
			[object setIcon:[QSResourceManager imageNamed:@"iPhotoAlbumIcon"]];
		return YES;
    }else if ([[object primaryType]isEqualToString:QSiPhotoPhotoType]){
		NSDictionary *imageDict=[object primaryObject];
		NSString *imagePath=[imageDict objectForKey:@"ThumbPath"];
        if (imagePath){
			[object setIcon:[[[NSImage alloc]initWithContentsOfFile:imagePath]autorelease]];
			return YES;
		}
	}
    return NO;
}

- (NSString *)detailsOfObject:(QSObject *)object{
	if ([[object primaryType]isEqualToString:QSiPhotoAlbumPboardType]){
        NSDictionary *albumDict=[object primaryObject];
		int count=[[albumDict objectForKey:@"PhotoCount"]intValue];
        return [NSString stringWithFormat:@"%d photo%@",count, ESS(count)];
    }else if ([[object primaryType]isEqualToString:QSiPhotoPhotoType]){
		NSDictionary *imageDict=[object primaryObject];
		NSDate *date=[NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[[imageDict objectForKey:@"DateAsTimerInterval"]floatValue]];
		return [date description];
	}
    return NO;
}


- (BOOL)objectHasChildren:(id <QSObject>)object{
    if ([[object primaryType]isEqualToString:QSiPhotoAlbumPboardType]){
        NSDictionary *albumDict=[object primaryObject];
        return [[albumDict objectForKey:@"Album Items"]count];
    }
    return NO;
}
- (BOOL)objectHasValidChildren:(id <QSObject>)object{
    return YES;
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
    NSArray *children=[self childrenForObject:object];
    
    if (children){
        [object setChildren:children];
        return YES;   
    }
    return NO;
}

- (NSArray *)childrenForObject:(QSObject *)object{
    if ([[object primaryType]isEqualToString:QSiPhotoAlbumPboardType]){
        NSDictionary *albumDict=[object primaryObject];
        NSArray *photos=[[[self iPhotoLibrary] objectForKey:@"Master Image List"]objectsForKeys:[albumDict objectForKey:@"KeyList"] notFoundMarker:[NSNull null]];
		NSMutableArray *objects=[NSMutableArray arrayWithCapacity:[photos count]];
        QSObject *newObject;
        NSDictionary *photoInfo;
		NSString *path;
        for (photoInfo in photos){
			newObject=[QSObject objectWithName:[photoInfo objectForKey:@"Caption"]];
            [newObject setObject:photoInfo forType:QSiPhotoPhotoType];
            if (path=[photoInfo objectForKey:@"ImagePath"])
				[newObject setObject:[NSArray arrayWithObject:path] forType:NSFilenamesPboardType];
            [newObject setPrimaryType:QSiPhotoPhotoType];
            [objects addObject:newObject];
        }
        return objects;
    }
    return NO;
}

- (NSDictionary *)iPhotoLibrary { 
    if (!iPhotoLibrary){
        NSString *libraryPath=[(NSString *)CFPreferencesCopyValue((CFStringRef) @"RootDirectory", (CFStringRef) @"com.apple.iPhoto", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
        libraryPath=[[libraryPath stringByAppendingPathComponent:@"AlbumData.xml"] stringByExpandingTildeInPath];
        [self setiPhotoLibrary:[NSDictionary dictionaryWithContentsOfFile:libraryPath]]; 
    }
    return iPhotoLibrary; 
}

- (void)setiPhotoLibrary:(NSDictionary *)newiPhotoLibrary {
    [iPhotoLibrary release];
    iPhotoLibrary = [newiPhotoLibrary retain];
}
@end


#pragma mark -
#pragma mark Action Provider

#define kQSiPhotoAlbumShowAction @"QSiPhotoAlbumShowAction"
#define kQSiPhotoAlbumSlideShowAction @"QSiPhotoAlbumSlideShowAction"

@implementation QSiPhotoActionProvider
- (id)init{
    if (self=[super init]){
        iPhotoScript=nil;
    }
    return self;
}


- (QSObject *) slideshow:(QSObject *)dObject{
    //  NSLog(@"woo");
    NSString *album=[[dObject objectForType:QSiPhotoAlbumPboardType]objectForKey:@"AlbumName"];
    
    NSDictionary *errorDict=nil;
    [[self iPhotoScript] executeSubroutine:@"start_slideshow" arguments:album error:&errorDict];
    if (errorDict) {
        NSLog(@"Error: %@",errorDict);     
    }
    return nil;
}

- (QSObject *) show:(QSObject *)dObject{
    NSString *album=[[dObject objectForType:QSiPhotoAlbumPboardType]objectForKey:@"AlbumName"];
    NSDictionary *errorDict=nil;
    [[self iPhotoScript] executeSubroutine:@"show_album" arguments:album error:&errorDict];
    if (errorDict) {
        NSLog(@"Error: %@",errorDict);     
    }
    return nil;
}

- (NSAppleScript *)iPhotoScript {
    if (!iPhotoScript)
        iPhotoScript=[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle bundleForClass:[self class]]pathForResource:@"iPhoto" ofType:@"scpt"]] error:nil];
    return iPhotoScript;
}

-(id)resolveProxyObject:(id)proxy{ 
	NSLog([proxy identifier]);
//	NSLog(@"proxyx, %@",proxy);
	
	
	if (!QSAppIsRunning(@"com.apple.iPhoto"))
		return nil;
	NSLog([proxy identifier]);

	NSDictionary *errorDict=nil;
	
	if ([[proxy identifier] isEqualToString:@"com.apple.iPhoto"] || !proxy){
		id result= [[self iPhotoScript] executeSubroutine:@"current_selection" arguments:nil error:&errorDict];
		if (errorDict) {
			NSLog(@"Error: %@",errorDict);     
		}
//		NSLog(@"result %@",[QSObject fileObjectsWithURLArray:[result objectValue]]);
		
		return [QSObject fileObjectWithArray:[[result objectValue]valueForKey:@"path"]];
	}else if ([[proxy identifier] isEqualToString:@"QSiPhotoSelectedAlbumProxy"]){
		id result= [[self iPhotoScript] executeSubroutine:@"current_album" arguments:nil error:&errorDict];
		if (errorDict) {
			NSLog(@"Error: %@",errorDict);     
		}
	//	NSLog(@"result %@",[result stringValue]);
	}
	return nil;
}

@end