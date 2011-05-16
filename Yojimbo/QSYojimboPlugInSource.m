//
//  QSYojimboPlugInSource.m
//  QSYojimboPlugIn
//
//  Created by Nicholas Jitkoff on 5/14/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSYojimboPlugInSource.h"
#import <QSCore/QSObject.h>
#import "QSYojimboPlugInDefines.h"


@implementation QSYojimboPlugInSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    /* the bad news is we have to look at every frakking parent folder
       (looking at individual items would miss deletions)
       the good news is we can bail out if we find just one that's updated */
    NSString *path = [@"~/Library/Caches/Metadata/com.barebones.yojimbo" stringByStandardizingPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager directoryContentsAtPath:path];
    for (NSString *topLevelDir in contents) {
        topLevelDir = [path stringByAppendingPathComponent:topLevelDir];
        for (NSString *secondLevelDir in [manager directoryContentsAtPath:topLevelDir]) {
            secondLevelDir = [topLevelDir stringByAppendingPathComponent:secondLevelDir];
            NSDate *modified = [[manager attributesOfItemAtPath:secondLevelDir error:NULL] fileModificationDate];
            if ([indexDate compare:modified] == NSOrderedAscending) {
                // something new - trigger a rescan
                return NO;
            }
        }
    }
    
    // none of the files are new or changed
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.barebones.yojimbo"];
}

