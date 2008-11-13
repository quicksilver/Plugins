//
//  QSMDFindWrapper.m
//  QSSpotlightPlugIn
//
//  Created by Nicholas Jitkoff on 3/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSNSMDQueryWrapper.h"
#import <QSFoundation/QSMDPredicate.h>

@implementation QSNSMDQueryWrapper

+ findWrapperWithQuery:(NSString *)query path:(NSString *)path keepalive:(BOOL)flag{
	return [[[self alloc]initWithQuery:(NSString *)query path:(NSString *)path keepalive:(BOOL)flag]autorelease];
}

- (id)initWithQuery:(NSString *)aQuery path:(NSString *)aPath keepalive:(BOOL)flag{
	if (self=[super init]){
		results=[[NSMutableArray alloc]init];
		resultPaths=[[NSMutableString alloc]init];
		path=[aPath retain];
		query=[aQuery retain];
		keepalive=flag;
	}
	return self;
}
- (void)dealloc{
	//NSLog(@"released wrapper");
	
	[results release];
	[path release];
	[query release];
	[resultPaths release];
	[mdquery release];
	[super dealloc];
}
- (id)metadataQuery:(NSMetadataQuery *)query replacementObjectForResultObject:(NSMetadataItem *)result{
	id object=[QSObject fileObjectWithPath:[result valueForKey:kMDItemPath]];
	
	float relevance=[[result valueForAttribute:NSMetadataQueryResultContentRelevanceAttribute]floatValue];
	
	if (relevance)
		object=[QSRankedObject rankedObjectWithObject:object matchString:nil order:NSNotFound score:relevance];
	return object;
}

- (NSMutableArray *)results{
	return results;
	
	//return [mdquery results];
}
- (void)startQuery{
	[self retain];
	mdquery=[[NSMetadataQuery alloc]init];
	
	if (path){
		[mdquery setSearchScopes:[NSArray arrayWithObject:path]];
	}


	[mdquery setPredicate:[QSMDQueryPredicate predicateWithString:query]];

	[mdquery setDelegate:self];
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(dataAvailable:)
												name:NSMetadataQueryGatheringProgressNotification
											  object:mdquery];
	
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(queryDidFinish:)
												name:NSMetadataQueryDidFinishGatheringNotification
											  object:mdquery];
	
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(dataAvailable:)
												name:NSMetadataQueryDidUpdateNotification
											  object:mdquery];
	
	
	
	//	results=[[NSMutableArray alloc]init];
	QSObject *searchObject=[QSObject objectWithString:@"Searching"];
	[searchObject setIcon:[QSResourceManager imageNamed:@"Find"]];
	[results addObject:searchObject];
	
	
	[QSTasks updateTask:@"QSSpotlight" status:@"Performing Search" progress:0];
	//return results;
	[mdquery startQuery];
}




-(void)queryDidFinish:(NSNotification *)notif{
	[QSTasks removeTask:@"QSSpotlight"];
	
	[mdquery stopQuery];

	[self release];
}
-(void)dataAvailable:(NSNotification *)notif{
	
//	NSArray *pathArray=
	
	//	NSLog(@"paths %d",[pathArray count]);	
	//NSLog(@"remaining:%p",[mdquery results]);
	
	[results setArray:[mdquery results]];
	[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayUpdated" object:results];
	
	//	[results release];
	//	results=nil;
//	if ([data length])
//		[handle readInBackgroundAndNotify];
//	else{
//		
//		[QSTasks removeTask:@"QSSpotlight"];
//		[results removeObjectAtIndex:0];
//		
//		[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayUpdated" object:results];
//		[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayFinished" object:results];
//		[self release];
//	}
}
@end
