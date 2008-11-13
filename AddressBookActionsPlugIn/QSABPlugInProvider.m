

#import "QSABPlugInProvider.h"

#define kABEventClass 'az00'
#define kABActionPropertyEventID 'az57'
#define kABActionTitleEventID 'az58'
#define kABActionEnableEventID 'az59'
#define kABActionPerformEventID 'az60'

@implementation QSABPlugInProvider
- (QSAction *)abScriptActionForPath:(NSString *)path{
	NSAppleScript *script=[[[NSAppleScript alloc]initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil]autorelease];
	
	NSArray *handlers=[NSAppleScript validHandlersFromArray:[NSArray arrayWithObjects:@"aevtoapp",@"DAEDopnt",@"aevtodoc",nil] 
											   inScriptFile:path];
	
	NSAppleEventDescriptor* event, *result;
	NSDictionary *errorInfo=nil;
	int pid = [[NSProcessInfo processInfo] processIdentifier];
	NSAppleEventDescriptor* targetAddress = [[[NSAppleEventDescriptor alloc] initWithDescriptorType:typeKernelProcessID bytes:&pid length:sizeof(pid)]autorelease];
	
	event = [[[NSAppleEventDescriptor alloc] initWithEventClass:kABEventClass eventID:kABActionPropertyEventID targetDescriptor:targetAddress returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID]autorelease];

	result=[script executeAppleEvent:event error:&errorInfo];
	
	NSString *actionProperty=[result stringValue];
	
	event = [[[NSAppleEventDescriptor alloc] initWithEventClass:kABEventClass eventID:kABActionTitleEventID targetDescriptor:targetAddress returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID]autorelease];
	//[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:[iObject stringValue]] forKeyword:keyDirectObject];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:@""] forKeyword:'az61'];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithString:@""] forKeyword:'az62'];
	
	result=[script executeAppleEvent:event error:&errorInfo];
	
	NSString *actionTitle=[result stringValue];
	//NSLog(@"er %@",errorInfo);
	
	NSLog(@"actionTitle %@ %@",actionTitle, actionProperty);
	QSAction *action=[QSAction actionWithIdentifier:[@"[Action]:" stringByAppendingString:path]];
	[[action actionDict]setObject:path forKey:@"actionScript"];
	
	[[action actionDict]setObject:NSStringFromClass([self class]) forKey:kActionClass];
	[[action actionDict]setObject:self forKey:kActionProvider];
	//NSLog(@"handlers %@ %@",action,handlers);
	
	
	[[action actionDict]setObject:[NSArray arrayWithObject:QSTextType] forKey:@"directTypes"];
	
	
	[action setName:actionTitle];
	[action setObject:path forMeta:kQSObjectIconName];
	return action;
}

- (NSArray *) fileActionsFromPaths:(NSArray *)scripts{
	return nil;
	scripts=[scripts pathsMatchingExtensions:[NSArray arrayWithObjects:@"scpt",@"app",nil]];
	NSEnumerator *e=[scripts objectEnumerator];
	NSString *path;
	NSMutableArray *array=[NSMutableArray array];
	NSLog(@"scripts %@",scripts);
	while(path=[e nextObject]){
		if (![[path pathExtension]isEqualToString:@"scpt"])continue;
		QSAction *action=[self abScriptActionForPath:path];
		[array addObject:action];
	}
	return array;
}

@end
