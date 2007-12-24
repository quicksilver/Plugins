//
//  WeatherNDFDParser.m
//  SkeletonTool
//
//  Created by Ralph Churchill on 12/4/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "WeatherNDFDParser.h"

@implementation WeatherNDFDParser
-(id) initWithData:(NSData *)data forDays:(int)days
{
	self = [super init];
	if(self) {
		if (_data != data) {
			[_data release];
			_data = [data copy];
		}
	}
	_forecastDays = days;
	dataDictionary = [[NSMutableDictionary alloc] initWithCapacity:6];
	
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
	
	NSEnumerator *e = [[self dataDictionary] keyEnumerator];
	id name;
	while(name = [e nextObject]) {
		id value = [[self dataDictionary] objectForKey:name];
		NSEnumerator *ee = [value objectEnumerator];
		id obj;
		while (obj = [ee nextObject]) {
			NSLog(@"%@ = %@",name, obj);
		}
	}
}
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
	namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
	attributes:(NSDictionary *)attributeDict
{
		// START OF NEW ELEMENT
		[self setCurrentElement:elementName];
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
		// END OF CURRENT ELEMENT
		// [[self weatherData] setObject:[self currentString] forKey:[self currentElement]];
		NSLog(@"%@ => %@", [self currentElement], [self currentString]);
		if([[self currentElement] isEqualToString:@"name"]) {
			NSMutableArray *currentData = [NSMutableArray arrayWithCapacity:_forecastDays];
			[self setCurrentKey:[self currentString]];
			[[self dataDictionary] setObject:currentData forKey:[self currentString]];
		} else {
			[[[self dataDictionary] objectForKey:[self currentKey]] addObject:[self currentString]];
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
- (NSMutableArray *)dailyMinTemp {
    return [[dailyMinTemp retain] autorelease];
}
- (NSMutableDictionary *)dataDictionary {
    return [[dataDictionary retain] autorelease];
}

- (void)setDataDictionary:(NSMutableDictionary *)newDataDictionary {
    if (dataDictionary != newDataDictionary) {
        [dataDictionary release];
        dataDictionary = [newDataDictionary copy];
    }
}
- (NSString *)currentKey {
    return [[_currentKey retain] autorelease];
}

- (void)setCurrentKey:(NSString *)newCurrentKey {
    if (_currentKey != newCurrentKey) {
        [_currentKey release];
        _currentKey = [newCurrentKey copy];
    }
}



- (void)setDailyMinTemp:(NSMutableArray *)newDailyMinTemp {
    if (dailyMinTemp != newDailyMinTemp) {
        [dailyMinTemp release];
        dailyMinTemp = [newDailyMinTemp copy];
    }
}

- (NSMutableArray *)dailyMaxTemp {
    return [[dailyMaxTemp retain] autorelease];
}

- (void)setDailyMaxTemp:(NSMutableArray *)newDailyMaxTemp {
    if (dailyMaxTemp != newDailyMaxTemp) {
        [dailyMaxTemp release];
        dailyMaxTemp = [newDailyMaxTemp copy];
    }
}

- (NSMutableArray *)precipProb {
    return [[precipProb retain] autorelease];
}

- (void)setPrecipProb:(NSMutableArray *)newPrecipProb {
    if (precipProb != newPrecipProb) {
        [precipProb release];
        precipProb = [newPrecipProb copy];
    }
}

- (NSMutableArray *)conditionIcons {
    return [[conditionIcons retain] autorelease];
}

- (void)setConditionIcons:(NSMutableArray *)newConditionIcons {
    if (conditionIcons != newConditionIcons) {
        [conditionIcons release];
        conditionIcons = [newConditionIcons copy];
    }
}


@end
