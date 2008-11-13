//
//  QSCommandLineTool.h
//  QSCommandLineTool
//
//  Created by Nicholas Jitkoff on 7/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import <QSCore/QSObject.h>
#import "QSCommandLineTool.h"

@interface QSCommandLineTool : NSObject{
    NSConnection *commandLineConnection;
}

+ (id)sharedInstance;

- (void)checkForTool;
- (void)startToolConnection;
@end

