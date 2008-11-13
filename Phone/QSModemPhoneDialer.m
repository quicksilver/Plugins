//
//  ModemDialer.m
//  BuddyPop
//
//  Created by Yann Bizeul on Wed May 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "QSModemPhoneDialer.h"
#import <unistd.h>

#include <SystemConfiguration/SystemConfiguration.h>
@implementation QSModemPhoneDialer
//static NSFileHandle *fhr;
+ (id)sharedInstance{
    static id _sharedInstance;
    if (!_sharedInstance) _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    return _sharedInstance;
}

- (NSArray *)actionProperties;
{
	return nil;//   return [NSArray arrayWithObject:kABPhoneProperty];
}
- (BOOL)shouldEnableActionForPerson:(ABPerson *)person identifier:(NSString *)identifier;
{
    return ([[NSFileManager defaultManager] fileExistsAtPath:@"/dev/cu.modem"]);
}

- (id)init
{
    self = [super init];
    [[NSNotificationCenter defaultCenter]addObserver:self
											selector:@selector(windowWillClose:)
												name:@"BPWindowWillCloseNotification"
											  object:nil];
    return self;
}
- (void)performActionForPerson:(ABPerson *)person identifier:(NSString *)identifier;
{
}

- (NSDictionary *)currentModemConfig{
	NSMutableArray * addresses;
	SCDynamicStoreRef dynRef=SCDynamicStoreCreate(kCFAllocatorSystemDefault, (CFStringRef)@"Whatever you want", NULL, NULL);
	NSArray *interfaceList=
		(NSArray *) SCDynamicStoreCopyKeyList(dynRef,(CFStringRef)@"Setup:/Network/Service/..*/Interface");
NSEnumerator *interfaceEnumerator=[interfaceList objectEnumerator];
addresses = [NSMutableArray arrayWithCapacity:[interfaceList count]];
NSString *interface;

while(interface=[interfaceEnumerator nextObject]) {
	NSDictionary *interfaceEntry=(NSDictionary *)SCDynamicStoreCopyValue(dynRef,(CFStringRef)interface);
	
	//NSLog(@"inter %@",interfaceEntry);
	NSString * deviceName = [interfaceEntry  objectForKey:@"DeviceName"];
	
	if ([deviceName isEqualToString:@"modem"]){
		
		NSDictionary *interfaceEntry=(NSDictionary *)SCDynamicStoreCopyValue(dynRef,[[(CFStringRef)interface stringByDeletingLastPathComponent]stringByAppendingPathComponent:@"Modem"]);
		
		return interfaceEntry;
	}
}
return nil;
}


- (void)dialString:(NSString *)string{
	
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init ];
	
	
	NSDictionary *config=[self currentModemConfig];
	
	BOOL enableSpeaker=[[config objectForKey:@"Speaker"]boolValue];
	BOOL pulseDial=[[config objectForKey:@"PulseDial"]boolValue];
	BOOL ignoreDialTone=[[config objectForKey:@"DialMode"]isEqualToString:@"IgnoreDialTone"];
	
	
	//ConnectionScript
	NSLog(@"Config %@",config);
	
    CONTINUE=NO;
    NSFileHandle *fhr=nil;
    if (! fhr)
    {
		/* TODO
		[[BPCaptionController sharedCaptionController]replaceCaption: NSLocalizedString(@"Initializing modem",@"") sender: self];
		*/
		fhr = [[NSFileHandle fileHandleForReadingAtPath:@"/dev/cu.modem"]retain];	
		[[NSNotificationCenter defaultCenter]addObserver:self
												selector:@selector(modemData:)
													name:@"NSFileHandleDataAvailableNotification"
												  object:fhr];
    }
    // TODO [[BPCaptionController sharedCaptionController]replaceCaption: [NSString stringWithFormat: NSLocalizedString(@"Dialing %@ with %@",@""),number, @"modem"] sender: self];
    NSData *data;
    fhw = [[NSFileHandle fileHandleForWritingAtPath:@"/dev/cu.modem"]retain];
    
    NSMutableString *options = [NSMutableString stringWithString:@""];
    
    if (enableSpeaker)
		[options appendString:@"M1"];
    else
		[options appendString:@"M0"];
    
    if (ignoreDialTone)
		[options appendString:@"X1"];
    
    NSString *init = [NSString stringWithFormat: @"AT&FE0S7=45S0=0L2%@\r",options];
    data = [NSData dataWithBytes:[init cString] length:[init length]];
    [fhr waitForDataInBackgroundAndNotify];
    [fhw writeData:data];
	
	    while (!CONTINUE){ 
			[[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
	  }
		CONTINUE=NO;
    if (pulseDial)
		data = [[NSString stringWithFormat: @"ATDP%@;\r",string]dataUsingEncoding:NSASCIIStringEncoding];
	else
		data = [[NSString stringWithFormat: @"ATDT%@;\r",string]dataUsingEncoding:NSASCIIStringEncoding];
    	NSLog(@"string %@",string);
	[fhw writeData:data];
    data=[fhr availableData];
	
	string = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
	NSLog(@"string %@",string);
	
	
//	string = [[NSString alloc]initWithData:data encoding:NSASCIIStringEncoding];
//	NSLog(@"string %@",string);
	
//    while (!CONTINUE){ 
//		[[NSRunLoop currentRunLoop]runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:1]];
  //  }
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    //[[BPCaptionController sharedCaptionController]replaceCaption: [NSString stringWithFormat: NSLocalizedString(@"Hanging up",@""),number] sender: self];
    //[[BPCaptionController sharedCaptionController]dispose: self];
    data = [NSData dataWithBytes:"ATH\r" length:4];
    [fhw writeData:data];
    [fhr closeFile];
    [fhr release];
	fhr=nil;
	sleep(1);
	[fhw closeFile];
    [fhw release];
  //  [[NSNotificationCenter defaultCenter]removeObserver:self];
	
    //[fhw closeFile];
    //[fhw release];
	// [pool release];
}
- (void)modemData:(NSNotification*)aNotification;{
    NSFileHandle *fh = [aNotification object];
    NSString *string = [[NSString alloc]initWithData:[fh availableData] encoding:NSASCIIStringEncoding];
	NSLog(@"strin %@",string);
	if (([string rangeOfString:@"OK"].location != NSNotFound) || ([string rangeOfString:@"ERROR"].location != NSNotFound))
		CONTINUE = YES;
    if ([string length])
		[fh waitForDataInBackgroundAndNotify];
    
}
- (int)timeout
{
    return 0;
}
- (void)windowWillClose:(NSNotification*)aNotification
{
	
	
    [self cancel];
}
- (void)dealloc
{

    [super dealloc];
}
@end
