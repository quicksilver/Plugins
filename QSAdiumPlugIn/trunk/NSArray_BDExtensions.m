//
//  NSArray_BDExtensions.m
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on 11/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <QSCore/QSMacros.h>
#import "NSArray_BDExtensions.h"

@implementation NSArray (QSInformalProtocol)

- (NSArray *)setObject:(SEL)objectSelector forType:(NSString *)type fromArray:(NSArray *)array {
	int i = 0;
	
	foreach (object, self) {
		[object setObject:[[array objectAtIndex:i++] performSelector:objectSelector] forType:type];
	}
	
	return self;
}

- (NSArray *)setIcon:(SEL)iconSelector withDefault:(NSImage *)defaultIcon fromArray:(NSArray *)array {
	int i = 0;
	id icon = nil;

	foreach (object, self) {
		if (!(icon = [[array objectAtIndex:i++] performSelector:iconSelector])) {
			icon = defaultIcon;
		} else if ([icon isKindOfClass:[NSData class]]) {
			icon = [[[NSImage alloc] initWithData:icon] autorelease];
		}
		[object setIcon:icon];
	}
	
	return self;
}

- (NSArray *)setDetails:(NSString *)keyPath fromArray:(NSArray *)array {
	int i = 0;
	NSString *details;
	
	foreach (object, self) {
		if (details = [[array objectAtIndex:i++] valueForKeyPath:keyPath]) {
			[object setDetails:details];
		}
	}
	
	return self;
}

- (NSMutableArray *)arrayWithMeta:(NSString *)key havingValue:(id)value {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:[self count]];
	
	foreach (object, self) {
		if ([[object objectForMeta:key] isEqual:value])
			[array addObject:[object copy]];
	}
	
	return array;
}
@end
