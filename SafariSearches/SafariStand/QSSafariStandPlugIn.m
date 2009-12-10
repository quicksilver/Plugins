//
//  QSSafariStandPlugIn.m
//  QSSafariStandPlugIn
//
//  Created by Nicholas Jitkoff on 9/21/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSafariStandPlugIn.h"
#import <QSCore/QSKeys.h>

@implementation QSSafariStandQueryParser

- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"jp.hetima.SafariStand.plist"];
}
- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    NSArray *queries=[dict objectForKey:@"Hetima_QuickSearchDict"];
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:[dict count]];
    
    NSEnumerator *e=[queries objectEnumerator];
    NSString *entry;
    while(entry=[e nextObject]){
		if ([entry objectForKey:@"state"] && ![[entry objectForKey:@"state"]boolValue])
			continue;
		
        NSString *url=[entry objectForKey:@"url"];
        
        url=[url stringByReplacing:@"http://" with:@"qss-http://"];
        url=[url stringByReplacing:@"@key" with:QUERY_KEY];
        
		QSObject *object=[QSObject URLObjectWithURL:url title:[entry objectForKey:@"shortcut"]];
		[object setLabel:[entry objectForKey:@"title"]];
		int encoding=-1;
		switch ([[entry objectForKey:@"encode"]intValue]){
			case 4: encoding=kCFStringEncodingUTF8; break;
			case 3: encoding=kCFStringEncodingEUC_JP; break;
			case 8: encoding=kCFStringEncodingShiftJIS; break;
			case 21: encoding=kCFStringEncodingJIS_X0201_76; break;
			case 5: encoding=kCFStringEncodingISOLatin1; break;
			case 30: encoding=kCFStringEncodingMacRoman; break;
			default: break;
		}
		
		if (encoding>=0)[object setObject:[NSNumber numberWithInt:encoding] forMeta:kQSStringEncoding];
		[array addObject:object];
		
    }
    return array;
}
@end
