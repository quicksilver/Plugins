//
//  QSAutomatorPlugIn_Action.m
//  QSAutomatorPlugIn
//
//  Created by Nicholas Jitkoff on 10/28/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSAutomatorPlugIn_Action.h"
#import <Automator/Automator.h>

@implementation QSAutomatorPlugIn_Action


#define kQSAutomatorPlugInAction @"QSAutomatorPlugInAction"
@class AMWorkflow;

- (QSObject *)runWorkflow:(QSObject *)dObject{
  if (NSClassFromString(@"AMWorkflow")) {
    NSURL *url = [NSURL fileURLWithPath:[dObject validSingleFilePath]];
    NSError *error = nil;
    id result = [AMWorkflow runWorkflowAtURL:url
                                   withInput:nil
                                       error:&error];
  } else {
    NSString *path=[dObject singleFilePath];
    [[NSWorkspace sharedWorkspace]openFile:path withApplication:@"/System/Library/CoreServices/Automator Launcher.app"];
  }
  return nil;
}
@end
