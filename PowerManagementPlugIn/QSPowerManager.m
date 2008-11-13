//
//  QSPowerManager.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 7/14/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSPowerManager.h"

id QSPM=nil;

@implementation QSPowerManager
+ (id)sharedInstance{
    if (!QSPM) QSPM = [[[self class] allocWithZone:[self zone]] init];
    return QSPM;
}
- (id) init {
	self = [super init];
	if (self != nil) {
		[[[NSWorkspace sharedWorkspace]notificationCenter]addObserver:self
															  selector:@selector(systemWoke:)
																  name:NSWorkspaceDidWakeNotification
																object:nil];
	}
	return self;
}
- (void)systemWoke:(NSNotification *)notif{
	NSLog(@"woke");	
}

//pmset schedule [cancel] <type> <date/time> [owner]
- (id)listEvents{
	
    NSLog(@"Scheduled Events%@",IOPMCopyScheduledPowerEvents()); 
	return nil;
}

- (void)scheduleEvent:(NSString *)type date:(NSDate *)date owner:(NSString *)owner{
	if (![self isAuthorized])[self setAuthorized:YES];
	NSArray *arguments=[NSArray arrayWithObjects:@"schedule", type,[date descriptionWithCalendarFormat:@"%m/%d/%y %H:%M:%S" timeZone:nil locale:nil],owner,nil];
	//arguments=[NSArray arrayWithObjects:@"repeat", @"cancel",nil];
	
	NSTask *task=[NSTask taskWithLaunchPath:[self toolPath] arguments:arguments];
	NSLog(@"Sch: %@ '%@'",arguments,[[NSString alloc]initWithData:[task launchAndReturnOutput] encoding:NSUTF8StringEncoding]);
	//[self cancelEvent:type date:date owner:owner];
}
- (void)cancelEvent:(NSString *)type date:(NSDate *)date owner:(NSString *)owner{
	if (![self isAuthorized])[self setAuthorized:YES];
	NSArray *arguments=[NSArray arrayWithObjects:@"schedule",@"cancel", type,[date descriptionWithCalendarFormat:@"%m/%d/%y %H:%M:%S" timeZone:nil locale:nil],owner,nil];
	NSTask *task=[NSTask taskWithLaunchPath:[self toolPath] arguments:arguments];
	NSLog(@"Des: %@ '%@'",arguments,[[NSString alloc]initWithData:[task launchAndReturnOutput] encoding:NSUTF8StringEncoding]);
	
}
- (NSString *)toolPath{
	return [[NSBundle bundleForClass:[self class]]pathForResource:@"qspmset" ofType:@""];
}
- (BOOL)isAuthorized{
	unsigned long perms=[[[[NSFileManager defaultManager]fileAttributesAtPath:[self toolPath] traverseLink:NO]valueForKey:NSFilePosixPermissions]unsignedLongValue];
	perms=perms&1<<11;
	//NSLog(@"authorized %d",perms);
	return (perms!=0);
}
- (void)setAuthorized:(BOOL)authorized{
	
	OSStatus myStatus;
	AuthorizationItem myAuthorizationExecuteRight = {kAuthorizationRightExecute, 0, NULL, 0};
	AuthorizationRights myAuthorizationRights = {1, &myAuthorizationExecuteRight};
 	char *prompt="Authentication is required to allow alarms to power-on the system. This will give Quicksilver access to energy saver settings.\n\n";
	char *icon="/System/Library/PreferencePanes/EnergySaver.prefPane/Contents/Resources/EnergySaver.icns";
	AuthorizationItem kAuthEnv[] = {
	{ kAuthorizationEnvironmentPrompt, strlen(prompt), prompt, 0},
	{ kAuthorizationEnvironmentIcon, strlen(icon), icon, 0 } };
	
    AuthorizationEnvironment myAuthorizationEnvironment = { 2, kAuthEnv };
	
	AuthorizationRef myAuthorizationRef = NULL;
	
	AuthorizationFlags myFlags = kAuthorizationFlagDefaults;    
	myFlags = kAuthorizationFlagDefaults |           //8
		kAuthorizationFlagInteractionAllowed |           //9
		kAuthorizationFlagPreAuthorize |         //10
		kAuthorizationFlagExtendRights;         //11
	SFAuthorization *auth=[SFAuthorization authorizationWithFlags:myFlags rights:&myAuthorizationRights environment:&myAuthorizationEnvironment];
	FILE *myCommunicationsPipe = NULL;
	char myReadBuffer[128];
	//AuthorizationFlags myFlags = kAuthorizationFlagDefaults;    
	//13
	
	char *myOtherArguments[]  = {authorized?"4555":"555",[[self toolPath]UTF8String], NULL };
	myStatus = AuthorizationExecuteWithPrivileges(
												  [auth authorizationRef], "/bin/chmod", kAuthorizationFlagDefaults, &myOtherArguments,          //15
												  &myCommunicationsPipe);         //16

	char *myArguments[] = {authorized?"root":[[NSString stringWithFormat:@"%d",getuid()]UTF8String],[[self toolPath]UTF8String], NULL };
	myStatus = AuthorizationExecuteWithPrivileges(
												  [auth authorizationRef], "/usr/sbin/chown", kAuthorizationFlagDefaults, &myArguments,          //15
												  &myCommunicationsPipe);         //16
	
		//NSLog(@"status %d",myStatus);
	if (myStatus == errAuthorizationSuccess){
		for(;;)
		{
			int bytesRead = read (fileno (myCommunicationsPipe),
								  myReadBuffer, sizeof (myReadBuffer));
			if (bytesRead < 1) break;
			write (fileno (stdout), myReadBuffer, bytesRead);
		}
	}		
	
}

@end
