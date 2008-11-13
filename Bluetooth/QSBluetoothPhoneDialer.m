//
//  QSBluetoothPhoneDialer.m
//  QSPhonePlugIn
//
//  Created by Nicholas Jitkoff on 3/30/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSBluetoothPhoneDialer.h"
#import "BTConnection.h"
#import "BTDialer.h"

@implementation QSBluetoothPhoneDialer

- (BOOL)dialString:(NSString *)number{
	
	
	NSArray *array=[BTConnection devicesWithService:0x400000];
	
	
	if (![array count]){
		NSBeep();
		return nil;
	}
	NSLog(@"Using Device:%@",[[array lastObject]objectForKey:@"name"]);
	
	//You can get a list of devices with + (NSArray*)devicesWithService:(BluetoothClassOfDevice)service with service 0x400000
	//The BTConnection's delegate receive btDeviceConnected:(id)sender message once the connection is established
	
	
	
	[[BTConnection sharedConnection]setDevice:[[array lastObject]objectForKey:@"address"]];
	[NSThread detachNewThreadSelector:@selector(dialBluetoothThreaded:) toTarget:self withObject:number];
	[[BTConnection sharedConnection]connect];
	return nil;
}

-(void)dialBluetoothThreaded:(NSString *)number{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	while(![[BTConnection sharedConnection] isConnected])usleep(250);
	id dialer=[[BTDialer alloc]init];
	[dialer dialerWillStartDialing];
	[dialer dial:number];
	[dialer release];
	//[[BTConnection sharedConnection]disconnect];
	[pool release];
}
@end
