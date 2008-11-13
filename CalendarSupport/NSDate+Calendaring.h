//
//  NSDate+Calendaring.h
//  QSCalendarSupport
//
//  Created by Brian Donovan on 31/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "VFileProperty.h"

@interface NSCalendarDate (VCalendar)

+ (id)dateWithVFileDateProperty:(VFileProperty *)property;

@end
