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
    // add the tags to the item(s) via AppleScript
    // NSLog(@"attempting to tag %@ with %@", [dObject identifier], tagNames);
    for (NSString *yojimboItem in [dObject arrayForType:kQSYojimboPlugInType])
    {
        [[self script]
            executeSubroutine:@"add_tags"
            arguments:[NSArray arrayWithObjects:
                yojimboItem,
                tagNames,
                nil
            ]
            error:nil
        ];
    }
    return nil;
}

- (QSObject *)appendToNote:(QSObject *)dObject content:(QSObject *)iObject{
    NSString *uuid=[dObject identifier];
    NSString *text=[iObject stringValue];
    [[self script]
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
    [[self script] executeSubroutine:@"show_item" arguments:uuid error:nil];
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
        [actions addObject:@"QSYojimboNameAddAction"];
    }
    return actions;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
    if ([action isEqualToString:@"QSYojimboAddAction"] || [action isEqualToString:@"QSYojimboNameAddAction"])
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
        // return a list of tags
        return [QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:kQSYojimboTagType]];
    }
    // no matches - return empty string
    QSObject *textObject=[QSObject textProxyObjectWithDefaultValue:@""];
    return [NSArray arrayWithObject:textObject];
}
@end
