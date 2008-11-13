/* QSDefaultsObjectSource */

#import <Cocoa/Cocoa.h>
#import <QSCore/QSCore.h>


#define QSNetworkLocationPasteboardType @"qs.networklocation"

@interface QSNetworkLocationObjectSource : QSObjectSource
{
    IBOutlet NSTextField *bundleIDField;
    IBOutlet NSTextField *keyField;
    IBOutlet NSPopUpButton *entryTypePopUp;
}
@end

@interface QSNetworkLocationActionProvider : QSActionProvider{

}
@end
