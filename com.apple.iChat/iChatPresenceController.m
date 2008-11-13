//
//  iChatPresenceController.m
//  iChatElement
//
//  Created by Nicholas Jitkoff on 12/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "iChatPresenceController.h"


#import <InstantMessage/IMService.h>
#import <ScriptingBridge/ScriptingBridge.h>

@implementation iChatPresenceController
@synthesize identities, infoForAllScreenNames, identitiesByAccount;


- (id) init
{
  self = [super init];
  if (self != nil) {
    // Register for Address Book notifications
    [[NSNotificationCenter defaultCenter] 
     addObserver:self selector:@selector(addressBookDatabaseExternallyChanged:) name:kABDatabaseChangedExternallyNotification object:nil];
    
    NSNotificationCenter *notificationCenter = [IMService notificationCenter];
    [notificationCenter addObserver:self selector:@selector(imBuddyInformationChangedNotification:) name:IMPersonInfoChangedNotification object:nil];
    [notificationCenter addObserver:self selector:@selector(imBuddyInformationChangedNotification:) name:IMPersonStatusChangedNotification  object:nil];
  }
  return self;
}

// Notifications
-(void) imBuddyInformationChangedNotification:(NSNotification *)notification {
  IMService *service = [notification object];  
  NSDictionary *info = [notification userInfo];
  NSString *serviceName = [service name];
  NSString *screenName = [info objectForKey: IMPersonScreenNameKey];
  [infoForAllScreenNames setObject:info 
                            forKey:[NSString stringWithFormat:@"%@:%@", serviceName, screenName]];
  //NSLog(@"Changed %@", [service internalName], [NSString stringWithFormat:@"%@:%@", serviceName, screenName]);
}
- (void)updateObjectWithPresence:(QSObject *)object identity:(NSDictionary *)identity{
  ABPerson *person = [identity objectForKey:@"ABPerson"];
  NSArray *resources = [identity objectForKey:@"identifiers"];
  
  
  int bestStatus = IMPersonStatusOffline;
  NSString *bestResource = nil;
  for (NSString *resource in resources) {
    NSNumber *status = [[infoForAllScreenNames objectForKey:resource] objectForKey:IMPersonStatusKey];
    if (status) {
      IMPersonStatus thisStatus = [status intValue];
      
      if ( IMComparePersonStatus(bestStatus, thisStatus) != NSOrderedAscending){
        
        bestStatus = thisStatus;  
        bestResource = resource;
      }
    }
  }
//  if (bestStatus == IMPersonStatusOffline) return;
  //NSLog(@"status %d %p", bestStatus, bestResource);
  NSString *resource = bestResource;
  NSDictionary *presenceInfo = [infoForAllScreenNames objectForKey:resource];
  //if (!presenceInfo) continue;
  
  // Get aBuddy's online status associated to this screen name
  NSNumber *status = [presenceInfo objectForKey:IMPersonStatusKey];
  NSString *statusMessage = [presenceInfo objectForKey:IMPersonStatusMessageKey];
  
  // Get aBuddy's picture; it is a NSData object
  NSData *buddyPicture = [presenceInfo objectForKey:IMPersonPictureDataKey];
  
  // Keep track of screen name
  NSString *buddyScreenName = [presenceInfo objectForKey:IMPersonScreenNameKey];
  
  NSString *firstName = [presenceInfo objectForKey:IMPersonFirstNameKey];
  NSString *lastName = [presenceInfo objectForKey:IMPersonLastNameKey];
  
  NSString *buddyName = firstName;
  if (![buddyName length]) {
    buddyName = lastName;
  } else if ([lastName length]) {
    buddyName = [buddyName stringByAppendingFormat:@" %@", lastName];
  }
  
  if (resource && (!buddyName || [buddyName isEqualToString:buddyScreenName])) {
    NSString *accountid = [[resource componentsSeparatedByString:@":"] componentsJoinedByString:@"."];
    NSString *path = [NSString stringWithFormat:@"/Volumes/Lore/Library/Application Support/Adium 2.0/Users/Default/ByObject/%@.plist", accountid];
    
    NSDictionary *adiumInfo = [NSDictionary dictionaryWithContentsOfFile:path];
    buddyName = [adiumInfo objectForKey:@"Alias"];
    //NSLog(@"adim %@", path);
  }
  if (!buddyName) buddyName = buddyScreenName;
  
  
  if (![statusMessage length] && [status intValue] == IMPersonStatusIdle)
    statusMessage = [NSString stringWithFormat:@"Idle (%dm) ", (int)(-[[presenceInfo objectForKey:IMPersonIdleSinceKey] timeIntervalSinceNow] /60)];
  if (![statusMessage length] && [status intValue] == IMPersonStatusAway)
    statusMessage = @"Away";
  
  //    NSMutableDictionary *buddyInfo = [NSMutableDictionary presenceInfoWithObjectsAndKeys:
  //                                 buddyScreenName, @"buddyScreenName",
  //                                 buddyName, @"buddyName",
  //                                 buddyPicture, @"buddyPicture",
  //                                 [NSNumber numberWithUnsignedInt:bestStatus], @"buddyStatus",
  //                                 nil];	
  //
  //    
  
  if (!buddyName) buddyName = [person displayName];
  if (!buddyName) buddyName = "Unknown";
  [object setName:buddyName];
  [object setObject:resource forType:QSIMAccountType];
  
  if (person) [object setObject:[NSArray arrayWithObject:[person uniqueId]] forType:@"ABPeopleUIDsPboardType"];
  [object setObject:(statusMessage ? statusMessage : @"") 
            forMeta:kQSObjectDetails];
  
  NSImage *image = [[[NSImage alloc] initWithData:buddyPicture]autorelease];
  if (!image) image = [QSResourceManager imageNamed:@"UserIcon"];
  [object setIcon:image];
  
  
}

