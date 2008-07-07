#import "QSObject_ContactHandling.h"
#import "ABPerson_Display.h"
#import "QSABSource.h"

@implementation QSAddressBookObjectSource
- (id)init {
	if ((self = [super init])) {
		contactDictionary = [[NSMutableDictionary alloc]init];
		addressBookModDate = [NSDate timeIntervalSinceReferenceDate];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addressBookChanged:) name:kABDatabaseChangedExternallyNotification object:nil];
	}
	return self;
}

- (BOOL)usesGlobalSettings {return YES;}


- (NSView *)settingsView {
	if ([NSApp featureLevel] < 3)return nil;
  if (![super settingsView]) {
    [NSBundle loadNibNamed:NSStringFromClass([self class]) owner:self];
		
		
    //	[self refreshGroupList];
	}
  return [super settingsView];
}


- (NSArray *)contactGroups {
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"All Contacts"];
	
	ABAddressBook *book = [ABAddressBook sharedAddressBook];
	NSMutableArray *groups = [[book groups] mutableCopy];
	groups = [[[groups valueForKey:kABGroupNameProperty]mutableCopy]autorelease];
	[groups removeObject:@"Me"];
	[groups sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	[array addObjectsFromArray:groups];
    [groups release];
	return array;
}


- (NSArray *)contactDistributions {
	NSMutableArray *array = [NSMutableArray array];
	[array addObject:@"None"];
	
	ABAddressBook *book = [ABAddressBook sharedAddressBook];
	NSMutableArray *groups = [[book groups] mutableCopy];
	groups = [[[groups valueForKey:kABGroupNameProperty]mutableCopy]autorelease];
	[groups removeObject:@"Me"];
	[groups sortUsingSelector:@selector(caseInsensitiveCompare:)];
	
	[array addObjectsFromArray:groups];
    [groups release];
	return array;
}
// - (void)refreshGroupList {
//	[groupList removeAllItems];
//	[distributionList removeAllItems];
//	
//
//	NSLog(@"group %@", groups);
//	[groupList addItemWithTitle:@"All Contacts"];
//	[[groupList menu]addItem:[NSMenuItem separatorItem]];
//	[groupList addItemsWithTitles:groups];
//	
//	[distributionList addItemWithTitle:@"Default Emails"];
//	[[distributionList menu]addItem:[NSMenuItem separatorItem]];
//	[distributionList addItemsWithTitles:groups];
//}

- (NSImage *)iconForEntry:(NSDictionary *)theEntry {return [[NSWorkspace sharedWorkspace]iconForFile:@"/Applications/Address Book.app"];}

