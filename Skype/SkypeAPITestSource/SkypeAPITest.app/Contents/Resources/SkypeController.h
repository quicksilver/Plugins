//
//  SkypeController.h
//  SkypeAPITest
//
//  Created by Janno Teelem on 14/04/2005.
//  Copyright 2005 Skype Technologies S.A.. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Skype/Skype.h>

@interface SkypeController : NSObject <SkypeAPIDelegate>
{
    IBOutlet id commandField;
    IBOutlet id infoView;
}

- (IBAction)onConnectBtn:(id)sender;
- (IBAction)onDisconnectBtn:(id)sender;
- (IBAction)onSendBtn:(id)sender;

@end
