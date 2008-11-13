//
//  QSProcessSwitcherSupportPlugIn.h
//  QSProcessSwitcherSupportPlugIn
//
//  Created by Nicholas Jitkoff on 9/17/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import <QSCore/QSObject.h>
#import "QSProcessSwitcherSupportPlugIn.h"

#define kQSProcessSwitchers @"QSProcessSwitchers"
@protocol QSProcessSwitcher
- (void)showSwitcher;
- (void)showSwitcherUnderMouse;
- (void)switchToNextApp;
- (void)switchToPrevApp;
@end

@interface QSProcessSwitcherSupportPlugIn : NSObject
{
}
@end

