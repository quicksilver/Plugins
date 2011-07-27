#import "QSAirPortProvider.h"
#include <Security/Security.h>
#include <CoreServices/CoreServices.h>

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
        for(CWNetwork *net in networks)
        {
            NSString *ssid = net.ssid;
            NSNumber *priority = net.rssi;
            NSString *securityString = @"Secure ";
            // this should use kCWSecurityModeOpen instead of 0, but that constant seems to be (null)
            if ([net.securityMode intValue] == 0) {
                securityString = @"";
            }
            if (net.wirelessProfile)
            {
                // indicate that this is a preferred network
                newObject = [QSObject objectWithName:[NSString stringWithFormat:@"%@ ★", ssid]];
                [newObject setDetails:[NSString stringWithFormat:@"%@AirPort Network (Preferred)", securityString]];
                // artificially inflate the priority for preferred networks
                priority = [NSNumber numberWithInt:[priority intValue] + 1000];
            } else {
                // just use the name
                newObject = [QSObject objectWithName:ssid];
                [newObject setDetails:[NSString stringWithFormat:@"%@AirPort Network", securityString]];
            }
            [newObject setObject:priority forMeta:@"priority"];
            [newObject setObject:net forType:kQSWirelessNetworkType];
            [newObject setPrimaryType:kQSWirelessNetworkType];
            [newObject setParentID:[object identifier]];
            int signal = [net.rssi intValue];
            if (signal > -70) {
                [newObject setIcon:[QSResourceManager imageNamed:@"AirPort" inBundle:[NSBundle bundleForClass:[self class]]]];
            } else if (signal > -80) {
                [newObject setIcon:[QSResourceManager imageNamed:@"AirPort3" inBundle:[NSBundle bundleForClass:[self class]]]];
            } else if (signal > -90) {
                [newObject setIcon:[QSResourceManager imageNamed:@"AirPort2" inBundle:[NSBundle bundleForClass:[self class]]]];
            } else if (signal > -100) {
                [newObject setIcon:[QSResourceManager imageNamed:@"AirPort1" inBundle:[NSBundle bundleForClass:[self class]]]];
            } else {
                [newObject setIcon:[QSResourceManager imageNamed:@"AirPort0" inBundle:[NSBundle bundleForClass:[self class]]]];
            }
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
    if (! setPowerSuccess) {
        NSLog(@"error enabling airport: %@", error);
    }
    return nil;
}

- (QSObject *)disableAirPort
{
    NSError *error = nil;
    CWInterface *wif = [CWInterface interface];
    BOOL setPowerSuccess = [wif setPower:NO error:&error];
    if (! setPowerSuccess) {
        NSLog(@"error disabling airport: %@", error);
    }
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
    NSString *passphrase = [net.wirelessProfile passphrase];
    NSDictionary *params = nil;
    if (passphrase != nil) {
        params = [NSDictionary dictionaryWithObjectsAndKeys:passphrase, kCWAssocKeyPassphrase, nil];
    }
    
    [wif associateToNetwork:net parameters:params error:&error];
    
    return nil;
}

- (QSObject *)connectNewNetwork:(QSObject *)dObject
{    
    CWNetwork *net = [dObject objectForType:kQSWirelessNetworkType];
    NSString *scriptPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"AirPort" ofType:@"scpt"];
    NSAppleScript *script = [[NSAppleScript alloc] initWithContentsOfURL:[NSURL fileURLWithPath:scriptPath] error:nil];
    [script executeSubroutine:@"connect_to_network" arguments:[NSArray arrayWithObjects:net.ssid, nil] error:nil];
#ifdef DEBUG
    NSLog(@"Connecting to new network: \"%@\"", net.ssid);
    NSLog(@"ApleScript path: %@", scriptPath);
#endif
    return nil;
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject
{
    if ([dObject containsType:kQSAirPortItemType]) {
        // the AirPort object
        CWInterface *wif = [CWInterface interface];
        if([wif power])
        {
            return [NSArray arrayWithObjects:@"QSAirPortPowerDisable", @"QSAirPortDisassociate", nil];
        } else {
            return [NSArray arrayWithObject:@"QSAirPortPowerEnable"];
        }
    } else if ([dObject containsType:kQSWirelessNetworkType]) {
        // an AirPort network
        CWNetwork *net = [dObject objectForType:kQSWirelessNetworkType];
        if (net.wirelessProfile) {
            // preferred network
            return [NSArray arrayWithObject:@"QSAirPortNetworkSelectAction"];
        } else {
            return [NSArray arrayWithObject:@"QSAirPortNetworkNewConnection"];
        }

    }
    return nil;
}
@end
