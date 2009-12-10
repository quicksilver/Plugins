//
//  QSAcidSearchPlugIn.m
//  QSAcidSearchPlugIn
//
//  Created by Nicholas Jitkoff on 9/26/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSAcidSearchPlugIn.h"

#import <QSCore/QSKeys.h>

@implementation QSAcidSearchQueryParser

- (BOOL)validParserForPath:(NSString *)path{
    return [[path lastPathComponent]isEqualToString:@"com.apple.Safari.plist"];
}


- (NSArray *)objectsForArray:(NSArray *)queries{
	NSMutableArray *array=[NSMutableArray arrayWithCapacity:[queries count]];
    
    NSEnumerator *e=[queries objectEnumerator];
    NSString *entry;
    while(entry=[e nextObject]){
		if ([entry isKindOfClass:[NSArray class]]){
			[array addObjectsFromArray:[self objectsForArray:entry]];
			continue;
			
		}
		if (![entry isKindOfClass:[NSDictionary class]])continue;
		
		
		NSString *name=[entry objectForKey:@"name"];
		if ([name isEqualToString:@"-"])continue;
		if ([name isEqualToString:@"JavaScript Console"])continue;
		NSString *url=[entry objectForKey:@"prefix"];
		if (![url length])continue;
		url=[url stringByReplacing:@"http://" with:@"qss-http://"];
		url=[url stringByAppendingString:QUERY_KEY];
		
		
	if ([url rangeOfString:@"{{"].location!=NSNotFound)continue;
		
		NSString *suffix=[entry objectForKey:@"suffix"];
		
		if ([suffix hasPrefix:@"[["] && [suffix hasSuffix:@"]]"])
			url=[url stringByAppendingString:[suffix substringWithRange:NSMakeRange(2,[suffix length]-4)]];
		
		QSObject *object=[QSObject URLObjectWithURL:url title:name];
		[array addObject:object];
		//NSLog(@"entry %@",object);
		
		
	}
	return array;
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSDictionary *dict=[NSDictionary dictionaryWithContentsOfFile: [path stringByStandardizingPath]];
    NSArray *queries=[dict objectForKey:@"PZChannelList"];	
	return [self objectsForArray:queries];
}

@end

