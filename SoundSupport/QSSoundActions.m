//
//  QSSoundActions.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on 12/29/04.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "QSSoundActions.h"
#import <Carbon/Carbon.h>
#import <QSCore/QSCore.h>


#include "QSMediaKeys.h"

#include <IOKit/IOKitLib.h>
#import <IOKit/hidsystem/IOHIDLib.h>
#import <IOKit/hidsystem/ev_keymap.h>



@implementation QSSoundActions
+(void)initialize{
//	HIDPostSysDefinedKey(NX_SUBTYPE_EJECT_KEY);
//	HIDPostAuxKey(NX_KEYTYPE_MUTE);
//	HIDPostAuxKey(NX_KEYTYPE_SOUND_UP);
//	HIDPostAuxKey(NX_KEYTYPE_SOUND_DOWN);
}
-(void)setSoundLevel:(int)level{
	long l;
	NSLog(@"soud %@",[NSSound soundUnfilteredFileTypes]);
	GetDefaultOutputVolume(&l);

	NSLog(@"%x %x",l,((l>>16)<<16));
	l = kFullVolume;

//	l = level * (float)l;
	long newLevel=level * (float)l;
	//long right=left;
	//left=0x0001;
	//	NSLog(@"lev %x %p",left,(left << 16)| left);
	
	
//	if (0){
//		}else{
//		while(!GetDefaultOutputVolume(&l) && ((l+l>>16-((l>>16)<<16))/2)>level){
//			NSLog(@"levd %d",((l+l>>16-((l>>16)<<16))/2));
//			HIDPostAuxKey(NX_KEYTYPE_SOUND_DOWN);
//			usleep(10000);
//		}
//		while(!GetDefaultOutputVolume(&l) && ((l+l>>16-((l>>16)<<16))/2)<level){
//			NSLog(@"levu %d",((l+l>>16-((l>>16)<<16))/2));
//			HIDPostAuxKey(NX_KEYTYPE_SOUND_UP);
//			usleep(10000);
//		}
//	}
	
	SetDefaultOutputVolume((newLevel << 16)| newLevel);

	// CGInhibitLocalEvents(YES);
	// CGEnableEventStateCombining(NO);
	//CGKeyCode keyCode=[[[[QSKeyCodeTranslator alloc]init]autorelease]keyCodeForCharacter:@"v"];
	
	
	//CGSetLocalEventsFilterDuringSupressionState(kCGEventFilterMaskPermitAllEvents, kCGEventSupressionStateSupressionInterval);


//	CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)56, true);

//	CGPostKeyboardEvent((CGCharCode)NULL, (CGKeyCode)56, false);
	

	
}

-(id)volumeUp{HIDPostAuxKey(NX_KEYTYPE_SOUND_UP);}
-(id)volumeDown{HIDPostAuxKey(NX_KEYTYPE_SOUND_DOWN);}
-(id)setMinVolume{[self setSoundLevel:1];}
-(id)setMaxVolume{[self setSoundLevel:256];}
-(id)setMidVolume{[self setSoundLevel:36];}
-(id)setMuteVolume{HIDPostAuxKey(NX_KEYTYPE_MUTE);}

-(QSObject *)playSound:(QSObject *)dObject{
	NSString *path=[dObject singleFilePath];
	NSSound *sound=[[[NSSound alloc]initWithContentsOfFile:path byReference:YES]autorelease];
	[sound play];
	[sound setDelegate:self];
	[sound retain];
	
	return nil;
}

- (void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool{
	[sound release];
}
@end
