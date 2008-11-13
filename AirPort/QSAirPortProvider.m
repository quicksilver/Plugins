

#import "QSAirPortProvider.h"


#import <QSCore/QSCore.h>
#include "Apple80211.h"

#include <Security/Security.h>
#include <CoreServices/CoreServices.h>


WirelessContextPtr gWirelessContext = NULL;
//extern char *gProgname;

NSArray *getAPNetworks(void)
{
    WIErr err;
    WirelessNetworkInfo *data;
    int i;
    CFArrayRef list1 = NULL;
    
    NSMutableArray *networks=[NSMutableArray arrayWithCapacity:0];
    
    err = WirelessScan(gWirelessContext, &list1, 0);
    
    if(err) {
        //fprintf(stderr, "Error: WirelessScan: %d\n", (int) err);
        return nil;
    }
    
    if(list1 == 0) {
        // this means either the scan failed, or there were no APs in range. there isn't any way to tell the difference

    } else {
        
        for(i=0; i < CFArrayGetCount(list1); i++) {
            data = (WirelessNetworkInfo *) CFDataGetBytePtr(CFArrayGetValueAtIndex(list1, i));
            // do something with the data (these are managed networks)
            [networks addObject:[NSString stringWithCString:data->name]];
            //printWirelessNetworkInfo(data);
        }
    }
    
    return [[NSSet setWithArray:networks]allObjects];
}

@implementation QSAirPortNetworkObjectSource
+ (void)registerInstance{
  //  QSAirPortNetworkObjectSource *source=[[[QSAirPortNetworkObjectSource alloc]init]autorelease];
    [QSReg registerSource:@"QSAirPortNetworkObjectSource"];
    [QSReg registerHandler:@"QSAirPortNetworkObjectSource" forType:QSAirPortNetworkSSIDType];
//    NSLog(@"source: %@",source);
}

- (id)init{
    if ((self=[super init])){
        //      [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange:) name:@"com.apple.system.config.network_change" object:nil];
        
        WIErr err = 0;
        int retVal = 0;
        int avail = WirelessIsAvailable();
        
        //if (avail) printf("wireless is available", avail);
        
        if(avail) {
            err = WirelessAttach(&gWirelessContext, 0);
            if(err) {
                printf("Error: WirelessAttach: %d\n", (int) err);
                exit(-1);
            }
        }
        // getNetworks();
        if(err != noErr) {
            //     fprintf(stderr, "%s: Error: %d\n", gProgname, (int) err);
            retVal = -1;
        }
        
        
    }
    return self;
}


    
- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"AirPortIcon"];
}

- (NSString *)identifierForObject:(id <QSObject>)object{
    return [@"[AirPort Network]:"stringByAppendingString:[object objectForType:QSAirPortNetworkSSIDType]];
}
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
    NSArray *networks=getAPNetworks(); 
    NSString *ssid;
    NSEnumerator *networkEnumerator=[networks objectEnumerator];
    while(ssid=[networkEnumerator nextObject]){
        
        newObject=[QSObject objectWithName:[NSString stringWithFormat:@"%@ AirPort Network",ssid]];
        [newObject setObject:ssid forType:QSAirPortNetworkSSIDType];
        [newObject setPrimaryType:QSAirPortNetworkSSIDType];
        [newObject setIcon:[QSResourceManager imageNamed:@"AirPortDocIcon"]];
        [objects addObject:newObject];
    }
    return objects;

}
@end





#define kQSAirPortNetworkSelectAction @"QSAirPortNetworkSelectAction"


@implementation QSAirPortNetworkActionProvider

- (void)turnAirPortOn{
	NSLog(@"Turning AirPort On");
	WirelessSetPower(gWirelessContext,1);	
}

- (void)turnAirPortOff{
	NSLog(@"Turning AirPort Off");
	WirelessSetPower(gWirelessContext,0);	
}


- (QSObject *) selectNetwork:(QSObject *)dObject{
    
    NSLog(@"Switching to network: \"%@\"", [dObject objectForType:QSAirPortNetworkSSIDType]);
    
    NSString *ssid=[dObject objectForType:QSAirPortNetworkSSIDType];
	NSString *password=[self passwordForAirPortNetwork:ssid];
	
    WIErr err=0;
    if (password)
        err = WirelessJoinWEP(gWirelessContext,(CFStringRef) ssid,(CFStringRef) password);
    if (err!=noErr || !password)
        err = WirelessJoin(gWirelessContext,(CFStringRef) ssid);
	
    if (err){
        [[NSAlert alertWithMessageText:@"Unable to join network" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Quicksilver was unable to join the AirPort network \"%@\". If it is protected by a password, please make sure it is stored in your keychain.",ssid]runModal];
    }
    return nil;
}

- (NSString *) passwordForAirPortNetwork:(NSString *)network{
    void *s = NULL;
    unsigned long l = 0;
    NSString *where=@"AirPort Network";
    NSString *string = nil;
    if(noErr==SecKeychainFindGenericPassword( NULL,[where length],[where UTF8String], [network length], [network UTF8String], &l, &s,NULL))
        string = [NSString stringWithCString:(const char *)s length:l];
    SecKeychainItemFreeContent(NULL,s);
    return string;
}
@end
