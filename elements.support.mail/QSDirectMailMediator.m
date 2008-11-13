

#import "QSDirectMailMediator.h"

#import <Message/NSMailDelivery.h>

@implementation QSDirectMailMediator

- (NSString*)defaultEmailAddress{
    NSDictionary *icDict = [(NSDictionary *) CFPreferencesCopyValue((CFStringRef) @"Version 2.5.4", (CFStringRef) @"com.apple.internetconfig", kCFPreferencesCurrentUser, kCFPreferencesAnyHost) autorelease];
    return [[[icDict objectForKey:@"ic-added"]objectForKey:@"Email"]objectForKey:@"ic-data"];
}
- (void) sendEmailTo:(NSArray *)addresses
				from:(NSString *)sender 
			 subject:(NSString *)subject 
				body:(NSString *)body 
		 attachments:(NSArray *)pathArray 
			 sendNow:(BOOL)sendNow{
    
	//NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    //NSString* smtpFromAddress = from; //[defaultsstringForKey:PMXSMTPFromAddress];
    BOOL sent;
    NSMutableDictionary *headers;
    NSFileWrapper* fw;
    NSTextAttachment* ta;
	body=[body stringByAppendingString:@"\r\r"];
    NSMutableAttributedString* msg=[[[NSMutableAttributedString alloc]initWithString:body]autorelease];
	
	foreach(attachment,pathArray){		
		fw = [[[NSFileWrapper alloc] initWithPath:attachment]autorelease]; //initRegularFileWithContents:[attachment dataUsingEncoding:NSNonLossyASCIIStringEncoding]];
		[fw setPreferredFilename:[attachment lastPathComponent]];
		ta = [[[NSTextAttachment alloc] initWithFileWrapper:fw]autorelease];
		[msg appendAttributedString:[NSAttributedString attributedStringWithAttachment:ta]];
}


headers = [NSMutableDictionary dictionary];
[headers setObject:[addresses componentsJoinedByString:@","] forKey:@"To"];
if (subject) [headers setObject:subject forKey:@"Subject"];
if (sender)  [headers setObject:sender forKey:@"From"];
[headers setObject:@"Quicksilver" forKey:@"X-Mailer"];
[headers setObject:@"multipart/mixed" forKey:@"Content-Type"];
[headers setObject:@"1.0" forKey:@"Mime-Version"];
sent = [NSMailDelivery deliverMessage: msg
							  headers: headers
							   format: NSMIMEMailFormat
							 protocol: nil];

//NSLog(@"headers %@",headers);
if ( !sent )
{
	NSBeep();
	NSLog(@"Send Failed");
}
else{
	NSSound *sound=[[[NSSound alloc] initWithContentsOfFile:@"/Applications/Mail.app/Contents/Resources/Mail Sent.aiff" byReference:YES]autorelease];
	[sound play];
}
}

@end
