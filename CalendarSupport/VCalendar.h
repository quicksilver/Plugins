//
//  VCalendar.h
//  QSCalendarSupport
//
//  Created by Brian Donovan on 31/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSScanner.h>
#import "VFileObject.h"

@interface VCalendar : VFileObject {

}

+ (id)calendarWithScanner:(NSScanner *)scanner;
+ (id)calendarWithString:(NSString *)string;
+ (id)calendarWithData:(NSData *)data;
+ (id)calendarWithFileObject:(VFileObject *)object;

- (id)initWithScanner:(NSScanner *)scanner;
- (id)initWithString:(NSString *)string;
- (id)initWithData:(NSData *)data;
- (id)initWithFileObject:(VFileObject *)object;

- (NSString *)calendarName;
- (NSString *)productIdentifier;
- (NSString *)version;
- (NSString *)scale;
- (NSString *)method;
- (NSString *)identifier;
- (NSString *)timezone;
- (NSArray *)events;
- (NSArray *)todoEntries;
- (NSArray *)journalEntries;

@end
