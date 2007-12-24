//
//  TSActions.h
//  TSActionsPlugin
//
//  Created by Kevin Ballard on 6/23/04.
//  Copyright 2004 TildeSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QSCore/QSActionProvider.h>


@interface TSActions : QSActionProvider {
	NSImage *bugMeNotImage;
}

@end

@interface NSString (TSActionsStringExtensions)
- (NSString *) stringByEscapingURLChars;
@end