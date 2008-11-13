//
//  BTDialer.m
//  BuddyPop
//
//  Created by Yann Bizeul on Sat May 15 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "BTDialer.h"
//#import "BPCaptionController.h"

#import <unistd.h>

@implementation BTDialer
+ (BOOL)isAvailable
{
    return [BTConnection bluetoothAvailable];
}
+ (BOOL)isReady
{
    return [[BTConnection sharedConnection] isConnected];
}
- (void)dialerWillStartDialing
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(_phoneStatusChanged:) name:@"BTPhoneStatusChanged" object:nil];
//    [super _prepareDialing: aNumber];
}

- (void)dial:(id)number
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init ];
 //   [[BPCaptionController sharedCaptionController]replaceCaption: [NSString stringWithFormat: NSLocalizedString(@"Dialing %@ with %@",@""),number,[[BTConnection sharedConnection]name]] sender: self];
    [[BTConnection sharedConnection]sendString:[NSString stringWithFormat: @"ATD%@;\r",number]];

  //  while (!DONE && !CANCEL){ sleep(1); }

    if (CANCEL)
		[[BTConnection sharedConnection]sendString:@"AT*EVH\r"];
    
   // [[BPCaptionController sharedCaptionController]dispose: self];
    [pool release];
}
- (void)_phoneStatusChanged:(NSNotification*)aNotification
{
//    int status = [[[aNotification userInfo]objectForKey:@"ccstatus"]intValue];
    
//    if (status==kBPSEStatusCalling)
//	return;
    
    DONE=YES;
    [[NSNotificationCenter defaultCenter]removeObserver: self name:@"BTPhoneStatusChanged" object:nil];
}
+ (NSString*)localizedNumber:(NSString*)aNumber
{
    return aNumber;
}
@end

