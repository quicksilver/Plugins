//
//  QSCLIXPlugIn.m
//  QSCLIXPlugIn
//
//  Created by Nicholas Jitkoff on 5/16/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSCLIXPlugIn.h"
#define QSShellCommandType @"qs.shellcommand"

@implementation QSCLIXPlugIn

- (BOOL)validParserForPath:(NSString *)path{
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isDirectory, exists;
    exists=[manager fileExistsAtPath:[path stringByStandardizingPath] isDirectory:&isDirectory];
	return exists && ![[path pathExtension]caseInsensitiveCompare:@"clix"];
}


- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
//- (NSArray *)objectsFromData:(NSData *)data encoding:(NSStringEncoding)encoding settings:(NSDictionary *)settings source:(NSURL *)source{
	NSString *string=[NSString stringWithContentsOfFile:path];
	NSArray *commands=[string componentsSeparatedByString:@"\n"];
	//NSLog(@"command %@",string);	
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
	
	QSObject *newObject;
	foreach(command,commands){
		NSArray *components=[command componentsSeparatedByString:@","];
		if ([components count]<4)continue;
		NSString *title=[components objectAtIndex:0];
		NSString *category=[components objectAtIndex:1];
		NSString *description=[components objectAtIndex:2];
		NSString *commandtext=[components objectAtIndex:3];
		
		newObject=[QSObject objectWithType:QSShellCommandType value:commandtext name:commandtext];
		[newObject setLabel:title];
		[newObject setDetails:description];
		
		if (newObject)
			[objects addObject:newObject];
	}
	
	
	
	return objects;
	
}


@end
