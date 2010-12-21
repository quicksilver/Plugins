//
//  CyberduckSource.m
//  Cyberduck
//
//  Created by Rob McBroom on 12/20/10.
//

#import "CyberduckSource.h"
#import <QSCore/QSObject.h>


@implementation CyberduckSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    NSString *path = [@"~/Library/Application Support/Cyberduck/Bookmarks" stringByStandardizingPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager directoryContentsAtPath:path];
    for (NSString *bookmark in contents) {
        bookmark = [path stringByAppendingPathComponent:bookmark];
        NSDate *modified = [[manager attributesOfItemAtPath:bookmark error:NULL] fileModificationDate];
        if ([indexDate compare:modified] == NSOrderedAscending) {
            // something new - trigger a rescan
            return NO;
        }
    }
    
    // none of the files are new or changed
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    //http://
    return [QSResourceManager imageNamed:@"ch.sudo.cyberduck"];
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSString *path = [@"~/Library/Application Support/Cyberduck/Bookmarks" stringByStandardizingPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager directoryContentsAtPath:path];
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    for (NSString *bookmark in contents) {
        QSObject *newObject = nil;
        bookmark = [path stringByAppendingPathComponent:bookmark];
        NSDictionary *bookmarkDetails = [NSDictionary dictionaryWithContentsOfFile:bookmark];
        if ( [bookmarkDetails valueForKey:@"Nickname"] )
        {
            newObject = [QSObject objectWithName:[bookmarkDetails valueForKey:@"Nickname"]];
        } else {
            newObject = [QSObject objectWithName:[bookmarkDetails valueForKey:@"Hostname"]];
        }
        [newObject setDetails:[NSString stringWithFormat:@"%@ (%@)",
            [bookmarkDetails valueForKey:@"Hostname"],
            [bookmarkDetails valueForKey:@"Protocol"]
        ]];
        [newObject setIdentifier:[bookmarkDetails valueForKey:@"UUID"]];
        [newObject setPrimaryType:kCyberduckType];
        // allow the bookmark to be open as if it were launched from Finder
        [newObject setObject:bookmark forType:QSFilePathType];
        // A type that allows actions to target Cyberduck bookmarks
        // (there aren't any that I know of, but maybe some day)
        [newObject setObject:[bookmarkDetails valueForKey:@"UUID"] forType:kCyberduckType];
        [newObject setPrimaryType:QSFilePathType];
        if (newObject)
        {
            [objects addObject:newObject];
        }
    }
    
    return objects;
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
    [object setChildren:[self objectsForEntry:nil]];
    return TRUE;
}

- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:@"duck"]];
}
@end
