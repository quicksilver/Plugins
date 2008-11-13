//
//  QSFirefoxPlugIn.m
//  QSFirefoxPlugIn
//
//  Created by Nicholas Jitkoff on 4/6/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSFirefoxPlugIn.h"

@implementation QSFirefoxPlugIn

- (void) performJavaScript:(NSString *)jScript{
	//NSLog(@"JAVASCRIPT perform: %@",jScript);
	NSDictionary *errorDict=nil;
	NSAppleScript *script=[[[NSAppleScript alloc]initWithSource:[NSString stringWithFormat:@"tell application \"Firefox\" to Get URL \"%@\"",jScript]]autorelease];
	if (errorDict) NSLog(@"Load Script: %@",[errorDict objectForKey:@"NSAppleScriptErrorMessage"]);
	else [script executeAndReturnError:&errorDict];
	if (errorDict) NSLog(@"Run Script: %@",[errorDict objectForKey:@"NSAppleScriptErrorMessage"]);
}

@end
	

@implementation QSMorkMozillaHistoryParser

- (BOOL)validParserForPath:(NSString *)path{
    return [[path pathExtension]isEqualToString:@"dat"];
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
	
	if (![[NSFileManager defaultManager]fileExistsAtPath:path])return nil;
	
	NSString *morkPath=[[NSBundle bundleForClass:[self class]]pathForResource:@"mork" ofType:@"pl"];
	
	NSTask *task=[NSTask taskWithLaunchPath:morkPath arguments:[NSArray arrayWithObject:path]];
	NSData *data=[task launchAndReturnOutput];
	//		/Volumes/Lore/Forge/Quicksilver/PlugIns/Firefox/Mozilla/mork.pl
	//		/Volumes/Lore/Library/Application\ Support/Firefox/Profiles/*/history.dat | cut -c 14- -
	NSString *string=[[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]autorelease];
	//[string lines];
	
	
    NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
    
    NSEnumerator *childEnum=[[string lines] objectEnumerator];
    NSDictionary *child;
    while (child=[childEnum nextObject]){
		if ([child length]<15) continue;
        NSString *url=[child substringFromIndex:13];
		//NSLog(url);
        NSString *title=nil;
        QSObject *object=[QSObject URLObjectWithURL:url title:title];
        if (object) [array addObject:object];
    }
    return  array;
    
}

@end
