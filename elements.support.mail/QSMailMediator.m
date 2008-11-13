

#import "QSMailMediator.h"

NSString *defaultMailClientID(){
    NSURL *appURL = nil; 
    OSStatus err; 
    err = LSGetApplicationForURL((CFURLRef)[NSURL URLWithString: @"mailto:"],kLSRolesAll, NULL, (CFURLRef *)&appURL); 
    if (err != noErr){
		NSLog(@"No default mail client found. Error %ld", err); 
		return nil;
	}
    NSDictionary *infoDict=(NSDictionary *)CFBundleCopyInfoDictionaryForURL((CFURLRef)appURL);
	[infoDict autorelease];
    return [infoDict objectForKey:(NSString *)kCFBundleIdentifierKey];
}


@implementation QSMailMediator


+ (id <QSMailMediator>)defaultMediator{
    return [QSReg QSMailMediator];
}



- (void) sendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow{
	[self sendEmailWithScript:[self mailScript] to:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow];
}

- (void) sendEmailWithScript:(NSAppleScript *)script to:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow
{
    
    if (!sender)sender=@""; 
    if (!addresses){ 
        NSRunAlertPanel(@"Invalid address",@"Missing email address", nil,nil,nil);
        
        // [self sendDirectEmailTo:address subject:subject body:body attachments:pathArray];
        return;
    }
    
   if (VERBOSE) NSLog(@"Sending Email:\r     To: %@\rSubject: %@\r   Body: %@\rAttachments: %@\r",[addresses componentsJoinedByString:@", "],subject,body,[pathArray componentsJoinedByString:@"\r"]);
    
    NSDictionary *errorDict=nil;
    
    //id message=
	[script executeSubroutine:(sendNow?@"send_mail":@"compose_mail")
							   arguments:[NSArray arrayWithObjects:subject,body,sender,addresses,(pathArray?pathArray:[NSArray array]),nil]
								   error:&errorDict];
    //  NSLog(@"%@",message);
    if (errorDict) 
        NSRunAlertPanel(@"An error occured while sending mail", [errorDict objectForKey:@"NSAppleScriptErrorMessage"], nil,nil,nil);
}



- (NSString *)scriptPath{
    return nil;
}
- (NSAppleScript *)mailScript {
    if (!mailScript){
        NSString *path=[self scriptPath];
        if (path) mailScript=[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil];
    }
    return mailScript;
}

- (void)setMailScript:(NSAppleScript *)newMailScript {
    [mailScript release];
    mailScript = [newMailScript retain];
}

@end


@implementation QSRegistry (QSMailMediator)
- (id <QSMailMediator>)QSMailMediator{
	id <QSMailMediator> mediator=[prefInstances objectForKey:kQSMailMediators];
	if (!mediator){
		mediator=[self instanceForKey:[QSReg QSMailMediatorID]
							  inTable:kQSMailMediators];
		if (mediator)
			[prefInstances setObject:mediator forKey:kQSMailMediators];
		else NSLog(@"Mediator not found %@",[[NSUserDefaults standardUserDefaults] stringForKey:kQSMailMediators]);
	}
	
	return mediator;
}
- (NSString *)QSMailMediatorID{
	NSString *key=[[NSUserDefaults standardUserDefaults] stringForKey:kQSMailMediators];
	if (!key)key=defaultMailClientID();
	return key;
}
@end

@interface QSResourceManager (QSMailMediator)
- (NSImage *)defaultMailClientImage;
@end
@implementation QSResourceManager (QSMailMediator)
- (NSImage *)defaultMailClientImage{
	return [[NSWorkspace sharedWorkspace]iconForFile:[[NSWorkspace sharedWorkspace]absolutePathForAppBundleWithIdentifier:[QSReg QSMailMediatorID]]];
}
@end



