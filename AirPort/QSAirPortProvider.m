

#import "QSAirPortProvider.h"


#import <QSCore/QSCore.h>
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
    QSObject *airport = [QSObject objectWithName:@"AirPort Networks"];
    [airport setDetails:@"AirPort Wireless Networks"];
    [airport setIcon:[QSResourceManager imageNamed:@"com.apple.airport.airportutility"]];
    [airport setObject:@"Virtual AirPort Object" forType:kQSAirPortItemType];
    [airport setPrimaryType:kQSAirPortItemType];
    return [NSArray arrayWithObject:airport];
}

- (BOOL)objectHasChildren:(QSObject *)object {
    // only the virtual AirPort object has children
    return [object containsType:kQSAirPortItemType];
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
            // TODO indicate connected network
            if([preferred containsObject:ssid])
            {
                // indicate that this is a preferred network
                newObject = [QSObject objectWithName:[NSString stringWithFormat:@"%@ ♥ Preferred", ssid]];
            } else {
                // just use the name
                newObject = [QSObject objectWithName:ssid];
            }
            [newObject setObject:ssid forType:kQSAirPortNetworkSSIDType];
            [newObject setPrimaryType:kQSAirPortNetworkSSIDType];
            [newObject setDetails:[NSString stringWithFormat:@"%@ AirPort Network",ssid]];
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

- (void)toggleAirPort
{
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    BOOL newPowerState = ![wif power];
    BOOL setPowerSuccess = [wif setPower:newPowerState error:&error];
    
#ifdef DEBUG
    if (! setPowerSuccess) {
        NSLog(@"error toggling airport: %@", error);
    }
#endif
}

- (QSObject *) selectNetwork:(QSObject *)dObject
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

- (NSString *) passwordForAirPortNetwork:(NSString *)network{
    void *s = NULL;
    unsigned long l = 0;
    NSString *where = @"AirPort Network";
    NSString *string = nil;
    if(noErr==SecKeychainFindGenericPassword( NULL,[where length],[where UTF8String], [network length], [network UTF8String], &l, &s,NULL))
        string = [NSString stringWithCString:(const char *)s length:l];
    SecKeychainItemFreeContent(NULL,s);
    return string;
}
@end
