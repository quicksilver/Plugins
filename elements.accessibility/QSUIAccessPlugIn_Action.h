//
//  QSUIAccessPlugIn_Action.h
//  QSUIAccessPlugIn
//
//  Created by Nicholas Jitkoff on 9/25/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#define kQSUIElementType @"qs.ui.element"
#define kQSUIActionType @"qs.ui.action"

//#import <QSCore/QSObject.h>
//#import <QSCore/QSActionProvider.h>
#import "QSUIAccessPlugIn_Action.h"
#define QSUIAccessPlugIn_Type @"QSUIAccessPlugIn_Type"
@interface QSUIAccessPlugIn_Action : QSActionProvider
{
}
- (QSObject *)resolvedProxy:(QSObject *)dObject;
@end

