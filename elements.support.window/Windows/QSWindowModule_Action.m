//
//  QSWindowModule_Action.m
//  QSWindowModule
//
//  Created by Nicholas Jitkoff on 8/18/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSWindowModule_Action.h"

#import <Carbon/Carbon.h>
#import <QSFoundation/NSAppleEventDescriptor_QSMods.h>
#import "WindowControllerEvents.h"
#import "WindowControllerEvents_BLTRX.h"



#define kQSWindowFadeOutAction @"QSWindowFadeOutAction"
#define kQSWindowFadeInAction @"QSWindowFadeInAction"

#define kQSWindowSetAlphaAction @"QSWindowSetAlphaAction"
#define kQSWindowSetAlphaAction @"QSWindowSetScaleAction"
#define kQSWindowSetLevelAction @"QSWindowSetLevelAction"
#define kQSWindowSetIgnoresMouseAction @"QSWindowSetIgnoresMouseAction"
#define kQSWindowSetHasShadowAction @"QSWindowSetHasShadowAction"
#define kQSWindowSelectAction @"QSWindowSelectAction"



@implementation QSWindowModule_Action





- (NSArray *) xtypes{
	return [NSArray arrayWithObjects:QSWindowIDType,nil];
}

- (NSArray *) xactions{
	NSMutableArray *array=[NSMutableArray array];
    QSAction *action;
	
	action=[QSAction actionWithIdentifier: kQSWindowFadeOutAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
    [action setAction:@selector(fadeOutWindow:)];
	[array addObject:action];
	
	action=[QSAction actionWithIdentifier: kQSWindowFadeInAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
    [action setAction:@selector(fadeInWindow:)];
	[array addObject:action];
	
	action=[QSAction actionWithIdentifier: kQSWindowSelectAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
    [action setProvider:self];
    [action setAction:@selector(selectWindow:)];
	[action setRankModification:0.5];
	[array addObject:action];
	
	action=[QSAction actionWithIdentifier: kQSWindowSetLevelAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
	[action setArgumentCount:2];
    [action setAction:@selector(setWindow:level:)];
	[array addObject:action];
	
	action=[QSAction actionWithIdentifier:kQSWindowSetAlphaAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
	[action setArgumentCount:2];
    [action setAction:@selector(setWindow:alpha:)];
	[array addObject:action];
	
	action=[QSAction actionWithIdentifier: kQSWindowSetIgnoresMouseAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
	[action setArgumentCount:2];
    [action setAction:@selector(setWindow:ignoresMouse:)];
	[array addObject:action];
	
	action=[QSAction actionWithIdentifier: kQSWindowSetHasShadowAction bundle:[NSBundle bundleForClass:[self class]]];
    [action setIcon:nil];
    [action setProvider:self];
	[action setArgumentCount:2];
    [action setAction:@selector(setWindow:hasShadow:)];
	[array addObject:action];
	

    return array;
}

- (NSArray *)xvalidActionsForDirectObject:(QSObject *)dObject indirectObject:(QSObject *)iObject{
    return [NSArray arrayWithObjects:kQSWindowSetAlphaAction,kQSWindowSelectAction,kQSWindowSetLevelAction,kQSWindowSetIgnoresMouseAction,kQSWindowSetHasShadowAction,nil,kQSWindowFadeInAction,kQSWindowFadeOutAction,nil];
}
- (NSAppleEventDescriptor *)windowControlEventWithID:(OSType)eventID{
	NSAppleEventDescriptor *dockTarget=[NSAppleEventDescriptor targetDescriptorWithTypeSignature:'dock'];
	return [NSAppleEventDescriptor appleEventWithEventClass:kWindowControllerClass eventID:eventID targetDescriptor:dockTarget returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
	
}
- (QSObject *)objectForLevel:(int)level name:(NSString *)name{
	QSObject *object=[[[QSObject alloc]init]autorelease];
	[object setName:name];
	[object setObject:[NSNumber numberWithInt:level] forType:QSNumericType];
	return object;
}
- (NSArray *) validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	
	if ([action isEqualToString:kQSWindowSetAlphaAction]){
		QSObject *proxy=[QSObject textProxyObjectWithDefaultValue:@"100"];
		return [NSArray arrayWithObject:proxy];
	}
	
	if ([action isEqualToString:kQSWindowSetLevelAction]){
		return [NSArray arrayWithObjects:
			[self objectForLevel:NSNormalWindowLevel name:@"Normal"],
			[self objectForLevel:NSFloatingWindowLevel name:@"Floating"],
			[self objectForLevel:kCGDesktopWindowLevel name:@"Desktop"],
			nil];
	}
	if ([action isEqualToString:kQSWindowSetHasShadowAction]||[action isEqualToString:kQSWindowSetIgnoresMouseAction]){
		return [QSObject booleanObjects];
	}
	
	
	return nil;
}



- (QSObject *)selectWindow:(QSObject *)dObject{
	int windowid=[[dObject objectForType:QSWindowIDType]intValue];
	NSAppleEventDescriptor *event=[self windowControlEventWithID:kWindowControllerSelectWindow];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt:windowid]
				   forKeyword:'wid '];
	[event AESend];
	return nil;
}

- (void)setScale:(float)scale forWindowID:(int)windowid{
	NSAppleEventDescriptor *event=[self windowControlEventWithID:kWindowControllerWindowScale];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt:windowid]
				   forKeyword:'wid '];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithFloat:scale]
				   forKeyword:'scal'];
	NSLog(@"Event %@",event);
	[event AESend];
}


