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
- (void)lookupWord:(NSString *)word inDictionary:(NSString *)dictName{
	word=[word lowercaseString];
    CFRange range;
    range.location = 0;
    range.length = [word length];
    NSString *definition;
    definition = (NSString*)DCSCopyTextDefinition( NULL, (CFStringRef)word, range);
    
	if (![definition length])
        definition = [NSString stringWithFormat:@"\"%@\" could not be found.", word];

    id cont = [[NSClassFromString(@"QSSimpleWebWindowController") alloc] initWithWindow:nil];
    [[cont window] center];
    [[cont window] setLevel:NSFloatingWindowLevel];
    [[cont window] setTitle:[NSString stringWithFormat:@"%@", word]];
    [[cont window] makeKeyAndOrderFront:nil];	
		
#if 0
	NSString *str = [NSString stringWithFormat:@"\"%@\" \"%@\" \"%@\"",[[NSBundle bundleForClass:[self class]] pathForResource:@"QSDictionaryLookup" ofType:@""], word, dictName];
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
#endif

	[cont loadHTMLString:definition baseURL:nil];
}

- (QSObject *)lookupWordInDictionary:(QSObject *)dObject{
    [self lookupWord:[dObject stringValue] inDictionary:DICTIONARY_NAME];
    return nil;
}

- (QSObject *)lookupWordInThesaurus:(QSObject *)dObject{
    [self lookupWord:[dObject stringValue] inDictionary:THESAURUS_NAME];
    return nil;
}

@end
