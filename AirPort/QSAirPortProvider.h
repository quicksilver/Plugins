

#import <Foundation/Foundation.h>
#import <QSCore/QSCore.h>

#define QSAirPortNetworkSSIDType @"QSAirPortNetworkSSIDType"
@interface QSAirPortNetworkObjectSource : QSObjectSource {
}

@end


@interface QSAirPortNetworkActionProvider : QSActionProvider{
}
- (NSString *) passwordForAirPortNetwork:(NSString *)network;

@end
