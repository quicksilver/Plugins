//
//  QSObject_BDExtensions.h
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on 11/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QSCore/QSMacros.h>
#import "QSAdiumObjectSource.h"

@interface QSObject (Transformation)

+ (NSMutableArray *)objectsForArray:(NSArray *)array type:(NSString *)type value:(SEL)valueSelector name:(SEL)nameSelector details:(SEL)detailsSelector;

@end

@interface QSObject (Adium)

+ (NSMutableArray *)objectsForAdiumContacts:(NSArray *)contacts;

@end