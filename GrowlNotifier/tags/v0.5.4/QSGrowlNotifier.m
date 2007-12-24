//
//  QSGrowlNotifier.m
//  QSGrowlNotifier
//
//  Created by Nicholas Jitkoff on 7/12/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSNotifyMediator.h>
#import "QSGrowlNotifier.h"
#import "GrowlDefines.h"
#import <GrowlAppBridge/GrowlApplicationBridge.h>

#define QSGrowlNotification			@"Quicksilver Notification"
#define QSiTunesNotification		@"iTunes Notification"

@implementation QSGrowlNotifier
NSTimeInterval interval;
+ (void)initialize{
	// Launch growl
	if (![GrowlAppBridge launchGrowlIfInstalledNotifyingTarget:self
													  selector:@selector(growlRegister:)
													   context:nil]) {
		// Growl isn't installed
		// I don't know what to do. I'll just log it
		NSLog(@"Growl notify mediator error: Growl not installed");
	}
}

+ (void)growlRegister:(void *)context {
	// Register with Growl
	NSArray			* allNotes = [NSArray arrayWithObjects:QSGrowlNotification, QSiTunesNotification,
											nil];
	NSDictionary	* regDict = [NSDictionary dictionaryWithObjectsAndKeys:
		@"Quicksilver", GROWL_APP_NAME,
		[[NSImage imageNamed:@"NSApplicationIcon"] TIFFRepresentation], GROWL_APP_ICON,
		allNotes, GROWL_NOTIFICATIONS_ALL,
		allNotes, GROWL_NOTIFICATIONS_DEFAULT,
		nil];
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:GROWL_APP_REGISTRATION
																   object:nil userInfo:regDict];
	interval=[NSDate timeIntervalSinceReferenceDate];
}

- (void) displayNotificationWithAttributes:(NSDictionary *)attributes{
	
	if (([NSDate timeIntervalSinceReferenceDate]-interval)<1.0) sleep(1);
	
	NSString *type = QSGrowlNotification;
	if ([[attributes objectForKey:QSNotifierType] isEqualToString:@"QSiTunesTrackChangeNotification"])
		type = QSiTunesNotification;
	
	NSString *text = [attributes objectForKey:QSNotifierText];
	if (!text)
		text = @"";
	
	NSDictionary *noteDict = [NSDictionary dictionaryWithObjectsAndKeys:
		type, GROWL_NOTIFICATION_NAME,
		@"Quicksilver", GROWL_APP_NAME,
		[attributes objectForKey:QSNotifierTitle], GROWL_NOTIFICATION_TITLE,
		text, GROWL_NOTIFICATION_DESCRIPTION,
		[[NSApp applicationIconImage] TIFFRepresentation], GROWL_NOTIFICATION_APP_ICON,
		[[attributes objectForKey:QSNotifierIcon] TIFFRepresentation], GROWL_NOTIFICATION_ICON,
		nil];
	
	[[NSDistributedNotificationCenter defaultCenter] postNotificationName:GROWL_NOTIFICATION
																   object:nil userInfo:noteDict];
				
}

@end