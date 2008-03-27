//
//  QSTextManipulationPlugIn.h
//  QSTextManipulationPlugIn
//
//  Created by Nicholas Jitkoff on 3/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSTextManipulationPlugIn.h"

@interface QSTextManipulationPlugIn : NSObject
- (QSObject *) prependObject:(QSObject *)dObject toObject:(QSObject *)iObject;
- (QSObject *) appendObject:(QSObject *)dObject toObject:(QSObject *)iObject;
- (QSObject *) appendObject:(QSObject *)dObject toObject:(QSObject *)iObject atBeginning:(BOOL)atBeginning;
@end

