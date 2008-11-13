//
//  QSDokuWikiPlugIn.m
//  QSDokuWikiPlugIn
//
//  Created by Nicholas Jitkoff on 2/24/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSDokuWikiPlugIn.h"
#define QSDokuWikiPageType @"org.splitbrain.dokuwiki.page"
#define QSDokuWikiNamespaceType @"org.splitbrain.dokuwiki.namespace"

@implementation QSDokuWikiPlugIn

- (QSObject *)editPage:(QSObject *)page{
	NSString *path=[page objectForType:QSDokuWikiPageType];
	path=[path stringByReplacing:@"/" with:@":"];
	
	[[NSWorkspace sharedWorkspace]openURL:
		[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost/~alcor/doku.php?do=edit&id=%@",path]]];
	
	return nil;
}
- (QSObject *)showPage:(QSObject *)page{
	NSString *path=[page objectForType:QSDokuWikiPageType];
	path=[path stringByReplacing:@"/" with:@":"];
	
	[[NSWorkspace sharedWorkspace]openURL:
		[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost/~alcor/doku.php?do=show&id=%@",path]]];

	return nil;
}
- (QSObject *)showPageRevisions:(QSObject *)page{
	NSString *path=[page objectForType:QSDokuWikiPageType];
	path=[path stringByReplacing:@"/" with:@":"];
	
	[[NSWorkspace sharedWorkspace]openURL:
		[NSURL URLWithString:[NSString stringWithFormat:@"http://localhost/~alcor/doku.php?do=revisions&id=%@",path]]];
	
	return nil;
}
- (QSObject *)showIndexOfNamespace:(QSObject *)page{	
	return nil;
}
@end


@implementation QSDokuWikiURLParser
- (BOOL)validParserForPath:(NSString *)path{
	if (![[path lastPathComponent]isEqualToString:@"data"])return NO;
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isDirectory, exists;
    exists=[manager fileExistsAtPath:[path stringByStandardizingPath] isDirectory:&isDirectory];
	
    return isDirectory;
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSNumber *depth=[settings objectForKey:kItemFolderDepth];
    int depthValue=(depth?[depth intValue]:1);
	
	NSFileManager *manager=[NSFileManager defaultManager];
	
	NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
	
	NSDirectoryEnumerator *de=[manager enumeratorAtPath:path];
	NSString *subpath=nil;
	QSObject *obj=nil;
	while(subpath=[de nextObject]){
		if ([[subpath pathExtension]isEqualToString:@"txt"]){
			obj=[QSObject fileObjectWithPath:[path stringByAppendingPathComponent:subpath]];
			[obj setObject:[subpath stringByDeletingPathExtension] forType:QSDokuWikiPageType];
			[obj setPrimaryType:QSDokuWikiPageType];
			[array addObject:obj];
		}		
	}
    return array;
}   

@end

@implementation QSDokuWikiParser
- (BOOL)validParserForPath:(NSString *)path{
	if (![[path lastPathComponent]isEqualToString:@"data"])return NO;
    NSFileManager *manager=[NSFileManager defaultManager];
    BOOL isDirectory, exists;
    exists=[manager fileExistsAtPath:[path stringByStandardizingPath] isDirectory:&isDirectory];
	
    return isDirectory;
}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings{
    NSNumber *depth=[settings objectForKey:kItemFolderDepth];
    int depthValue=(depth?[depth intValue]:1);
	
	NSFileManager *manager=[NSFileManager defaultManager];
	
	NSMutableArray *array=[NSMutableArray arrayWithCapacity:1];
	
	NSDirectoryEnumerator *de=[manager enumeratorAtPath:path];
	NSString *subpath=nil;
	QSObject *obj=nil;
	while(subpath=[de nextObject]){
		if ([[subpath pathExtension]isEqualToString:@"txt"]){
			obj=[QSObject fileObjectWithPath:[path stringByAppendingPathComponent:subpath]];
			[obj setObject:[subpath stringByDeletingPathExtension] forType:QSDokuWikiPageType];
			[obj setPrimaryType:QSDokuWikiPageType];
			[array addObject:obj];
		}		
	}
    return array;
}   
@end
