//
//  METARParser.h
//  MYWeatherPlugin
//
//  Created by Ralph Churchill on 12/6/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeatherObject.h"

@interface METARParser : NSObject {
@private
	WeatherObject *_weather;
	NSString *metar;
}
-(id)initWithString:(NSString *)string;
-(void)parseMETAR;
-(NSString *)parseWind:(NSString *)wind;
-(NSString *)convertTrueNorthToCompass:(int)compass;
-(NSString *)parseVisibility:(NSString *)vis;
- (WeatherObject *)weather;
- (void)setWeather:(WeatherObject *)newWeather;

@end
