//
//  NSURL_BLTRExtensions.h
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 7/13/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSURL (Keychain)

- (NSString *)keychainPassword;
-(NSURL *)URLByInjectingPasswordFromKeychain;
@end
