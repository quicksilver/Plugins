//
//  VCalendar.m
//  QSCalendarSupport
//
//  Created by Brian Donovan on 31/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "VCalendar.h"
#import "VFileGlobals.h"


@implementation VCalendar

+ (id)calendarWithScanner:(NSScanner *)scanner {
	return [[[VCalendar alloc] initWithScanner:scanner] autorelease];
}

+ (id)calendarWithString:(NSString *)string {
	return [[[VCalendar alloc] initWithString:string] autorelease];
}

+ (id)calendarWithData:(NSData *)data {
	return [[[VCalendar alloc] initWithData:data] autorelease];
}

+ (id)calendarWithFileObject:(VFileObject *)object {
	return [[[VCalendar alloc] initWithFileObject:object] autorelease];
}


- (id)initWithScanner:(NSScanner *)scanner {
	if (!(self = [super init]))
		return nil;
	
	return [self initWithFileObject:[VFileObject objectWithScanner:scanner]];
}

- (id)initWithString:(NSString *)string {
	if (!(self = [super init]))
		return nil;
	
	return [self initWithFileObject:[VFileObject objectWithString:string]];
}

- (id)initWithData:(NSData *)data {
	if (!(self = [super init]))
		return nil;
	
	return [self initWithFileObject:[VFileObject objectWithData:data]];
}

- (id)initWithFileObject:(VFileObject *)object {
	if (!(self = [super init]))
		return nil;
	
	if (!eqci([object type], VCALENDARType)) {
		NSLog(@"Error: Parsed object is type %@, expecting %@", [object type], VCALENDARType);
		[self autorelease];
		return nil;
	}
	
	[self setType:VCALENDARType];
	[self setContents:[object contents]];
	
	return self;
}


- (NSString *)calendarName {
	return [self parsedValueForProperty:VCALENDARName];
}

- (NSString *)productIdentifier {
	return [self parsedValueForProperty:VCALENDARProductIdentifier];
}

- (NSString *)version {
	return [self parsedValueForProperty:VCALENDARVersion];
}

- (NSString *)scale {
	return [self parsedValueForProperty:VCALENDARScale];
}

- (NSString *)method {
	return [self parsedValueForProperty:VCALENDARMethod];
}

- (NSString *)identifier {
	return [self parsedValueForProperty:VCALENDARIdentifier];
}

- (NSString *)timezone {
	return [self parsedValueForProperty:VCALENDARTimezoneProperty];
}

- (NSArray *)events {
	return [self objectsForType:VCALENDAREventType];
}

- (NSArray *)todoEntries {
	return [self objectForType:VCALENDARTodoType];
}
- (NSArray *)journalEntries;

@end
