

#import <Foundation/Foundation.h>

@interface QSEmailActions : QSActionProvider {

}
- (QSObject *) sendEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject;
- (QSObject *) composeEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject;
- (QSObject *) composeEmailTo:(QSObject *)dObject withItem:(QSObject *)iObject sendNow:(BOOL)sendNow direct:(BOOL)direct;
@end
