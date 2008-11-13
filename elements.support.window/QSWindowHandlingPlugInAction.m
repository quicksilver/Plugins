//
//  QSWindowHandlingPlugInAction.m
//  QSWindowHandlingPlugIn
//
//  Created by Nicholas Jitkoff on 8/31/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSWindowHandlingPlugInAction.h"

#import <Carbon/Carbon.h>
#import "QXCGSWindowManager.h"
//#import <QSFoundation/NSAppleEventDescriptor_QSMods.h>
//#import "WindowControllerEvents.h"
//#import "WindowControllerEvents_BLTRX.h"



#define kQSWindowFadeOutAction @"QSWindowFadeOutAction"
#define kQSWindowFadeInAction @"QSWindowFadeInAction"

#define kQSWindowSetAlphaAction @"QSWindowSetAlphaAction"
#define kQSWindowSetLevelAction @"QSWindowSetLevelAction"
#define kQSWindowSetIgnoresMouseAction @"QSWindowSetIgnoresMouseAction"
#define kQSWindowSetHasShadowAction @"QSWindowSetHasShadowAction"
#define kQSWindowSelectAction @"QSWindowSelectAction"
#define kQSWindowSetStickyAction @"QSWindowSetStickyAction"


@implementation QSWindowHandlingPlugInAction


//- (NSAppleEventDescriptor *)windowControlEventWithID:(OSType)eventID {
//	NSAppleEventDescriptor *dockTarget = [NSAppleEventDescriptor targetDescriptorWithTypeSignature:'dock'];
//	return [NSAppleEventDescriptor appleEventWithEventClass:kWindowControllerClass eventID:eventID targetDescriptor:dockTarget returnID:kAutoGenerateReturnID transactionID:kAnyTransactionID];
//	
//}

- (QSObject *)objectForLevel:(int)level name:(NSString *)name {
	QSObject *object = [[[QSObject alloc] init] autorelease];
	[object setName:name];
	[object setObject:[NSNumber numberWithInt:level] forType:QSNumericType];
	[object setObject:@"Window" forMeta:kQSObjectIconName];
	return object;
}
- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
	
	if ([action isEqualToString:kQSWindowSetAlphaAction]) {
		QSObject *proxy = [QSObject textProxyObjectWithDefaultValue:@"100"];
		return [NSArray arrayWithObject:proxy];
	}
	
	if ([action isEqualToString:kQSWindowSetLevelAction]) {
		return [NSArray arrayWithObjects:
            [self objectForLevel:NSNormalWindowLevel name:@"Normal"] ,
            [self objectForLevel:NSFloatingWindowLevel name:@"Floating"] ,
            [self objectForLevel:kCGDesktopWindowLevel name:@"Desktop"] ,
            nil];
	}
	if ([action isEqualToString:kQSWindowSetHasShadowAction] || [action isEqualToString:kQSWindowSetStickyAction] || [action isEqualToString:kQSWindowSetIgnoresMouseAction]) {
		return [QSObject booleanObjectsWithToggle];
	}
	
	
	return nil;
}


- (id <QXCGSWindowManager>) remoteWindowManager {
  
  //  NSSocketPort *port = [[NSSocketPortNameServer sharedInstance] portForName:@"RemoteWindowConnection" host:@"*"];
  //  NSConnection *connection = [NSConnection connectionWithReceivePort:nil sendPort:port];
  //  
  
  id proxy = [NSConnection rootProxyForConnectionWithRegisteredName:@"RemoteWindowConnection" host:nil];
  
  if (proxy) {
		[proxy setProtocolForProxy:@protocol(QXCGSWindowManager)];
  }
  NSLog(@"proxy %@", proxy);
  return proxy;
  
}
- (id <QXCGSWindow>) remoteWindowWithID:(int)wid {
  return [[self remoteWindowManager] windowWithID:wid];
}

- (QSObject *)selectWindow:(QSObject *)dObject {
	int wid = [[dObject objectForType:QSWindowIDType] intValue];
  NSLog(@"select %d", wid);
  
  [[self remoteWindowWithID:wid] makeKeyAndOrderFront];
  
	return nil;
}

- (void)setScale:(float)scale forWindowID:(int)wid {
  [[self remoteWindowWithID:wid] setScale:scale];
}

- (void)setAlpha:(float)alpha forWindowID:(int)wid {
  [[self remoteWindowWithID:wid] setAlphaValue:alpha];
}

- (QSObject *)fadeOutWindow:(QSObject *)dObject {
	NSNumber *number = [dObject objectForType:QSWindowIDType];

	[self setAlpha:0.5 forWindowID:[number intValue]];
	
	return nil;
}

- (QSObject *)setWindow:(QSObject *)dObject alpha:(QSObject *)iObject {
	float alpha = [[iObject objectForType:QSTextType] floatValue];
	if (alpha > 1.0) alpha /= 100.0;
	
  for (NSNumber *widValue in [dObject arrayForType:QSWindowIDType]) {
    [[self remoteWindowWithID:[widValue intValue]] setAlphaValue:alpha];
  }
	return nil;
}

- (QSObject *)setWindow:(QSObject *)dObject scale:(QSObject *)iObject {
	NSNumber *number = [dObject objectForType:QSWindowIDType];
	float scale = [[iObject objectForType:QSTextType] floatValue];
//	if (scale > 1.0f) scale /= 100.0f;
	
	[self setScale:scale forWindowID:[number intValue]];
	
	return nil;
}

- (QSObject *)setWindow:(QSObject *)dObject hasShadow:(QSObject *)iObject {
	NSNumber *number = [dObject objectForType:QSWindowIDType];
	int wid = [number intValue];
	BOOL value = [[iObject objectForType:QSNumericType] boolValue];
}


- (QSObject *)setWindow:(QSObject *)dObject isSticky:(QSObject *)iObject {
	NSNumber *number = [dObject objectForType:QSWindowIDType];
	int wid = [number intValue];
	int value = [[iObject objectForType:QSNumericType] intValue];
	
  [[self remoteWindowWithID:wid] setSticky:value];
  	return nil;
}


- (QSObject *)setWindow:(QSObject *)dObject ignoresMouse:(QSObject *)iObject {
  BOOL value = [[iObject objectForType:QSNumericType] boolValue];
  for (NSNumber *number in [dObject arrayForType:QSWindowIDType]) {
    [[self remoteWindowWithID:[number intValue]] setIgnoresMouseEvents:value];
  }
	return nil;
}


- (QSObject *)setWindow:(QSObject *)dObject level:(QSObject *)iObject {
	int level = [[iObject objectForType:QSNumericType] intValue];
  for (NSNumber *number in [dObject arrayForType:QSWindowIDType]) {
    [[self remoteWindowWithID:[number intValue]] setLevel:level];
  }
	return nil;
}

//
//- (QSObject *)fadeInWindow:(QSObject *)dObject {
//	NSNumber *number = [dObject objectForType:QSWindowIDType];
////	NSLog(@"object %@", number);
//	
//	NSAppleEventDescriptor *event = [self windowControlEventWithID:kWindowControllerUnFadeWindow];
//	[event setParamDescriptor:[NSAppleEventDescriptor descriptorWithInt32:[number intValue]]
//				   forKeyword:'wid '];
//	[event AESend];
//	
//	return nil;
//}
@end
