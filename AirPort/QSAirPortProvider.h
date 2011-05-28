#import <CoreWLAN/CoreWLAN.h>

#define kQSAirPortNetworkSSIDType @"QSAirPortNetworkSSIDType"
#define kQSAirPortItemType @"QSAirPortItemType"

@interface QSAirPortNetworkObjectSource : QSObjectSource {
}

@end


@interface QSAirPortNetworkActionProvider : QSActionProvider{
}
- (NSString *) passwordForAirPortNetwork:(NSString *)network;

@end
