//
//  Dialer.h
//  BuddyPop
//
//  Created by Yann Bizeul on Wed May 26 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSArrayAdditions.h"
#import "NSStringAdditions.h"
#import "NSCharacterSetAdditions.h"
#import "BPContact.h"

@interface Dialer : NSObject {
    BOOL CANCEL;
    NSString *number;
    NSDictionary *userInfo;
}
+ (BOOL)isAvailable;
+ (BOOL)isReady;
+ (void)dial:(NSString*)aNumber;
- (void)setNumber:(NSString*)aNumber;
- (void)dialerWillStartDialing;
- (int)timeout;
+ (void)setUserInfo:(NSDictionary*)aDictionary;
- (void)setUserInfo:(NSDictionary*)aDictionary;
- (NSDictionary*)userInfo;
- (void)cancel;
+(void)cancel;
+ (void)setCountryCode:(NSString*)aString;
+ (NSString*)countryCode;
+ (void)setPrefix:(NSString*)aString;
+ (NSString*)prefix;
+ (void)setEnableSpeaker:(BOOL)flag;
+ (BOOL)enableSpeaker;
+ (NSString*)localizedNumber:(NSString*)number;
@end