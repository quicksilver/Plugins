
#import <AddressBook/AddressBook.h>

#import "QSObject_ContactHandling.h"
#import "ABPerson_Display.h"

@implementation QSContactObjectHandler
// Object Handler Methods
- (BOOL)objectHasChildren:(id <QSObject > )object {
    return YES;
}

- (void)setQuickIconForObject:(QSObject *)object {
    [object setIcon:[QSResourceManager imageNamed:@"VCard"]];
}

- (BOOL)loadIconForObject:(QSObject *)object {
	ABPerson *person = (ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[object objectForType:@"ABPeopleUIDsPboardType"]];
	NSImage *personImage = [[NSImage alloc] initWithData:[person imageData]];
	if (personImage) {
		[personImage createRepresentationOfSize:NSMakeSize(32, 32)];
		[personImage createRepresentationOfSize:NSMakeSize(16, 16)];
		[object setIcon:personImage];
		[personImage release];
	}
	return YES;
}

- (QSObject *)objectWithAEDescriptor:(NSAppleEventDescriptor *)desc types:(NSArray *)types {
	//desc = [desc descriptorAtIndex:1];
	//	NSLog(@" > %@", desc = [desc paramDescriptorForKeyword:'from']);
	//		desc = [desc descriptorAtIndex:1];
	//	NSLog(@" > %@", desc = [desc paramDescriptorForKeyword:'seld']);
	//	NSLog(@"str %@", [desc objectValue]);
	//	NSLog(@"str %@", [desc objectValueAPPLE]);
	//	
	//	NSLog(@"str %@", [desc xobjectValue]);
	
	NSAppleScript *script = [[NSAppleScript alloc] initWithSource:@"on resolve (theContacts)\rtell app \"Address Book\" to return name of theContacts\rend"];
	desc = [script executeSubroutine:@"resolve" arguments:[NSArray arrayWithObject:desc] error:nil];
	NSLog(@"desc %@", [desc objectValueAPPLE]);
	return nil;
}

- (NSString *)identifierForObject:(id <QSObject > )object {
    return [[object objectForType:@"ABPeopleUIDsPboardType"] objectAtIndex:0];
}

+ (NSString *)contactlingNameForPerson:(ABPerson *)person label:(NSString *)label type:(NSString *)type asChild:(BOOL)child {
	if (child)
		return [NSString stringWithFormat:@"%@ %@ (%@)", label, type, [person displayName], label, type];
	else
		return [NSString stringWithFormat:@"%@'s %@ %@", [person displayName], label, type];
}

+ (NSArray *)URLObjectsForPerson:(ABPerson *)person asChild:(BOOL)asChild {
	ABMultiValue *urls = [person valueForProperty:kABURLsProperty];
	int i;
	NSMutableArray *contactlings = [NSMutableArray arrayWithCapacity:1];
	for (i = 0; i < [urls count]; i++) {
		NSString *address = [urls valueAtIndex:i];
		NSString *name = [self contactlingNameForPerson:person label:ABLocalizedPropertyOrLabel([urls labelAtIndex:i]) type:ABLocalizedPropertyOrLabel(kABURLsProperty) asChild:asChild];

		QSObject *obj = [QSObject URLObjectWithURL:address title:name];
        [obj setParentID:[person uniqueId]];
        [contactlings addObject:obj];
	}
	
	return contactlings;
}

+ (NSArray *)emailObjectsForPerson:(ABPerson *)person asChild:(BOOL)asChild {
	
	ABMultiValue *emailAddresses = [person valueForProperty:kABEmailProperty];
	int i;
    NSMutableArray *contactlings = [NSMutableArray arrayWithCapacity:1];
	for (i = 0; i < [emailAddresses count]; i++) {
		NSString *address = [emailAddresses valueAtIndex:i];
		NSString *name = [self contactlingNameForPerson:person label:ABLocalizedPropertyOrLabel([emailAddresses labelAtIndex:i]) type:[ABLocalizedPropertyOrLabel(kABEmailProperty) lowercaseString] asChild:asChild];

		QSObject *obj = [QSObject URLObjectWithURL:[NSString stringWithFormat:@"mailto:%@", address]
                                             title:name];
        [obj setParentID:[person uniqueId]];
        [contactlings addObject:obj];
	}
	return contactlings;
}

