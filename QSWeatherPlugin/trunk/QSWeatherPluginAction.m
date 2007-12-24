//
//  QSWeatherPluginAction.m
//  QSWeatherPlugin
//
//  Created by Ralph Churchill on 11/2/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSWeatherPluginAction.h"
#import "WeatherXMLParser.h"
#import "WeatherNDFDParser.h"
#include "NDFDStub.h"
#include "QSCore/QSRegistry.h"
#include "QSCore/QSNotifyMediator.h"

@implementation QSWeatherPluginAction


#define kQSWeatherPluginAction @"QSWeatherPluginAction"
-(id)init
{
	self = [super init];
	if(self) {
		[self setCachedDate:[NSDate dateWithTimeIntervalSinceNow:-60.0*60.0]];
		[self setCachedForecastDate:[NSDate dateWithTimeIntervalSinceNow:-60*60]];
		[self setCachedWeather:[NSString string]];
		[self setCachedForecast:[NSString string]];
	}
	return self;
	
}

- (void)getCurrentConditions:(QSObject *)dObject
{
	[self ensureWeatherIsCurrent];
	NSMutableString *current = [[NSMutableString alloc] initWithCapacity:50];
	NSString *t = [[self cachedWeather] temperatureString];
	if(t!=nil)
		[current appendFormat:@"Temp: %@",t];
	t = [[self cachedWeather] dewPointString];
	if(t!=nil)
		[current appendFormat:@"Dew Point: %@", t];
	t = [[self cachedWeather] weather];
	
	[current appendString:@"\n"];
	
	if(t!=nil)
		[current appendFormat:@"%@, ",t];
	t = [[self cachedWeather] windString];
	if(t!=nil)
		[current appendFormat:@"Winds %@",t];
	t = [[self cachedWeather] observationTime];
	if(t!=nil) 
		[current appendFormat:@"\n%@",t];
	
	[self displayNotification:current andTitle:@"Current Conditions"];
	[current release];
}

-(void)getCurrentTemperature:(QSObject *)dObject
{
	[self ensureWeatherIsCurrent];
	[self displayNotification:[[self cachedWeather] temperatureString] andTitle:@"Temperature"];
}
-(void)getCurrentDewPoint:(QSObject *)dObject
{
	[self ensureWeatherIsCurrent];
	[self displayNotification:[[self cachedWeather] dewPointString] andTitle:@"Dew Point"];
}

-(void)getCurrentHumidity:(QSObject *)dObject
{
	[self ensureWeatherIsCurrent];
	[self displayNotification:[NSString stringWithFormat:@"%@%@",[[self cachedWeather] relativeHumidity],@"%"]
					 andTitle:@"Humidity"];
}

-(void)getCurrentWinds:(QSObject *)dObject
{
	[self ensureWeatherIsCurrent];
	[self displayNotification:[[self cachedWeather] windString] andTitle:@"Winds"];
}
-(void)getCurrentVisibility:(QSObject *)dObject
{
	[self ensureWeatherIsCurrent];
	[self displayNotification:[NSString stringWithFormat:@"%@%@",[[self cachedWeather] visibility],@"mi"]
                     andTitle:@"Visibility"];
}

-(void)getForecast:(QSObject *)dObject
{
	[self ensureForecastIsCurrent];
	[self displayNotification:[self cachedForecast] andTitle:@"Forecast" usingIcon:[self cachedForecastIcon]];
    
}
-(NSDate *)cachedDate
{
	return _cachedDate;
}
-(void)setCachedDate:(NSDate *)newCacheDate
{
	id old = _cachedDate;
	_cachedDate = [newCacheDate retain];
	[old release];
}
-(NSDate *)cachedForecastDate
{
	return _cachedForecastDate;
}
-(void)setCachedForecastDate:(NSDate *)newCacheDate
{
	id old = _cachedForecastDate;
	_cachedForecastDate = [newCacheDate retain];
	[old release];
}

