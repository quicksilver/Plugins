//
//  QSShiiraBookmarkParser.h
//  QSShiiraPlugIn
//
//  Created by Brian Donovan on Sun Nov 21 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QSShiiraBookmarkParser : QSParser {

}

- (NSArray *)objectsFromPath:(NSString *)path withSettings:(NSDictionary *)settings;
- (BOOL)validParserForPath:(NSString *)path;

@end
