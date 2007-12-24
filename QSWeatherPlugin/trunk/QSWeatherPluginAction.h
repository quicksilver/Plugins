//
//  QSWeatherPluginAction.h
//  QSWeatherPlugin
//
//  Created by Ralph Churchill on 11/2/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>
#import "QSWeatherPluginAction.h"
#import "WeatherObject.h"

#define QSWeatherPluginType @"QSWeatherPlugin_Type"

@interface QSWeatherPluginAction : QSActionProvider
{
@private
    NSDate *_cachedDate;
    NSDate *_cachedForecastDate;
    NSString *_cachedStation;
    WeatherObject *_cachedWeather;
    NSString *_cachedForecast;
    NSImage *_cachedWeatherIcon;
    NSImage *_cachedForecastIcon;
    NSString *_cachedLatitude;
    NSString *_cachedLongitude;
}
-(void)getCurrentConditions:(QSObject *)dObject;
-(void)getCurrentTemperature:(QSObject *)dObject;
-(void)getCurrentDewPoint:(QSObject *)dObejct;
-(void)getCurrentHumidity:(QSObject *)dObejct;
-(void)getCurrentWinds:(QSObject *)dObejct;
-(void)getCurrentVisibility:(QSObject *)dObejct;
-(void)getForecast:(QSObject *)dObejct;

-(NSDate *)cachedDate;
-(void)setCachedDate:(NSDate *)newCacheDate;
-(NSDate *)cachedForecastDate;
-(void)setCachedForecastDate:(NSDate *)newCacheDate;
-(NSString *)cachedStation;
-(void)setCachedStation:(NSString *)newCacheStation;
- (WeatherObject *)cachedWeather;
- (void)setCachedWeather:(WeatherObject *)value;
- (NSString *)cachedForecast;
- (void)setCachedForecast:(NSString *)value;
- (NSImage *)cachedWeatherIcon;
- (void)setCachedWeatherIcon:(NSImage *)value;
- (NSImage *)cachedForecastIcon;
- (void)setCachedForecastIcon:(NSImage *)value;
- (NSString *)cachedLatitude;
- (void)setCachedLatitude:(NSString *)value;
- (NSString *)cachedLongitude;
- (void)setCachedLongitude:(NSString *)value;


-(void)displayNotification:(NSString*)data andTitle:(NSString *)title;
-(void)displayNotification:(NSString*)data andTitle:(NSString *)title usingIcon:(NSImage *) icon;
-(NSString *)downloadForecast;
-(WeatherObject *)downloadWeather;
-(void)ensureWeatherIsCurrent;
-(void)ensureForecastIsCurrent;

@end

