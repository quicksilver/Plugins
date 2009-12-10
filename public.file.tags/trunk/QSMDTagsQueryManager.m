//
//  QSMDTagsQueryManager.m
//  QSFileTagsPlugIn
//
//  Created by Etienne on 11/09/08.
//  Copyright 2008 Etienne Samson. All rights reserved.
//

#import "QSMDTagsQueryManager.h"

static QSMDTagsQueryManager *defaultQueryManager = nil;

@implementation QSObject (QSFileTagsHandling)
+ (QSObject *)objectForTag:(NSString *)tag {
	return [self objectWithType:QSFileTagType value:tag name:[[QSMDTagsQueryManager sharedInstance] stringByRemovingTagPrefix:tag]]; 	
}

@end

@implementation QSMDTagsQueryManager

+ (id)sharedInstance {
    if (!defaultQueryManager)
        defaultQueryManager = [[QSMDTagsQueryManager alloc] init];
    return defaultQueryManager;
}

- (id)init {
    self = [super init];
    if (self) {
        tagQueries = [[NSMutableDictionary alloc] initWithCapacity:1];
        tagDelegates = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return self;
}

- (void)dealloc {
    for(NSString * tag in [tagQueries allKeys]) {
        [self stopScanningForTagPrefix:tag delegate:self];
    }
    [tagQueries release], tagQueries = nil;
    [tagDelegates release], tagDelegates = nil;
    [super dealloc];
}

#pragma mark Utilities
- (NSString*)tagPrefixForQuery:(NSMetadataQuery*)query {
    return [[tagQueries allKeysForObject:query] lastObject];
}

- (NSArray*)tagPrefixes {
    return [tagQueries allKeys];
}

- (NSString*)tagPrefixForTag:(NSString*)tag {
    for(NSString * tagPrefix in [self tagPrefixes]) {
        if([tag hasPrefix:tagPrefix])
            return tagPrefix;
    }
    return nil;
}

#pragma mark Delegate management
- (void)addDelegate:(id)delegate forTagPrefix:(NSString*)tagPrefix {
    if (!delegate)
        return;
    
    NSMutableSet *delegates = [tagDelegates objectForKey:tagPrefix];
    if (!delegates)
        [tagDelegates setObject:(delegates = [NSMutableSet setWithCapacity:1]) forKey:tagPrefix];
    [delegates addObject:delegate];
}

- (BOOL)removeDelegate:(id)delegate forTagPrefix:(NSString*)tagPrefix {
    NSMutableSet *delegates = [tagDelegates objectForKey:tagPrefix];
    if (delegates) {
        [delegates removeObject:delegate];
        if ([delegates count] == 0)
            return YES;
    }
    return NO;
}

#pragma mark NSMetadataQueries Management
- (NSPredicate*)predicateForTag:(NSString*)tag {
    NSString *taggedString = [self stringByAddingTagPrefix:tag];
	NSString *string = [NSString stringWithFormat:@"kMDItemFinderComment like[cd] \"*%@*\"", taggedString];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:string];
    if (!predicate) {
        NSLog(@"%@ %@ failed creating predicate with string %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), string);
        return nil;
    }
    return predicate;
}

- (NSArray *)tagsFromQuery:(NSMetadataQuery *)aQuery {	
	NSMutableSet *set = [NSMutableSet set];
	NSString *prefix = [self tagPrefixForQuery:aQuery];
	NSEnumerator *commentEnum = [[[aQuery results] valueForKey:(NSString *)kMDItemFinderComment] objectEnumerator];
	NSString *comment;
	while(comment = [commentEnum nextObject]) {
		for(NSString * word in [comment componentsSeparatedByString:@" "]) {
			if ([word hasPrefix:prefix])
				[set addObject:word];
		}
	}
	return [set allObjects];
    //	NSLog(@"tags %@", set);
}

- (NSArray *)filesWithTag:(NSString*)tag fromQuery:(NSMetadataQuery *)aQuery {	
	NSMutableSet *set = [NSMutableSet set];
	NSEnumerator *resultsEnum = [[aQuery results] objectEnumerator];
	NSMetadataItem *result;
	while(result = [resultsEnum nextObject]) {
        NSString *name = [result valueForAttribute:(NSString *)kMDItemPath];
        NSString *comment = [result valueForAttribute:(NSString *)kMDItemFinderComment];
		for(NSString * word in [comment componentsSeparatedByString:@" "]) {
			if ([word isEqualToString:tag])
				[set addObject:name];
		}
	}
	return [set allObjects];
}

- (NSMetadataQuery*)queryForTagPrefix:(NSString*)tagPrefix create:(BOOL)create {
    NSMetadataQuery *query = [tagQueries objectForKey:tagPrefix];
    if (!query && create) {
        query = [[NSMetadataQuery alloc] init];
        [query setDelegate:self];
        [query setPredicate:[self predicateForTag:tagPrefix]];
        [query setSearchScopes:[NSArray arrayWithObject:NSMetadataQueryLocalComputerScope]];
        [tagQueries setObject:query forKey:tagPrefix];
        
        NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
        [defaultCenter addObserver:self
                          selector:@selector(queryStarted:) name:NSMetadataQueryDidStartGatheringNotification object:query];
        
/*        [defaultCenter addObserver:self
                          selector:@selector(queryChanged:) name:NSMetadataQueryGatheringProgressNotification object:query];*/
        
		[defaultCenter addObserver:self
                          selector:@selector(queryChanged:) name:NSMetadataQueryDidFinishGatheringNotification object:query];
        
		[defaultCenter addObserver:self
                          selector:@selector(queryChanged:) name:NSMetadataQueryDidUpdateNotification object:query];
    }
    return query;
}

#pragma mark Quicksilver accessors
- (BOOL)startScanningForTagPrefix:(NSString*)tagPrefix delegate:(id)delegate {
    NSMetadataQuery *query = [self queryForTagPrefix:tagPrefix create:YES];
    [self addDelegate:delegate forTagPrefix:tagPrefix];
    if (![query isStarted]) {
        NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[NSMetadataQuery instanceMethodSignatureForSelector:@selector(startQuery)]];
        [inv setTarget:query];
        [inv setSelector:@selector(startQuery)];
        [inv performSelectorOnMainThread:@selector(invoke)
                              withObject:nil waitUntilDone:YES];
        BOOL ret = NO;
        [inv getReturnValue:&ret];
        return ret;
    }
    return YES;
}

