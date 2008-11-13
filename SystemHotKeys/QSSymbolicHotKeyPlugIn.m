//
//  QSSymbolicHotKeyPlugIn.m
//  QSSymbolicHotKeyPlugIn
//
//  Created by Nicholas Jitkoff on 11/10/04.
//  Copyright __MyCompanyName__ 2004. All rights reserved.
//

#import "QSSymbolicHotKeyPlugIn.h"


void QSPerformSymbolicHotKey(int k){
	CFPreferencesAppSynchronize(CFSTR("com.apple.symbolichotkeys"));
	NSDictionary *hotKeyInfo=(NSDictionary *)[CFPreferencesCopyAppValue(CFSTR("AppleSymbolicHotKeys"),CFSTR("com.apple.symbolichotkeys")) autorelease];
	NSArray *hotKey=[hotKeyInfo valueForKeyPath:[NSString stringWithFormat:@"%d.value.parameters",k]];
	CGKeyCode keyCode=0;
	long modifiers=0;
	
	if ([hotKey count]==3){
		keyCode=[[hotKey objectAtIndex:1]intValue];
		modifiers=[[hotKey objectAtIndex:2]longValue];
	}else{
		switch (k){
			case 32: keyCode=101; break;
			case 33: keyCode=109; break;
			case 36: keyCode=103; break;
			case 62: keyCode=111; break;
		}
	}
	
	int command=modifiers & NSCommandKeyMask;
	int option=modifiers & NSAlternateKeyMask;
	int shift=modifiers & NSShiftKeyMask;
	int control=modifiers & NSControlKeyMask;
	
	
	usleep (100000);
	
	CGInhibitLocalEvents(YES);
	CGEnableEventStateCombining(NO);
	
	CGSetLocalEventsFilterDuringSupressionState(kCGEventFilterMaskPermitAllEvents, kCGEventSupressionStateSupressionInterval);
	
		
	if (command) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)55, true);
	if (shift) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)56, true);
	if (option) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)58, true);
	if (control) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)59, true);
	
	CGPostKeyboardEvent((CGCharCode)NULL, keyCode, true);
	CGPostKeyboardEvent((CGCharCode)NULL, keyCode, false);
	
	if (control) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)59, false);
	if (option) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)58, false);
	if (shift) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)56, false);
	if (command) CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)55, false);
	
	CGEnableEventStateCombining(YES);
	CGInhibitLocalEvents(NO);
}


@implementation QSSymbolicHotKeyPlugIn

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return [QSResourceManager imageNamed:@"/System/Library/PreferencePanes/Expose.prefPane/Contents/Resources/WindowVous.tif"];
}
#define ICON_NAME @"ExposŽIcon"
- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
//	NSArray *array;
	
//	CopySymbolicHotKeys(&array);
	
	//NSLog(@"sym %@",array);
	SInt32 *osVersion;
	Gestalt(gestaltSystemVersion, &osVersion);
	
	CFPreferencesAppSynchronize(CFSTR("com.apple.symbolichotkeys"));
	NSDictionary *hotKeyInfo=(NSDictionary *)[CFPreferencesCopyAppValue(CFSTR("AppleSymbolicHotKeys"),CFSTR("com.apple.symbolichotkeys")) autorelease];
	
    NSMutableArray *objects=[NSMutableArray arrayWithCapacity:1];
    QSObject *newObject;
	
	NSDictionary *entry=nil;
	if (!(entry=[hotKeyInfo objectForKey:[NSString stringWithFormat:@"%d",32]]) || [entry boolForKey:@"enabled"]){
		[objects addObject:(newObject=[QSObject messageObjectWithTargetClass:NSStringFromClass([self class]) selectorString:@"showAllWindows"])];
		[newObject setName:@"ExposŽ All Windows"];
		[newObject setIdentifier:@"QSAllWindowsSystemHotKey"];
		[newObject setObject:ICON_NAME forMeta:kQSObjectIconName];
	}
	if (!(entry=[hotKeyInfo objectForKey:[NSString stringWithFormat:@"%d",33]]) || [entry boolForKey:@"enabled"]){
		[objects addObject:(newObject=[QSObject messageObjectWithTargetClass:NSStringFromClass([self class]) selectorString:@"showApplicationWindows"])];
		[newObject setName:@"ExposŽ Application Windows"];
		[newObject setIdentifier:@"QSAppWindowsSystemHotKey"];
		[newObject setObject:ICON_NAME forMeta:kQSObjectIconName];
	}
				
	if (!(entry=[hotKeyInfo objectForKey:[NSString stringWithFormat:@"%d",36]]) || [entry boolForKey:@"enabled"]){
		[objects addObject:(newObject=[QSObject messageObjectWithTargetClass:NSStringFromClass([self class]) selectorString:@"showDesktop"])];
		[newObject setName:@"ExposŽ Desktop"];
		
		[newObject setIdentifier:@"QSDesktopSystemHotKey"];
		[newObject setObject:ICON_NAME forMeta:kQSObjectIconName];
	}
	
	if (osVersion>= 0x1040){
		if (!(entry=[hotKeyInfo objectForKey:[NSString stringWithFormat:@"%d",62]]) || [entry boolForKey:@"enabled"]){
			[objects addObject:(newObject=[QSObject messageObjectWithTargetClass:NSStringFromClass([self class]) selectorString:@"showDashboard"])];
			[newObject setName:@"Show Dashboard"];
			[newObject setIdentifier:@"QSDashboardSystemHotKey"];
			[newObject setObject:ICON_NAME forMeta:kQSObjectIconName];
		}
	}
	return objects;
	
}
- (BOOL)loadChildrenForObject:(QSObject *)object{
	[object setChildren:[self objectsForEntry:nil]];
	return YES;
}

- (void)showAllWindows{QSPerformSymbolicHotKey(32);}
- (void)showApplicationWindows{QSPerformSymbolicHotKey(33);}
- (void)showDesktop{QSPerformSymbolicHotKey(36);}
- (void)showDashboard{QSPerformSymbolicHotKey(62);}

	//	32 - Show all windows (F14=107)
	//	33 - Show application windows (F15=113)
	//	34 - Slow motion show all windows
	//	35 - Slow motion show application windows
	//	36 - Show desktop (F16=106)
	//	37 - Slow motion show desktop
	// 62 - Dashboard
	// 63 - Dashboard Slow
@end
