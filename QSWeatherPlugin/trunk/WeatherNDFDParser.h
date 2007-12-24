//
//  WeatherNDFDParser.h
//  SkeletonTool
//
//  Created by Ralph Churchill on 12/4/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WeatherObject.h"

@interface WeatherNDFDParser : NSObject {
@private
	NSXMLParser *_parser;
	NSString *_currentElement;
	NSString *_currentString;
	NSString *_currentKey;
	NSData *_data;
	int _forecastDays;
	
	NSMutableDictionary *dataDictionary;
	NSMutableArray *dailyMinTemp;
	NSMutableArray *dailyMaxTemp;
	NSMutableArray *precipProb;
	NSMutableArray *conditionIcons;
}
-(id)initWithData:(NSData *)data forDays:(int)days;
-(void)parseXMLFile;
-(NSString *)currentElement;
-(void)setCurrentElement:(NSString *)newElement;
-(NSString *)currentString;
-(void)setCurrentString:(NSString *)newString;
- (NSString *)currentKey;
- (void)setCurrentKey:(NSString *)newCurrentKey;


- (NSMutableDictionary *)dataDictionary;
- (void)setDataDictionary:(NSMutableDictionary *)newDataDictionary;
- (NSMutableArray *)dailyMinTemp;
- (void)setDailyMinTemp:(NSMutableArray *)newDailyMinTemp;
- (NSMutableArray *)dailyMaxTemp;
- (void)setDailyMaxTemp:(NSMutableArray *)newDailyMaxTemp;
- (NSMutableArray *)precipProb;
- (void)setPrecipProb:(NSMutableArray *)newPrecipProb;
- (NSMutableArray *)conditionIcons;
- (void)setConditionIcons:(NSMutableArray *)newConditionIcons;

@end
