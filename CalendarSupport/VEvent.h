//
//  VEvent.h
//  QSCalendarSupport
//
//  Created by Brian Donovan on 31/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Foundation/NSScanner.h>

@interface VEvent : VFileObject {

}

+ (id)eventWithScanner:(NSScanner *)scanner;
+ (id)eventWithString:(NSString *)string;
+ (id)eventWithData:(NSData *)data;
+ (id)eventWithFileObject:(VFileObject *)object;

- (id)initWithScanner:(NSScanner *)scanner;
- (id)initWithString:(NSString *)string;
- (id)initWithData:(NSData *)data;
- (id)initWithFileObject:(VFileObject *)object;

- (NSCalendarDate *)startDate;
- (NSCalendarDate *)endDate;
- (NSString *)location;
- (NSString *)status;
- (NSString *)uid;
- (NSDate *)timeStamp;
- (int)sequence;
- (NSString *)description;
- (NSString *)summary;
- (NSArray *)attendees;
- (VFileProperty *)organizer;
- (NSURL *)organizerAddress;
- (NSString *)organizerName;

@end