- (WeatherObject *)cachedWeather {
    return _cachedWeather;
}

- (void)setCachedWeather:(WeatherObject *)value {
    id old = _cachedWeather;
    _cachedWeather = [value retain];
    [old release];
}
-(NSString *)cachedForecast
{
	return _cachedForecast;
}
-(void)setCachedForecast:(NSString *)newCache
{
	id old = _cachedForecast;
	_cachedForecast = [newCache retain];
	[old release];
}
-(NSString *)cachedStation
{
	return _cachedStation;
}
-(void)setCachedStation:(NSString *)newCacheStation
{
	id old = _cachedStation;
	_cachedStation = [newCacheStation retain];
	[old release];
}
- (NSImage *)cachedWeatherIcon {
    return [[_cachedWeatherIcon retain] autorelease];
}

- (void)setCachedWeatherIcon:(NSImage *)value {
    if (_cachedWeatherIcon != value) {
        [_cachedWeatherIcon release];
        _cachedWeatherIcon = [value copy];
    }
}

- (NSImage *)cachedForecastIcon {
    return [[_cachedForecastIcon retain] autorelease];
}

- (void)setCachedForecastIcon:(NSImage *)value {
    if (_cachedForecastIcon != value) {
        [_cachedForecastIcon release];
        _cachedForecastIcon = [value copy];
    }
}
- (NSString *)cachedLatitude {
    return [[_cachedLatitude retain] autorelease];
}

- (void)setCachedLatitude:(NSString *)value {
    if (_cachedLatitude != value) {
        [_cachedLatitude release];
        _cachedLatitude = [value copy];
    }
}

- (NSString *)cachedLongitude {
    return [[_cachedLongitude retain] autorelease];
}

- (void)setCachedLongitude:(NSString *)value {
    if (_cachedLongitude != value) {
        [_cachedLongitude release];
        _cachedLongitude = [value copy];
    }
}


- (void)ensureWeatherIsCurrent
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *station = [defaults objectForKey:@"QSWeatherStation"];
	
	if((fabs([[self cachedDate] timeIntervalSinceNow]) > 60.0*60.0) ||
	   (![[self cachedStation] isEqualToString:station])){
		WeatherObject *w = [self downloadWeather];
		if(w!=nil) {
			[self setCachedWeather:w];
            [self setCachedWeatherIcon:[[NSImage alloc] initByReferencingURL:[w currentConditionIconURL]]];
			[self setCachedDate:[NSDate date]];
			[self setCachedStation:station];
		}
	}
}
- (void)ensureForecastIsCurrent
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *lat = [defaults objectForKey:@"QSWeatherLatitude"];
    NSString *lng = [defaults objectForKey:@"QSWeatherLongitude"];
	
	if((fabs([[self cachedForecastDate] timeIntervalSinceNow]) > 60.0*60.0) ||
       (![[self cachedLatitude] isEqualToString:lat]) ||
       (![[self cachedLongitude] isEqualToString:lng])) {
		NSString *f = [self downloadForecast];
		if(f!=nil) {
			[self setCachedForecast:f];
            // [self setCachedForecastIcon:[[NSImage alloc] initByReferencingURL:[]]];
			[self setCachedForecastDate:[NSDate date]];
            [self setCachedLatitude:lat];
            [self setCachedLongitude:lng];
		}
	}
}
- (void)displayNotification:(NSString*)data andTitle:(NSString *)title
{
    [self displayNotification:data andTitle:title usingIcon:[self cachedWeatherIcon]];
}
- (void)displayNotification:(NSString*)data andTitle:(NSString *)title usingIcon:(NSImage *)icon
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *useHelper = [defaults objectForKey:@"QSWeatherUseHelper"];
	if(useHelper!=nil && [useHelper boolValue]) {
		id notifier = [[QSRegistry sharedInstance] preferredNotifier];
		if(notifier!=nil) {
			[notifier displayNotificationWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
				data,QSNotifierText,
                title,QSNotifierTitle,
                icon,QSNotifierIcon,
                nil]];
			return;
		}
	}
	QSShowLargeType(data);
}

