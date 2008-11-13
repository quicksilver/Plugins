//
//  QSMouseTriggerManager.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Sun Jun 13 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QSCore/QSTriggerManager.h>

#define kQSTriggerEvents @"QSTriggerEvents"
#define kEventTrigger @"eventTrigger"

#define QSEventNotification @"QSEventNotification"


@interface NSObject (QSEventTriggerProvider)

// Called when first trigger enabled for event
- (void)enableEventObserving:(NSString *)event;

// Called when last trigger disabled for event
- (void)disableEventObserving:(NSString *)event;

// Called when any matching triggers are enabled/disabled
- (void)addObserverForEvent:(NSString *)event trigger:(NSDictionary *)trigger;
- (void)removeObserverForEvent:(NSString *)event trigger:(NSDictionary *)trigger;


@end


@interface QSEventTriggerManager : QSTriggerManager {
	IBOutlet NSPopUpButton *eventPopUp;
	IBOutlet NSTableView *triggerObjectsTable;
	NSDictionary *triggersByEvent;
	id eventTriggerObject;
}

+ (id)sharedInstance;
- (IBAction)updateTrigger:(id)sender;
- (IBAction)setEventType:(id)sender;

-(void)handleTriggerEvent:(NSString *)event withObject:(id)object;
- (id)eventTriggerObject;
- (void)setEventTriggerObject:(id)newEventTriggerObject;
@end
