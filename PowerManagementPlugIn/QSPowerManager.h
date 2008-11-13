//
//  QSPowerManager.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 7/14/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <SecurityFoundation/SFAuthorization.h>
#import <Security/Security.h>

@interface QSPowerManager : NSObject{
	SFAuthorization *auth;
}
+ (id)sharedInstance;
@end