- (BOOL)isScanningForTagPrefix:(NSString*)tagPrefix {
    return ([self queryForTagPrefix:tagPrefix create:NO] != nil);
}

- (void)stopScanningForTagPrefix:(NSString*)tagPrefix delegate:(id)delegate {
    if ([self removeDelegate:delegate forTagPrefix:tagPrefix]) {
        /* There are no more listeners to this tag's changes, stop query */
        NSMetadataQuery *query = [self queryForTagPrefix:tagPrefix create:NO];
        if (query) {
            [query stopQuery];
            /* Unregister notifications */
            NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
            [defaultCenter removeObserver:self name:NSMetadataQueryDidStartGatheringNotification object:query];
            //            [defaultCenter removeObserver:self name:NSMetadataQueryGatheringProgressNotification object:nil];
            [defaultCenter removeObserver:self name:NSMetadataQueryDidFinishGatheringNotification object:query];
            [defaultCenter removeObserver:self name:NSMetadataQueryDidUpdateNotification object:query];
            
            [tagQueries removeObjectForKey:tagPrefix];
            
            [query release];
        }
    }
}

- (NSArray*)tagsWithTagPrefix:(NSString*)tagPrefix {
    NSMetadataQuery *query = [self queryForTagPrefix:tagPrefix create:NO];
    if (!query)
        return nil;
    NSArray *objects = nil;
    [query disableUpdates];
    if ([query resultCount] != 0) {
        objects = [self tagsFromQuery:query];
    }
    [query enableUpdates];
    return objects;
}

- (NSArray*)filesForTag:(NSString*)tag {
    NSMetadataQuery *query = [self queryForTagPrefix:[self tagPrefixForTag:tag] create:NO];
    if (!query)
        return nil;
    NSArray *objects = nil;
    [query disableUpdates];
    if ([query resultCount] != 0) {
        objects = [self filesWithTag:tag fromQuery:query];
    }
    [query enableUpdates];
    return objects;
}

- (NSArray*)filesForTags:(NSArray*)tags {
    NSMutableSet * files = nil;
    for(NSString * tag in tags) {
        NSArray *tempArray = [self filesForTag:tag];
        if (tempArray) {
            files = [NSMutableArray arrayWithCapacity:[tempArray count]];
            [files addObjectsFromArray:tempArray];
        }
    }
    return [files allObjects];
}

#pragma mark NSString additions
- (NSString *)stringByAddingTagPrefix:(NSString *)tag {
    NSString *string = tag;
	if (![tag hasPrefix:gTagPrefix])
		string = [gTagPrefix stringByAppendingString:tag];
	return string;
}

- (NSString *)stringByRemovingTagPrefix:(NSString *)tag {
    NSString *string = tag;
	if ([tag hasPrefix:gTagPrefix])
		string = [tag substringFromIndex:[gTagPrefix length]];
	return string;
}

#pragma mark Notification Handling
- (void)performSelector:(SEL)selector onDelegatesForTagPrefix:(NSString*)tagPrefix {
    for (id delegate in [tagDelegates objectForKey:tagPrefix]) {
        if ([delegate respondsToSelector:selector])
            [delegate performSelector:selector withObject:tagPrefix];
    }
}

- (void)queryStarted:(NSNotification *)notif {
    [[notif object] enableUpdates];
}

- (void)queryChanged:(NSNotification *)notif {
    [self performSelector:@selector(tagQueryDidUpdate:) onDelegatesForTagPrefix:[self tagPrefixForQuery:[notif object]]];
}

@end
