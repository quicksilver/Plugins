//
//  NotificationHub.m
//  NotificationHub
//
//  Created by Kevin Ballard on 3/28/05.
//  Copyright Kevin Ballard 2005. All rights reserved.
//

#import "NotificationHub.h"
#import "Preferences.h"
#import <QSCore/QSNotifyMediator.h>
#import <QSCore/QSRegistry.h>

@implementation NotificationHub
- (void) displayNotificationWithAttributes:(NSDictionary *)attributes {
	NSString *type = [attributes objectForKey:QSNotifierType];
	NSArray *notifs = [[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHub];
	NSString *defaultNotif = [[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHubDefault];
	NSEnumerator *e = [notifs objectEnumerator];
	NSDictionary *item;
	BOOL hasNotified = NO;
	if (type != nil && [type length] > 0) {
		while (item = [e nextObject]) {
			if ([[item objectForKey:@"notification"] isEqualToString:type]) {
				id <QSNotifier> notifier = [QSReg instanceForKey:[item objectForKey:@"notifier"] inTable:kQSNotifiers];
				if ([(NSObject *)notifier isKindOfClass:[self class]]) {
					NSLog(@"Invalid Notifier Hub entry: %@", item);
				} else {
					[notifier displayNotificationWithAttributes:attributes];
					hasNotified = YES;
				}
			}
		}
	}
	if (!hasNotified) {
		id <QSNotifier> notifier = [QSReg instanceForKey:defaultNotif inTable:kQSNotifiers];
		if ([(NSObject *)notifier isKindOfClass:[self class]]) {
			NSLog(@"Invalid Default Notifier");
			notifier = [QSReg instanceForKey:@"com.blacktree.quicksilver" inTable:kQSNotifiers];
		}
		[notifier displayNotificationWithAttributes:attributes];
	}
	
	if (type != nil)
		[[NSNotificationCenter defaultCenter] postNotificationName:@"NotificationHub Notification" object:self userInfo:[NSDictionary dictionaryWithObject:type forKey:@"notification"]];
}
@end
