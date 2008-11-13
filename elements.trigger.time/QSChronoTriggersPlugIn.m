//
//  QSChronoTriggersPlugIn.m
//  QSChronoTriggersPlugIn
//
//  Created by Nicholas Jitkoff on 11/9/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSChronoTriggersPlugIn.h"
//#import <QSCore/QSTriggerCenter.h>
#import <QSFoundation/NSArray_BLTRExtensions.h>

#define kItemID @"ID"
@interface NSDate (CalendarDateConvenience)
- (NSCalendarDate *)calendarDate;
- (NSDate *)dateByCombiningDate:(NSDate *)date withTime:(NSDate *)time;
@end

@implementation NSDate (CalendarDateConvenience)
- (NSCalendarDate *)calendarDate{
	if ([self isKindOfClass:[NSCalendarDate class]])return self;
	return [NSCalendarDate dateWithTimeIntervalSinceReferenceDate:[self timeIntervalSinceReferenceDate]];	
}

+ (NSDate *)dateByCombiningDate:(NSDate *)date withTime:(NSDate *)time{
	date=[date calendarDate];
	if (!date) date=[NSCalendarDate date];
	time=[time calendarDate];
	if (!time) time=[NSCalendarDate date];
	
	
	return [NSCalendarDate dateWithYear:[date yearOfCommonEra]
								  month:[date monthOfYear]
									day:[date dayOfMonth]
								   hour:[time hourOfDay]
								 minute:[time minuteOfHour]
								 second:[time secondOfMinute]
							   timeZone:[time timeZone]];
}
@end

@implementation QSChronoTriggerManager
+(void)initialize{
	[self setKeys:[NSArray arrayWithObjects: @"currentTrigger", @"currentTrigger.info.ChronoRepeat", nil]
triggerChangeNotificationsForDependentKey: 
		@"ChronoUseRelativeTitle"];
	
}
-(NSString *)name{
	return @"Time";
}
-(NSImage *)image{
	NSImage *image= [[[NSImage imageNamed:@"Recent"]copy]autorelease];
	[image setSize:NSMakeSize(16,16)];
	return image;
}

-(NSString *)descriptionForTrigger:(NSDictionary *)trigger{
	return @"Time";
}


- (NSView *) settingsView{
    if (!settingsView){
        [NSBundle loadNibNamed:@"QSChronoTrigger" owner:self];		
	}
	//	NSLog(@"sview %@",settingsView);
    return [[settingsView retain] autorelease];
}



-(void)initializeTrigger:(NSDictionary *)trigger{
	
}



-(BOOL)triggerHotKey:(NSString *)triggerID{
	return [[NSClassFromString(@"QSTriggerCenter") sharedInstance] executeTriggerID:triggerID];
}

-(BOOL)enableTrigger:(NSDictionary *)entry{
//	NSLog(@"entry %@",entry);
	[self nextFireDateForTrigger:entry afterDate:[NSDate date]];
    return YES;
}

-(BOOL)disableTrigger:(NSDictionary *)entry{
    NSString *theID=[entry objectForKey:kItemID];
	
    return YES;
}


