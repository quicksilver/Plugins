//
//  METARParser.m
//  MYWeatherPlugin
//
//  Created by Ralph Churchill on 12/6/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "METARParser.h"


@implementation METARParser
-(id) initWithString:(NSString *)string
{
	self = [super init];
	if(self) {
		if (metar != string) {
			[metar release];
			metar = [string copy];
		}
	}
	return self;
}
- (void)parseMETAR
{
	NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:
		@"M0123456789"];
	_weather = [[WeatherObject alloc] init];
	
	NSLog(@"METAR: %@",metar);
	
	metar = [[metar componentsSeparatedByString:@"\n"] objectAtIndex:1];
	NSArray *fields = [metar componentsSeparatedByString:@" "];
	NSEnumerator *itr = [fields objectEnumerator];
	
	int index = 0;
	id obj;
	while(obj = [itr nextObject]) {
		 NSLog(@"[%d] %@",index++,obj);
	 }
	index = 0;
	NSString *station = [fields objectAtIndex:index++];
	
	NSString *readingDateString = [fields objectAtIndex:index++];
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	NSCalendarDate *readingDate = [NSCalendarDate
	dateWithYear: [now yearOfCommonEra]
		   month: [now monthOfYear]
			 day: [[readingDateString substringWithRange:NSMakeRange(0,2)] intValue]
			hour: [[readingDateString substringWithRange:NSMakeRange(2,2)] intValue]
		  minute: [[readingDateString substringWithRange:NSMakeRange(4,2)] intValue]
		  second:0
		timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	[readingDate setTimeZone:[now timeZone]];
	[readingDate setCalendarFormat: @"%m/%d/%y %I:%M%p"];
	[_weather setObservationTime:[NSString stringWithFormat:@"Last Updated: %@",readingDate]];
	
	/*NSDateFormatter *dateFormat = [[NSDateFormatter alloc]
		initWithDateFormat:@"%d%H%M" allowNaturalLanguage:NO];*/
	
	/*
	 if([[fields objectAtIndex:index] isEqualToString:@"AUTO"]) {
		// eat it
		index++;
	}
	*/
	
	while(index<[fields count]-1){
		// NSLog(@"Checking %@",[fields objectAtIndex:index]);
		if([[fields objectAtIndex:index] hasSuffix:@"KT"]) {
			NSString *wind = [self parseWind:[fields objectAtIndex:index]];
			NSLog(@"Wind: %@",wind);
			[_weather setWindString:wind];
		}
		else if([[fields objectAtIndex:index] hasSuffix:@"SM"]){
			NSString *visibility = [self parseVisibility:[fields objectAtIndex:index]];
			NSLog(@"Visibility: %@",visibility);
			[_weather setVisibility:visibility];
		} else {
			NSString *s = [fields objectAtIndex:index];
			if([s rangeOfCharacterFromSet:charSet].location==0 &&
			   [s rangeOfString:@"/"].length==1) {
				NSArray *tempAndDewPoint = [[fields objectAtIndex:index] componentsSeparatedByString:@"/"];
				NSString *tempInCelsiusString = [tempAndDewPoint objectAtIndex:0];
				float tempInCelsius = (([tempInCelsiusString hasPrefix:@"M"])?
									   [[tempInCelsiusString substringFromIndex:1] floatValue]*-1.0:
									   [tempInCelsiusString floatValue]);
				
				float tempInF = 1.8*tempInCelsius + 32.0; //  F = 1.8xC + 32
				
				NSString *dewPointInCelsiusString = [tempAndDewPoint objectAtIndex: 1];
				float dewPointInCelsius = (([dewPointInCelsiusString hasPrefix:@"M"])?
										   [[dewPointInCelsiusString substringFromIndex:1] floatValue]*-1.0:
										   [dewPointInCelsiusString floatValue]);
				float dewPointInF = 1.8*dewPointInCelsius + 32.0;
				
				[_weather setTemperatureString:[NSString stringWithFormat:@"%.0f F (%.0f C)",tempInF,tempInCelsius]];
				[_weather setDewPointString:[NSString stringWithFormat:@"%.0f F (%.0f C)",
					dewPointInF,dewPointInCelsius]];
			}
		}
		index++;
	}
}

- (NSString *)parseWind:(NSString *)wind
{
	if([wind isEqualToString:@"00000KT"]) {
		return [[NSString stringWithString:@"Calm"] autorelease];
	}
	NSMutableString *windString = [[NSMutableString alloc] init];
	// true north or VRB "variable"
	NSString *direction = [wind substringToIndex:3];
	if([direction isEqualToString:@"VRB"]) {
		[windString appendString:@"Variable winds "];
	} else {
		// convert to N/S/E/W
		[windString appendFormat:@" from the %@ ",
			[self convertTrueNorthToCompass: [direction intValue]]];
	}
	
	NSString *speed = [wind substringWithRange:NSMakeRange(3,2)];
	[windString appendFormat:@"at %.1fmph ",[speed doubleValue]*1.1508];
	
	// check for Gusting
	NSArray *w = [wind componentsSeparatedByString:@"G"];
	if([w count]>=2) {
		[windString appendFormat:@"Gusting at %.1fmph",[[[w objectAtIndex:1] substringToIndex:2] doubleValue]*1.1508];
	}
	return [windString autorelease];
}
-(NSString *)convertTrueNorthToCompass:(int)trueNorth
{
	NSString *compass;
	if (trueNorth < 15) {
		compass = @"North";
	} else if (trueNorth < 30) {
		compass = @"North/Northeast";
	} else if (trueNorth < 60) {
		compass = @"Northeast";
	} else if (trueNorth < 75) {
		compass = @"East/Northeast";
	} else if (trueNorth < 105) {
		compass = @"East";
	} else if (trueNorth < 120) {
		compass = @"East/Southeast";
	} else if (trueNorth < 150) {
		compass = @"Southeast";
	} else if (trueNorth < 165) {
		compass = @"South/Southeast";
	} else if (trueNorth < 195) {
		compass = @"South";
	} else if (trueNorth < 210) {
		compass = @"South/Southwest";
	} else if (trueNorth < 240) {
		compass = @"Southwest";
	} else if (trueNorth < 265) {
		compass = @"West/Southwest";
	} else if (trueNorth < 285) {
		compass = @"West";
	} else if (trueNorth < 300) {
		compass = @"West/Northwest";
	} else if (trueNorth < 330) {
		compass = @"Northwest";
	} else if (trueNorth < 345) {
		compass = @"North/Northwest";
	} else {
		compass = @"North";
	}
	return [compass autorelease];
}
-(NSString *)parseVisibility:(NSString *)visibility
{
	NSString *vis = [[[visibility componentsSeparatedByString:@"SM"] objectAtIndex:0] retain];
	if([vis hasPrefix:@"M"]) {
		return [NSString stringWithFormat:@"less than %@ statute miles",vis];
	} else {
		return [NSString stringWithFormat:@"%@ statute miles", vis];
	}
}

- (WeatherObject *)weather {
    return [[_weather retain] autorelease];
}

- (void)setWeather:(WeatherObject *)newWeather {
    if (_weather != newWeather) {
        [_weather release];
        _weather = [newWeather copy];
    }
}


@end
