//
//  QSMouseTriggerManager.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Sun Jun 13 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QSCore/QSTriggerManager.h>
#import "QSMouseTriggerView.h"

@interface QSMouseTriggerManager : QSTriggerManager {
    NSMutableDictionary *anchorWindows;
    NSMutableDictionary *anchorArrays;
	NSMutableArray *anywhereArray;
//	IBOutlet NSView *settingsView;
//	NSMutableDictionary *settingsSelection;
	
	IBOutlet NSView *anchorView;
    IBOutlet NSView *modifiersView;
    IBOutlet NSPopUpButton *mouseTriggerTypePopUp;
    IBOutlet NSPopUpButton *mouseTriggerScreenPopUp;
    IBOutlet NSTextField *mouseTriggerClickCountField;
    IBOutlet NSStepper *mouseTriggerClickCountStepper;
    IBOutlet NSButton *mouseTriggerDelaySwitch;
    IBOutlet NSTextField *mouseTriggerDelayField;
    IBOutlet NSButton *menuBarAnchorButton;
    IBOutlet NSButton *anywhereButton;
	IBOutlet id desktopImageView;
	
	
	id mouseTriggerObject;
}

+ (id)sharedInstance;
- (void)updateTriggerWindows;


- (NSString *)descriptionForTrigger:(NSDictionary *)dict;

- (IBAction) setMouseTriggerModifierFlag:(id)sender;
- (IBAction) setMouseTriggerAnchorMask:(id)sender;
- (IBAction) setMouseTriggerType:(id)sender;
- (IBAction) setMouseTriggerValueForSender:(id)sender;

- (void)populateInfoFields;
- (NSString *)descriptionForMouseTrigger:(NSDictionary *)dict;
- (void)handleMouseTriggerEvent:(NSEvent *)theEvent forView:(QSMouseTriggerView *)view;
- (void)handleMouseTriggerEvent:(NSEvent *)theEvent type:(int)type forView:(QSMouseTriggerView *)view;

- (id)mouseTriggerObject;
- (void)setMouseTriggerObject:(id)newMouseTriggerObject;
@end
