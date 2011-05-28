#import <Foundation/Foundation.h>
#import <QSCore/QSCore.h>
#import <CoreWLAN/CoreWLAN.h>

#define kQSAirPortNetworkSSIDType @"QSAirPortNetworkSSIDType"
#define kQSAirPortItemType @"QSAirPortItemType"

// TODO check to see if some imports are still needed

@interface QSAirPortNetworkObjectSource : QSObjectSource {
}

@end


@interface QSAirPortNetworkActionProvider : QSActionProvider{
}
- (NSString *) passwordForAirPortNetwork:(NSString *)network;

@end
