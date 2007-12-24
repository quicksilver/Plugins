//
//  MYWeatherPlugin_Action.m
//  MYWeatherPlugin
//
//  Created by Ralph Churchill on 11/26/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "MYWeatherPlugin_Action.h"
#import "WeatherXMLParser.h"
#import "METARParser.h"

@implementation MYWeatherPlugin_Action

#define kMYWeatherPluginAction @"MYWeatherPluginAction"
-(id)init
{
	self = [super init];
	if(self) {
		[self setCacheDate:[NSDate dateWithTimeIntervalSinceNow:-60.0*60.0]];
		[self setCacheMetar:[NSString string]];
	}
	return self;
	
}
- (void)getCurrentConditions:(QSObject *)dObject
{
	[self updateData];
	NSMutableString *current = [[NSMutableString alloc] initWithCapacity:50];
	NSString *t = [[self cacheMetar] temperatureString];
	if(t!=nil)
		[current appendFormat:@"Temp: %@",t];
	t = [[self cacheMetar] dewPointString];
	if(t!=nil)
		[current appendFormat:@"Dew Point: %@", t];
	t = [[self cacheMetar] weather];
	
	[current appendString:@"\n"];
	
	if(t!=nil)
		[current appendFormat:@"%@, ",t];
	t = [[self cacheMetar] windString];
	if(t!=nil)
		[current appendFormat:@"Winds %@",t];
	t = [[self cacheMetar] observationTime];
	if(t!=nil) 
		[current appendFormat:@"\n%@",t];
	
	[self displayNotification:current andTitle:@"Current Conditions"];
	[current release];
}

-(void)getCurrentTemperature:(QSObject *)dObject
{
	[self updateData];
	[self displayNotification:[[self cacheMetar] temperatureString] andTitle:@"Temperature"];
}
-(void)getCurrentDewPoint:(QSObject *)dObject
{
	[self updateData];
	[self displayNotification:[[self cacheMetar] dewPointString] andTitle:@"Dew Point"];
}

-(void)getCurrentHumidity:(QSObject *)dObject
{
	[self updateData];
	[self displayNotification:[NSString stringWithFormat:@"%@%@",[[self cacheMetar] relativeHumidity],@"%"]
					 andTitle:@"Humidity"];
}

-(void)getCurrentWinds:(QSObject *)dObject
{
	[self updateData];
	[self displayNotification:[[self cacheMetar] windString] andTitle:@"Winds"];
}
-(void)getCurrentVisibility:(QSObject *)dObject
{
	[self updateData];
	[self displayNotification:[[self cacheMetar] visibility] andTitle:@"Visibility"];
}

- (void)updateData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *station = [defaults objectForKey:@"MYWeatherStation"];

	if((fabs([[self cacheDate] timeIntervalSinceNow]) > 60.0*60.0) ||
	   (![[self cacheStation] isEqualToString:station])){
		WeatherObject *w = [self reload];
		if(w!=nil) {
			[self setCacheMetar:w];
			[self setCacheDate:[NSDate date]];
			[self setCacheStation:station];
		}
	}
}
- (WeatherObject *)reload
{
	// Pref pane
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *targetStation = [[defaults objectForKey:@"MYWeatherStation"] uppercaseString];
	WeatherObject *w = nil;
	
	NSString *url = [NSString stringWithFormat:@"http://www.nws.noaa.gov/data/current_obs/%@.xml",
		targetStation];
	NSLog(@"Downloading XML from %@ ...",url);
	
	NSBundle *pluginBundle = [NSBundle bundleForClass:[self class]];
	NSBundle *curlBundle = [NSBundle bundleWithPath:
		[[pluginBundle privateFrameworksPath] stringByAppendingPathComponent:@"CURLHandle.framework"]];
	//NSLog(@"Bundle Path: %@",[curlBundle bundlePath]);

	[curlBundle load];
	Class curlClass = [curlBundle classNamed:@"CURLHandle"]; // NSClassFromString(@"CURLHandle");
	id curlInstance = [[curlClass alloc] initWithURL:[NSURL URLWithString:url] cached:NO];
	NSData *data = [curlInstance loadInForeground];
	// NSLog(@"Data: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
	if(data!=nil&&[curlInstance httpCode]==200) {
		WeatherXMLParser *p = [[WeatherXMLParser alloc] initWithData:data];
		[p parseXMLFile];
		w = [p weather];
		[p release];
	} else {
		NSLog(@"Error downloading XML, switching to METAR");
		NSString *METARURL = [NSString stringWithFormat:@"ftp://weather.noaa.gov/data/observations/metar/stations/%@.TXT",
			targetStation];
		METARParser *p = [[METARParser alloc] initWithString:[NSString stringWithContentsOfURL:[NSURL URLWithString:METARURL]]];
		[p parseMETAR];
		w = [p weather];
		[p release];
	}
	[curlInstance release];
	return [w autorelease];
}
- (void)displayNotification:(NSString*)data andTitle:(NSString *)title
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSNumber *useHelper = [defaults objectForKey:@"MYWeatherUseHelper"];
	if(useHelper!=nil && [useHelper boolValue]) {
		id notifier = [[QSRegistry sharedInstance] preferredNotifier];
		if(notifier!=nil) {
			[notifier displayNotificationWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
				data,@"text",title,@"title",nil]];
			return;
		}
	}
	QSShowLargeType(data);
}

-(NSDate *)cacheDate
{
	return cacheDate;
}
-(void)setCacheDate:(NSDate *)newCacheDate
{
	id old = cacheDate;
	cacheDate = [newCacheDate retain];
	[old release];
}
-(WeatherObject *)cacheMetar
{
	return cacheMetar;
}
-(void)setCacheMetar:(WeatherObject *)newCacheMetar
{
	id old = cacheMetar;
	cacheMetar = [newCacheMetar retain];
	[old release];
}
-(NSString *)cacheStation
{
	return cacheStation;
}
-(void)setCacheStation:(NSString *)newCacheStation
{
	id old = cacheStation;
	cacheStation = [newCacheStation retain];
	[old release];
}
@end