#pragma mark Online buddies
- (QSObject *)objectForIdentity:(NSDictionary *)identity {
  QSObject *object = [QSObject makeObjectWithIdentifier:[NSString uniqueString]];
  [object setName:@"Offline"];
  [self updateObjectWithPresence:object identity:identity];
  //NSLog(@"obeect %@", object);
  return object;
}


- (NSArray *)onlineBuddies {
  if (!identities) {
    [self loadAccounts];
  }
  
  NSMutableArray *array = [NSMutableArray array];
  for (NSMutableDictionary *dictionary in identities) {
    QSObject *object = [self objectForIdentity:dictionary];
    if (object) [array addObject:object];
  }
  return array;
}




-(NSArray *) abContactsWithAIMOrJabber
{			
  // Search for Address Book contacts with AIM screen names
  ABSearchElement *aimScreenName = [ABPerson searchElementForProperty:kABAIMInstantProperty 
                                                                label:nil key:nil value:nil comparison:kABNotEqual];
  
  // Search for Address Book contacts with Jabber screen names
  ABSearchElement *jabberScreenName = [ABPerson searchElementForProperty:kABJabberInstantProperty 
                                                                   label:nil key:nil value:nil comparison:kABNotEqual];
  
  // Combine the above search conditions to look for AIM or Jabber screen names
  ABSearchElement *searchForAIMJabberScreenName = [ABSearchElement searchElementForConjunction:kABSearchOr
                                                                                      children:[NSArray arrayWithObjects:aimScreenName, jabberScreenName, nil]];	
  
  // Assign the result to the abPeople array							                   
  return [NSMutableArray arrayWithArray:[[ABAddressBook sharedAddressBook] recordsMatchingSearchElement:searchForAIMJabberScreenName]];						                  	
}

- (void) addSource:(NSDictionary *)source {
  
}