-(NSDate *)nextFireDateForTrigger:(NSDictionary *)trigger afterDate:(NSDate *)lastFire{
	
	NSDictionary *selection=[self settings];
	NSCalendarDate *baseDate=[NSCalendarDate date];
	
	NSArray *months=nil;
	NSArray *daysOfMonth=nil;
	NSArray *daysOfWeek=nil;
	
	int fireMinute=[baseDate minuteOfHour];
	int fireHour=[baseDate hourOfDay];
	int fireDay=[baseDate dayOfMonth];
	int fireMonth=[baseDate monthOfYear];
	int fireYear=[baseDate yearOfCommonEra];
	
	NSArray *filterDayOfMonth=nil;
	NSArray *filterDayOfWeek=nil;
	NSArray *filterMonthOfYear=nil;
	
	NSMutableArray *fireDates=[NSMutableArray array];
	
	if([[selection objectForKey:kChronoUseMonthOfYear]boolValue]){
		filterMonthOfYear=[selection objectForKey:kChronoMonthOfYear];
	}
	if([[selection objectForKey:kChronoUseDayOfMonth]boolValue]){
		filterDayOfMonth=[selection objectForKey:kChronoDayOfMonth];
	}
	if ([[selection objectForKey:kChronoUseDayOfWeek]boolValue]){
		filterDayOfWeek=[selection objectForKey:kChronoDayOfWeek];
	}
	
	BOOL repeat=[[selection objectForKey:kChronoRepeat]boolValue];
	
	

	
	//[[selection objectForKey:kChronoIgnoreMisfire]boolValue];
	BOOL useRelative=[[selection objectForKey:kChronoUseRelative]boolValue];
	float relativeOffset=0;
	
	if (1){
		float relativeOffset=[[selection objectForKey:kChronoRelativeDuration]floatValue];
		int duration=1;
		switch([[selection objectForKey:kChronoRelativeUnit]intValue]){
			case 5: duration*=7;
			case 4: duration*=24;
			case 3: duration*=60;
			case 2: duration*=60;
			default: break;
		}
		relativeOffset=relativeOffset*duration;
		//NSLog(@"relative %fs",relativeOffset);
				
	}
	
	if ([[selection objectForKey:kChronoUseAtTime]boolValue]){
		NSDate *atDate=[selection objectForKey:kChronoAtDate];
		
	}
	if ([[selection objectForKey:kChronoUseUntilTime]boolValue]){
		NSDate *untilDate=[selection objectForKey:kChronoUntilDate];
	}
	
	
	
	if (!repeat){
		if (relativeOffset){
		return [baseDate addTimeInterval:relativeOffset];
		}else{
			NSDate *atDate=[selection objectForKey:kChronoAtDate];
			return atDate;
		}
		
	}
	
	
	if([[selection objectForKey:kChronoUseAppleScript]boolValue]){
		[selection objectForKey:kChronoAppleScript];
	}
	
	//NSLog
	return [NSDate dateWithTimeIntervalSinceNow:20.0];
}



