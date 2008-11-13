//
//  QSProcessSwitcherSupportPlugIn.m
//  QSProcessSwitcherSupportPlugIn
//
//  Created by Nicholas Jitkoff on 9/17/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSProcessSwitcherSupportPlugIn.h"

#import <QSCore/QSRegistry.h>
#import <QSFoundation/NDHotKeyEvent_QSMods.h>


@implementation QSRegistry (QSProcessSwitcher)
- (NSString *)preferredProcessSwitcherID{
	//NSLog(@"pref?");
	NSString *key=[[NSUserDefaults standardUserDefaults] stringForKey:kQSProcessSwitchers];
	if (!key)key=[[[self tableNamed:kQSProcessSwitchers]allKeys]lastObject];
		return key;
}

- (id <QSProcessSwitcher>)preferredProcessSwitcher{
	id mediator=[prefInstances objectForKey:kQSProcessSwitchers];
	if (!mediator){
		mediator=[self instanceForKey:[self preferredProcessSwitcherID]
							  inTable:kQSProcessSwitchers];
		if (mediator)
			[prefInstances setObject:mediator forKey:kQSProcessSwitchers];
	}
	return mediator;
}
@end

@implementation QSProcessSwitcherSupportPlugIn

mSHARED_INSTANCE_CLASS_METHOD

+ (void)loadPlugIn{

//	QSHotKeyEvent *switcherKey=(QSHotKeyEvent *)[QSHotKeyEvent getHotKeyForKeyCode:48
//																		 character:0
//																	 modifierFlags:NSControlKeyMask];
//	[switcherKey setTarget:[self sharedInstance] selectorReleased:(SEL)0 selectorPressed:@selector(switchToNextApp)];
//	[switcherKey setIdentifier:@"QSSwitchAppliciationHotKey"];
//	[switcherKey setEnabled:YES];
////	NSLog(@"hot %@",switcherKey);
//	switcherKey=(QSHotKeyEvent *)[QSHotKeyEvent getHotKeyForKeyCode:48
//														  character:0
//													  modifierFlags:NSControlKeyMask|NSShiftKeyMask];
//	[switcherKey setTarget:[self sharedInstance] selectorReleased:(SEL)0 selectorPressed:@selector(switchToPrevApp)];
//	[switcherKey setIdentifier:@"QSSwitchBackAppliciationHotKey"];
//	[switcherKey setEnabled:YES];
	[QSReg preferredProcessSwitcher];
}
+ (void)showSwitcher{
	[[QSReg preferredProcessSwitcher]showSwitcher];
}

- (void)switchToNextApp{
	[[QSReg preferredProcessSwitcher]switchToNextApp];
}
- (void)switchToPrevApp{
	[[QSReg preferredProcessSwitcher]switchToPrevApp];
}
- (void)showSwitcher{
	[[QSReg preferredProcessSwitcher]showSwitcher];
}
- (void)showSwitcherUnderMouse{
	[[QSReg preferredProcessSwitcher]showSwitcherUnderMouse];
}

@end