- (NSArray *)contactWebPages {
	NSMutableArray *array = [NSMutableArray array];
	
	ABAddressBook *book = [ABAddressBook sharedAddressBook];
	NSArray *people = [book people];
	NSEnumerator *personEnumerator = [people objectEnumerator];
	id thePerson;
	while ((thePerson = [personEnumerator nextObject])) {
		NSString *homePage = [thePerson valueForProperty:kABHomePageProperty];
		if (!homePage)continue;
		
		NSString *name = @"(no name)";
		NSString *namePiece;
		
		BOOL showAsCompany = [[thePerson valueForProperty:kABPersonFlags] intValue] & kABShowAsMask & kABShowAsCompany;
		if (showAsCompany) {
			if ((namePiece = [thePerson valueForProperty:kABOrganizationProperty]))
				name = namePiece;
		}else {
			NSMutableArray *nameArray = [NSMutableArray arrayWithCapacity:3];
			if ((namePiece = [thePerson valueForProperty:kABFirstNameProperty]))
				[nameArray addObject:namePiece];
			if ((namePiece = [thePerson valueForProperty:kABMiddleNameProperty]))
				[nameArray addObject:namePiece];
			if ((namePiece = [thePerson valueForProperty:kABLastNameProperty]))
				[nameArray addObject:namePiece];
			if ([nameArray count])name = [nameArray componentsJoinedByString:@" "];
		}
		QSObject *object = [QSObject URLObjectWithURL:homePage
                                          title:name];
		
		[array addObject:object];
	}
	NSSortDescriptor *nameDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES] autorelease];
  [array sortUsingDescriptors:[NSArray arrayWithObject:nameDescriptor]];
	
	return array;
}
- (void) addressBookChanged:(NSNotification *)notif {
	NSArray *inserted = [[notif userInfo] objectForKey:kABInsertedRecords];
	NSArray *updated = [[notif userInfo] objectForKey:kABUpdatedRecords];
	NSArray *deleted = [[notif userInfo] objectForKey:kABDeletedRecords];
	int count, i;
	QSObject *thisPerson;
	NSString *thisID;
	//	if (VERBOSE) NSLog(@"AB %d %d %d", [inserted count], [updated count], [deleted count]);
	if ((count = [updated count])) {
		NSEnumerator *objEnum = [[contactDictionary objectsForKeys:updated notFoundMarker:[NSNull null]]objectEnumerator];
		QSObject *person = nil;
		while ((person = [objEnum nextObject])) {
			if ([person isKindOfClass:[QSObject class]])
				[person loadContactInfo];
		}
		
	} 
	if ((count = [inserted count])) {
		//NSEnumerator *idEnum = [inserted objectEnumerator];
		ABAddressBook *book = [ABAddressBook sharedAddressBook];
		
		ABSearchElement *groupSearch = [ABGroup searchElementForProperty:kABGroupNameProperty label:nil key:nil value:@"Quicksilver" comparison:kABPrefixMatchCaseInsensitive];
		ABGroup *qsGroup = [[book recordsMatchingSearchElement:groupSearch]lastObject];
		
		for (i = 0; i < count; i++) {
			thisID = [inserted objectAtIndex:i];
			ABPerson *person = (ABPerson *)[book recordForUniqueId:thisID];
			
			if ([[qsGroup members]containsObject:person]) {
				thisPerson = [QSObject objectWithPerson:person];
				[contactDictionary setObject:thisPerson forKey:thisID];
			}
		}
		
	} 
	if ((count = [deleted count])) {
		[contactDictionary removeObjectsForKeys:deleted];
	}
	
	[self invalidateSelf];
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry {
	return ([indexDate timeIntervalSinceReferenceDate] > addressBookModDate);
}

- (void)invalidateSelf {
	addressBookModDate = [NSDate timeIntervalSinceReferenceDate];
	[super invalidateSelf];
}


- (BOOL)scanInMainThread { return YES;}

- (BOOL)loadChildrenForObject:(QSObject *)object {
  NSArray *abchildren = [self objectsForEntry:nil];
  [object setChildren:abchildren];
  return YES;
}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
	NSMutableArray *array = [NSMutableArray array];
    
    ABAddressBook *book = [ABAddressBook sharedAddressBook];
    
    NSArray *people = nil;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    BOOL includePhone = [defaults boolForKey:@"QSABIncludePhone"];
    BOOL includeURL = [defaults boolForKey:@"QSABIncludeURL"];
    BOOL includeIM = [defaults boolForKey:@"QSABIncludeIM"];
    BOOL includeEmail = [defaults boolForKey:@"QSABIncludeEmail"];
    BOOL includeContacts = [defaults boolForKey:@"QSABIncludeContacts"];
    
    NSString *group = [defaults stringForKey:@"QSABGroupLimit"];
    if (!group) group = @"Quicksilver";
    ABSearchElement *groupSearch = [ABGroup searchElementForProperty:kABGroupNameProperty label:nil key:nil value:group comparison:kABPrefixMatchCaseInsensitive];
    ABGroup *qsGroup = [[book recordsMatchingSearchElement:groupSearch] lastObject];
    people = [qsGroup members];
    
    if (![people count]) people = [book people];
    NSEnumerator *personEnumerator = [people objectEnumerator];
    id thePerson;
    while ((thePerson = [personEnumerator nextObject])) {
        if (includeContacts)	[array addObject:[QSObject objectWithPerson:thePerson]];
        if (includePhone)		[array addObjectsFromArray:[QSContactObjectHandler phoneObjectsForPerson:thePerson asChild:NO]];
        if (includeURL)			[array addObjectsFromArray:[QSContactObjectHandler URLObjectsForPerson:thePerson asChild:NO]];
        if (includeIM)			[array addObjectsFromArray:[QSContactObjectHandler imObjectsForPerson:thePerson asChild:NO]];
        if (includeEmail)		[array addObjectsFromArray:[QSContactObjectHandler emailObjectsForPerson:thePerson asChild:NO]];
    }
    return array;
}

@end



@implementation QSABMailRecentsObjectSource
- (NSImage *)iconForEntry:(NSDictionary *)theEntry {return [[NSWorkspace sharedWorkspace] iconForFile:@"/Applications/Mail.app"];}

- (NSArray *)objectsForEntry:(NSDictionary *)theEntry {
	NSMutableArray *abArray = [NSMutableArray arrayWithCapacity:1];
	NSEnumerator *personEnumerator = [[[ABAddressBook sharedAddressBook] performSelector:@selector(mailRecents)] objectEnumerator];
	ABPerson *thePerson;
	while ((thePerson = [personEnumerator nextObject])) {
        
		NSString *email = [thePerson valueForProperty:kABEmailProperty];
		
		if ([thePerson valueForProperty:@"PersonUID"]) continue;  
		
#warning I should use this to set the default email for an addressbook contact
		
		NSString *name = [thePerson displayName];
		
		if (email) {
			QSObject *emailObject = [QSObject URLObjectWithURL:[NSString stringWithFormat:@"mailto:%@", email]
                                                         title:[NSString stringWithFormat:@"%@ (recent email)", [name length] ? name : email]];
			
			[abArray addObject:emailObject];
		}
	}
	return abArray;
}

@end

# define kContactShowAction @"QSABContactShowAction"
# define kContactEditAction @"QSABContactEditAction"

@implementation QSABContactActions

