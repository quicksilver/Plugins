//
//  QSHotKeyTriggerManager.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Sun Jun 13 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//
#import "QSTriggerManager.h"
#import <Foundation/Foundation.h>
@class QSHotKeyField;
@interface QSHotKeyTriggerManager : QSTriggerManager {
	IBOutlet QSHotKeyField *hotKeyField;
}
- (IBAction)setHotKeyFromSender:(id)sender;
@end