- (BOOL)objectHasChildren:(QSObject *)object {
    // indicate that tags can be arrowed into
    if ([object containsType:kQSYojimboTagType])
    {
        return YES;
    }
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
    if ([object containsType:kQSYojimboTagType])
    {
        // right-arrowed into a tag
        // return a list of matching tags and items
        NSMutableArray *matchingTags = [NSMutableArray arrayWithCapacity:1];
        NSMutableArray *children = [NSMutableArray arrayWithCapacity:1];
        // track which tags we're combining
        NSMutableArray *navigationHistory = [NSMutableArray arrayWithArray:[object objectForMeta:@"navigationHistory"]];
        if (navigationHistory)
        {
            [navigationHistory addObject:[object name]];
        } else {
            navigationHistory = [NSArray arrayWithObject:[object name]];
        }
        // NSLog(@"current navigation history: %@", navigationHistory);
        /* on the assumption that it's easier to find tags by typing and
        items by looking, we add items to the top of the list, then tags */
        // add items to the list using objects already created by objectsForEntry
        for (NSString *uuid in [object objectForMeta:@"items"])
        {
            QSObject *yojimboItem = [QSObject objectWithIdentifier:uuid];
            BOOL matchesAllTags = true;
            for (NSString *navTag in navigationHistory)
            {
                if (![[yojimboItem objectForMeta:@"tags"] containsObject:navTag])
                {
                    matchesAllTags = false;
                }
            }
            if (matchesAllTags) {
                // add this item
                [children addObject:yojimboItem];
                // look for tags
                for (NSString *tag in [yojimboItem objectForMeta:@"tags"])
                {
                    // if we don't have it yet, and it wasn't already arrowed into
                    if (![matchingTags containsObject:tag] && ![navigationHistory containsObject:tag])
                    {
                        // we don't have this tag yet
                        [matchingTags addObject:tag];
                    }
                }
            } else if ([[object identifier] isEqualToString:@"yojimbotag:untagged"]
                    && [[yojimboItem objectForMeta:@"tags"] count] == 0
                    && ![yojimboItem containsType:kQSYojimboTagType]
               )
            // list items with no tags
            {
                [children addObject:yojimboItem];
            }
        }
        // add tags to the list
        for (NSString *tag in matchingTags)
        {
            // use the tag object that was created by objectsForEntry
            NSString *ident = [NSString stringWithFormat:@"yojimbotag:%@", tag];
            QSObject *tagObject = [QSObject objectWithIdentifier:ident];
            // navigation history is transient and shouldn't be set on the
            // actual tag, so we use a temporary stand-in with no identifier
            NSString *tag = [tagObject name];
            QSObject *transientTag = [QSObject objectWithName:tag];
            [transientTag setObject:tag forType:kQSYojimboTagType];
            [transientTag setObject:[tagObject objectForMeta:@"items"] forMeta:@"items"];
            [transientTag setObject:kQSYojimboTagType forMeta:@"itemKind"];
            [transientTag setDetails:@"Yojimbo Tag"];
            [transientTag setObject:navigationHistory forMeta:@"navigationHistory"];
            [children addObject:transientTag];
        }
        [object setChildren:children];
    } else {
        // right-arrowed into Yojimbo
        // return a list of tags
        NSArray *tags = [QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:kQSYojimboTagType]];
        [object setChildren:tags];
    }
    return TRUE;
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSString *path = [@"~/Library/Caches/Metadata/com.barebones.yojimbo" stringByStandardizingPath];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *contents = [manager directoryContentsAtPath:path];
    // pretty names for various types of items Yojimbo stores
    NSDictionary *typeTable = [NSDictionary dictionaryWithObjectsAndKeys:
        @"Yojimbo Note", @"com.barebones.yojimbo.yojimbonote",
        @"Yojimbo Bookmark", @"com.barebones.yojimbo.yojimbobookmark",
        @"Yojimbo Web Archive", @"com.barebones.yojimbo.yojimbowebarchive",
        @"Yojimbo PDF Archive", @"com.barebones.yojimbo.yojimbopdfarchive",
        @"Yojimbo Serial Number", @"com.barebones.yojimbo.yojimboserialnumber",
        @"Yojimbo Image", @"com.barebones.yojimbo.yojimboimage",
        nil
    ];
    
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject = nil;
    QSObject *tagObject = nil;
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithCapacity:1];
    NSMutableArray *untaggedItems = [NSMutableArray arrayWithCapacity:1];
    
    // NSLog(@"Yojimbo plug-in hitting the filesystem");
    for (NSString *topLevelDir in contents) {
        topLevelDir = [path stringByAppendingPathComponent:topLevelDir];
        for (NSString *secondLevelDir in [manager directoryContentsAtPath:topLevelDir]) {
            secondLevelDir = [topLevelDir stringByAppendingPathComponent:secondLevelDir];
            for (NSString *yojimboItem in [manager directoryContentsAtPath:secondLevelDir]) {
                if ([yojimboItem rangeOfString:@"yojimbo"].location == NSNotFound) continue;
                yojimboItem = [secondLevelDir stringByAppendingPathComponent:yojimboItem];
                NSDictionary *item = [NSDictionary dictionaryWithContentsOfFile:yojimboItem];
                newObject = nil;
                
                @try {
                    if ([[item valueForKey:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.yojimbobookmark"]) {
                        // Christ, BareBones! You can't settle on a capitalization scheme for dictionary keys?
                        NSString *URLString;
                        if ([item valueForKey:@"URLString"]) {
                            URLString = [item valueForKey:@"URLString"];
                        } else if ([item valueForKey:@"urlString"]) {
                            URLString = [item valueForKey:@"urlString"];
                        }
                        newObject = [QSObject URLObjectWithURL:URLString title:[item valueForKey:@"name"]];
                    } else {
                        newObject = [QSObject objectWithName:[item valueForKey:@"name"]];
                    }
                    
                    if ([[item valueForKey:@"encrypted"]boolValue]){
                        [newObject setDetails:[NSString stringWithFormat:@"%@ (Encrypted)", [typeTable valueForKey:[item valueForKey:@"itemKind"]]]];
                    } else {
                        [newObject setDetails:[typeTable valueForKey:[item valueForKey:@"itemKind"]]];
                    }
                    [newObject setIdentifier:[item valueForKey:@"uuid"]];
                    [newObject setPrimaryType:kQSYojimboPlugInType];
                    [newObject setObject:[item valueForKey:@"uuid"] forType:kQSYojimboPlugInType];
                    if ([[item valueForKey:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.yojimbonote"] && [item valueForKey:@"content"])
                    {
                        // this will enable actions like "Paste" and "Large Type" for notes
                        [newObject setObject:[item valueForKey:@"content"] forType:QSTextType];
                    }
                    // store the type of Yojimbo item
                    [newObject setObject:[item valueForKey:@"itemKind"] forMeta:@"itemKind"];
                    // store this item's tags
                    [newObject setObject:[item valueForKey:@"tags"] forMeta:@"tags"];
                    
                    if ([[item valueForKey:@"tags"] count] == 0)
                    {
                        [untaggedItems addObject:[item valueForKey:@"uuid"]];
                    } else {
                        // get a list of all tags and the associated items
                        for (NSString *tag in [item valueForKey:@"tags"])
                        {
                            if ([[tags allKeys] containsObject:tag])
                            {
                                // append to the list
                                [[tags objectForKey:tag] addObject:[item valueForKey:@"uuid"]];
                            } else {
                                // create a list of items for this tag
                                NSMutableArray *itemsForTag = [NSMutableArray arrayWithObject:[item valueForKey:@"uuid"]];
                                [tags setObject:itemsForTag forKey:tag];
                            }
                        }
                    }
                    
                    if (newObject)
                    {
                        [objects addObject:newObject];
                    }
                }
                @catch (id theException) {
                    NSLog(@"error with: %@ %@", item, theException);
                }
            }
        }
    }
    // add tags to the catalog
    for (NSString *tag in [tags allKeys])
    {
        NSString *ident = [NSString stringWithFormat:@"yojimbotag:%@", tag];
        tagObject = [QSObject objectWithName:tag];
        [tagObject setIdentifier:ident];
        [tagObject setObject:tag forType:kQSYojimboTagType];
        [tagObject setObject:[tags objectForKey:tag] forMeta:@"items"];
        // tags don't have an official itemKind, but I'm making one up for consistency
        [tagObject setObject:kQSYojimboTagType forMeta:@"itemKind"];
        [tagObject setDetails:@"Yojimbo Tag"];
        [objects addObject:tagObject];
    }
    
    // create and register an "untagged items" object
    // to allow access to items with no tags
    QSObject *untagged = [QSObject objectWithName:@"Untagged Items"];
    [untagged setObject:@"Untagged" forType:kQSYojimboTagType];
    [untagged setObject:kQSYojimboTagType forMeta:@"itemKind"];
    [untagged setObject:untaggedItems forMeta:@"items"];
    [untagged setDetails:@"Items With No Tags"];
    [untagged setIdentifier:@"yojimbotag:untagged"];
    [objects addObject:untagged];
    
    return objects;
}

// Object Handler Methods

- (void)setQuickIconForObject:(QSObject *)object{
    // set some useful icons depending on the type of object
    if ([[object objectForMeta:@"itemKind"] isEqualToString:kQSYojimboTagType])
    {
        [object setIcon:[QSResourceManager imageNamed:@"com.barebones.yojimbo"]];
    } else if ([[object objectForMeta:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.yojimbopdfarchive"]) {
        [object setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:@"pdf"]];
    } else if ([[object objectForMeta:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.yojimbobookmark"]) {
        [object setIcon:[QSResourceManager imageNamed:@"DefaultBookmarkIcon"]];
    } else {
        [object setIcon:[[NSWorkspace sharedWorkspace] iconForFileType:@"yojimbonote"]];
    }
}
@end