- (WeatherObject *) downloadWeather
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *targetStation = [[defaults objectForKey:@"QSWeatherStation"] uppercaseString];
    WeatherObject *w = nil;
	
	NSString *url = [NSString stringWithFormat:@"http://www.nws.noaa.gov/data/current_obs/%@.xml",
		targetStation];
	NSLog(@"Downloading XML from %@ ...",url);
    WeatherXMLParser *p = [[WeatherXMLParser alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [p parseXMLFile];
    w = [p weather];
    [p release];

	return [w autorelease];
}
- (NSString *) downloadForecast
{
    NSLog(@"downloading forecast...");
    NSMutableString *forecast = [[NSMutableString alloc] init];
	NSString *today = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d" timeZone:nil locale:nil];
    
	// /////////////////////////
	// get Lat. Long. from user def.
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	double latitude = [[defaults objectForKey:@"QSWeatherLatitude"] doubleValue];
	NSString *lngStr = [defaults objectForKey:@"QSWeatherLongitude"];
	
    double longitude = [lngStr doubleValue];
    // convert WEST to negative
    if ([lngStr compare:@"w" options:NSCaseInsensitiveSearch
                  range:NSMakeRange([lngStr length]-1,1) locale:nil]==NSOrderedSame) {
        longitude *= -1.0;
    }
	
	// /////////////////////////
	// retrieve
	int forecastDays = 2;
	id result = [ndfdXMLService NDFDgenByDay:latitude in_longitude:longitude
								in_startDate:today 
								  in_numDays:[NSNumber numberWithInt:forecastDays]
								   in_format:@"24 hourly"];
	if(result==nil) return;
	NSXMLDocument *ndfdXML = [[NSXMLDocument alloc] initWithData:
        [result dataUsingEncoding:NSASCIIStringEncoding] options: nil error: nil];
	// /////////////////////////
	// if debugging, save file
	if([defaults boolForKey:@"QSWeatherDebug"]) {
        /*
		[ndfdXML writeToFile:[NSString stringWithFormat:@"%@/ndfd.%@.xml",
			[@"~/Documents/ndfd/" stringByExpandingTildeInPath],[[NSDate date] descriptionWithCalendarFormat:@"%m%d%y%H%M"  timeZone:nil locale:nil]] atomically:TRUE];
            */
    }


	// /////////////////////////
    // parse the XML with XQuery
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSError *err = [[NSError alloc] init];
    NSString *xquery = [NSString stringWithContentsOfFile:
        [NSString stringWithFormat:@"%@/%@",[bundle resourcePath], @"ndfd.xq"]];
    NSArray *nodes = [ndfdXML objectsForXQuery:xquery error:&err];
    if([nodes count] < 1) {
        NSLog(@"Errors: %@",[err localizedFailureReason]);
    } else {
        NSXMLNode *root = [nodes objectAtIndex: 0];
        [forecast setString:[NSString stringWithFormat:@"%@\n%@",
            [[root childAtIndex:0] childAtIndex:0], [[root childAtIndex:1] childAtIndex:0]]];
    }
    
    // /////////////////////////
    // hack alert :)
    NSString *xpath = @".//conditions-icon/icon-link[1]/text()";
    nodes = [ndfdXML nodesForXPath:xpath error:&err];
    if([nodes count] < 1) {
        NSLog(@"Errors: %@",[err localizedFailureReason]);
    } else {
        NSString *iconURL = [NSString stringWithFormat:@"%@",[nodes objectAtIndex:0]];
        [self setCachedForecastIcon:[[NSImage alloc] initByReferencingURL:[NSURL URLWithString:iconURL]]];
    }
    
    
    [err release];
    [ndfdXML release];
    [forecast autorelease];
    
}
@end
