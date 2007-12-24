//
//  HRObjectParser.h
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Wed Oct 27 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HRObjectParser : NSObject {

}

+ (HRObjectParser *)parserForType:(NSString *)type;

- (BOOL)canHandleType:(NSString *)type;
- (NSArray *)objectsFromString:(NSString *)data ofType:(NSString *)type;
- (NSDictionary *)objectFromString:(NSString *)data ofType:(NSString *)type;

@end
