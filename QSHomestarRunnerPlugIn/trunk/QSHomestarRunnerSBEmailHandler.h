//
//  QSHomestarRunnerSBEmailSource.h
//  QSHomestarRunnerPlugIn
//
//  Created by Brian Donovan on Mon Oct 25 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QSCore/QSObjectSource.h>
#import "QSHomestarRunnerPlugIn.h"
#import "QSHomestarRunnerConstants.h"

@interface QSHomestarRunnerSBEmailHandler : NSObject {

}

- (BOOL)loadChildrenForObject:(QSObject *)object;
- (BOOL)objectHasChildren:(QSObject *)object;
- (NSArray *)fetchEmailsWithParent:(QSObject *)parent;
- (NSArray *)fetchEmailData:(QSObject *)email;

@end
