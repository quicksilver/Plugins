//
//  QSWeatherPluginSource.m
//  QSWeatherPlugin
//
//  Created by Ralph Churchill on 11/2/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSWeatherPluginSource.h"
#import "QSWeatherPluginAction.h"
#import <QSCore/QSObject.h>

@implementation QSWeatherPluginSource
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return nil;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    NSLog(@"rescanned catalog");
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	NSDictionary *actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([QSWeatherPluginAction class]), kActionClass,
                                                   @"getCurrentConditions:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Weather",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"QSWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([QSWeatherPluginAction class]), kActionClass,
                                    @"getCurrentTemperature:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Temperature",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"QSWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
    
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([QSWeatherPluginAction class]), kActionClass,
                                       @"getCurrentDewPoint:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Dew Point",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"QSWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([QSWeatherPluginAction class]), kActionClass,
									   @"getCurrentHumidity:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Humidity",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"QSWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([QSWeatherPluginAction class]), kActionClass,
                                          @"getCurrentWinds:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Winds",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"QSWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([QSWeatherPluginAction class]), kActionClass,
                                     @"getCurrentVisibility:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Visibility",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"QSWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
    
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([QSWeatherPluginAction class]), kActionClass,
                                              @"getForecast:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Forecast",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"QSWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
    
    return objects;
    
}


// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:nil]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:QSWeatherPluginType];
	[object setIcon:nil];
    return YES;
}
*/
- (BOOL)loadChildrenForObject:(QSObject *)object
{
    [object setChildren:[self objectsForEntry:nil]];
    return YES;   	
}
@end
