//
//  HREmailParser.h
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Wed Oct 27 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HRObjectParser.h"
#import "AGRegex.h"

#define HREmailListItemPattern				@"(?<index>\\d+)\\.\\s*\\[\\[(?<name>[^\\]|]+)(?<label>[^\\]]*)\\]\\]"
#define HREmailCastPattern					@"cast.*:[^\\[]*(?<cast>.*)$"

@interface HREmailParser : HRObjectParser {

}

+ (HREmailParser *)defaultParser;

@end