- (void) loadPresenceInfo {
  self.infoForAllScreenNames = [NSMutableDictionary dictionary];
  
  for (IMService *service in [IMService allServices]) {
    NSString *serviceName = [service name];
    for (NSDictionary *info in [service infoForPreferredScreenNames]) {
      NSString *screenName = [info objectForKey: IMPersonScreenNameKey];
      [infoForAllScreenNames setObject:info 
                                forKey:[NSString stringWithFormat:@"%@:%@", serviceName, screenName]];
    }
  }  
  //QSLog(@"keys %@", [infoForAllScreenNames allKeys]);
}

- (void) loadAccounts {
  self.identities = [NSMutableArray array];
  self.identitiesByAccount = [NSMutableDictionary dictionary];
  [self loadPresenceInfo];
  
  
  for (ABPerson *person in [self abContactsWithAIMOrJabber]) {
    NSString *uniqueID = [person uniqueId];
    
    NSMutableArray *identifiers = [NSMutableArray array];
    [identifiers addObject:[NSString stringWithFormat:@"addressbook://%@", uniqueID]];
    
    
    NSMutableArray *accounts = [NSMutableArray array];
    for (IMService *service in [IMService allServices]) {
      NSString *serviceName = [service name];
      for (NSString *screenName in [service screenNamesForPerson:person]) {
        screenName = [NSString stringWithFormat:@"%@:%@", serviceName, screenName];
        [identifiers addObject:screenName];
        [accounts addObject:screenName];
      }
    }
    
    
    NSMutableDictionary *sourceEntry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        person, @"ABPerson",
                                        uniqueID, @"source",
                                        identifiers, @"identifiers",
                                        nil];
    
    for (NSString *account in accounts)
      [identitiesByAccount setObject:sourceEntry forKey:account];
    
    [identities addObject:sourceEntry];
  }
  
  for (NSString *account in infoForAllScreenNames) {
    if (![identitiesByAccount objectForKey:account]) {
      
      
      NSMutableDictionary *sourceEntry = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                          account, @"source",
                                          [NSArray arrayWithObject:account], @"identifiers",
                                          nil];
      
      [identitiesByAccount setObject:sourceEntry forKey:account];
      [identities addObject:sourceEntry];
    }
  }
  
  for (NSDictionary *identity in identities) {
    //NSLog(@"%@ -> %@", [identity objectForKey:@"source"], [[identity objectForKey:@"identifiers"] componentsJoinedByString:@","]); 
  }
  
  
  //  NSLog(@"identities, %@", identitiesByAccount);
}

//    
//    
//    
//    
//    QSObject *object = [QSObject objectWithName:name];
//    [object setObject:[NSString stringWithFormat:@"AIM:%@", account] forType:QSIMAccountType];
//    
//    if ([status length]) [object setObject:status forMeta:kQSObjectDetails];
//    [object setIcon:[[[NSImage alloc] initWithData:[dictionary objectForKey:@"IMPersonPictureData"]]autorelease]];
//    [identities addObject:object];
//    
//     
//     for (IMService *service in [IMService allServices])
//     {
//     // Returns an array of valid screen names for aBuddy
//     NSArray *screenNames = [service screenNamesForPerson:aBuddy];
//  }
//  
//
//  
//  //  Ask all logged-in services (AIM,Jabber, and Bonjour) to find this buddy
//  for (IMService *service in [IMService allServices]) {
//    NSArray *allInfo = [service infoForAllScreenNames]; 
//    for (NSDictionary *dictionary in allInfo) {
//      
////   //        



//      
////}


//  // Returns an array of valid screen names for aBuddy
//  
//  
//  // Iterate through all persons in abPeople
//  for(ABPerson *person in abPeople)
//  {
//    // Get this person's information
//    NSMutableDictionary *buddyInfo = [self lookUpInformationForABuddy:person];
//    if (buddyInfo != nil)
//    {
//      // Check whether this person is online 
//      if ([self buddyIsOnline:[buddyInfo objectForKey:@"buddyStatus"]] == YES )	
//      {
//        // Add this person to buddies if that person's status is set to available or idle
//        [buddies addObject:buddyInfo];
//      }
//    }
//  }
//  
//  
// }
// }
//}


@end
