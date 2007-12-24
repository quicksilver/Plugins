//
//  NSStringAdditions.h
//  FindModule
//
//  Created by Kevin Ballard on 8/5/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSString (FindModuleStringAdditions) 
- (NSString *) stringByEscapingCharactersFromSet:(NSCharacterSet *)charSet;
@end