- (void)setAlpha:(float)alpha forWindowID:(int)windowid{
	NSAppleEventDescriptor *event=[self windowControlEventWithID:kWindowControllerWindowAlpha];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt:windowid]
				   forKeyword:'wid '];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithFloat:alpha]
				   forKeyword:'alph'];
	NSLog(@"Event %@",event);
	[event AESend];
}

- (QSObject *)fadeOutWindow:(QSObject *)dObject{
	NSNumber *number=[dObject objectForType:QSWindowIDType];
	NSLog(@"object %@",number);
	
	[self setAlpha:0.5 forWindowID:[number intValue]];
	
	return nil;
}

- (QSObject *)setWindow:(QSObject *)dObject alpha:(QSObject *)iObject{
	NSNumber *number=[dObject objectForType:QSWindowIDType];
	float alpha=[[iObject objectForType:QSTextType]floatValue];
	if (alpha>1.0)alpha/=100.0;
	
	[self setAlpha:alpha forWindowID:[number intValue]];
	
	return nil;
}

- (QSObject *)setWindow:(QSObject *)dObject scale:(QSObject *)iObject{
	NSNumber *number=[dObject objectForType:QSWindowIDType];
	float scale=[[iObject objectForType:QSTextType]floatValue];
	if (scale>1.0)scale/=100.0;
	
	[self setScale:scale forWindowID:[number intValue]];
	
	return nil;
}


- (QSObject *)setWindow:(QSObject *)dObject hasShadow:(QSObject *)iObject{
	NSNumber *number=[dObject objectForType:QSWindowIDType];
	int wid=[number intValue];
	BOOL value=[[iObject objectForType:QSNumericType]boolValue];
	
	
	NSAppleEventDescriptor *event=[self windowControlEventWithID:kWindowControllerWindowHasShadow];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[number intValue]]
				   forKeyword:'wid '];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:value]
				   forKeyword:'wshd'];
	[event AESend];
	NSLog(@"event %@",event);
	return nil;
}

- (QSObject *)setWindow:(QSObject *)dObject ignoresMouse:(QSObject *)iObject{
	NSNumber *number=[dObject objectForType:QSWindowIDType];
	int wid=[number intValue];
	BOOL value=[[iObject objectForType:QSNumericType]boolValue];
	
	
	NSAppleEventDescriptor *event=[self windowControlEventWithID:kWindowControllerWindowIgnoreMouse];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[number intValue]]
				   forKeyword:'wid '];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:value]
				   forKeyword:'wigm'];
	[event AESend];
	NSLog(@"event %@",event);
	return nil;
}


- (QSObject *)setWindow:(QSObject *)dObject level:(QSObject *)iObject{
	NSNumber *number=[dObject objectForType:QSWindowIDType];
	int level=[[iObject objectForType:QSNumericType]intValue];
	
	NSAppleEventDescriptor *event=[self windowControlEventWithID:kWindowControllerWindowLevel];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[number intValue]]
				   forKeyword:'wid '];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:level]
				   forKeyword:'wlev'];
	[event AESend];
	NSLog(@"AESend %@",event);
	
	return nil;
}

- (QSObject *)fadeInWindow:(QSObject *)dObject{
	NSNumber *number=[dObject objectForType:QSWindowIDType];
	NSLog(@"object %@",number);
	
	NSAppleEventDescriptor *event=[self windowControlEventWithID:kWindowControllerUnFadeWindow];
	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[number intValue]]
				   forKeyword:'wid '];
	[event AESend];
	
	return nil;
}


@end
