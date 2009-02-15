

#import "QSAccountsSource.h"
#import <QSCore/QSCore.h>
#import <DirectoryService/DirServicesConst.h>

// @"sharedDir"
//#define userAttributes [NSArray arrayWithObjects:kDS1AttrUniqueID, kDSNAttrRecordName, kDS1AttrDistinguishedName, kDS1AttrNFSHomeDirectory, kDS1AttrPicture, nil]

@implementation QSAccountsSource

- (NSImage *)iconForEntry:(NSDictionary *)dict {
	return [[NSBundle bundleForClass:[self class]] imageNamed:@"User"];
}

- (NSString *)identifierForObject:(QSObject*)object {
    NSNumber *uid = [[object objectForType:QSUserPboardType] objectForKey:[NSString stringWithCString:kDS1AttrUniqueID]];
    return [NSString stringWithFormat:@"[uid]: %@", uid];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
    return NO;
	NSDate *modDate = [[[NSFileManager defaultManager] fileAttributesAtPath:@"/var/db/dslocal/nodes/Default" traverseLink:YES] fileModificationDate];
	return [modDate compare:indexDate]==NSOrderedAscending;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
    //  nireport local@localhost /users uid name realname home sharedDir
    /* Our arguments for reading the list of users from dscl, as a plist file */
    NSArray *args = [NSArray arrayWithObjects:@"-q", @"-plist", @".", @"-readall", @"/Users", nil];
	NSPipe *output = [NSPipe pipe];
	if (!output)
		[NSException raise:NSInternalInconsistencyException format:@"Failed to create pipe"];
    
    NSTask *getUsersTask = [[[NSTask alloc] init] autorelease];
    [getUsersTask setStandardOutput:output];
    [getUsersTask setLaunchPath:@"/usr/bin/dscl"];
    [getUsersTask setArguments:args];
    [getUsersTask launch];
    
    NSMutableData *returnData = [NSMutableData data];
    while ([getUsersTask isRunning]) {
        [returnData appendData:[[output fileHandleForReading] readDataToEndOfFile]];
        sleep(1);
    }
    
    if ([getUsersTask terminationStatus] != 0)
        [NSException raise:NSInternalInconsistencyException format:@"Failed getting user list, error %d", [getUsersTask terminationStatus]];
    
    NSString *errorString = nil;
    NSArray *users = [NSPropertyListSerialization propertyListFromData:returnData
                                                      mutabilityOption:NSPropertyListImmutable
                                                                format:NULL
                                                      errorDescription:&errorString];
    
    if (users == nil)
        [NSException raise:NSInternalInconsistencyException format:@"Failed converting dscl output, %@", errorString];
    
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[users count]];
    
    int i;
    QSObject *newObject;
    
    for (i = 0; i < [users count]; i++) {
        NSMutableDictionary *userDictionary = [[[users objectAtIndex:i] mutableCopy] autorelease];
        
        /* Collect interesting values */
        NSString *name = [[userDictionary objectForKey:[NSString stringWithCString:kDSNAttrRecordName]] objectAtIndex:0];
        NSString *realname = [[userDictionary objectForKey:[NSString stringWithCString:kDS1AttrDistinguishedName]] objectAtIndex:0];
        NSNumber *uid = [[userDictionary objectForKey:[NSString stringWithCString:kDS1AttrUniqueID]] objectAtIndex:0];
        NSString *picture = [[userDictionary objectForKey:[NSString stringWithCString:kDS1AttrPicture]] objectAtIndex:0];
        NSData *jpegPhoto = [[userDictionary objectForKey:[NSString stringWithCString:kDSNAttrJPEGPhoto]] objectAtIndex:0];
        
        if (!name)
            continue;
        if ([uid intValue] < 500)
            continue;
        
        /* Workaround for dscl returning string instead of data */
        if (jpegPhoto && ![jpegPhoto isKindOfClass:[NSData class]]) {
            NSString *jpegPhotoStr = (NSString*)jpegPhoto;
            jpegPhoto = [[NSMutableData alloc] init];
            int j = 0;
            
            NSAssert([jpegPhotoStr length] % 2 == 0, @"String is not correct data");
            
            for (j = 0; j < [jpegPhotoStr length] / 2; j += 2) {
                NSString *chars = [jpegPhotoStr substringWithRange:NSMakeRange(j, 2)];
                char hex = strtol([chars UTF8String], NULL, 16);
                [(NSMutableData*)jpegPhoto appendBytes:&hex length:sizeof(hex)];
            }
        }
        
        /* Now coalesce all used values into single values, for easier access */
        [userDictionary setObject:name forKey:[NSString stringWithCString:kDSNAttrRecordName]];
        if (realname)
            [userDictionary setObject:realname forKey:[NSString stringWithCString:kDS1AttrDistinguishedName]];
        if (uid)
            [userDictionary setObject:uid forKey:[NSString stringWithCString:kDS1AttrUniqueID]];
        if (picture)
            [userDictionary setObject:picture forKey:[NSString stringWithCString:kDS1AttrPicture]];
        if (jpegPhoto)
            [userDictionary setObject:jpegPhoto forKey:[NSString stringWithCString:kDSNAttrJPEGPhoto]];
        
        newObject = [QSObject objectWithName:name];
        if(realname)
            [newObject setLabel:realname];
        [newObject setObject:userDictionary
                     forType:QSUserPboardType];
        [newObject setPrimaryType:QSUserPboardType];
        [objects addObject:newObject];
    }
    
    return objects;
}

// Object Handler Methods
- (BOOL)loadIconForObject:(QSObject *)object {
    NSString *imagePath = [[object objectForType:QSUserPboardType] objectForKey:[NSString stringWithCString:kDS1AttrPicture]];
    NSData *jpegData = [[object objectForType:QSUserPboardType] objectForKey:[NSString stringWithCString:kDSNAttrJPEGPhoto]];
    
    NSImage *image = nil;
    if (imagePath) image = [[[NSImage alloc] initWithContentsOfFile:imagePath] autorelease];
    if (!image && jpegData) image = [[[NSImage alloc] initWithData:jpegData] autorelease];
    if (!image) image = [[NSBundle bundleForClass:[self class]] imageNamed:@"User"];
    [image createIconRepresentations];
    [object setIcon:image];
    return YES;
}

- (QSObject *)switchToUser:(QSObject *)dObject {
    NSString *uid = [[dObject objectForType:QSUserPboardType] objectForKey:[NSString stringWithCString:kDS1AttrUniqueID]];
    NSTask *getUsersTask = [[[NSTask alloc] init] autorelease];
    [getUsersTask setStandardOutput:[NSPipe pipe]];
    [getUsersTask setLaunchPath:@"/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"];
    [getUsersTask setArguments:[NSArray arrayWithObjects:@"-switchToUserID", uid, nil]];
    [getUsersTask launch];    
    return nil;
}

@end
