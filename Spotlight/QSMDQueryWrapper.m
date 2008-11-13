//
//  QSMDQueryWrapper.m
//  QSSpotlightPlugIn
//
//  Created by Nicholas Jitkoff on 4/1/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSMDQueryWrapper.h"

void QSMDQueryCallBack (CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object,  CFDictionaryRef userInfo){
	NSLog(@"notif %@",name);
	[observer handleCFNotification:name object:object userInfo:userInfo];
}



const void *QSObjectFromMDQueryItem(MDQueryRef query, MDItemRef item, void *context){
	NSString *path=MDItemCopyAttribute(item, kMDItemPath);
//	NSNumber *rank=MDItemCopyAttribute(item, kMDQueryResultContentRelevance);

	QSObject *object=[[QSObject alloc]initWithArray:[NSArray arrayWithObject:path]];
//	if (rank)
//		object=[[QSRankedObject alloc]initWithObject:object matchString:nil order:nil score:[rank floatValue]];
	
	[path release];
	return object;
}



@implementation QSMDQueryWrapper
+ findWrapperWithQuery:(NSString *)query path:(NSString *)path keepalive:(BOOL)flag{
	return [[[self alloc]initWithQuery:(NSString *)query path:(NSString *)path keepalive:(BOOL)flag]autorelease];
}
- (void)handleCFNotification:(CFStringRef)name object:(const void *)object userInfo:(CFDictionaryRef) userInfo{
	NSLog(@"notifx %@",name);
	
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
	[task release];
	[resultPaths release];
	[super dealloc];
}
- (NSMutableArray *)results{
	return results;
}
- (void)done:(NSNotification *)notif{
	NSLog(@"notif %@",notif);	
}
- (void)startQuery{
	[self retain];
	MDQueryRef mdquery=MDQueryCreate (NULL,query,[NSArray arrayWithObject:kMDItemPath],[NSArray arrayWithObject:kMDItemFSContentChangeDate]);
	
	
	MDQuerySetSearchScope (mdquery,[NSArray arrayWithObject:path],0);
	
	MDQuerySetCreateResultFunction (mdquery,&QSObjectFromMDQueryItem,
									self,
									NULL
									);
	//	
	
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(done:) name:kMDQueryDidUpdateNotification object:nil];
	
	
	CFNotificationCenterAddObserver (CFNotificationCenterGetLocalCenter(), 
									 self, 
									 &QSMDQueryCallBack, 
									 kMDQueryDidFinishNotification, 
									 nil, 
									 CFNotificationSuspensionBehaviorDeliverImmediately
									 );
	
	CFNotificationCenterAddObserver (CFNotificationCenterGetLocalCenter(), 
									 self, 
									 &QSMDQueryCallBack, 
									 kMDQueryProgressNotification, 
									 nil, 
									 CFNotificationSuspensionBehaviorCoalesce
									 );
	
	
	
	NSLog(@"mdquerying %d",MDQueryExecute (mdquery,kMDQuerySynchronous));
	NSLog(@"results %d",MDQueryGetResultCount (mdquery));
	int i;
	for (i=0;i<MDQueryGetResultCount(mdquery);i++){
		[results addObject:MDQueryGetResultAtIndex (mdquery,i)];
	}
	NSLog(@"results %@",MDQueryCopyValuesOfAttribute(mdquery, kMDItemPath));
	
	
	
	//
	//	MDItemRef item=	///\
	
	
	
	QSObject *searchObject=[QSObject objectWithString:@"Searching"];
	[searchObject setIcon:[QSResourceManager imageNamed:@"Find"]];
	//[results addObject:searchObject];
	
	
	[QSTasks updateTask:@"QSSpotlight" status:@"Performing Search" progress:0];
	//	return results;
}




//-(void)dataAvailable:(NSNotification *)notif{
//	
//	NSFileHandle *handle=[notif object];
//	//return;
//	NSData *data=[[notif userInfo]
//                  objectForKey: NSFileHandleNotificationDataItem];
//	NSString *newString=[[[NSString alloc]initWithData:data encoding:nil]autorelease];
//	if ([newString length])
//		[resultPaths appendString:newString];
//	
//	
//	NSArray *pathArray=[resultPaths componentsSeparatedByString:@"\n"];
//	
//	[resultPaths setString:[pathArray lastObject]];
//	pathArray=[pathArray subarrayWithRange:NSMakeRange(0,[pathArray count]-1)];
//	//	NSLog(@"paths %d",[pathArray count]);	
//	//NSLog(@"remaining:%@",resultPaths);
//	
//	[results addObjectsFromArray:[QSObject fileObjectsWithPathArray:pathArray]];
//	[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayUpdated" object:results];
//	
//	//	[results release];
//	//	results=nil;
//	[QSTasks removeTask:@"QSSpotlight"];
//	if ([data length])
//		[handle readInBackgroundAndNotify];
//	else{
//		[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayFinished" object:results];
//		[self release];
//	}
//}

@end
