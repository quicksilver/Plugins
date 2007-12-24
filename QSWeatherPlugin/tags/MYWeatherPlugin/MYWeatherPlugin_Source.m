//
//  MYWeatherPlugin_Source.m
//  MYWeatherPlugin
//
//  Created by Ralph Churchill on 11/26/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "MYWeatherPlugin_Source.h"
#import "MYWeatherPlugin_Action.h"
#import <QSCore/QSObject.h>
#import <QSCore/QSObjCMessageSource.h>

@implementation MYWeatherPlugin_Source
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
	NSLog(@"rescanned catalog");
    
	NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	NSDictionary *actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([MYWeatherPlugin_Action class]), kActionClass,
		@"getCurrentConditions:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Weather",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"MYWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([MYWeatherPlugin_Action class]), kActionClass,
									 @"getCurrentTemperature:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Temperature",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"MYWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];

	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([MYWeatherPlugin_Action class]), kActionClass,
									@"getCurrentDewPoint:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Dew Point",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"MYWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([MYWeatherPlugin_Action class]), kActionClass,
									   @"getCurrentHumidity:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Humidity",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"MYWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([MYWeatherPlugin_Action class]), kActionClass,
									   @"getCurrentWinds:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Winds",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"MYWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];
	
	actionDict = [NSDictionary dictionaryWithObjectsAndKeys:
		NSStringFromClass([MYWeatherPlugin_Action class]), kActionClass,
										  @"getCurrentVisibility:", kActionSelector,
		/*@"",kActionIcon,*/
		@"Visibility",@"name",nil];
	newObject = [QSAction actionWithDictionary:actionDict 
									identifier:@"MYWeatherPluginWeather" bundle:nil];
	[objects addObject:newObject];

    return objects;
    
}

 - (BOOL)loadChildrenForObject:(QSObject *)object
{
	 [object setChildren:[self objectsForEntry:nil]];
	 return YES;   	
}
@end
