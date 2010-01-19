//
//  QSYojimboPlugInAction.m
//  QSYojimboPlugIn
//
//  Created by Nicholas Jitkoff on 5/14/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSYojimboPlugInAction.h"
#import "QSYojimboPlugInDefines.h"

@implementation QSYojimboPlugInAction

#define kQSYojimboPlugInAction @"QSYojimboPlugInAction"

- (NSAppleScript *)script{
    NSString *scriptPath=[[NSBundle bundleForClass:[self class]]pathForResource:@"Yojimbo" ofType:@"scpt"];
    if (!scriptPath)return nil;
    NSAppleScript *script=[[NSAppleScript alloc]initWithContentsOfURL:[NSURL fileURLWithPath:scriptPath] error:nil];
    return script;
}

- (QSObject *)addObject:(QSObject *)dObject withName:(QSObject *)itemName
{
    NSString *addRoutine = nil;
    id itemContent = [dObject stringValue];
    // figure out how to add this thing based on type
    if ([dObject containsType:QSURLType])
    {
        // add this as a "bookmark"
        addRoutine = @"add_url";
    } else if ([dObject containsType:QSFilePathType]) {
        // import a file
        addRoutine = @"add_file";
        // override default content
        itemContent = [dObject objectForType:QSFilePathType];
    } else {
        // add this as a "note"
        addRoutine = @"add_note";
    }
    NSAppleEventDescriptor *appleScriptResult = [[self script]
        executeSubroutine:addRoutine
        arguments:[NSArray arrayWithObjects:
            [itemName stringValue],
            itemContent,
            nil
        ]
        error:nil];
    
    NSString *uuid= [appleScriptResult stringValue];
    QSObject *newObject=[QSObject makeObjectWithIdentifier:uuid];
    [newObject setName:[itemName stringValue]];
    [newObject setDetails:@"New Yojimbo Item"];
    [newObject setIdentifier:uuid];
    [newObject setObject:uuid forType:kQSYojimboPlugInType];
    [newObject setPrimaryType:kQSYojimboPlugInType];
    return newObject;
}

- (QSObject *)addTagsToItem:(QSObject *)dObject withTags:(QSObject *)tags
{
    // get a list of tags passed in
    NSMutableArray *tagNames = [NSMutableArray arrayWithCapacity:1];
    if ([[tags stringValue] isEqualToString:@"combined objects"])
    {
        // multiple tags
        for (QSObject *tag in [tags objectForCache:kQSObjectComponents])
        {
            [tagNames addObject:[tag stringValue]];
        }
    } else {
        // single tag
        [tagNames addObject:[tags stringValue]];
    }
    // add the tags to the item via AppleScript
    // TODO this needs to allow multiple items
    // NSLog(@"attempting to tag %@ with %@", [dObject identifier], tagNames);
    [[self script]
        executeSubroutine:@"add_tags"
        arguments:[NSArray arrayWithObjects:
            [dObject identifier],
            tagNames,
            nil
        ]
        error:nil
    ];
}

- (QSObject *)appendToNote:(QSObject *)dObject content:(QSObject *)iObject{
    // TODO see how hard it would be to make this action reversible (it really needs to be)
    NSString *uuid=[dObject identifier];
    NSString *text=[iObject stringValue];
    NSAppleEventDescriptor *appleScriptResult = [[self script]
        executeSubroutine:@"append_to_note"
        arguments:[NSArray arrayWithObjects:uuid, text, nil]
        error:nil
    ];
    return nil;
}

- (QSObject *)addObjectArchive:(QSObject *)dObject{
    NSAppleEventDescriptor *appleScriptResult=[[self script] executeSubroutine:@"add_url_archive" arguments:[NSArray arrayWithObject:[dObject objectForType:QSURLType]]
                                                             error:nil];
    NSString *uuid= [appleScriptResult stringValue];
    QSObject *newObject=[QSObject makeObjectWithIdentifier:uuid];   
    [newObject setName:[dObject name]];
    [newObject setIdentifier:uuid];
    [newObject setObject:uuid forType:kQSYojimboPlugInType];
    [newObject setPrimaryType:kQSYojimboPlugInType];
    //NSLog(@"newob %@",newObject);
    return newObject;
}

- (QSObject *)showObject:(QSObject *)dObject{
    NSString *uuid=[dObject objectForType:kQSYojimboPlugInType];
    NSAppleEventDescriptor *appleScriptResult=[[self script] executeSubroutine:@"show_item" arguments:uuid error:nil];
    return nil;
}

- (NSArray *) validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    // the list of actions to return
    NSMutableArray *actions = [NSMutableArray arrayWithCapacity:1];
    // check based on item type
    if ([dObject containsType:kQSYojimboPlugInType])
    {
        [actions addObject:@"QSYojimboShowAction"];
        [actions addObject:@"QSYojimboTagAction"];
        // only allow appending to notes
        if ([[dObject objectForMeta:@"itemKind"] isEqualToString:@"com.barebones.yojimbo.yojimbonote"])
        {
            [actions addObject:@"QSYojimboAppendAction"];
        }
    } else {
        [actions addObject:@"QSYojimboAddAction"];
    }
    return actions;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
    // QSObject *textObject=[QSObject textProxyObjectWithDefaultValue:@""];
    // return [NSArray arrayWithObject:textObject];
    if ([action isEqualToString:@"QSYojimboAddAction"])
    {
        return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:[dObject name]]];
    }
    if ([action isEqualToString:@"QSYojimboAppendAction"])
    {
        NSString *clipBoardContents=[[NSPasteboard pasteboardWithName:NSGeneralPboard] stringForType:NSStringPboardType];
        return [NSArray arrayWithObject: [QSObject textProxyObjectWithDefaultValue:clipBoardContents]];
    }
    if ([action isEqualToString:@"QSYojimboTagAction"])
    {
        // FIXME this method currently causes all items to be loaded from disk on every call
        // return a list of tags
        NSString *path = [@"~/Library/Caches/Metadata/com.barebones.yojimbo" stringByStandardizingPath];
        NSFileManager *manager = [NSFileManager defaultManager];
        NSArray *contents = [manager directoryContentsAtPath:path];
        NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
        QSObject *tagObject = nil;
        NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithCapacity:1];
        
        // NSLog(@"Yojimbo plug-in hitting the filesystem");
        for (NSString *topLevelDir in contents) {
            topLevelDir = [path stringByAppendingPathComponent:topLevelDir];
            for (NSString *secondLevelDir in [manager directoryContentsAtPath:topLevelDir]) {
                secondLevelDir = [topLevelDir stringByAppendingPathComponent:secondLevelDir];
                for (NSString *yojimboItem in [manager directoryContentsAtPath:secondLevelDir]) {
                    if ([yojimboItem rangeOfString:@"yojimbo"].location == NSNotFound) continue;
                    yojimboItem = [secondLevelDir stringByAppendingPathComponent:yojimboItem];
                    NSDictionary *item = [NSDictionary dictionaryWithContentsOfFile:yojimboItem];

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
            // tags don't have an official itemKind, but I'm making one up for consitency
            [tagObject setObject:kQSYojimboTagType forMeta:@"itemKind"];
            [tagObject setDetails:@"Yojimbo Tag"];
            [objects addObject:tagObject];
        }
        return objects;
    }
}
@end
