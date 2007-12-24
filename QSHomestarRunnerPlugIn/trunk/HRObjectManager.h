//
//  HRToonManager.h
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Wed Oct 27 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRObjectParser.h"
#import "HREmailParser.h"

@interface HRObjectManager : NSObject {
	HRObjectParser *_parser;
	NSMutableDictionary *_prefs;
	NSDictionary *_sources;
}

+ (HRObjectManager *)defaultManager;
+ (HRObjectManager *)defaultStrongBadEmailManager;
+ (HRObjectManager *)defaultToonManager;
+ (HRObjectManager *)defaultCharacterManager;

- (NSDictionary *)objectsForKey:(NSString *)key;
- (NSString *)rootKey;
- (NSDictionary *)rootChildren;
- (HRObjectParser *)parser;
- (void)setParser:(HRObjectParser *)parser;
- (NSMutableDictionary *)preferences;
- (void)setPreference:(id)object forKey:(NSString *)key;

@end
