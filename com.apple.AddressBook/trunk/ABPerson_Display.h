//
//  ABPerson-DisplayProperties.h
//  QSAddressBookPlugIn
//
//  Created by Brian Donovan on 23/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/ABPerson.h>
#import <AddressBook/ABAddressBook.h>

@interface ABRecord (Display)

- (BOOL)firstNameFirst;
- (NSString *)displayName;
- (NSString *)jobTitle;

@end
