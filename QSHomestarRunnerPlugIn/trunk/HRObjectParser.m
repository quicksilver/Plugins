//
//  HRObjectParser.m
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Wed Oct 27 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "HRObjectParser.h"
#import "HREmailParser.h"

@implementation HRObjectParser

+ (HRObjectParser *)parserForType:(NSString *)type {
	if( [HREmailParser canHandleType:type] ) {
		/* email type */
		return [HREmailParser defaultParser];
	}
}

@end
