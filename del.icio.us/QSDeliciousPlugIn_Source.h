//
//  QSDeliciousPlugIn_Source.h
//  QSDeliciousPlugIn
//
//  Created by Nicholas Jitkoff on 9/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


#import "QSDeliciousPlugIn_Source.h"

@interface QSDeliciousPlugIn_Source : QSObjectSource{
	NSMutableArray *posts;
	NSMutableArray *tags;
	NSMutableArray *dates;
	
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passField;
}

- (IBAction)savePassword:(id)sender;

@end