-(void)populateInfoFields{
	
	
	NSDictionary *selection=[self settings];
	
	BOOL repeat=[[selection objectForKey:kChronoRepeat]boolValue];
	BOOL useRelative=[[selection objectForKey:kChronoUseRelative]boolValue];
	BOOL useAtTime=[[selection objectForKey:kChronoUseAtTime]boolValue];
	BOOL useUntilTime=[[selection objectForKey:kChronoUseUntilTime]boolValue];
	BOOL useAtDate=[[selection objectForKey:kChronoUseAtDate]boolValue];
	BOOL useUntilDate=[[selection objectForKey:kChronoUseUntilDate]boolValue];
	BOOL useDayOfWeek=[[selection objectForKey:kChronoUseDayOfWeek]boolValue];
	BOOL useDayOfMonth=[[selection objectForKey:kChronoUseDayOfMonth]boolValue];
	BOOL useMonthOfYear=[[selection objectForKey:kChronoUseMonthOfYear]boolValue];
	BOOL useAppleScript=[[selection objectForKey:kChronoUseAppleScript]boolValue];
	
	int relativeUnit=[[selection objectForKey:kChronoRelativeUnit]intValue];
	if (!relativeUnit)relativeUnit=2; //Default to minutes
									  //Rules
	
	BOOL dayOrWeekRelative=useRelative && relativeUnit>3;
	BOOL forceNow=NO;
	BOOL enableAtDate=YES;
	BOOL enableUntil=NO;
	BOOL oneDayAWeek=NO;
	BOOL enableDaySpecifiers=YES;
	BOOL relativeOnly=!repeat && useRelative;
	
	
	
	if (!repeat && useRelative && !useAtTime)  //	Relative - repeat - From >> checks now
		forceNow=YES;
	
	if (relativeOnly){  //	Relative - repeat >> hides day specifier
		enableDaySpecifiers=NO;
	}
	if (dayOrWeekRelative)//	Relative + DW >> disables day specifier
		enableDaySpecifiers=NO; 
	
	if (repeat && useRelative)  //	Relative - Once >> Enables Until
		enableUntil=YES;
	
	if (repeat && !useRelative)
		enableAtDate=NO;
	
	if (useAtDate && !(useRelative && useUntilDate))
		enableDaySpecifiers=NO;
	
	//if (dayOrWeekRelative && (useDayOfWeek || useDayOfMonth || useMonthOfYear))enableAtDate=NO;
	//	At + Day Specifier >> hides date
	
	
	
	
	if (dayOrWeekRelative || !enableDaySpecifiers){
		useDayOfWeek=NO;
		useDayOfMonth=NO;
		useMonthOfYear=NO;
		
	}
	BOOL dayIsSpecified=useDayOfWeek || useDayOfMonth || useMonthOfYear;
	//NSLog(@"ATdate:%d",enableAtDate);
	
	BOOL enableTimeRange=!relativeOnly && useRelative && useAtTime && !dayOrWeekRelative;
	BOOL enableDateRange=!relativeOnly && useRelative && useAtDate;	
	
	BOOL alternateFromTimeTitle=useRelative&&!dayOrWeekRelative;
	BOOL alternateFromDateTitle=(useRelative && dayOrWeekRelative)||(enableDateRange && useUntilDate);
	
	oneDayAWeek=useDayOfMonth||!repeat; // Single instances required in these cases
	
	[repeatSwitch setState:repeat];
	
	[relativeCriteriaSwitch setTitle:repeat?@"Every":@"In"];
	
	[atCriteriaTimeSwitch setTitle:alternateFromTimeTitle&&!relativeOnly?@"From":@"At"];
	[atCriteriaDateSwitch setTitle:alternateFromDateTitle&&!relativeOnly?@"From":@"On"];
	
#warning day of month should become "Thurs of month" with one selected and become disabled when more than one is selected
#warning at+on should suppress day specifiers
	
	
	
	[untilCriteriaTimeSwitch setHidden:!enableTimeRange];
	[untilCriteriaDateSwitch setHidden:!enableDateRange];
	[untilCriteriaTimeField setHidden:!enableTimeRange];
	[untilCriteriaDateField setHidden:!enableDateRange];
	
	[ignoreMisfireSwitch setObjectValue:[selection objectForKey:kChronoIgnoreMisfire]];
	
	
	[relativeCriteriaSwitch setState:useRelative];
	[relativeCriteriaField setEnabled:useRelative];
	[relativeCriteriaPopUp setEnabled:useRelative];
	[relativeCriteriaField setObjectValue:[selection objectForKey:kChronoRelativeDuration]];
	[relativeCriteriaPopUp selectItemAtIndex:[relativeCriteriaPopUp indexOfItemWithTag:relativeUnit]];
	
	//Always Enabled
	
	useAtTime=useAtTime && !relativeOnly;
	[atCriteriaTimeSwitch setEnabled:!relativeOnly];
	[atCriteriaTimeSwitch setState:useAtTime];
	[atCriteriaTimeField setObjectValue:useAtTime?[selection objectForKey:kChronoAtDate]:@""];
	[atCriteriaTimeField setEnabled:useAtTime];
	
	useAtDate=useAtDate && !relativeOnly;
	[atCriteriaDateSwitch setEnabled:!relativeOnly && enableAtDate];
	[atCriteriaDateSwitch setState:useAtDate];
	[atCriteriaDateField setEnabled:useAtDate && enableAtDate];
	[atCriteriaDateField setObjectValue:useAtDate&&enableAtDate?[selection objectForKey:kChronoAtDate]:@""];
	
	//[atCriteriaNowSwitch setEnabled:useAtDate ];
	//[atCriteriaNowSwitch setState:forceNow || [[selection objectForKey:kChronoAtNow]boolValue]];
	
	useUntilTime=useUntilTime && enableUntil;
	[untilCriteriaTimeSwitch setState:useUntilTime];
	[untilCriteriaTimeSwitch setEnabled:enableUntil];
	[untilCriteriaDateSwitch setState:useUntilDate];
	[untilCriteriaDateSwitch setEnabled:enableUntil];
	
	[untilCriteriaTimeField setEnabled:useUntilTime];
	[untilCriteriaDateField setEnabled:useUntilDate];
	//	[untilCriteriaNowSwitch setEnabled:useUntil];
	[untilCriteriaTimeField setObjectValue:[selection objectForKey:kChronoUntilDate]];
	[untilCriteriaDateField setObjectValue:[selection objectForKey:kChronoUntilDate]];
	//	[untilCriteriaNowSwitch setObjectValue:[selection objectForKey:kChronoUntilNow]];
	
	
	
	
	[dayOfWeekCriteriaSwitch setState:useDayOfWeek];
	[dayOfWeekCriteriaSwitch setEnabled:enableDaySpecifiers];
	
	//[dayOfWeekControl setTrackingMode:oneDayAWeek?NSSegmentSwitchTrackingSelectOne:NSSegmentSwitchTrackingSelectAny];
	
	NSArray *weekDayArray=[selection objectForKey:kChronoDayOfWeek];
	int i;
	for (i=0;i<7;i++){
		[dayOfWeekControl setSelected:[weekDayArray containsObject:[NSNumber numberWithInt:i]] forSegment:i];
		[dayOfWeekControl setEnabled:useDayOfWeek forSegment:i];
	}
	
	[dayOfMonthCriteriaSwitch setState:useDayOfMonth];
	[dayOfMonthCriteriaSwitch setEnabled:enableDaySpecifiers];
	[dayOfMonthCriteriaField setEnabled:useDayOfMonth];
	NSArray *dayOfMonthArray=[selection objectForKey:kChronoDayOfMonth];
	[dayOfMonthCriteriaField setObjectValue:[dayOfMonthArray componentsJoinedByString:@", "]];
	
	
	[monthOfYearCriteriaSwitch setState:useMonthOfYear];
	[monthOfYearCriteriaSwitch setEnabled:enableDaySpecifiers];
	[monthOfYearCriteriaField setEnabled:useMonthOfYear];
	
	NSArray *monthOfYearArray=[selection objectForKey:kChronoMonthOfYear];
	[monthOfYearCriteriaField setObjectValue:[monthOfYearArray componentsJoinedByString:@", "]];
	
	
	
	
	
	[appleScriptCriteriaSwitch setState:useAppleScript];
	[appleScriptTextView setHidden:!useAppleScript];
	//[appleScriptTextView setString:[selection objectForKey:kChronoAppleScript]];
	
	
	[setTriggerField setObjectValue:[NSDate date]];
	[lastFireField setObjectValue:[selection objectForKey:kTriggerLastFireDate]];
	[nextFireField setObjectValue:[self nextFireDateForTrigger:selection afterDate:nil]];

	
}

