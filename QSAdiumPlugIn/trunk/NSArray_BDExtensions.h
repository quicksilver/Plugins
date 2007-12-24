//
//  NSArray_BDExtensions.h
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on 11/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSArray (QSObjectInformalProtocol)

- (NSArray *)setObject:(SEL)objectSelector forType:(NSString *)type fromArray:(NSArray *)array;
- (NSArray *)setIcon:(SEL)iconSelector withDefault:(NSImage *)defaultIcon fromArray:(NSArray *)array;
- (NSMutableArray *)arrayWithMeta:(NSString *)key havingValue:(id)value;

@end
