#import "QSAirPortProvider.h"
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

NSArray *getPreferredNetworks(void)
{
    // check stored System Preferences and return SSIDs
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:1];
    @try {
        NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:@"/Library/Preferences/SystemConfiguration/preferences.plist"];
        NSDictionary *sets = [config objectForKey:@"Sets"];
        for (NSString *setKey in sets) {
            NSDictionary *set = [sets objectForKey:setKey];
            NSDictionary *network = [set objectForKey:@"Network"];
            NSDictionary *interface = [network objectForKey:@"Interface"];
            for(NSString *interfaceKey in interface) {
                NSDictionary *bsdInterface = [interface objectForKey:interfaceKey];
                for(NSString *namedInterfaceKey in bsdInterface) {
                    NSDictionary *namedInterface = [bsdInterface objectForKey:namedInterfaceKey];
                    NSArray *networks = [namedInterface objectForKey:@"PreferredNetworks"];
                    for (NSDictionary *network in networks) {
                        NSString *ssid = [network objectForKey:@"SSID_STR"];
                        [result addObject:ssid];
                    }
                }
            }
        }
    } @catch (NSException * e) {
        NSLog(@"Failed to read known networks: %@", e);
    }
    return result;
}

NSArray *getAvailableNetworks(void)
{
    // scan for currently available wireless networks
    // retrun the entire network object
    NSMutableArray *available = [NSMutableArray arrayWithCapacity:1];
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    for (CWNetwork *net in [wif scanForNetworksWithParameters:nil error:&error])
    {
        [available addObject:net];
    }
    return available;
}

NSInteger sortNetworkObjects(QSObject *net1, QSObject *net2, void *context)
{
    NSNumber *n1 = [net1 objectForMeta:@"priority"];
    NSNumber *n2 = [net2 objectForMeta:@"priority"];
    // reverse the sort order
    if ([n1 isEqualToNumber:n2]) {
        return NSOrderedSame;
    } else if ([n1 compare:n2] == NSOrderedDescending) {
        return NSOrderedAscending;
    } else {
        return NSOrderedDescending;
    }
}

@implementation QSAirPortNetworkObjectSource

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"com.apple.airport.airportutility"];
}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry
{
    // create a virtual object representing the AirPort interface
    QSObject *airport = [QSObject objectWithName:@"AirPort"];
    [airport setDetails:@"AirPort Wireless Networks"];
    [airport setIcon:[QSResourceManager imageNamed:@"com.apple.airport.airportutility"]];
    [airport setObject:@"Virtual AirPort Object" forType:kQSAirPortItemType];
    [airport setIdentifier:@"AirPortNetworks"];
    [airport setPrimaryType:kQSAirPortItemType];
    return [NSArray arrayWithObject:airport];
}

- (BOOL)objectHasChildren:(QSObject *)object {
    // only the virtual AirPort object has children (not the networks)
    // nothing to list if the interface is powered off
    return ([object containsType:kQSAirPortItemType] && [[CWInterface interface] power]);
}

- (BOOL)loadChildrenForObject:(QSObject *)object
{
    if ([object containsType:kQSAirPortItemType])
    {
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
        QSObject *newObject = nil;
        NSArray *networks = getAvailableNetworks(); 
        NSArray *preferredNetworks = getPreferredNetworks();
        for(CWNetwork *net in networks)
        {
            NSString *ssid = net.ssid;
            NSNumber *priority = net.rssi;
            if([preferredNetworks containsObject:ssid])
            {
                // indicate that this is a preferred network
                newObject = [QSObject objectWithName:[NSString stringWithFormat:@"%@ ★", ssid]];
                [newObject setDetails:[NSString stringWithFormat:@"%@ AirPort Network (Preferred)", ssid]];
                // artificially inflate the priority for preferred networks
                priority = [NSNumber numberWithInt:[priority intValue] + 1000];
            } else {
                // just use the name
                newObject = [QSObject objectWithName:ssid];
                [newObject setDetails:[NSString stringWithFormat:@"%@ AirPort Network", ssid]];
            }
            [newObject setObject:priority forMeta:@"priority"];
            [newObject setObject:net forType:kQSWirelessNetworkType];
            [newObject setPrimaryType:kQSWirelessNetworkType];
            [newObject setParentID:[object identifier]];
            [newObject setIcon:[QSResourceManager imageNamed:@"AirPort" inBundle:[NSBundle bundleWithIdentifier:@"com.blacktree.Quicksilver.QSAirPortPlugIn"]]];
            [objects addObject:newObject];
        }
        [object setChildren:[objects sortedArrayUsingFunction:sortNetworkObjects context:NULL]];
        return YES;
    } else {
        return NO;
    }
}

- (void)setQuickIconForObject:(QSObject *)object
{
    [object setIcon:[QSResourceManager imageNamed:@"com.apple.airport.airportutility"]];
}
@end

@implementation QSAirPortNetworkActionProvider

- (QSObject *)enableAirPort
{
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    BOOL setPowerSuccess = [wif setPower:YES error:&error];
    
#ifdef DEBUG
    if (! setPowerSuccess) {
        NSLog(@"error enabling airport: %@", error);
    }
#endif
    return nil;
}

- (QSObject *)disableAirPort
{
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    BOOL setPowerSuccess = [wif setPower:NO error:&error];
    
#ifdef DEBUG
    if (! setPowerSuccess) {
        NSLog(@"error disabling airport: %@", error);
    }
#endif
    return nil;
}

- (QSObject *)disassociateAirPort
{
    [[CWInterface interface] disassociate];
    return nil;
}

- (QSObject *)selectNetwork:(QSObject *)dObject
{
#ifdef DEBUG
    NSLog(@"Switching to network: \"%@\"", [dObject name]);
#endif
    
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    CWNetwork *net = [dObject objectForType:kQSWirelessNetworkType];
    NSString *password = [self passwordForAirPortNetwork:net.ssid];
    NSDictionary *params = nil;
    if (password != nil) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:password, kCWAssocKeyPassphrase, nil];
    }
    
    [wif associateToNetwork:net parameters:params error:&error];
    
    return nil;
}

- (NSString *)passwordForAirPortNetwork:(NSString *)network
{
    void *s = NULL;
    unsigned long l = 0;
    NSString *where = @"AirPort Network";
    NSString *string = nil;
    OSStatus status = SecKeychainFindGenericPassword(
        NULL,
        [where length], [where UTF8String],
        [network length], [network UTF8String],
        &l, &s,
        NULL);
    if(status == noErr)
        string = [NSString stringWithCString:(const char *)s length:l];
    SecKeychainItemFreeContent(NULL, (void *)s);
    return string;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
    CWInterface *wif = [CWInterface interface];
    if([wif power])
    {
        return [NSArray arrayWithObjects:@"QSAirPortPowerDisable", @"QSAirPortDisassociate", nil];
    } else {
        return [NSArray arrayWithObject:@"QSAirPortPowerEnable"];
    }
}
@end
