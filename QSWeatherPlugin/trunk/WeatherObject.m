//
//  WeatherObject.m
//  SkeletonTool
//
//  Created by Ralph Churchill on 12/4/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "WeatherObject.h"

@implementation WeatherObject
- (NSString *)stationId {
    return [[_stationId retain] autorelease];
}

- (void)setStationId:(NSString *)newStationId {
    if (_stationId != newStationId) {
        [_stationId release];
        _stationId = [newStationId copy];
    }
}

- (NSString *)observationTime {
    return [[_observationTime retain] autorelease];
}

- (void)setObservationTime:(NSString *)newObservationTime {
    if (_observationTime != newObservationTime) {
        [_observationTime release];
        _observationTime = [newObservationTime copy];
    }
}

- (NSString *)weather {
    return [[_weather retain] autorelease];
}

- (void)setWeather:(NSString *)newWeather {
    if (_weather != newWeather) {
        [_weather release];
        _weather = [newWeather copy];
    }
}

- (NSString *)temperatureString {
    return [[_temperatureString retain] autorelease];
}

- (void)setTemperatureString:(NSString *)newTemperatureString {
    if (_temperatureString != newTemperatureString) {
        [_temperatureString release];
        _temperatureString = [newTemperatureString copy];
    }
}

- (NSString *)relativeHumidity {
    return [[_relativeHumidity retain] autorelease];
}

- (void)setRelativeHumidity:(NSString *)newRelativeHumidity {
    if (_relativeHumidity != newRelativeHumidity) {
        [_relativeHumidity release];
        _relativeHumidity = [newRelativeHumidity copy];
    }
}

- (NSString *)dewPointString {
    return [[_dewPointString retain] autorelease];
}

- (void)setDewPointString:(NSString *)newDewPointString {
    if (_dewPointString != newDewPointString) {
        [_dewPointString release];
        _dewPointString = [newDewPointString copy];
    }
}

- (NSString *)windString {
    return [[_windString retain] autorelease];
}

- (void)setWindString:(NSString *)newWindString {
    if (_windString != newWindString) {
        [_windString release];
        _windString = [newWindString copy];
    }
}

- (NSString *)pressureString {
    return [[_pressureString retain] autorelease];
}

- (void)setPressureString:(NSString *)newPressureString {
    if (_pressureString != newPressureString) {
        [_pressureString release];
        _pressureString = [newPressureString copy];
    }
}

- (NSString *)visibility {
    return [[_visibility retain] autorelease];
}

- (void)setVisibility:(NSString *)newVisibility {
    if (_visibility != newVisibility) {
        [_visibility release];
        _visibility = [newVisibility copy];
    }
}

- (NSURL *)currentConditionIconURL
{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",[self iconURL],[self iconName]]];
}

- (NSString *)iconURL {
    return [[_iconURL retain] autorelease];
}

- (void)setIconURL:(NSString *)value {
    if (_iconURL != value) {
        [_iconURL release];
        _iconURL = [value copy];
    }
}

- (NSString *)iconName {
    return [[_iconName retain] autorelease];
}

- (void)setIconName:(NSString *)value {
    if (_iconName != value) {
        [_iconName release];
        _iconName = [value copy];
    }
}



@end
