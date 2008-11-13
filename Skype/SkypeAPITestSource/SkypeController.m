//
//  SkypeController.mm
//  SkypeAPITest
//
//  Created by Janno Teelem on 14/04/2005.
//  Copyright 2005 Skype Technologies S.A.. All rights reserved.
//

#import "SkypeController.h"

NSString* const cMyApplicationName = @"My Skype API Tester";

@implementation SkypeController

/////////////////////////////////////////////////////////////////////////////////////
- (void)awakeFromNib
{
	[SkypeAPI setSkypeDelegate:self];
}

/////////////////////////////////////////////////////////////////////////////////////
// required delegate method
- (NSString*)clientApplicationName
{
	return cMyApplicationName;
}

/////////////////////////////////////////////////////////////////////////////////////
// optional delegate method
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode
{
	switch (aAttachResponseCode)
	{
		case 0:
			[infoView insertText:@"Failed to connect\n"];
			break;
		case 1:
			[infoView insertText:@"Successfully connected to Skype!\n"];
			break;
		default:
			[infoView insertText:@"Unknown response from Skype\n"];
			break;
	}
	
}

/////////////////////////////////////////////////////////////////////////////////////
// optional delegate method
- (void)skypeNotificationReceived:(NSString*)aNotificationString
{
	[infoView insertText:aNotificationString];
	[infoView insertText:@"\n"];
}

/////////////////////////////////////////////////////////////////////////////////////
// optional delegate method
- (void)skypeBecameAvailable:(NSNotification*)aNotification
{
	[infoView insertText:@"Skype became available\n"];
}

/////////////////////////////////////////////////////////////////////////////////////
// optional delegate method
- (void)skypeBecameUnavailable:(NSNotification*)aNotification
{
	[infoView insertText:@"Skype became unavailable\n\n"];
}

/////////////////////////////////////////////////////////////////////////////////////
- (IBAction)onConnectBtn:(id)sender
{
	[SkypeAPI connect];
}

/////////////////////////////////////////////////////////////////////////////////////
- (IBAction)onDisconnectBtn:(id)sender
{
	[SkypeAPI disconnect];
}

/////////////////////////////////////////////////////////////////////////////////////
- (IBAction)onSendBtn:(id)sender
{
	[infoView insertText:[commandField stringValue]];
	[infoView insertText:@"\n"];
	
	[SkypeAPI sendSkypeCommand:[commandField stringValue]];
}

/////////////////////////////////////////////////////////////////////////////////////
@end
