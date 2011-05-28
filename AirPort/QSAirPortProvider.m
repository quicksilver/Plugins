#import "QSAirPortProvider.h"
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

NSArray *getPreferredNetworks(void)
{
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
    NSMutableArray *available = [NSMutableArray arrayWithCapacity:1];
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    for (CWNetwork *net in [wif scanForNetworksWithParameters:nil error:&error])
    {
        [available addObject:net.ssid];
    }
    return available;
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
        NSArray *preferred = getPreferredNetworks();
        NSMutableArray *objects = [NSMutableArray arrayWithCapacity:1];
        QSObject *newObject = nil;
        NSArray *networks = getAvailableNetworks(); 
        for(NSString *ssid in networks)
        {
            // TODO indicate connected network?
            newObject = [QSObject objectWithName:ssid];
            if([preferred containsObject:ssid])
            {
                // indicate that this is a preferred network
                [newObject setDetails:[NSString stringWithFormat:@"%@ AirPort Network (Preferred)", ssid]];
            } else {
                // just use the name
                [newObject setDetails:[NSString stringWithFormat:@"%@ AirPort Network",ssid]];
            }
            [newObject setObject:ssid forType:kQSAirPortNetworkSSIDType];
            [newObject setPrimaryType:kQSAirPortNetworkSSIDType];
            [newObject setParentID:[object identifier]];
            [newObject setIcon:[QSResourceManager imageNamed:@"com.apple.airport.airportutility"]];
            [objects addObject:newObject];
        }
        [object setChildren:objects];
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
    [wif release];
    
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
    [wif release];
    
#ifdef DEBUG
    if (! setPowerSuccess) {
        NSLog(@"error disabling airport: %@", error);
    }
#endif
    return nil;
}

- (QSObject *)selectNetwork:(QSObject *)dObject
{
#ifdef DEBUG
    NSLog(@"Switching to network: \"%@\"", [dObject objectForType:kQSAirPortNetworkSSIDType]);
#endif
    
    NSString *ssid = [dObject objectForType:kQSAirPortNetworkSSIDType];
    NSString *password = [self passwordForAirPortNetwork:ssid];
    
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    CWNetwork *net = nil;
    [wif associateToNetwork:net parameters:nil error:&error];
    
    return nil;
}

- (NSString *)passwordForAirPortNetwork:(NSString *)network
{
    void *s = NULL;
    unsigned long l = 0;
    NSString *where = @"AirPort Network";
    NSString *string = nil;
    if(noErr==SecKeychainFindGenericPassword(NULL, [where length], [where UTF8String], [network length], [network UTF8String], &l, &s, NULL))
        string = [NSString stringWithCString:(const char *)s length:l];
    SecKeychainItemFreeContent(NULL,s);
    return string;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
    CWInterface *wif = [CWInterface interface];
    if([wif power])
    {
        return [NSArray arrayWithObject:@"QSAirPortPowerDisable"];
    } else {
        return [NSArray arrayWithObject:@"QSAirPortPowerEnable"];
    }
}
@end
