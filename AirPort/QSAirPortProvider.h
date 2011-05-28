#import <CoreWLAN/CoreWLAN.h>

#define kQSWirelessNetworkType @"QSWirelessNetworkType"
#define kQSAirPortItemType @"QSAirPortItemType"

@interface QSAirPortNetworkObjectSource : QSObjectSource {
}

@end


@interface QSAirPortNetworkActionProvider : QSActionProvider{
}
- (NSString *) passwordForAirPortNetwork:(NSString *)network;

@end
