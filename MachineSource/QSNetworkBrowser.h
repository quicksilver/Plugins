/* QSNetworkBrowser */

#import "QSObjectSource.h"

#import "QSActionProvider.h"


#define QSMachinePasteboardType @"QSMachinePasteboardType"

@interface QSMachineSource : QSObjectSource{
    
    NSNetServiceBrowser * browser;
    NSMutableArray * services;
    NSMutableArray * resolvedServices;
    NSNetService * serviceBeingResolved;
}
@end
