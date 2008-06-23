//
//  QSFileTagsPlugInSource.m
//  QSFileTagsPlugIn
//
//  Created by Nicholas Jitkoff on 5/3/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSFileTagsPlugInSource.h"
#import <QSCore/QSObject.h>
#import <QSCore/QSLibrarian.h>

#import "QSFileTagsPlugInAction.h"
//#import <QSFoundation/QSMDPredicate.h>


@implementation QSFileTagsPlugInSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
    return NO;
}

- (NSImage *)iconForEntry:(NSDictionary *)dict {
    return  [QSResourceManager imageNamed:@"Tag"];
}

- (NSString *)identifierForObject:(id <QSObject>)object {
    return nil;
}
- (void)resultsChanged:(NSNotification *)notif {
	[self invalidateSelf];
}
- (void)resultsComplete:(NSNotification *)notif {
    //	NSLog(@"notif %@ %@", notif, [self tagsFromQuery:tagQuery]);
	[self invalidateSelf];
	
    
}
- (NSArray *)tagsFromQuery:(NSMetadataQuery *)aQuery {	
	NSMutableSet *set = [NSMutableSet set];
	NSString *prefix = [[NSUserDefaults standardUserDefaults] objectForKey:@"QSTagPrefix"];
	NSEnumerator *commentEnum = [[[aQuery results] valueForKey:(NSString *)kMDItemFinderComment] objectEnumerator];
	NSString *comment;
	while(comment = [commentEnum nextObject]) {
		foreach(word, [comment componentsSeparatedByString:@" "]) {
			if ([word hasPrefix:prefix])
				[set addObject:[word substringFromIndex:[prefix length]]];
		}
	}
	return [set allObjects];
    //	NSLog(@"tags %@", set);
}
- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
    
    if (!tagQuery) {
		tagQuery = [[NSMetadataQuery alloc] init]; 	
		[tagQuery setDelegate:self];
//		NSString *string = [NSString stringWithFormat:@"kMDItemFinderComment = \"%@\"w", [[NSUserDefaults standardUserDefaults] objectForKey:@"QSTagPrefix"]];
        
//        NSPredicate *predicate = [QSMDQueryPredicate predicateWithFormat:string];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"kMDItemFinderComment = \"%@\"", [[NSUserDefaults standardUserDefaults] objectForKey:@"QSTagPrefix"]]];
        //NSLog(@"predicate %@", predicate);
        [tagQuery setPredicate:predicate];
        [tagQuery setDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resultsComplete:) name:NSMetadataQueryDidFinishGatheringNotification object:nil];
        //	
        //		[[NSNotificationCenter defaultCenter] addObserver:self
        //												selector:@selector(resultsChanged:) name:NSMetadataQueryDidStartGatheringNotification object:nil];
        //		
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resultsChanged:) name:NSMetadataQueryDidUpdateNotification object:nil];
        //		[[NSNotificationCenter defaultCenter] addObserver:self
        //												selector:@selector(resultsChanged:) name:NSMetadataQueryGatheringProgressNotification object:nil];
        //				
        [tagQuery performSelectorOnMainThread:@selector(startQuery) withObject:nil waitUntilDone:YES];
        
    }
    //NSLog(@"query %@ %@", tagQuery, [tagQuery results]);
    if ([tagQuery resultCount]) {
        
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
        QSObject *newObject;
        foreach(tag, [self tagsFromQuery:tagQuery]) {
            newObject = [QSObject objectWithType:QSFileTagType value:tag name:tag];
            [objects addObject:newObject];
        }
        
        return objects;
    }
    return nil;
}


// Object Handler Methods


- (void)setQuickIconForObject:(QSObject *)object {
    [object setIcon:[QSResourceManager imageNamed:@"Tag"]]; // An icon that is either already in memory or easy to load
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
    NSString *path = [object singleFilePath];
    [object setChildren:[self targetArrayForTag:[object stringValue]]];
    return YES;
}

- (NSMutableArray *)targetArrayForTag:(NSString *)tag {
    
    NSString *predicateString = [QSFileTagsPlugInAction queryStringForTag:tag];
    
    id wrap = [NSClassFromString(@"QSMDFindWrapper") findWrapperWithQuery:predicateString path:nil keepalive:NO];
    NSMutableArray *results = [wrap results];
    [wrap startQuery];
    return results;
}
/*
 - (BOOL)loadIconForObject:(QSObject *)object {
 return NO;
 id data = [object objectForType:QSFileTagsPlugInType];
 [object setIcon:nil];
 return YES;
 }
 */
@end
