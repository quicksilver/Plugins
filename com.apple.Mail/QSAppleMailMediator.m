

#import "QSAppleMailMediator.h"

#import "QSMailMediator.h"
//#import <QSCore/QSBadgeImage.h>
@class QSCountBadgeImage;

@implementation QSAppleMailMediator

- (void) sendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow{
    if (!sender){
        NSArray *accounts=[[[self mailScript] executeSubroutine:@"account_list"
													  arguments:[NSArray arrayWithObjects:subject,body,addresses,pathArray,nil]
														  error:nil]objectValue];
		//NSLog(@"accounts %@",accounts);
        int i; 
        int accountIndex=0;
        for (i=0;i<[accounts count];i++){
            if (emailsShareDomain([addresses lastObject],[[accounts objectAtIndex:i]objectAtIndex:0])){
                accountIndex=i;   
                break;
            }
        }
        NSArray *account=[accounts objectAtIndex:accountIndex];
        NSString *accountFormatted=[(NSString *)[account lastObject]length]?[NSString stringWithFormat:@"%@ <%@>",[account lastObject],[account objectAtIndex:0]]:[account objectAtIndex:0];
        sender=accountFormatted;
        //NSLog(@"accounts %@",accountFormatted);
        
    }
	[[QSReg getClassInstance:@"QSMailMediator"] sendEmailWithScript:[self mailScript] to:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow];

 //   [self superSendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow];
}

- (NSString *)scriptPath{
    return [[NSBundle bundleForClass:[QSAppleMailMediator class]]pathForResource:@"Mail" ofType:@"scpt"];
}

//-------------------------

- (void) superSendEmailTo:(NSArray *)addresses from:(NSString *)sender subject:(NSString *)subject body:(NSString *)body attachments:(NSArray *)pathArray sendNow:(BOOL)sendNow{
    
    if (!sender)sender=@""; 
    if (!addresses){ 
        NSRunAlertPanel(@"Invalid address",@"Missing email address", nil,nil,nil);
        
        // [self sendDirectEmailTo:address subject:subject body:body attachments:pathArray];
        return;
    }
    
    if (VERBOSE)NSLog(@"Sending Email:\r     To: %@\rSubject: %@\r   Body: %@\rAttachments: %@\r",[addresses componentsJoinedByString:@", "],subject,body,[pathArray componentsJoinedByString:@"\r"]);
    
    NSDictionary *errorDict=nil;
    
    //id message=
	[[self mailScript] executeSubroutine:(sendNow?@"send_mail":@"compose_mail")
							   arguments:[NSArray arrayWithObjects:subject,body,sender,addresses,(pathArray?pathArray:[NSArray array]),nil]
								   error:&errorDict];
    //  NSLog(@"%@",message);
    if (errorDict) 
        NSRunAlertPanel(@"An error occured while sending mail", [errorDict objectForKey:@"NSAppleScriptErrorMessage"], nil,nil,nil);
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


//--------------------

- (BOOL)drawIconForObject:(QSObject *)object inRect:(NSRect)rect flipped:(BOOL)flipped{
	if (![object objectForType:QSProcessType])return nil;
	
	int count=[[[self mailScript] executeSubroutine:@"unread_count"
																   arguments:nil
																	   error:nil]int32Value];
	//NSLog(@"count %d",count);
	NSImage *icon=[object icon];
	[icon setFlipped:flipped];
	NSImageRep *bestBadgeRep=[icon bestRepresentationForSize:rect.size];    
	[icon setSize:[bestBadgeRep size]];
	[icon drawInRect:rect fromRect:NSMakeRect(0,0,[bestBadgeRep size].width,[bestBadgeRep size].height) operation:NSCompositeSourceOver fraction:1.0];
	
	QSCountBadgeImage *countImage=[QSCountBadgeImage badgeForCount:count];
	
	[countImage drawBadgeForIconRect:rect];				
	
	return YES;	
}

@end
