//
//  QSWindowModule.h
//  QSWindowModule
//
//  Created by Nicholas Jitkoff on 8/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSObject.h>
#import "QSWindowModule.h"

@interface QSObject (WindowModule)
- (QSObject *)windowObjectWithWindowID:(int)wid;
@end

