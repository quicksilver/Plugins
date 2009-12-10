#import "QSNetworkLocationSource.h"

#import <QSCore/QSCore.h>
#import <QSCore/QSNotifyMediator.h>

NSDictionary *getNetworkLocations(NSString **currentLocation){
	NSString *string=nil;
	
    if ( (bool)getenv("USERBREAK")){
        NSLog(@"Skipping Network Locations");
		return nil;
    }else{
    NSTask *getNetTask=[[[NSTask alloc] init]autorelease];
    NSPipe *helpPipe=[NSPipe pipe];
    [getNetTask setStandardError:helpPipe];
    [getNetTask setStandardOutput:[NSPipe pipe]];
    [getNetTask setLaunchPath:@"/usr/sbin/scselect"];
    [getNetTask launch];
  //  NSLog(@"launch");
    
//    [getNetTask waitUntilExit];
    
    NSDate *startDate=[NSDate date];
    while ([getNetTask isRunning]){
        [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:.1]]; // *** this should be done better
        if ([[NSDate date]timeIntervalSinceDate:startDate]>1){
            NSLog(@"Giving up on network locations");
            return nil;
        }
    }
    
    //    NSLog(@"exit");
    NSFileHandle *output=[helpPipe fileHandleForReading];
    string=[[[NSString alloc] initWithData:[output availableData] encoding:NSUTF8StringEncoding]autorelease];
    }
	
	string=@"";
    NSString *networkIdentifier=nil;
    NSString *name=nil;
    NSString *prefixString=nil;
    
    NSScanner *locationScanner=[NSScanner scannerWithString:string];
    
    NSCharacterSet *spaceAndAsterixSet=[NSCharacterSet characterSetWithCharactersInString:@" *"];
    NSMutableDictionary *locationDictionary=[NSMutableDictionary dictionaryWithCapacity:1];
    
    [locationScanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"] intoString:&name];
    while(![locationScanner isAtEnd]){
    //     NSLog(@"while");
        [locationScanner scanCharactersFromSet:spaceAndAsterixSet intoString:&prefixString];
        [locationScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&networkIdentifier];
        [locationScanner scanUpToCharactersFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet] intoString:&name];
       // NSLog(@"ScannedLocation (%@) (%@) (%@)",prefixString,networkIdentifier,name);
        if ([name length]>2)
            name=[name substringWithRange:NSMakeRange(1,[name length]-2)];
        if (name && networkIdentifier)
            [locationDictionary setObject:name forKey:networkIdentifier];
    }
    return locationDictionary;
}


void setNetworkLocation(NSString *location){
    NSTask *setNetTask=[[[NSTask alloc] init]autorelease];
//    NSPipe *helpPipe=[NSPipe pipe];
    [setNetTask setLaunchPath:@"/usr/sbin/scselect"];
    [setNetTask setArguments:[NSArray arrayWithObject:location]];
    [setNetTask launch];
    [setNetTask waitUntilExit];
}


@implementation QSNetworkLocationObjectSource

- (id)init{
    if (self=[super init]){
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:@"com.apple.system.config.network_change" object:nil];
    }
    return self;
}
- (void)networkChange:(NSNotification *)notif{
    NSLog(@"Network Change");   
}

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
	NSDate *modDate=[[[NSFileManager defaultManager] fileAttributesAtPath:@"/Library/Preferences/SystemConfiguration/preferences.plist" traverseLink:YES]fileModificationDate];
	return [modDate compare:indexDate]==NSOrderedAscending;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"GenericNetworkIcon"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return [@"[Network Location]:"stringByAppendingString:[object objectForType:QSNetworkLocationPasteboardType]];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{	
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
//    NSDictionary *networkLocations=getNetworkLocations(nil); // *** could also get this from a plist. this might mess up international stuff
	NSDictionary *networkLocations=[[NSDictionary dictionaryWithContentsOfFile:@"/Library/Preferences/SystemConfiguration/preferences.plist"]objectForKey:@"Sets"];
    
	NSString *key;
    NSEnumerator *networkEnumerator=[networkLocations keyEnumerator];
    while(key=[networkEnumerator nextObject]){
        newObject=[QSObject objectWithName:[NSString stringWithFormat:@"%@ Network Location",[[networkLocations objectForKey:key]objectForKey:@"UserDefinedName"]]];
		[newObject setObject:key forType:QSNetworkLocationPasteboardType];
        [newObject setPrimaryType:QSNetworkLocationPasteboardType];
        [objects addObject:newObject];
    }
    return objects;
}

- (void)setQuickIconForObject:(QSObject *)object{
        [object setIcon:[QSResourceManager imageNamed:@"GenericNetworkIcon"]];
}
@end





#define kQSNetworkLocationSelectAction @"QSNetworkLocationSelectAction"


@implementation QSNetworkLocationActionProvider
//- (NSArray *) types{
//    return [NSArray arrayWithObject:QSNetworkLocationPasteboardType];
//}
//- (NSArray *) actions{
//    QSAction *action=[QSAction actionWithIdentifier:kQSNetworkLocationSelectAction];
//    [action setIcon:[QSResourceManager imageNamed:@"GenericNetworkIcon"]];
//    [action setProvider:self];
//    [action setAction:@selector(selectNetwork:)];
//    [action setArgumentCount:1];
//    return [NSArray arrayWithObject:action];
//}
//
//- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
//    return [NSArray arrayWithObject:kQSNetworkLocationSelectAction];
//}

- (QSObject *) selectNetwork:(QSObject *)dObject{
    setNetworkLocation([dObject objectForType:QSNetworkLocationPasteboardType]);
	
	QSShowNotifierWithAttributes([NSDictionary dictionaryWithObjectsAndKeys:
		@"QSiTunesTrackChangeNotification",QSNotifierType,
		@"Network Changed",QSNotifierTitle,
		[dObject name],QSNotifierText,
		[QSResourceManager imageNamed:@"GenericNetworkIcon"], QSNotifierIcon,
		nil]);
	
	return nil;
}
@end
