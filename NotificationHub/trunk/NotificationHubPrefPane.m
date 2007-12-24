//
//  NotificationHubPrefPane.m
//  NotificationHub
//
//  Created by Kevin Ballard on 3/28/05.
//  Copyright 2005 Kevin Ballard. All rights reserved.
//

#import "NotificationHubPrefPane.h"
#import <QSCore/QSRegistry.h>
#import <QSCore/QSResourceManager.h>
#import <QSCore/QSNotifyMediator.h>
#import <QSFoundation/NSBundle_BLTRExtensions.h>
#import "Preferences.h"

@implementation NotificationHubPrefPane
- (id) init {
	if (self = [super init]) {
		notifications = [[NSArray alloc] initWithObjects:
			@"QSiTunesTrackChangeNotification", @"QSCalculatorResultNotification",
			@"QSPlugInInstalledNotification", nil];
		notifiers = nil;
		
		NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
			@"com.blacktree.quicksilver", kNotificationHubDefault,
			[NSArray array], kNotificationHub,
			nil];
		[[NSUserDefaults standardUserDefaults] registerDefaults:dict];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotifications:) name:@"NotificationHub Notification" object:nil];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pluginLoaded:) name:QSPlugInLoadedNotification object:nil];
	}
	return self;
}

- (void) dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[notifications release];
	[notifiers release];
	
	[super dealloc];
}

- (void) reloadHelpersList {
	NSMenu *menu = [self notifierMenuWithSelector:@selector(setDefaultNotifier:)];
	[defaultPopup setMenu:menu];
	NSEnumerator *e = [[menu itemArray] objectEnumerator];
	NSMenuItem *item;
	NSString *target = [[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHubDefault];
	while (item = [e nextObject]) {
		if ([[item representedObject] isEqualToString:target]) {
			[defaultPopup selectItem:item];
			target = nil;
			break;
		}
	}
	if (target != nil)
		[defaultPopup selectItem:nil];
	
	menu = [self notifierMenuWithSelector:NULL];
	NSTableColumn *notifierColumn = [tableView tableColumnWithIdentifier:@"notifier"];
	[(NSPopUpButtonCell *)[notifierColumn dataCell] setMenu:menu];
	
	[notifiers release];
	notifiers = [[[self notifiers] valueForKey:@"id"] retain];
}

- (void) pluginLoaded:(NSNotification *)aNotification {
	[self reloadHelpersList];
}

- (void) awakeFromNib {
	[self reloadHelpersList];
}

- (NSString *) mainNibName {
	return @"NotificationHubPrefPane";
}

- (NSArray *) notifiers {
	NSDictionary *notifierTable = [QSReg tableNamed:kQSNotifiers];
	NSMutableArray *notifs = [NSMutableArray arrayWithCapacity:[notifierTable count] - 1];
	NSEnumerator *e = [notifierTable keyEnumerator];
	NSString *notifier;
	while (notifier = [e nextObject]) {
		if ([notifier isEqualToString:@"com.blacktree.quicksilver.notificationhub"])
			continue;
		NSString *class = [notifierTable objectForKey:notifier];
		NSBundle *bundle = [QSReg bundleForClassName:class];
		NSString *title = [bundle safeLocalizedStringForKey:class value:@"" table:nil];
		if (![title length]) {
			NSString *path = [[NSWorkspace sharedWorkspace] absolutePathForAppBundleWithIdentifier:notifier];
			bundle = [NSBundle bundleWithPath:path];
			title = [bundle objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
			
			if (!title) {
				title =[[NSFileManager defaultManager] displayNameAtPath:[bundle bundlePath]];
			}
		}
		NSDictionary *entry = [NSDictionary dictionaryWithObjectsAndKeys:
			notifier, @"id", class, @"class", title, @"title", nil];
		[notifs addObject:entry];
	}
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
	[notifs sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
	[sortDescriptor release];
	return notifs;
}

- (NSMenu *) notifierMenuWithSelector:(SEL)aSelector {
	NSArray *notifs = [self notifiers];
	NSWorkspace *ws = [NSWorkspace sharedWorkspace];
	NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Notifiers"] autorelease];
	NSEnumerator *e = [notifs objectEnumerator];
	NSDictionary *dict;
	while (dict = [e nextObject]) {
		NSString *title = [dict objectForKey:@"title"];
		NSString *bundleID = [dict objectForKey:@"id"];
		NSMenuItem *item = [[[NSMenuItem alloc] initWithTitle:title action:aSelector keyEquivalent:@""] autorelease];
		if (aSelector) [item setTarget:self];
		[item setRepresentedObject:bundleID];
		if ([bundleID hasPrefix:@"com.blacktree.quicksilver."])
			bundleID = @"com.blacktree.quicksilver";
		NSImage *icon = [ws iconForFile:[ws absolutePathForAppBundleWithIdentifier:bundleID]];
		[icon setSize:NSMakeSize(16.0,16.0)];
		[item setImage:icon];
		[menu addItem:item];
	}
	return menu;
}

- (IBAction) addRow:(id)sender {
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		@"Change Me", @"notification",
		@"com.blacktree.quicksilver", @"notifier",
		nil];
	NSArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHub];
	if (array == nil)
		array = [NSArray array];
	array = [array arrayByAddingObject:dict];
	[[NSUserDefaults standardUserDefaults] setObject:array forKey:kNotificationHub];
	[tableView noteNumberOfRowsChanged];
}

- (IBAction) removeRow:(id)sender {
	if ([tableView selectedRow] == -1) {
		NSBeep();
	} else {
		NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHub] mutableCopy];
		[array removeObjectAtIndex:[tableView selectedRow]];
		[[NSUserDefaults standardUserDefaults] setObject:array forKey:kNotificationHub];
		[tableView reloadData];
	}
}