-(NSString *)ChronoUseRelativeTitle{
	if ([[currentTrigger valueForKeyPath:@"info.ChronoRepeat"]boolValue])
		return @"Every";
	return @"In";
	
}




-(IBAction)setValueForSender:(id)sender{
	NSControl *nextResponder=nil;

	NSMutableDictionary *settings=[self settings];
	if ( sender==repeatSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoRepeat];
	} else if ( sender==ignoreMisfireSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoIgnoreMisfire];
		
	} else if ( sender==relativeCriteriaSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseRelative];
		
		if (![settings objectForKey:kChronoRelativeUnit]) // Default to minutes
			[settings setObject:[NSNumber numberWithInt:2] forKey:kChronoRelativeUnit];
		nextResponder=relativeCriteriaField;
	} else if ( sender==relativeCriteriaField ){
		[settings setObject:[sender objectValue] forKey:kChronoRelativeDuration];
	} else if ( sender==relativeCriteriaPopUp ){
		[settings setObject:[NSNumber numberWithInt:[[sender selectedItem]tag]] forKey:kChronoRelativeUnit];
	} else if ( sender==atCriteriaTimeSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseAtTime];
		if ([sender state]) nextResponder=atCriteriaTimeField;
		
	} else if ( sender==atCriteriaDateSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseAtDate];
		if ([sender state]) nextResponder=atCriteriaDateField;
		
	} else if ( sender==atCriteriaTimeField ){
		NSDate *date=[NSDate dateByCombiningDate:[settings objectForKey:kChronoAtDate]
										withTime:[sender objectValue]];
		[settings setObject:date forKey:kChronoAtDate];

	} else if ( sender==atCriteriaDateField ){
		NSDate *date=[NSDate dateByCombiningDate:[sender objectValue]
										withTime:[settings objectForKey:kChronoAtDate]];
		[settings setObject:date forKey:kChronoAtDate];
	} else if ( sender==atCriteriaNowSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoAtNow];
		
	} else if ( sender==untilCriteriaTimeSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseUntilTime];
		nextResponder=untilCriteriaTimeField;
	} else if ( sender==untilCriteriaDateSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseUntilDate];
		nextResponder=atCriteriaDateField;
	} else if ( sender==untilCriteriaTimeField ){
		NSDate *date=[NSDate dateByCombiningDate:[settings objectForKey:kChronoUntilDate]
										withTime:[sender objectValue]];
		[settings setObject:date forKey:kChronoUntilDate];
	} else if ( sender==untilCriteriaDateField ){
		NSDate *date=[NSDate dateByCombiningDate:[sender objectValue]
										withTime:[settings objectForKey:kChronoUntilDate]];
		[settings setObject:date forKey:kChronoUntilDate];
	} else if ( sender==dayOfWeekCriteriaSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseDayOfWeek];
		nextResponder=dayOfWeekControl;
	} else if ( sender==dayOfWeekControl ){
		NSMutableArray *array=[[[settings objectForKey:kChronoDayOfWeek]mutableCopy]autorelease];
		if (![array isKindOfClass:[NSArray class]])array=nil;
		if (!array)array=[NSMutableArray array];
		if ([array containsObject:[sender objectValue]])
			[array removeObject:[sender objectValue]];
		else
			[array addObject:[sender objectValue]];
		
		NSLog(@"dWeek,%@, %@",[sender objectValue],array);
		
		[settings setObject:array forKey:kChronoDayOfWeek];
		
	} else if ( sender==dayOfMonthCriteriaSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseDayOfMonth];
		nextResponder=dayOfMonthCriteriaField;
	} else if ( sender==dayOfMonthCriteriaField ){
		NSArray *array=[[sender objectValue]componentsSeparatedByString:@","];
		array=[array arrayByPerformingSelector:@selector(stringByTrimmingCharactersInSet:) withObject:[NSCharacterSet whitespaceCharacterSet]];
		[settings setObject:array forKey:kChronoDayOfMonth];
		
	} else if ( sender==monthOfYearCriteriaSwitch ){
		[settings setObject:[sender objectValue] forKey:kChronoUseMonthOfYear];
		nextResponder=monthOfYearCriteriaField;
	} else if ( sender==monthOfYearCriteriaField ){
		NSArray *array=[[sender objectValue]componentsSeparatedByString:@","];
		array=[array arrayByPerformingSelector:@selector(stringByTrimmingCharactersInSet:) withObject:[NSCharacterSet whitespaceCharacterSet]];
		[settings setObject:array forKey:kChronoMonthOfYear];
		
		
	} else if ( sender==appleScriptCriteriaSwitch ){
		nextResponder=untilCriteriaTimeField;
		[settings setObject:[sender objectValue] forKey:kChronoUseAppleScript];
		
	} else if ( sender==appleScriptTextView ){
		[settings setObject:[sender objectValue] forKey:kChronoAppleScript];
	}
	
	[[sender window] endEditingFor:nil];	//Force text fields to end editing

	[self populateInfoFields];
	if (nextResponder){
//		[[nextResponder window]display];
//		NSLog(@"responder %@ %@",nextResponder,[nextResponder objectValue]);
//		[[nextResponder window]makeFirstResponder:nextResponder];
		
		[[nextResponder window]performSelector:@selector(makeFirstResponder:) withObject:nextResponder afterDelay:0.0];
	}
}

-(IBAction)selectPreset:(id)sender{
	
}
-(IBAction)reloadTrigger:(id)sender{
	
}




@end


@interface QSChronoTriggerManager (Settings)
@end
@implementation QSChronoTriggerManager (Settings)


- (NSMutableDictionary *)settings{return currentTrigger;}

- (NSString *)useDayOfMonth{ }

- (NSString *)dayOfMonth{}
- (NSString *)setDayOfMonth{}



@end
