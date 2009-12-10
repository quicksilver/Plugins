//
//  QSIndigoPlugIn_Action.m
//  QSIndigoPlugIn
//
//  Created by Nicholas Jitkoff on 10/19/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSIndigoPlugIn_Action.h"
#import "QSIndigo.h"

@implementation QSIndigoPlugIn_Action
- (NSString *)target{
	if (![[NSUserDefaults standardUserDefaults] boolForKey:@"QSIndigoUsesRemoteCommands"]) return @"";
	
	NSString *account=[[NSUserDefaults standardUserDefaults] objectForKey:@"QSIndigoUserName"];
	NSString *target=[[NSUserDefaults standardUserDefaults] objectForKey:@"QSIndigoTarget"];
	NSString *password=nil;
	if (account && target){
		NSURL *url=[NSURL URLWithString:[NSString stringWithFormat:@"eppc://%@@%@",account,target]];
		password=[url keychainPassword];
	}

	NSString *url=[NSString stringWithFormat:@"eppc://%@:%@@%@",account,password,target];
	NSLog(@"url %@",url);
	if (!password)return @"";
	return url;
}


- (QSObject *)turnOnDevice:(QSObject *)dObject{
	NSDictionary *dict=nil;

	[self sendAction:@"On" toDevice:@"A10"];
	//	[[self script]executeSubroutine:@"do_command" arguments:[NSArray arrayWithObjects:[self target],[dObject objectForType:kQSX10AddressType],@"on",@"",nil] error:&dict];
	//NSLog(@"dict %@",dict);
	return nil;
}
- (QSObject *)turnOffDevice:(QSObject *)dObject{
	[[self script]executeSubroutine:@"do_command" arguments:[NSArray arrayWithObjects:[self target],[dObject objectForType:kQSX10AddressType],@"off",@"",nil] error:nil];
	return nil;
}
- (QSObject *)brightenDevice:(QSObject *)dObject by:(QSObject *)iObject{
	[[self script]executeSubroutine:@"do_command" arguments:[NSArray arrayWithObjects:[self target],[dObject objectForType:kQSX10AddressType],@"brighten",[iObject stringValue],nil] error:nil];
	return nil;
}
- (QSObject *)dimDevice:(QSObject *)dObject by:(QSObject *)iObject{
	[[self script]executeSubroutine:@"do_command" arguments:[NSArray arrayWithObjects:[self target],[dObject objectForType:kQSX10AddressType],@"dim",[iObject stringValue],nil] error:nil];
	return nil;
}
- (QSObject *)presetDevice:(QSObject *)dObject by:(QSObject *)iObject{
	[[self script]executeSubroutine:@"do_command" arguments:[NSArray arrayWithObjects:[self target],[dObject objectForType:kQSX10AddressType],@"preset",[iObject stringValue],nil] error:nil];
	return nil;
}
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	return [NSArray arrayWithObject:[QSObject textProxyObjectWithDefaultValue:@"20"]];	
}

- (void)sendAction:(NSString *)action toDevice:(NSString *)device{
	//curl -m 1  http://192.168.10.224/0?{2F=A,3L=1,3E=On}>/dev/null;
	
	NSString *houseCode=@"http://192.168.10.224/0?2F=A";
	NSString *unitCode=@"http://192.168.10.224/0?3L=1";
	NSString *actionCode=@"http://192.168.10.224/0?3E=On";
	
	NSMutableURLRequest *houseRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:houseCode]
															  cachePolicy:NSURLRequestReloadIgnoringCacheData
														  timeoutInterval:3.0];
	
	NSMutableURLRequest *unitRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:unitCode]
															 cachePolicy:NSURLRequestReloadIgnoringCacheData
														 timeoutInterval:3.0];
	NSMutableURLRequest *actionRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionCode]
															   cachePolicy:NSURLRequestReloadIgnoringCacheData
														   timeoutInterval:3.0];
	
	NSDictionary *error=nil;
	NSData *data=[NSURLConnection sendSynchronousRequest:houseRequest returningResponse:nil error:&error];
	NSLog(@"data %@ %@",nil,error);
	usleep(500000);
	data=[NSURLConnection sendSynchronousRequest:unitRequest returningResponse:nil error:&error];
	NSLog(@"data %@ %@",nil,error);
	usleep(500000);
	data=[NSURLConnection sendSynchronousRequest:actionRequest returningResponse:nil error:&error];
		NSLog(@"data %@ %@",nil,error);
	
	
}

- (NSAppleScript *)script {
	static NSAppleScript *script=nil;
	if (!script){
		NSString *path=[[NSBundle bundleForClass:[self class]]pathForResource:@"Indigo" ofType:@"scpt"];
		if (path)
			script=[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
	}
	//[self doomSelector:@selector(setFinderScript:) delay:10*MINUTES extend:YES];
	return script;
}

/*
 - (void)setFinderScript:(NSAppleScript *)aFinderScript {
	 if (finderScript != aFinderScript) {
		 [finderScript release];
		 finderScript = [aFinderScript retain];
	 }
 }
 */

@end
