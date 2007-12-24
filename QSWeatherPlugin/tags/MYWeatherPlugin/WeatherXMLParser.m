//
//  WeatherXMLParser.m
//  SkeletonTool
//
//  Created by Ralph Churchill on 12/4/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "WeatherXMLParser.h"

@implementation WeatherXMLParser
-(id) initWithData:(NSData *)data
{
	self = [super init];
	if(self) {
		if (_data != data) {
			[_data release];
			_data = [data copy];
		}
	}
	return self;
}

-(void) parseXMLFile
{
	if(_parser) {
		[_parser release];
	}
	_parser = [[NSXMLParser alloc] initWithData:_data];
	[_parser setDelegate:self];
	[_parser setShouldResolveExternalEntities:YES];
	[_parser parse];
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
	namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{
	//NSLog(@"Start %@",elementName);
	if([elementName isEqualToString:@"current_observation"]) {
		if(!_weatherData)  {
			_weatherData = [[NSMutableDictionary alloc] initWithCapacity:10];
		}
		return;
	} else {
		[self setCurrentElement:elementName];
	}
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	[self setCurrentString:string];
}
-(void) paser:(NSXMLParser *) parser foundIgnorableWhitespace:(NSString *)string
{
	NSLog(@"ignorable whitespace");
}
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
	namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	//NSLog(@"End: %@",elementName);
	if([elementName isEqualToString:@"current_observation"]) {
		// we're done, create weather object
		if(!_weather) {
			_weather = [[WeatherObject alloc] init];
			[_weather setStationId:[[self weatherData] objectForKey:kSTATION_ID]];
			[_weather setObservationTime:[[self weatherData] objectForKey:kOBSERVATION_TIME]];
			[_weather setWeather:[[self weatherData] objectForKey:kWEATHER]];
			[_weather setTemperatureString:[[self weatherData] objectForKey:kTEMPERATURE_STRING]];
			[_weather setRelativeHumidity:[[self weatherData] objectForKey:kRELATIVE_HUMIDITY]];
			[_weather setDewPointString:[[self weatherData] objectForKey:kDEWPOINT_STRING]];
			[_weather setWindString:[[self weatherData] objectForKey:kWIND_STRING]];
			[_weather setPressureString:[[self weatherData] objectForKey:kPRESSURE_STRING]];
			[_weather setVisibility:[[self weatherData] objectForKey:kVISIBILITY]];
		}
		return;
	} else {
		[[self weatherData] setObject:[self currentString] forKey:[self currentElement]];
	}
}
-(NSString *)currentElement
{
	return _currentElement;
}
-(void)setCurrentElement:(NSString *)newElement
{
	id old = _currentElement;
	_currentElement = [newElement retain];
	[old release];
}
-(NSString *)currentString
{
	return _currentString;
}
-(void)setCurrentString:(NSString *)newString
{
	id old = _currentString;
	_currentString = [newString retain];
	[old release];
}
- (NSMutableDictionary *)weatherData {
    return [[_weatherData retain] autorelease];
}

- (void)setWeatherData:(NSMutableDictionary *)newWeatherData {
    if (_weatherData != newWeatherData) {
        [_weatherData release];
        _weatherData = [newWeatherData copy];
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