// - (NSArray *)actions {
//	
//	NSMutableArray *actionArray = [NSMutableArray arrayWithCapacity:5];
//	//NSString *chatApp = [[NSWorkspace sharedWorkspace]absolutePathForAppBundleWithIdentifier:[QSReg chatMediatorID]];
//	
//	//NSImage *chatIcon = [[NSWorkspace sharedWorkspace]iconForFile:chatApp];
//	   
//	//  NSImage *finderProxyIcon = [[(QSController *)[NSApp delegate]finderProxy]icon];  
//	
//	QSAction *action;
//	
//	action = [QSAction actionWithIdentifier:kContactShowAction];
//	[action setIcon:        [QSResourceManager imageNamed:@"com.apple.AddressBook"]];
//	[action setProvider:    self];
//	[action setArgumentCount:1];
//	[actionArray addObject:action];  
//	
//	action = [QSAction actionWithIdentifier:kContactEditAction];
//	[action setIcon:        [QSResourceManager imageNamed:@"com.apple.AddressBook"]];
//	[action setProvider:    self];
//	[action setArgumentCount:1];
//	[actionArray addObject:action];  
//	
//	
//	
//	return actionArray; 	
//}

/*
 - (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject {
   NSMutableArray *newActions = [NSMutableArray arrayWithCapacity:1];
   if ([[dObject primaryType] isEqualToString:@"ABPeopleUIDsPboardType"]) {
     ABPerson *person = (ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[dObject identifier]];
     
     [newActions addObject:kContactShowAction];
     [newActions addObject:kContactEditAction];
     
     
     if (0 && [(NSArray *)[person valueForProperty:kABAIMInstantProperty]count]) {
       [newActions addObject:kContactIMAction];  
       // ***warning   * learn to check if they are online
       [newActions addObject:kContactSendItemIMAction];
       
       //  Person *thisPerson = [[[AddressCard alloc]initWithABPerson:person]autorelease];
       //  [IMService connectToDaemonWithLaunch:NO];
       
     }
     // [AddressBookPeople loadBuddyList];
     
     // People *people = [[[People alloc]init]autorelease];
     //[people addPerson:thisPerson];
     //NSLog(@"%@", );
     //  [People sendMessageToPeople:[NSArray arrayWithObject:thisPerson]];
     // [self defaultEmailAddress];
   }else if ([dObject objectForType:QSTextType]) {
     [newActions addObject:kItemSendToContactIMAction];
   }
   
   return newActions;
 }
 
 
 - (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
   //  NSLog(@"request");
   if ([action isEqualToString:kContactSendItemEmailAction]) {
     return nil; //[QSLibarrayForType:NSFilenamesPboardType];
   }
   if ([action isEqualToString:kContactSendItemIMAction]) {
     
     QSObject *textObject = [QSObject textProxyObjectWithDefaultValue:@""];
     return [NSArray arrayWithObject:textObject]; //[QSLibarrayForType:NSFilenamesPboardType];
                                                  //   return [NSArray arrayWithObject:QSTextProxy]; //[QSLibarrayForType:NSFilenamesPboardType];
   }
   if ([action isEqualToString:kItemSendToContactEmailAction]) {
     QSLibrarian *librarian = QSLib;
     return [librarian scoredArrayForString:nil inSet:[librarian arrayForType:@"ABPeopleUIDsPboardType"]];
     return [[librarian arrayForType:@"ABPeopleUIDsPboardType"] sortedArrayUsingSelector:@selector(nameCompare:)];
   }
   return nil;
 }
 
 - (QSObject *)performAction:(QSAction *)action directObject:(QSBasicObject *)dObject indirectObject:(QSBasicObject *)iObject {
   //NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
   if ([[action identifier] isEqualToString:kContactShowAction]) {
			} else if ([[action identifier] isEqualToString:kContactEditAction]) {
      }
   else if ([[action identifier] isEqualToString:kContactEmailAction]) {
     ABPerson *person = (ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[dObject identifier]];
     NSString *address = [[person valueForProperty:kABEmailProperty]valueAtIndex:0];
     [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", address]]];
   }
   return nil;
 }
 
 */

- (QSObject *)showContact:(QSObject *)dObject {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"addressbook://%@", [dObject objectForType:QSABPersonType]]]];
	return nil;
}

- (QSObject *)editContact:(QSObject *)dObject {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"addressbook://%@?edit", [dObject objectForType:QSABPersonType]]]];
	return nil;
}


- (QSObject *)sendItemViaIM:(QSObject *)dObject toPerson:(QSObject *)iObject {
	if ([dObject validPaths]) {
		[[QSReg preferredChatMediator] sendFile:[dObject stringValue] toPerson:[iObject identifier]];
	}else {
		[[QSReg preferredChatMediator] sendText:[dObject stringValue] toPerson:[iObject identifier]];
	}	
	return nil;
}

- (QSObject *)composeIMToPerson:(QSObject *)dObject {
	[[QSReg preferredChatMediator] chatWithPerson:[dObject identifier]];
	return nil;
}


@end
