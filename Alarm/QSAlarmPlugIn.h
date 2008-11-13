//
//  QSAlarmPlugIn.h
//  QSAlarmPlugIn
//
//  Created by Nicholas Jitkoff on 7/11/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <QSCore/QSObject.h>
#import "QSAlarmPlugIn.h"

@interface QSAlarmPlugIn : NSWindowController
{
	//IBOutlet NSImageView *imageView;
	
	IBOutlet NSTextField *snoozeField;
	IBOutlet NSTextView *textView;

	IBOutlet NSTextField *objectTitleField;
	IBOutlet NSView *objectView;
	
	IBOutlet NSTextField *commandNameField;
	IBOutlet NSView *commandObjectView;
	IBOutlet NSTabView *alarmTabView;
}
- (IBAction)run:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)snooze:(id)sender;
@end