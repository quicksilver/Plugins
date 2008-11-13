//
//  QSStikkitPlugIn_Source.h
//  QSStikkitPlugIn
//
//  Created by Nicholas Jitkoff on 9/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//


#import "QSStikkitPlugIn.h"

@interface QSStikkitPlugIn : QSObjectSource{
//	NSMutableArray *posts;
//	NSMutableArray *tags;
//	NSMutableArray *dates;
	
	IBOutlet NSTextField *userField;
	IBOutlet NSTextField *passField;
}

- (IBAction)savePassword:(id)sender;

@end

