

#import <QSCore/QSCore.h>

#import "QSCaminoParser.h"

//#import <QSCore/NSString_BLTRExtensions.h>
@implementation QSCaminoBookmarksParser
- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"bookmarks.plist"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    return [self caminoBookmarksForDict:dict];
}

- (NSArray *)caminoBookmarksForDict:(NSDictionary *)dict{

    if ([dict objectForKey:@"Children"]){
        NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
        NSEnumerator *childEnum=[[dict objectForKey:@"Children"]objectEnumerator];
        NSDictionary *child;
        while ((child=[childEnum nextObject]))
            [array addObjectsFromArray: [self caminoBookmarksForDict:child]];
        return  array;
    }else{
        //QSURLObject *entry=[[[QSURLObject alloc]init]autorelease];
        NSString *url=[dict objectForKey:@"URL"];
        NSString *title=[dict objectForKey:@"Title"];
        QSObject *leaf=[QSObject URLObjectWithURL:url title:title];
        if (leaf) return [NSArray arrayWithObject:leaf];
    }
    return nil;
}


@end


@implementation QSOldCaminoBookmarksParser
- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"bookmarks.xml"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSString *string=[NSString stringWithContentsOfFile: [path stringByStandardizingPath]];
    return [self linksFromCamino:string];
}
- (NSArray *)linksFromCamino:(NSString *)html{
    
    NSScanner *scanner=[NSScanner scannerWithString:html];
    
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
    
    NSString *url=nil;
    NSString *title=nil;
    QSObject *urlObject=nil;
    while (![scanner isAtEnd]){
        [scanner scanUpToString:@"<bookmark name=\"" intoString:nil];
        [scanner scanString:@"<bookmark name=\"" intoString:nil];
        
        [scanner scanUpToString:@"\"" intoString:&title];
        [scanner scanString:@"\"" intoString:nil];
        
        [scanner scanUpToString:@"href=\"" intoString:nil];
        [scanner scanString:@"href=\"" intoString:nil];
        
        [scanner scanUpToString:@"\"" intoString:&url];
        [scanner scanUpToString:@"/>" intoString:nil];
        // NSLog(url);
        if (url)
            url=[url stringByReplacing:@"&amp;" with:@"&"];
        
        if (url && title)
            urlObject=[QSObject URLObjectWithURL:url title:title];
        
        if (urlObject)
            [array addObject: urlObject];
        url=nil;
        
    }
    return array;
    
    return nil;
}

@end

/*
@implementation QSMozillaHistoryParser
- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"history.dat"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSString *string=[NSString stringWithContentsOfFile: [path stringByStandardizingPath]];
	
    return [self historyFromMork:string];
}
- (NSArray *)historyFromMozilla:(NSString *)lines{
    
    NSScanner *scanner=[NSScanner scannerWithString:html];
    
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
    
    NSString *url=nil;
    NSString *title=nil;
    QSObject *urlObject=nil;
    while (![scanner isAtEnd]){
        [scanner scanUpToString:@"<bookmark name=\"" intoString:nil];
        [scanner scanString:@"<bookmark name=\"" intoString:nil];
        
        [scanner scanUpToString:@"\"" intoString:&title];
        [scanner scanString:@"\"" intoString:nil];
        
        [scanner scanUpToString:@"href=\"" intoString:nil];
        [scanner scanString:@"href=\"" intoString:nil];
        
        [scanner scanUpToString:@"\"" intoString:&url];
        [scanner scanUpToString:@"/>" intoString:nil];
        // NSLog(url);
        if (url)
            url=[url stringByReplacing:@"&amp;" with:@"&"];
        
        if (url && title)
            urlObject=[QSObject URLObjectWithURL:url title:title];
        
        if (urlObject)
            [array addObject: urlObject];
        url=nil;
        
    }
    return array;
    
    return nil;
}

@end

*/
