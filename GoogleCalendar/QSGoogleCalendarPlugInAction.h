//
//  QSGoogleCalendarPlugInAction.h
//  QSGoogleCalendarPlugIn
//
//  Created by Nicholas Jitkoff on 4/30/06.
//  Copyright __MyCompanyName__ 2006. All rights reserved.
//

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>

@interface QSGoogleCalendarPlugInAction : NSObject{
	NSString *auth;	
	IBOutlet NSPanel *loginPanel;
	IBOutlet NSTextField *loginField;
	IBOutlet NSTextField *passField;
	
	IBOutlet NSProgressIndicator *indicator;
}
- (IBAction)endPanel:(id)sender;
@end

