//
//  AppController.h
//  DictProtocolTest
//
//  Created by Kevin Ballard on 11/2/04.
//  Copyright 2004 Kevin Ballard. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppController : NSObject {
	NSString *urlString;
	NSURLConnection *urlConnection;
	NSMutableData *urlData;
	IBOutlet NSTextView *resultText;
	IBOutlet NSProgressIndicator *progressIndicator;
	IBOutlet NSButton *queryButton;
}
- (IBAction) query:(id)sender;
- (IBAction) stopQuery:(id)sender;

- (NSString *)urlString;
- (void) setUrlString:(NSString *)string;
@end