+ (NSArray *)phoneObjectsForPerson:(ABPerson *)person asChild:(BOOL)asChild {	
	ABMultiValue *phoneNumbers = [person valueForProperty:kABPhoneProperty];
    NSMutableArray *contactlings = [NSMutableArray arrayWithCapacity:1];
	int i;
	for (i = 0; i < [phoneNumbers count]; i++) {
		NSString *address = [phoneNumbers valueAtIndex:i];
		NSString *name = [self contactlingNameForPerson:person label:ABLocalizedPropertyOrLabel([phoneNumbers labelAtIndex:i]) type:[ABLocalizedPropertyOrLabel(kABPhoneProperty) lowercaseString] asChild:asChild];
        QSObject * obj = [QSObject objectWithString:address name:name type:QSContactPhoneType];
        [obj setParentID:[person uniqueId]];
        
		[contactlings addObject:obj];
	}
	return contactlings;
}


+ (NSArray *)addressObjectsForPerson:(ABPerson *)person asChild:(BOOL)asChild {
    ABMultiValue *addresses = [person valueForProperty:kABAddressProperty];
	NSMutableArray *contactlings = [NSMutableArray arrayWithCapacity:1];
	int i;
	for (i = 0; i < [addresses count]; i++) {
        ABMultiValue *address = [addresses valueAtIndex:i];
        NSString *string = [[[ABAddressBook sharedAddressBook] formattedAddressFromDictionary:(NSDictionary *)address] string];
		NSString *name = [self contactlingNameForPerson:person label:ABLocalizedPropertyOrLabel([addresses labelAtIndex:i]) type:[ABLocalizedPropertyOrLabel(kABAddressProperty) lowercaseString] asChild:asChild];
        QSObject * obj = [QSObject objectWithString:string name:name type:QSContactAddressType];
        [obj setParentID:[person uniqueId]];
        [contactlings addObject:obj];
    }
	return contactlings;
}

+ (NSArray *)imObjectsForPerson:(ABPerson *)person asChild:(BOOL)asChild {
	NSArray *imTypes = [NSArray arrayWithObjects:kABAIMInstantProperty, kABJabberInstantProperty, kABMSNInstantProperty, kABYahooInstantProperty, kABICQInstantProperty, nil];
    NSMutableArray *contactlings = [NSMutableArray arrayWithCapacity:1];
	foreach(type, imTypes) {
		ABMultiValue *ims = [person valueForProperty:type];
		int i;
		for (i = 0; i < [ims count]; i++) {
			NSString *name = [self contactlingNameForPerson:person label:ABLocalizedPropertyOrLabel([ims labelAtIndex:i]) type:ABLocalizedPropertyOrLabel(type) asChild:asChild];
			QSObject *obj = [QSObject objectWithString:[ims valueAtIndex:i] name:name type:QSIMAccountType];
            [obj setParentID:[person uniqueId]];
            [contactlings addObject:obj];
		}
	}
	return contactlings;
}

- (BOOL)loadChildrenForObject:(QSObject *)object {
    ABPerson *person = (ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[object objectForType:@"ABPeopleUIDsPboardType"]];
    
    NSMutableArray *contactlings = [NSMutableArray arrayWithCapacity:1];
    
	[contactlings addObjectsFromArray:[QSContactObjectHandler phoneObjectsForPerson:person asChild:YES]];
	[contactlings addObjectsFromArray:[QSContactObjectHandler emailObjectsForPerson:person asChild:YES]];
	[contactlings addObjectsFromArray:[QSContactObjectHandler imObjectsForPerson:person asChild:YES]];
	[contactlings addObjectsFromArray:[QSContactObjectHandler addressObjectsForPerson:person asChild:YES]];
	[contactlings addObjectsFromArray:[QSContactObjectHandler URLObjectsForPerson:person asChild:YES]];
	
	NSString *note = [person valueForProperty:kABNoteProperty];
    if (note) {
        QSObject *obj = [QSObject objectWithString:note];
        [obj setParentID:[object identifier]];
        [contactlings addObject:obj];
    }
	
    [contactlings makeObjectsPerformSelector:@selector(setParentID:) withObject:[object identifier]];
    
    if (contactlings) {
        [object setChildren:contactlings];
        return YES;
    }
    return NO;
}

- (NSString *)detailsOfObject:(QSObject *)object {
	/*    ABPerson *person = (ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[object objectForType:@"ABPeopleUIDsPboardType"]];
    NSString *companyName = [person valueForProperty:kABOrganizationProperty];
    NSString *jobTitle = [person valueForProperty:kABJobTitleProperty];
    if (jobTitle && companyName)
	return [NSString stringWithFormat:@"%@, %@", jobTitle, companyName];
    return nil;
    return [[object objectForType:@"ABPeopleUIDsPboardType"] objectAtIndex:0]; */
	return [[[ABAddressBook sharedAddressBook] recordForUniqueId:[object objectForType:@"ABPeopleUIDsPboardType"]] jobTitle];
}

