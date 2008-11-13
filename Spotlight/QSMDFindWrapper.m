//
//  QSMDFindWrapper.m
//  QSSpotlightPlugIn
//
//  Created by Nicholas Jitkoff on 3/21/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSMDFindWrapper.h"


@implementation QSMDFindWrapper

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
	[task release];
	[resultPaths release];
	[super dealloc];
}
- (NSMutableArray *)results{
	return results;
}
- (void)startQuery{
	[self retain];
	
	task=[[NSTask taskWithLaunchPath:@"/usr/bin/mdfind"
						   arguments:[NSArray arrayWithObjects:query,
											   path?@"-onlyin":nil,path,
							   nil]]retain];
	
	[task setStandardOutput:[NSPipe pipe]];
	NSFileHandle *handle=[[task standardOutput]fileHandleForReading];

	[handle retain];
		[task launch];
		
		
	[[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(dataAvailable:)
												name:NSFileHandleReadCompletionNotification
											  object:handle];
	[handle readInBackgroundAndNotify];
	//	results=[[NSMutableArray alloc]init];
	QSObject *searchObject=[QSObject objectWithString:@"Searching"];
	[searchObject setIcon:[QSResourceManager imageNamed:@"Find"]];
	[results addObject:searchObject];
	
	
	[QSTasks updateTask:@"QSSpotlight" status:@"Performing Search" progress:0];
	//return results;
}




-(void)dataAvailable:(NSNotification *)notif{
	
	NSFileHandle *handle=[notif object];
	//return;
	NSData *data=[[notif userInfo]
                  objectForKey: NSFileHandleNotificationDataItem];
	NSString *newString=[[[NSString alloc]initWithData:data encoding:nil]autorelease];
	if ([newString length])
		[resultPaths appendString:newString];
	
	
	NSArray *pathArray=[resultPaths componentsSeparatedByString:@"\n"];
	
	[resultPaths setString:[pathArray lastObject]];
	pathArray=[pathArray subarrayWithRange:NSMakeRange(0,[pathArray count]-1)];
//	NSLog(@"paths %d",[pathArray count]);	
	//NSLog(@"remaining:%@",resultPaths);
	
	[results addObjectsFromArray:[QSObject fileObjectsWithPathArray:pathArray]];
	[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayUpdated" object:results];
	
	//	[results release];
	//	results=nil;
	if ([data length])
		[handle readInBackgroundAndNotify];
	else{
		
		[QSTasks removeTask:@"QSSpotlight"];
		[results removeObjectAtIndex:0];
		
		[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayUpdated" object:results];
		[[NSNotificationCenter defaultCenter]postNotificationName:@"QSSourceArrayFinished" object:results];
		[self release];
	}
}
@end
