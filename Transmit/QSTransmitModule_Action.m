//
//  QSTransmitModule_Action.m
//  QSTransmitModule
//
//  Created by Nicholas Jitkoff on 7/12/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSTransmitModule_Action.h"

@implementation QSTransmitModule_Action


#define kQSTransmitModuleAction @"QSTransmitModuleAction"
- (NSArray *) types{
	return [NSArray arrayWithObjects:MyObjectType,nil];
}

- (NSArray *) actions{
    QSAction *action=[QSAction actionWithIdentifier: kQSTransmitModuleAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
    [action setAction:@selector(performActionOnObject:)];
    return [NSArray arrayWithObject:action];
}

- (NSArray *)validActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return [NSArray arrayWithObject:kQSTransmitModuleAction];
}

- (QSObject *)performActionOnObject:(QSObject *)dObject{
	return nil;
}
@end
