//
//  NSDate+Calendaring.m
//  QSCalendarSupport
//
//  Created by Brian Donovan on 31/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Calendaring.h"


@implementation NSCalendarDate (VCalendar)

+ (id)dateWithVFileDateProperty:(VFileProperty *)property {
	NSCalendarDate *date;
	if ([property hasParameterValue:VFILEValueParameterDate forKey:VFILEValueParameter]) {
		// we're dealing with a date but no time, e.g. 20050331
		date = [NSCalendarDate dateWithString:[property parsedValue]
							   calendarFormat:@"%Y%m%d"];
	} else {
		// we're dealing with a date and time, e.g. 20050331T122900
		date = [NSCalendarDate dateWithString:[property parsedValue]
							   calendarFormat:@"%Y%m%dT%H%M%S"];
	}
	[date setTimeZone:[NSTimeZone timeZoneWithName:[property firstValueForKey:VCALENDARTimezoneParameter]]];
}

@end
