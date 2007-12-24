//
//  MYWeatherPlugin_Action.h
//  MYWeatherPlugin
//
//  Created by Ralph Churchill on 11/26/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSObject.h>
#import <QSCore/QSActionProvider.h>
#import <QSCore/QSNotifyMediator.h>
#import "MYWeatherPlugin_Action.h"
#import "WeatherObject.h"

@interface MYWeatherPlugin_Action : NSObject
{
@private
	NSDate *cacheDate;
	WeatherObject *cacheMetar;
	NSString *cacheStation;
}
-(void)getCurrentConditions:(QSObject *)dObject;
-(void)getCurrentTemperature:(QSObject *)dObject;
-(void)getCurrentDewPoint:(QSObject *)dObejct;
-(void)getCurrentHumidity:(QSObject *)dObejct;
-(void)getCurrentWinds:(QSObject *)dObejct;
-(void)getCurrentVisibility:(QSObject *)dObejct;

-(NSDate *)cacheDate;
-(void)setCacheDate:(NSDate *)newCacheDate;
-(WeatherObject *)cacheMetar;
-(void)setCacheMetar:(WeatherObject *)newCacheMetar;
-(NSString *)cacheStation;
-(void)setCacheStation:(NSString *)newCacheStation;
-(void)updateData;
-(WeatherObject *)reload;
-(void)displayNotification:(NSString *)data andTitle:(NSString *)title;
@end

