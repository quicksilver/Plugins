//
//  ABPerson-DisplayProperties.m
//  QSAddressBookPlugIn
//
//  Created by Brian Donovan on 23/03/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "ABPerson_Display.h"

@implementation ABRecord (Display)

- (BOOL)firstNameFirst {
  
	if (![self isKindOfClass:[ABPerson class]]) return NO;
  
	int nameOrderingFlags = [[self valueForProperty:kABPersonFlags] intValue] & kABNameOrderingMask;
	
	if (nameOrderingFlags == kABDefaultNameOrdering) {
		nameOrderingFlags = [[ABAddressBook sharedAddressBook] defaultNameOrdering];
	}
	
	return (nameOrderingFlags == kABFirstNameFirst);
}

- (NSString *)displayName {
  NSString *first = nil, *last = nil;

  if ([self isKindOfClass:[ABPerson class]]) { // ABMailRecent doesn't understand these properties
    int flags = [[self valueForProperty:kABPersonFlags] intValue];
    
    // it's a company, just return the company name
    if (flags & kABShowAsMask & kABShowAsCompany)
      return [self valueForProperty:kABOrganizationProperty];
    
    first = [self valueForProperty:kABNicknameProperty];
  }
  
  if (!first) 
     first = [self valueForProperty:kABFirstNameProperty];
	last = [self valueForProperty:kABLastNameProperty];
	
	if (first) {
		if (last)
			return [self firstNameFirst] ? [NSString stringWithFormat:@"%@ %@", first, last]
                                   : [NSString stringWithFormat:@"%@, %@", last, first];
		else
			return first;
	} else {
		if (last)
			return last;
		else
			return @"No Name";
	}
}

- (NSString *)jobTitle {
  
	if (![self isKindOfClass:[ABPerson class]]) return nil;
  
	// companies do not have job titles
  if ([[self valueForProperty:kABPersonFlags] intValue] & kABShowAsMask & kABShowAsCompany)
		return nil;
	
	NSString *title		= [self valueForProperty:kABTitleProperty],
			 *company	= [self valueForProperty:kABOrganizationProperty];
	
	if (title) {
		if (company)
			return [NSString stringWithFormat:@"%@, %@", title, company];
		else
			return title;
	} else {
		if (company)
			return company;
		else
			return nil;
	}
}

@end
