//
//  QSDictionaryPlugIn.m
//  DictPlugin
//
//  Created by Nicholas Jitkoff on 11/24/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSDictionaryPlugIn.h"
//#import <QSFoundation/NSTask_BLTRExtensions.h>


#define THESAURUS_NAME @"Oxford American Writers Thesaurus"
#define DICTIONARY_NAME	@"New Oxford American Dictionary"

@implementation QSDictionaryPlugIn
- (QSObject *)lookupWordInDictionary:(QSObject *)dObject{
	[self lookupWord:[dObject stringValue] inDictionary:DICTIONARY_NAME];
	return nil;
}
- (QSObject *)lookupWordInThesaurus:(QSObject *)dObject{
	[self lookupWord:[dObject stringValue] inDictionary:THESAURUS_NAME];
	return nil;
}
- (void)lookupWord:(NSString *)word inDictionary:(NSString *)dictName{
	word=[word lowercaseString];
//	NSTask *task=[NSTask taskWithLaunchPath:
//								  arguments:[NSArray arrayWithObjects:word,dictName,nil]];
//	NSData *data=[task launchAndReturnOutput];
	NSString *string=nil;//[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

		id cont=[[NSClassFromString(@"QSSimpleWebWindowController") alloc]initWithWindow:nil];
		[[cont window]center];
		[[cont window]setLevel:NSFloatingWindowLevel];
		[[cont window]setTitle:[NSString stringWithFormat:@"%@",word]];
		[[cont window]makeKeyAndOrderFront:nil];	
		
	NSString *str=[NSString stringWithFormat:@"\"%@\" \"%@\" \"%@\"",[[NSBundle bundleForClass:[self class]]pathForResource:@"QSDictionaryLookup" ofType:@""],word,dictName];
	//NSLog(@"string %@",str);
	FILE *file = popen( [str UTF8String], "r" );
	NSMutableData *pipeData=[NSMutableData data];
	if( file )
	{
		char buffer[1024];
		size_t length;
		while (length = fread( buffer, 1, sizeof( buffer ), file ))[pipeData appendBytes:buffer length:length];
		string=[[[NSString alloc]initWithData:pipeData encoding:NSUTF8StringEncoding]autorelease];
		pclose( file );
	} 
	if (![string length])string=[NSString stringWithFormat:@"\"%@\" could not be found.",word];
	

	[cont loadHTMLString:string baseURL:nil];
}


@end
