//
//  QSObject_BDExtensions.m
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on 11/02/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "QSObject_BDExtensions.h"

@implementation QSObject (Transformation)

+ (NSMutableArray *)objectsForArray:(NSArray *)array type:(NSString *)type value:(SEL)valueSelector name:(SEL)nameSelector details:(SEL)detailsSelector {
	NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[array count]];
	
	foreach (item, array) {
		QSObject *object = [QSObject objectWithType:type
											  value:[item performSelector:valueSelector]
											   name:[item performSelector:nameSelector]];
		if (detailsSelector)
			[object setDetails:[item performSelector:detailsSelector]];
		[objects addObject:object];
	}
	
	return objects;
}

@end

@implementation QSObject (Adium)

+ (NSMutableArray *)objectsForAdiumContacts:(NSArray *)contacts {
	NSMutableArray *objects;
	
	/* create the QS objects */
	objects = [[[QSObject objectsForArray:contacts
									 type:kQSAdiumContactType
									value:@selector(internalObjectID)
									 name:@selector(displayName)
								  details:nil]//@selector(statusMessage)]
								/* set the icons */
								  setIcon:@selector(userIconData)
							  withDefault:[[QSResourceManager sharedInstance] imageNamed:@"AdiumDefaultContactIcon"]
							    fromArray:contacts]
								/* set the details */
							   setDetails:@"statusMessage.string"
								fromArray:contacts];
	/* set the details */
	int i = 0;
	foreach (contact, contacts) {
		if ([[contact className] isEqualToString:@"AIMetaContact"]) {
			[[objects objectAtIndex:i] setObject:[contact internalObjectID] forType:kQSAdiumMetaContactType];
			contact = [contact preferredContact];
		}
		[[objects objectAtIndex:i] setObject:([contact online] ? @"online" : @"offline") forMeta:kQSAdiumOnline];
		[[objects objectAtIndex:i++] setObject:[NSString stringWithFormat:@"%@:%@", [contact serviceID], [contact UID]] forType:QSIMAccountType];
	}
	
	return objects;
}

@end