@end


@implementation QSObject (ContactHandling)

+ (id)objectWithPerson:(ABPerson *)person {
    return [[[QSObject alloc] initWithPerson:person] autorelease];
}

// - -NSString *formalName(NSString *title, NSString *firstName, NSString *middleName, NSString *lastName, NSString *suffix) {
//NSMutableString *formalName=

- (NSString *)nameForRecord:(ABRecord *)record {
    return nil;
}


- (void)loadContactInfo {
	ABPerson *person = (ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[[self arrayForType:@"ABPeopleUIDsPboardType"]lastObject]];
	
	
	NSString *newName = nil;
	NSString *newLabel = nil;
	
	NSString *firstName = [person valueForProperty:kABFirstNameProperty];
	NSString *lastName = [person valueForProperty:kABLastNameProperty];
	NSString *middleName = [person valueForProperty:kABMiddleNameProperty];
//	NSString *nickName = [person valueForProperty:kABNicknameProperty];
  
	NSString *title = [person valueForProperty:kABTitleProperty];
	NSString *suffix = [person valueForProperty:kABSuffixProperty];
	
	
	newLabel = formattedContactName(firstName, lastName, middleName, title, suffix);
	newName = [person displayName];
	
	[self setName:newName];
	
	if (newLabel)
		[self setLabel:newLabel];
	
	[self setPrimaryType:@"ABPeopleUIDsPboardType"];
	
	NSString *group = [[NSUserDefaults standardUserDefaults]stringForKey:@"QSABPreferredDistribution"];
	if (!group)group = @"Quicksilver";
	
	ABSearchElement *groupSearch = [ABGroup searchElementForProperty:kABGroupNameProperty label:nil key:nil value:group comparison:kABPrefixMatchCaseInsensitive];
	
	ABGroup *qsGroup = [[[ABAddressBook sharedAddressBook] recordsMatchingSearchElement:groupSearch] lastObject];
	
	NSString *distID = [qsGroup distributionIdentifierForProperty:kABEmailProperty person:person];
	ABMultiValue *emailAddresses = [person valueForProperty:kABEmailProperty];
	int multiIndex = (distID ? [emailAddresses indexForIdentifier:distID] : 0);
	NSString *address = [emailAddresses valueAtIndex:multiIndex];

	if (address)
		[self setObject:[NSArray arrayWithObject:address] forType:QSEmailAddressType];
	
	/*	NSArray *aimAccounts = [person valueForProperty:kABAIMInstantProperty];
	if ([aimAccounts count])
		[self setObject:[NSString stringWithFormat:@"AIM:%@", [aimAccounts valueAtIndex:0]] forType:QSIMAccountType]; */
	[self useDefaultIMFromPerson:person];
}

- (BOOL)useDefaultEmailFromPerson:(ABPerson *)person {
	return NO;
}

/*!
* @abstract If possible, makes this object respond to IM actions by associating it with the first IM account it finds.
 * @param person The person to search for IM accounts.
 * @result YES if a suitable IM account was found, NO otherwise.
 */
- (BOOL)useDefaultIMFromPerson:(ABPerson *)person {
	ABMultiValue *accounts;
	NSDictionary *imProperties = [NSDictionary dictionaryWithObjectsAndKeys:@"AIM:", kABAIMInstantProperty, @"MSN:", kABMSNInstantProperty, @"Yahoo!:", kABYahooInstantProperty, @"ICQ:", kABICQInstantProperty, @"Jabber:", kABJabberInstantProperty, nil];
	
	foreachkey (property, prefix, imProperties) {
		accounts = [person valueForProperty:property];
		if ([accounts count]) {
			[self setObject:[prefix stringByAppendingString:[accounts valueAtIndex:0]] forType:QSIMAccountType];
			return YES;
		}
	}
	return NO;
}

- (id)initWithPerson:(ABPerson *)person {
	//id object = [QSObject objectWithIdentifier:[person uniqueId]];
    if ((self = [self init])) {
        [data setObject:[NSArray arrayWithObject:[person uniqueId]] forKey:@"ABPeopleUIDsPboardType"];
		//[QSObject registerObject:self withIdentifier:[self identifier]];
        [self setIdentifier:[person uniqueId]];
		[self loadContactInfo];
    }
    return self;
}

@end
