//
//  VEvent.m
//  QSCalendarSupport
//
//  Created by Brian Donovan on 31/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "VEvent.h"


@implementation VEvent

+ (id)eventWithScanner:(NSScanner *)scanner {
	return [[[VEvent alloc] initWithScanner:scanner] autorelease];
}

+ (id)eventWithString:(NSString *)string {
	return [[[VEvent alloc] initWithString:string] autorelease];
}

+ (id)eventWithData:(NSData *)data {
	return [[[VEvent alloc] initWithData:data] autorelease];
}

+ (id)eventWithFileObject:(VFileObject *)object {
	return [[[VEvent alloc] initWithFileObject:object] autorelease];
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
	
	if (!eqci([object type], VCALENDAREventType)) {
		NSLog(@"Error: Parsed object is type %@, expecting %@", [object type], VCALENDAREventType);
		[self autorelease];
		return nil;
	}
	
	[self setType:VCALENDAREventType];
	[self setContents:[object contents]];
	
	return self;
}


- (NSCalendarDate *)startDate {
	return [NSCalendarDate dateWithVFileDateProperty:[self firstPropertyForName:VCALENDARDateTimeStart]];
}

- (NSCalendarDate *)endDate {
	return [NSCalendarDate dateWithVFileDateProperty:[self firstPropertyForName:VCALENDARDateTimeEnd]];
}

- (NSString *)location {
	return [self parsedValueForProperty:VCALENDARLocation];
}

- (NSString *)status {
	return [self parsedValueForProperty:VCALENDARStatus];
}

- (NSString *)uid {
	return [self parsedValueForProperty:VCALENDARIdentifier];
}

- (NSDate *)timeStamp {
	return [self parsedValueForProperty:VCALENDARTimestamp];
}

- (int)sequence {
	return [[self parsedValueForProperty:VCALENDARSequence] intValue];
}

- (NSString *)description {
	return [self parsedValueForProperty:VCALENDARDescription];
}

- (NSString *)summary {
	return [self parsedValueForProperty:VCALENDARSummary];
}

- (NSArray *)attendees {
	return [self propertiesForName:VCALENDARAttendee];
}

- (VFileProperty *)organizer {
	return [self firstPropertyForName:VCALENDAROrganizer];
}

- (NSURL *)organizerAddress {
	return [self parsedValueForProperty:VCALENDAROrganizer];
}

- (NSString *)organizerName {
	return [[self organizer] firstValueForKey:VCALENDARCommonName];
}

- (id)parsedValueForProperty:(NSString *)propName {
	if (eqci(propName, VCALENDAROrganizer)) {
		return [NSURL URLWithString:[super parsedValueForProperty:propName]];
	} else if (eqci(propName, VCALENDARSequence)) {
		return [[super parsedValueForProperty:propName] convert
	}
}

@end
