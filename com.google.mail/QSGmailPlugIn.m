//
//  QSGmailPlugIn.m
//  QSGmailPlugIn
//
//  Created by Nicholas Jitkoff on 1/30/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import "QSGmailPlugIn.h"
#define QSURLEncode(s) [(NSString*)CFURLCreateStringByAddingPercentEscapes(NULL, s, NULL, @":/=+&?", kCFStringEncodingUTF8) autorelease]
@implementation QSGmailPlugIn


- (void)sendEmailTo:(NSArray *)addresses
               from:(NSString *)sender 
            subject:(NSString *)subject 
               body:(NSString *)body 
        attachments:(NSArray *)pathArray
            sendNow:(BOOL)sendNow
{
	NSMutableString *mailURL = [NSMutableString stringWithString:@"https://mail.google.com/mail/?view = cm"];
	[mailURL appendFormat:@"&fs = 1"]; // fullscreen
	[mailURL appendFormat:@"&tf = 1"]; // tearoff
	
	[mailURL appendFormat:@"&to = %@", [addresses componentsJoinedByString:@", "]];
  //	[mailURL appendFormat:@"&cc = %@",];
  //	[mailURL appendFormat:@"&bcc = %@",];
	[mailURL appendFormat:@"&su = %@", QSURLEncode(subject)];
	[mailURL appendFormat:@"&body = %@", QSURLEncode(body)];
  
  
  //Just append any of these to the GMail Compose Email URL above.
  //Email To: "to"
  //Usage: "%26to%3Dmike%40rabidsquirrel%2Enet"
  //CC: "cc"
  //Usage: "%26cc%3D"
  //	Comma Delimited list of emails
  //BCC: "bcc"
  //Usage: "%26bcc%3D"
  //	Comma Delimited list of emails
  //	Subject Line: "su"
  //Usage: "%26su%3DYour%2520Subject%2520Line"
  //Body: "body"
  //Usage: "%26body%3DBlahblah"
  //	https://mail.google.com/mail/?dest = https://mail.google.com/mail?view = cm&fs = 1&tf = 1&to = zero@blacktree.com&su = blah&body = blah
	NSString *trueURL = mailURL; //[NSString stringWithFormat:@"https://mail.google.com/mail/?dest = %@", (mailURL)];
  NSLog(@"email to %@", trueURL);
  
  if (0) {
    id cont = [[NSClassFromString(@"QSSimpleWebWindowController") alloc] initWithWindow:nil];
    [cont openURL:[NSURL URLWithString:trueURL]];
    [[cont window] makeKeyAndOrderFront:nil];
  } else {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:trueURL]];
    
  }
	
	
}



@end
