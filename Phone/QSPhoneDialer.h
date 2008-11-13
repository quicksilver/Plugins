//
//  QSPhoneDialer.h
//  QSPhonePlugIn
//
//  Created by Nicholas Jitkoff on 3/30/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QSPhoneDialer
- (id)initWithSettings:(NSDictionary *)def;
- (BOOL)dialString:(NSString *)string;
@end

@interface QSAppleScriptPhoneDialer : NSObject <QSPhoneDialer>{
	NSAppleScript *script;
}

@end