//
//  QSSogudiPlugIn.m
//  QSSogudiPlugIn
//
//  Created by Nicholas Jitkoff on 9/21/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSogudiPlugIn.h"

#import <QSCore/QSKeys.h>

@implementation QSSogudiLinkParser
- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"SogudiShortcuts.plist"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:[dict count]];
    
    NSEnumerator *keyEnumer=[dict keyEnumerator];
    NSString *key;
    while(key=[keyEnumer nextObject]){
        NSString *url=[dict objectForKey:key];
        
        url=[url stringByReplacing:@"http://" with:@"qss-http://"];
        url=[url stringByReplacing:@"@@@" with:QUERY_KEY];
        [array addObject:[QSObject URLObjectWithURL:url title:key]];
    }
    return array;
}
@end

