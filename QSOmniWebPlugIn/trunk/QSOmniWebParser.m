

#import "QSOmniWebParser.h"
#import <QSCore/QSCore.h>
#import <QSFoundation/QSFoundation.h>
//#import <QSCore/NSString_BLTRExtensions.h>
//#import "Quicksilver_Keys.h"

#define QUERY_KEY @"***"

@implementation QSOmniWebObjectHandler
-(id)resolveProxyObject:(id)proxy
{
    id res = nil;
    if(!QSAppIsRunning(@"com.omnigroup.OmniWeb5")) return nil;
    NSAppleScript* script = [[[NSAppleScript alloc] initWithSource:@"tell application \"OmniWeb\" to if(count browsers) > 0 then address of first browser"] autorelease];
    NSString* url = [[script executeAndReturnError:nil] stringValue];
    if(url)
        res = [QSObject URLObjectWithURL:url title:nil];
    return res;
}
@end

@implementation QSOmniWebHistoryParser

- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"History.plist"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    NSArray *history=[dict objectForKey:@"entries"];
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
    NSEnumerator *childEnum=[history objectEnumerator];
    NSDictionary *child;
    while (child=[childEnum nextObject]){
        NSString *url=[child objectForKey:@"url"];
        NSString *title=[child objectForKey:@"title"];
        QSObject *object=[QSObject URLObjectWithURL:url title:title];
        if (object) [array addObject:object];
    }
    return  array;
}

@end



@implementation QSOmniWebShortcutsParser
- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"com.omnigroup.OmniWeb5.plist"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    dict=[dict objectForKey:@"OW5AddressShortcuts"];
    
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:[dict count]];
    
    NSEnumerator *keyEnumer=[dict keyEnumerator];
    NSString *key;
    while(key=[keyEnumer nextObject]){
        NSDictionary *options=[dict objectForKey:key];
        
        NSString *label=[options objectForKey:@"name"];
        
        NSString *url=[options objectForKey:@"format"];

        NSString *formData=[options objectForKey:@"formData"];
        NSString *method=[options objectForKey:@"method"];
        
        // only add form data if not already part of URL
        if (formData && [url rangeOfString:formData].location == NSNotFound)
            url=[NSString stringWithFormat:@"%@?%@",url,formData];
        
        if ([url rangeOfString:@"%@"].location!=NSNotFound)
            url=[url stringByReplacing:@"%@" with:QUERY_KEY];
        else if ([url hasSuffix:@"="])
            url=[url stringByAppendingString:QUERY_KEY];

        // only modify URLs with a query string
        if([url rangeOfString:QUERY_KEY].location!=NSNotFound)
        {
            // only the http-scheme is currently supported
            if([url hasPrefix:@"http://"]==NO)
                continue;
            
            if ([method isEqualToString:@"POST"])
                url=[url stringByReplacing:@"http://" with:@"qssp-http://"];
            if ([method isEqualToString:@"GET"])
                url=[url stringByReplacing:@"http://" with:@"qss-http://"];
        }

        // replace spaces with %20
        url=[url stringByReplacing:@" " with:@"%20"];

        // remove @ from key
        key=[key stringByReplacing:@"@" with:@""];

        // NSLog(@"url %@",url);
        QSObject *object=[QSObject URLObjectWithURL:url title:key];
        [object setObject:url forType:@"QSSearchURLType"];
        [object setPrimaryType:@"QSSearchURLType"];
        [object setIcon:[NSImage imageNamed:@"DefaultBookmarkIcon"]];
        if (label) [object setLabel:label];
        if (object) [array addObject:object];
    }
    return array;
}
@end