- (IBAction) setDefaultNotifier:(id)sender {
	[[NSUserDefaults standardUserDefaults] setObject:[sender representedObject]
											  forKey:kNotificationHubDefault];
}

- (void) updateNotifications:(NSNotification *)aNotification {
	NSString *notif = [[aNotification userInfo] objectForKey:@"notification"];
	if (![notifications containsObject:notif]) {
		NSArray *temp = notifications;
		notifications = [[notifications arrayByAddingObject:notif] retain];
		[temp release];
		
		[[[tableView tableColumnWithIdentifier:@"notification"] dataCell] noteNumberOfItemsChanged];
	}
}

#pragma mark -
#pragma mark NSTableView DataSource

- (int)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHub] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
	NSDictionary *dict = [[[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHub] objectAtIndex:rowIndex];
	if ([[aTableColumn identifier] isEqualToString:@"notifier"]) {
		return [NSNumber numberWithInt:[notifiers indexOfObject:[dict objectForKey:@"notifier"]]];
	} else {
		return [dict objectForKey:[aTableColumn identifier]];
	}
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex {
	NSMutableArray *array = [[[NSUserDefaults standardUserDefaults] objectForKey:kNotificationHub] mutableCopy];
	NSMutableDictionary *dict = [[array objectAtIndex:rowIndex] mutableCopy];
	if ([[aTableColumn identifier] isEqualToString:@"notifier"]) {
		if ([anObject intValue] == -1)
			return;
		[dict setObject:[notifiers objectAtIndex:[anObject intValue]] forKey:@"notifier"];
	} else {
		[dict setObject:anObject forKey:[aTableColumn identifier]];
	}
	[array replaceObjectAtIndex:rowIndex withObject:dict];
	[[NSUserDefaults standardUserDefaults] setObject:array forKey:kNotificationHub];
}

#pragma mark -
#pragma mark NSTableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification {
	if ([tableView selectedRow] == -1) {
		[deleteButton setEnabled:NO];
	} else {
		[deleteButton setEnabled:YES];
	}
}

#pragma mark -
#pragma mark ComboBoxCell DataSource

- (int)numberOfItemsInComboBoxCell:(NSComboBoxCell *)aComboBoxCell {
	return [notifications count];
}

- (id)comboBoxCell:(NSComboBoxCell *)aComboBoxCell objectValueForItemAtIndex:(int)index {
	return [notifications objectAtIndex:index];
}
@end
