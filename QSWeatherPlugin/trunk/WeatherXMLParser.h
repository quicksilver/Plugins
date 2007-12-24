//
//  WeatherXMLParser.h
//  SkeletonTool
//
//  Created by Ralph Churchill on 12/4/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeatherObject.h"

@interface WeatherXMLParser : NSObject {
@private
	NSXMLParser *_parser;
	NSString *_currentElement;
	NSString *_currentString;
	NSMutableDictionary *_weatherData;
	NSData *_data;
    WeatherObject *_weather;
}
-(id)initWithData:(NSData *)data;
-(void)parseXMLFile;
-(NSString *)currentElement;
-(void)setCurrentElement:(NSString *)newElement;
-(NSString *)currentString;
-(void)setCurrentString:(NSString *)newString;
- (NSMutableDictionary *)weatherData;
- (void)setWeatherData:(NSMutableDictionary *)newWeatherData;
- (WeatherObject *)weather;
- (void)setWeather:(WeatherObject *)newWeather;

@end
