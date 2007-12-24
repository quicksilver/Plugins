//
//  WeatherObject.h
//  SkeletonTool
//
//  Created by Ralph Churchill on 12/4/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
/*
current_observation
credit
credit_URL
image
url
title
link
suggested_pickup
suggested_pickup_period
location
 */
#define kSTATION_ID @"station_id"
/*
latitude
longitude
elevation
 */
#define kOBSERVATION_TIME @"observation_time"
#define kWEATHER @"weather"
#define kTEMPERATURE_STRING @"temperature_string"
/*
temp_f
temp_c
 */
#define kRELATIVE_HUMIDITY @"relative_humidity"
#define kWIND_STRING @"wind_string"
/*
wind_dir
wind_degrees
wind_mph
wind_gust_mph
*/
#define kPRESSURE_STRING @"pressure_string"
/*
pressure_mb
pressure_in
 */
#define kDEWPOINT_STRING @"dewpoint_string"
/*
dewpoint_f
dewpoint_c
heat_index_string
heat_index_f
heat_index_c
windchill_string
windchill_f
windchill_c
 */
#define kVISIBILITY @"visibility_mi"
/*
two_day_history_url
ob_url
disclaimer_url
copyright_url
privacy_policy_url
*/
#define kICON_URL_BASE @"icon_url_base"
#define kICON_URL_NAME @"icon_url_name"


@interface WeatherObject : NSObject {
@private
	NSString *_stationId;
	NSString *_observationTime;
	NSString *_weather;
	NSString *_temperatureString;
	NSString *_relativeHumidity;
	NSString *_dewPointString;
	NSString *_windString;
	NSString *_pressureString;
	NSString *_visibility;
    NSString *_iconURL;
    NSString *_iconName;
}
- (NSString *)stationId;
- (void)setStationId:(NSString *)newStationId;
- (NSString *)observationTime;
- (void)setObservationTime:(NSString *)newObservationTime;
- (NSString *)weather;
- (void)setWeather:(NSString *)newWeather;
- (NSString *)temperatureString;
- (void)setTemperatureString:(NSString *)newTemperatureString;
- (NSString *)relativeHumidity;
- (void)setRelativeHumidity:(NSString *)newRelativeHumidity;
- (NSString *)dewPointString;
- (void)setDewPointString:(NSString *)newDewPointString;
- (NSString *)windString;
- (void)setWindString:(NSString *)newWindString;
- (NSString *)pressureString;
- (void)setPressureString:(NSString *)newPressureString;
- (NSString *)visibility;
- (void)setVisibility:(NSString *)newVisibility;
- (NSURL *)currentConditionIconURL;
- (NSString *)iconURL;
- (void)setIconURL:(NSString *)value;
- (NSString *)iconName;
- (void)setIconName:(NSString *)value;
@end
