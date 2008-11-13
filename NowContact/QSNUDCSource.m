

#import "QSNUDCSource.h"
#import <QSCore/QSCore.h>

#define QSNUDCContactType @"QSNUDCContactType"
#define kQSNUTDContactShowAction @"QSNUTDContactShowAction"


@implementation QSNUDCSource


// Object Source Methods
 - (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.poweronsoftware.nowcontact"];
 }

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return [[NSDate date]timeIntervalSinceDate:indexDate]>60*60*24;
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    
    
    NSWorkspace *workspace=[NSWorkspace sharedWorkspace];
    
    if (![workspace applicationIsRunning:@"Now Contact"])return nil;

    NSDictionary *errorDict=nil;
    NSAppleEventDescriptor *desc=[[self contactScript] executeSubroutine:@"get_contacts" arguments:nil error:&errorDict];
    if (errorDict) NSLog(@"Execute Error: %@",errorDict);
    
    //NSLog(@"Contacts:%@",);
    NSArray *contactRecords=[desc objectValue];
    NSArray *ids=[contactRecords objectAtIndex:0];
    NSArray *names=[contactRecords objectAtIndex:1];
    NSArray *emails=[contactRecords objectAtIndex:2];
        NSMutableArray *objects=[NSMutableArray arrayWithCapacity:[ids count]];
    
    int i;
    QSObject *newObject;
    for (i=0;i<[ids count];i++){
        newObject=[QSObject objectWithName:[names objectAtIndex:i]];
        [newObject setObject:[ids objectAtIndex:i] forType:QSNUDCContactType];
	if ([(NSString *)[emails objectAtIndex:i]length])
			[newObject setObject:[NSArray arrayWithObject:[emails objectAtIndex:i]] forType:QSEmailAddressType];
        [newObject setPrimaryType:QSNUDCContactType];
        [objects addObject:newObject];
    }
    
    return objects;
}


// Object Handler Methods

- (NSString *)detailsOfObject:(id <QSObject>)object{
	return nil;
}

- (void)setQuickIconForObject:(QSObject *)object{
	[object setIcon:[QSResourceManager imageNamed:@"com.poweronsoftware.nowcontact"]];
    return YES;
}

- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
}

// Action Provider Methods
- (NSArray *) types{
    return [NSArray arrayWithObject:QSNUDCContactType];
}
- (NSArray *) actions{
    
    
    QSAction *action=[QSAction actionWithIdentifier:kQSNUTDContactShowAction];
    [action setIcon:[QSResourceManager imageNamed:@"NowContactIcon"]];
    [action setProvider:self];
    [action setAction:@selector(showContact:)];
    [action setArgumentCount:1];
    return [NSArray arrayWithObject:action];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return [NSArray arrayWithObject:kQSNUTDContactShowAction];
}

- (QSObject *) showContact:(QSObject *)dObject{

    NSDictionary *errorDict=nil;
    [[self contactScript] executeSubroutine:@"open_contact"
                                                        arguments:[NSArray arrayWithObject:[dObject objectForType:QSNUDCContactType]]
                                                            error:&errorDict];
    if (errorDict) NSLog(@"Execute Error: %@",errorDict);
 //   setNetworkLocation([dObject objectForType:QSNetworkLocationPasteboardType]);
    return nil;
}


- (NSAppleScript *)contactScript{
	NSString *path=[[NSBundle bundleForClass:[self class]]pathForResource:@"NUDC" ofType:@"scpt"];
	return [[[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:nil]autorelease];
}
@end
