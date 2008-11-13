//
//  QSSurveyPlugIn.h
//  QSSurveyPlugIn
//
//  Created by Nicholas Jitkoff on 10/11/07.
//  Copyright Blacktree Inc 2007. All rights reserved.
//

#import <QSCore/QSObject.h>

@interface QSSurveyPlugIn : NSObject {
  IBOutlet NSWindow *surveyRequestWindow;
  IBOutlet id progessWindow;
  
  IBOutlet NSProgressIndicator *progressIndicator;
  IBOutlet NSTextField *progressLabel;
  IBOutlet NSButton *doneButton;
  NSString *uuid;
}
- (IBAction)decline:(id)sender;
- (IBAction)accept:(id)sender;
@end

