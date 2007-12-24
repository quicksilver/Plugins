

#import "QSABMimicActionProvider.h"
//#import <QSCore/QSCore.h>
//#import "QSWindow.h"
#import <AddressBook/AddressBook.h>


#define kABAimToAction @"AIM_MESSAGE"
#define kABCopyMapURLAction @"COPY_MAP_URL"
#define kQSABLargeTypeAction @"QSABLargeTypeAction"

@implementation QSABMimicActionProvider

- (NSArray *) types{
    return [NSArray arrayWithObjects:QSContactPhoneType,nil];
}
- (NSArray *) actions{
	return nil;
    QSAction *action=[QSAction actionWithIdentifier:kQSABLargeTypeAction];
    [action setIcon:[NSImage imageNamed:@"All16"]];
    [action setProvider:self];
    [action setAction:@selector(showLargeType:)];
    [action setArgumentCount:1];
    return [NSArray arrayWithObject:action];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
	    return nil;
    return [NSArray arrayWithObject:kQSABLargeTypeAction];

}


- (QSObject *)mapOf:(QSObject *)dObject{
    
    return nil;
}


- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	
	//if ([action isEqualToString:
	QSObject *proxy=[QSObject textProxyObjectWithDefaultValue:@""];
	return [NSArray arrayWithObject:proxy];

	
	//NSMutableArray *objects=[QSLib scoredArrayForString:nil inSet:[QSLib arrayForType:@"ABPeopleUIDsPboardType"]];
	//return [NSArray arrayWithObjects:[NSNull null],objects,nil];
}

- (QSObject *)addData:(QSObject *)dObject toContact:(QSObject *)iObject{
	//NSLog(@"%@,,,",[iObject objectForType:@"ABPeopleUIDsPboardType"]);
	ABPerson *thePerson=(ABPerson *)[[ABAddressBook sharedAddressBook] recordForUniqueId:[iObject objectForType:@"ABPeopleUIDsPboardType"]];

	NSString *string=[dObject stringValue];
	
	NSString *note=[thePerson valueForProperty:kABNoteProperty];
	if ([note length])
		note=[note stringByAppendingFormat:@"\r%@",string];
	else
		note=string;

	[thePerson setValue:note forProperty:kABNoteProperty];
	
	//NSLog(@"note %@",[thePerson valueForProperty:kABNoteProperty]);
	
	[[ABAddressBook sharedAddressBook]save];
    return nil;
}

/*
 - (char)isAMacDotComAddress:(QSObject *)dObject;
 - (char)isAOLAddress:(QSObject *)dObject;
 - (void)aimTo:(QSObject *)dObject;
 - (void)sendIndividualMailNotification:(QSObject *)dObject;
 - (void)gotoHomePage:(QSObject *)dObject;
 - _mapURL:(QSObject *)dObject;
 - (void)mapOf:(QSObject *)dObject;
 - (void)copyMapURL:(QSObject *)dObject;
 - (void)copyAddress:(QSObject *)dObject;
 - (void)emailTo:(QSObject *)dObject;
 - (void)macDotComHomePage:(QSObject *)dObject;
 - (void)aolHomePage:(QSObject *)dObject;
 - (void)homePageFromEmail:(QSObject *)dObject;
 - (void)openPublicIDiskForUser:(QSObject *)dObject isMe:(char)fp12;
 - (void)openIDisk:(QSObject *)dObject;
 - (void)showLargeType:(QSObject *)dObject;
 */
@end