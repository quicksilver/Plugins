//
//  QSChronoTriggersPlugIn.h
//  QSChronoTriggersPlugIn
//
//  Created by Nicholas Jitkoff on 11/9/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSObject.h>
#import "QSChronoTriggersPlugIn.h"
#import <QSCore/QSTriggerManager.h>


#define kChronoRepeat			@"ChronoRepeat"
#define kChronoIgnoreMisfire	@"ChronoIgnoreMisfire"

#define kChronoUseRelative		@"ChronoUseRelative"
#define kChronoRelativeDuration	@"ChronoRelativeDuration"
#define kChronoRelativeUnit		@"ChronoRelativeUnit"

#define kChronoUseAtTime		@"ChronoUseAtTime"
#define kChronoUseAtDate		@"ChronoUseAtDate"
#define kChronoAtDate			@"ChronoAtDate"
#define kChronoAtNow			@"ChronoAtNow"

#define kChronoUseUntilTime		@"ChronoUseUntilTime"
#define kChronoUseUntilDate		@"ChronoUseUntilDate"
#define kChronoUntilDate		@"ChronoUntilDate"
#define kChronoUntilNow			@"ChronoUntilNow"


#define kChronoUseDayOfWeek		@"ChronoUseDayOfWeek"
#define kChronoDayOfWeek		@"ChronoDayOfWeek"

#define kChronoUseDayOfMonth	@"ChronoUseDayOfMonth"
#define kChronoDayOfMonth		@"ChronoDayOfMonth"

#define kChronoUseMonthOfYear	@"ChronoUseMonthOfYear"
#define kChronoMonthOfYear		@"ChronoMonthOfYear"

#define kChronoUseAppleScript	@"ChronoUseAppleScript"
#define kChronoAppleScript		@"ChronoAppleScript"

#define kTriggerLastFireDate	@"TriggerLastFireDate"

@interface QSChronoTriggerManager : QSTriggerManager{

		
	IBOutlet NSButton *repeatSwitch;
	IBOutlet NSButton *ignoreMisfireSwitch;
	
	IBOutlet NSButton *relativeCriteriaSwitch;
	IBOutlet NSTextField *relativeCriteriaField;
	IBOutlet NSPopUpButton *relativeCriteriaPopUp;
	
	
	IBOutlet NSButton *atCriteriaNowSwitch;
	
	IBOutlet NSButton *atCriteriaTimeSwitch;
	IBOutlet NSButton *untilCriteriaTimeSwitch;
	
	IBOutlet NSButton *atCriteriaDateSwitch;
	IBOutlet NSButton *untilCriteriaDateSwitch;
	
	IBOutlet NSTextField *atCriteriaTimeField;
	IBOutlet NSTextField *untilCriteriaTimeField;
	
	IBOutlet NSTextField *atCriteriaDateField;
	IBOutlet NSTextField *untilCriteriaDateField;
	
	//IBOutlet NSButton *untilCriteriaNowSwitch;
	
	
	IBOutlet NSButton *dayOfWeekCriteriaSwitch;
	IBOutlet NSSegmentedControl *dayOfWeekControl;
	
	IBOutlet NSButton *dayOfMonthCriteriaSwitch;
	IBOutlet NSTextField *dayOfMonthCriteriaField;
	
	IBOutlet NSButton *monthOfYearCriteriaSwitch;
	IBOutlet NSTextField *monthOfYearCriteriaField;
	
	IBOutlet NSButton *appleScriptCriteriaSwitch;
	IBOutlet NSTextView *appleScriptTextView;
	
	IBOutlet NSTextField *nextFireField;
	IBOutlet NSTextField *lastFireField;
	IBOutlet NSTextField *setTriggerField;
	

	}

-(IBAction)setValueForSender:(id)sender;
-(IBAction)selectPreset:(id)sender;
@end

