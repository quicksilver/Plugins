

#import "QSSherlockSource.h"
#import <QSCore/QSCore.h>

#define QSSherlockChannelIDType @"QSSherlockChannelIDType"

@implementation QSSherlockSource


- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:[@"~/Library/Preferences/com.apple.Sherlock.plist" stringByStandardizingPath] traverseLink:YES]fileModificationDate];
    return [modDate compare:indexDate]==NSOrderedAscending;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.apple.Sherlock"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return [@"[Sherlock Channel]:"stringByAppendingString:[object objectForType:QSSherlockChannelIDType]];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSDictionary *channels= (NSDictionary *)CFPreferencesCopyAppValue((CFStringRef)@"SherlockChannelCache",(CFStringRef) @"com.apple.Sherlock");
    [channels autorelease];
    NSDictionary *queryStrings=[NSDictionary dictionaryWithContentsOfFile:
        [[NSBundle mainBundle]pathForResource:@"SherlockQueries" ofType:@"plist"]];
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
    NSString *key;
    NSDictionary *thisChannel;
    NSEnumerator *networkEnumerator=[channels keyEnumerator];
    while(key=[networkEnumerator nextObject]){
        thisChannel=[channels objectForKey:key];
        newObject=[QSObject objectWithName:[thisChannel objectForKey:@"displayName"]];
        [newObject setObject:key forType:QSSherlockChannelIDType];
        
        
        NSString *queryName=[queryStrings objectForKey:key];
        if (!queryName)queryName=@"query";
        
        NSString *queryString=nil;
        if ([queryName length])
            queryString=[NSString stringWithFormat:@"sherlock://%@?%@=%@&new_window&toolbar=hidden",key,queryName,@"***"];
        if (queryString)
            [newObject setObject:queryString forType:QSURLType];
        if ([thisChannel objectForKey:@"description"])
            [newObject setObject:[thisChannel objectForKey:@"description"]
                         forMeta:kQSObjectDetails];
        [newObject setPrimaryType:QSSherlockChannelIDType];
        
        [objects addObject:newObject];
    }
    return objects;
    
}

- (BOOL)loadChildrenForObject:(QSObject *)object{
		[object setChildren:[self objectsForEntry:nil]];
		return YES;   	
}
// Object Handler Methods
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.Sherlock"]];
}
- (BOOL)loadIconForObject:(QSObject *)object{
    NSString *identifier=[object objectForType:QSSherlockChannelIDType];
    
    NSDictionary *iconData=[NSUnarchiver unarchiveObjectWithFile:
        [[NSString stringWithFormat:@"~/Library/Preferences/Sherlock/Icons/%@.archive",identifier]stringByStandardizingPath]];
    
    [object setIcon:[iconData objectForKey:@"image"]];
	//[[[iconData objectForKey:@"image"]TIFFRepresentation]writeToFile:
	//	[NSString stringWithFormat:@"/Volumes/Lore/Desktop/%@.tiff",identifier]
	//													  atomically:NO];

    return YES;
}
@end


#define kQSSherlockChannelShowAction @"QSSherlockChannelShowAction"


@implementation QSSherlockActionProvider

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return [NSArray arrayWithObject:kQSSherlockChannelShowAction];
}

- (QSObject *) selectChannel:(QSObject *)dObject{
    
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:
        [NSString stringWithFormat:@"sherlock://%@?new_window&toolbar=hidden",[dObject objectForType:QSSherlockChannelIDType]]
        ]];
    
    return nil;
}
@end


