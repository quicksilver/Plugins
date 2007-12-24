//
//  QSAdiumLogSource.h
//  QSAdiumPlugIn
//
//  Created by Brian Donovan on Wed Oct 20 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//
// subversion kicks ass!

#import <Foundation/Foundation.h>


@interface QSAdiumLogSource : QSObjectSource {

}

- (NSArray *)logsForContact:(QSObject *)contact;

@end
