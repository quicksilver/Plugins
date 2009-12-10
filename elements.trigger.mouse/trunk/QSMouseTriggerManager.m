//
//  QSMouseTriggerManager.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Sun Jun 13 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "QSMouseTriggerManager.h"
#import "QSMouseTriggerView.h"

#import <Carbon/Carbon.h>
#define QSTriggerCenter NSClassFromString(@"QSTriggerCenter")
#define NSAllModifierKeysMask (NSShiftKeyMask|NSControlKeyMask|NSAlternateKeyMask|NSCommandKeyMask|NSFunctionKeyMask)

@implementation NSEvent (CarbonConversion)
- (NSEvent *)mouseEventWithCarbonClickEvent:(EventRef)theEvent{
	return nil;
}
@end
@interface QSMouseTriggerTableCell : NSTextFieldCell
@end
@implementation QSMouseTriggerTableCell
- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	
	NSRect imageRect,textRect;
	NSDivideRect(cellFrame,&imageRect,&textRect,NSHeight(cellFrame),NSMinXEdge);
	
	[[NSColor lightGrayColor]set];
	//NSRectFill(imageRect);	
	[NSGraphicsContext currentContext];
	
	
	NSAffineTransform *flipTransform=[NSAffineTransform transform];
	[flipTransform translateXBy:0 yBy:NSMinY(cellFrame)];
	[flipTransform scaleXBy:1 yBy:-1];
	[flipTransform translateXBy:0 yBy:-NSMaxY(cellFrame)];
	
	[flipTransform concat];
	
	int anchors=[[[self representedObject] objectForKey:@"anchorMask"]intValue];
	
	
	NSBezierPath *path=[NSBezierPath bezierPath];
	[path appendBezierPathWithRoundedRectangle:NSInsetRect(imageRect,4,4)
									withRadius:2];
	[path fill];
	
	[[NSColor blueColor]set];
	imageRect=NSInsetRect(imageRect,1,1);
	if (anchors&QSMinXAnchorMask) //Left
		NSRectFill(rectForAnchor(QSMinXAnchor, imageRect,2,4));
	
	if (anchors&QSTopLeftAnchorMask)
		NSRectFill(rectForAnchor(QSTopLeftAnchor, imageRect,2,4));
	
	if (anchors&QSMaxYAnchorMask) //Top
		NSRectFill(rectForAnchor(QSMaxYAnchor, imageRect,2,4));
	
	if (anchors&QSTopRightAnchorMask)
		NSRectFill(rectForAnchor(QSTopRightAnchor, imageRect,2,4));
	
	if (anchors&QSMaxXAnchorMask) //Right
		NSRectFill(rectForAnchor(QSMaxXAnchor, imageRect,2,4));
	
	if (anchors&QSBottomRightAnchorMask)
		NSRectFill(rectForAnchor(QSBottomRightAnchor, imageRect,2,4));
	
	if (anchors&QSMinYAnchorMask) //Bottom
		NSRectFill(rectForAnchor(QSMinYAnchor, imageRect,2,4));
	
	if (anchors&QSBottomLeftAnchorMask)
		NSRectFill(rectForAnchor(QSBottomLeftAnchor, imageRect,2,4));
	
	
	
	[flipTransform invert];
	[flipTransform concat];
	
	[super drawWithFrame:textRect inView:controlView];	
}
@end


OSStatus mouseActivated(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData) {
	EventMouseButton button;
    GetEventParameter(theEvent, kEventParamMouseButton,typeMouseButton,0,
					  sizeof(button),0,&button);
	
	//	NSLog(@"------------------event %d",button);
	return CallNextEventHandler(nextHandler, theEvent); 
	return eventNotHandledErr;
}
BOOL is1043;
@implementation QSMouseTriggerManager
+(void)registerEventHandlers{
	//	if (VERBOSE) NSLog(@"Registering for Global Mouse Events");
	static EventHandlerRef trackMouse;
	EventTypeSpec eventType[2]={{kEventClassMouse, kEventMouseUp}, {kEventClassMouse, kEventMouseDown}};
	EventHandlerUPP handlerFunction = NewEventHandlerUPP(mouseActivated);
	InstallEventHandler(GetEventMonitorTarget(), handlerFunction, 2, eventType, NULL, &trackMouse);
}
+ (void)initialize{	
	SInt32 version;
	Gestalt (gestaltSystemVersion, &version);
	if (version >= 0x1043){
		is1043=YES;
		[self registerEventHandlers];
	}
	
}
- (NSCell *)descriptionCellForTrigger:(QSTrigger *)trigger{
	return	[[[QSMouseTriggerTableCell alloc]init]autorelease];
}

-(NSString *)name{
	return @"Mouse";
}
-(NSImage *)image{
	return [NSImage imageNamed:@"MouseTrigger"];
}
- (void)initializeTrigger:(NSMutableDictionary *)trigger{
	if (![trigger objectForKey:@"eventType"])
		[trigger setObject:[NSNumber numberWithInt:NSLeftMouseDown] forKey:@"eventType"];	
}

+ (id)sharedInstance{
    static QSMouseTriggerManager *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    }
    return _sharedInstance;
}

- (id) init{
    if (self=[super init]){
        anchorWindows=[[NSMutableDictionary alloc]initWithCapacity:0];
        anchorArrays=[[NSMutableDictionary alloc]initWithCapacity:0];
        anywhereArray=[[NSMutableArray alloc]init];
		// int i;
		//  for (i=1;i<9;i++)
		//   [anchorArrays setObject:[NSMutableArray arrayWithCapacity:0] forKey:[NSString stringWithFormat:@"%d",i]];
		
		//NSLog(@"init");
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidChangeScreenParameters:)
                                                     name:NSApplicationDidChangeScreenParametersNotification object:nil];
		
		[self addObserver:self
			   forKeyPath:@"currentTrigger"
				  options:0
				  context:nil];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	[self populateInfoFields];
}


-(NSMutableArray *)anchorArrayForScreen:(int)screen anchor:(int)anchor{
	NSString *key=[NSString stringWithFormat:@"%d:%d",screen,anchor];
	NSMutableArray *array=[anchorArrays objectForKey:key];
	if (!array){
		array=[NSMutableArray array];
		[anchorArrays setObject:array forKey:key];
		//NSLog(@"Array %@",key);
	}
	return array;
}


-(BOOL)enableTrigger:(NSDictionary *)entry{
	int anchorMask=[[entry objectForKey:@"anchorMask"]intValue];
	int screen=[[entry objectForKey:@"screen"]intValue];
	BOOL anywhere=[[entry objectForKey:@"anywhere"]boolValue];
	
	NSArray *screens=[NSScreen screens];
	int screenCount=[screens count];
	
	if (anywhere)
		[anywhereArray addObject:entry];
	
	int i;
	//NSArray *array;
	for (i=1;i<9;i++){
		if ((1 << i) & anchorMask){
			
			if (screen==0 || (screen==-1 && screenCount==1)){
				[[self anchorArrayForScreen:[[screens objectAtIndex:0]screenNumber]
									 anchor:i] addObject:entry];
			}else if (screen==1){
				if (screenCount>1){
					[[self anchorArrayForScreen:[[screens objectAtIndex:1]screenNumber]
										 anchor:i] addObject:entry];
				}
			}else if (screen==-1 && screenCount>1){
				for(NSScreen * targetScreen in screens){
					[[self anchorArrayForScreen:[targetScreen screenNumber]
										 anchor:i] addObject:entry];	
				}
			}else{
				[[self anchorArrayForScreen:screen anchor:i]  addObject:entry];
			}
			
			
			
		}
		
	}
	[self updateTriggerWindows];
	
    return YES;
}

-(BOOL)disableTrigger:(NSDictionary *)entry{
	//   NSString *theID=[entry objectForKey:kItemID];
    [[anchorArrays allValues]makeObjectsPerformSelector:@selector(removeObject:) withObject:entry];
	[anywhereArray removeObject:entry];
	[self updateTriggerWindows];
    return YES;
}

- (NSWindow *)triggerDescriptionWindowForAnchor:(int)anchor onScreen:(NSScreen *)screen{
	//	NSArray *array=[anchorArrays objectForKey:[NSString stringWithFormat:@"%d",anchor]];
	
	
	//	NSDictionary *thisTrigger;
	//	NSEnumerator *triggerEnum=[[anchorArrays objectForKey:[NSString stringWithFormat:@"%d",anchor]]objectEnumerator];
    
	//    while(thisTrigger=[triggerEnum nextObject]){
	//		NSLog(@"\rTrigger: %@\rCommand: %@",[self descriptionForTrigger:thisTrigger],[[QSTriggerCenter commandForTrigger:thisTrigger]description]);
	//	}	
	return nil;
}



- (void)handleMouseTriggerEvent:(NSEvent *)theEvent type:(int)type forView:(QSMouseTriggerView *)view{
	//NSLog(@"Mouse %@",theEvent);
	int anchor=view?view->anchor:-1;
	int screen=view?view->screenNum:-1;
	NSDictionary *thisTrigger;
	NSEnumerator *triggerEnum=nil;
	
	if (!view)
		triggerEnum=[anywhereArray objectEnumerator];
    else
		triggerEnum=[[anchorArrays objectForKey:[NSString stringWithFormat:@"%d:%d",screen,anchor]]objectEnumerator];
    
	NSMutableArray *matchedTriggers=[NSMutableArray array];
	BOOL checkForMoreClicks=NO;
	//BOOL checkForDelay=NO;
	
	//int inverseEvent=0;
	int inverseEventMask= 1 << (type+1);
	NSDate *date=[NSDate date];
	float thisDelay=0.0;
	float longestDelay=0.0;
    while(thisTrigger=[triggerEnum nextObject]){
		if (!type) type=[theEvent type];
		if (!theEvent) theEvent=[NSApp currentEvent];
		//				NSLog(@"match %@",thisTrigger);
        if ([[thisTrigger objectForKey:@"eventType"]intValue]!=type) continue;
		//	NSLog(@"match1 %@",[thisTrigger info]);
		if (type==NSOtherMouseDown && [[thisTrigger objectForKey:@"buttonNumber"]intValue]!=([theEvent buttonNumber]+1))continue;
		//NSLog(@"match2 %@",[thisTrigger description]);
		int flags=[[thisTrigger objectForKey:@"modifierFlags"]intValue];
		
		int currentFlags=[theEvent modifierFlags];
		
		if(flags!=(currentFlags&NSAllModifierKeysMask))continue;
		
		if (type==NSLeftMouseDown || type==NSRightMouseDown || type==NSOtherMouseDown){
#warning if only single click events are enabled, multi clicks should still resolve
			int clickCount=[[thisTrigger objectForKey:@"clickCount"]intValue];
			if (!clickCount)clickCount=1;
			if (clickCount && clickCount!=[theEvent clickCount]){
				if (clickCount>[theEvent clickCount])
					checkForMoreClicks=YES;
				continue;
			}
		}
		
		
		
		id delayValue=[thisTrigger objectForKey:@"delay"];
		thisDelay=delayValue?[delayValue floatValue]:0;
		
		if (thisDelay<longestDelay){
			continue;
		}else if (thisDelay>longestDelay){
			//NSLog(@"lookingForDelay %f",thisDelay,longestDelay);
			NSEvent *anEvent=[NSApp nextEventMatchingMask:inverseEventMask untilDate:[date addTimeInterval:thisDelay] inMode:NSDefaultRunLoopMode dequeue:NO];
			
			if (anEvent){
				//NSLog(@"skipping x %@",anEvent);
				
				
				continue;
			}else{
				
				//NSLog(@"accepting x, clearing previous %d",[matchedTriggers count]);
				longestDelay=thisDelay;
				[matchedTriggers removeAllObjects];
			}
			
		}
		
		
		
		
		[matchedTriggers addObject:thisTrigger];
		
	}
	
	
	if (checkForMoreClicks){
		NSEvent *anotherClick=[NSApp nextEventMatchingMask:1<<[theEvent type] untilDate:[NSDate dateWithTimeIntervalSinceNow:0.25] inMode:NSDefaultRunLoopMode dequeue:NO];
		if (anotherClick) return;
	}
	
	
	
	for(id match in matchedTriggers){
		//	NSLog(@"matched %@",match);
		[[QSTriggerCenter sharedInstance] executeTrigger:match]; 
	}
	
}

- (void)handleMouseTriggerEvent:(NSEvent *)theEvent forView:(QSMouseTriggerView *)view{
	[self handleMouseTriggerEvent:theEvent type:[theEvent type] forView:view];
}

//- (NSString *)descriptionForTrigger:(NSDictionary *)dict{return [[self class]descriptionForTrigger:dict];}
- (NSString *)descriptionForTrigger:(NSDictionary *)dict{
	
	//return [self descriptionForMouseTrigger:dict];
	int anchors=[[dict objectForKey:@"anchorMask"]intValue];
	
	NSMutableString *desc=[NSMutableString stringWithCapacity:0];
    
	NSMutableArray *anchorArray=[NSMutableArray array];
	
	if (anchors&QSMinXAnchorMask) //Left
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2190]];
	
	if (anchors&QSTopLeftAnchorMask)
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2196]];
	
	if (anchors&QSMaxYAnchorMask) //Top
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2191]];
	
	if (anchors&QSTopRightAnchorMask)
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2197]];
	
	if (anchors&QSMaxXAnchorMask) //Right
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2192]];
	
	if (anchors&QSBottomRightAnchorMask)
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2198]];
	
	if (anchors&QSMinYAnchorMask) //Bottom
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2193]];
	
	if (anchors&QSBottomLeftAnchorMask)
		[anchorArray addObject:[NSString stringWithFormat:@"%C",0x2199]];
				
	[desc appendString:[self descriptionForMouseTrigger:dict]];
	
	if ([anchorArray count])
		[desc appendFormat:@"(%@)",[anchorArray componentsJoinedByString:@","]];
				
				
	return desc;
}


- (NSString *)descriptionForMouseTrigger:(NSDictionary *)dict{
	
    NSMutableString *desc=[NSMutableString stringWithCapacity:0];
    
    int modifiers=[[dict objectForKey:@"modifierFlags"]intValue];
	
	
    
    if (modifiers&NSShiftKeyMask)[desc appendFormat:@"%C",0x21e7];
    if (modifiers&NSControlKeyMask)[desc appendFormat:@"%C",0x2303];
    if (modifiers&NSAlternateKeyMask)[desc appendFormat:@"%C",0x2325];
    if (modifiers&NSCommandKeyMask)[desc appendFormat:@"%C",0x2318];
    if (modifiers&NSFunctionKeyMask)[desc appendString:@"Fn"];
    
    NSEventType type=[[dict objectForKey:@"eventType"]intValue];
	
	
    switch (type){
        case NSLeftMouseDown:
            [desc appendFormat:@"%C",0x25BD];
            break;
        case NSRightMouseDown:
            [desc appendFormat:@"%C%C",0x25BD,0x1D3F];
            break;
        case NSOtherMouseDown:
			switch ([[dict objectForKey:@"buttonNumber"]intValue]){
				case 3: [desc appendFormat:@"%C%C",0x25BD,0x00B3]; break;
				case 4: [desc appendFormat:@"%C%C",0x25BD,0x2074]; break;
				case 5: [desc appendFormat:@"%C%C",0x25BD,0x2075]; break;
				default:  [desc appendFormat:@"%C?",0x25BD]; break;
			}
            break;
        case 101:
            [desc appendFormat:@"Drag Enter"];
            break;
        case 102:
            [desc appendFormat:@"Drag Exit"];
            break;
        case NSMouseEntered:
            [desc appendFormat:@"Mouse Enter"];
            break;
		case NSMouseExited:
            [desc appendFormat:@"Mouse Exit"];
            break;
        default:
            break;
    }
    
    
    int clickCount=[[dict objectForKey:@"clickCount"]intValue];
    if (clickCount>1)
        [desc appendFormat:@"%C%d",0x00D7,clickCount];
    
    
	//   NSLog(@"clickdel %@",[dict objectForKey:@"clickDelay"]);
    if ([dict objectForKey:@"delay"] && [[dict objectForKey:@"delay"]floatValue]>0)
        [desc appendFormat:@"...%.1fs",[[dict objectForKey:@"clickDelay"]floatValue]];
    
    
    
    return desc;
}

- (void)updateTriggerWindows{
    
    NSEnumerator *keyEnum=[anchorArrays keyEnumerator];
    NSString *key;
    
    NSEnumerator *triggerEnum;
    NSDictionary *thisTrigger;
    BOOL visible;
    BOOL clickable;
    BOOL draggable;
	int mainScreenNum=[[NSScreen mainScreen]screenNumber];
	//  NSLog(@"asch%@",anchorArrays);
    while (key=[keyEnum nextObject]){
        triggerEnum=[[anchorArrays objectForKey:key]objectEnumerator];
        visible=clickable=draggable=NO;
        NSMutableArray *tips=[NSMutableArray arrayWithCapacity:0];
        while(thisTrigger=[triggerEnum nextObject]){
            
            if (![[thisTrigger objectForKey:@"enabled"]boolValue])continue;
            
            [tips addObject:[NSString stringWithFormat:@"%@:\t%@",[self descriptionForMouseTrigger:thisTrigger],[thisTrigger name]]];
            visible=YES;
            NSEventType type=[[thisTrigger objectForKey:@"eventType"]intValue];
            switch (type){
                case NSLeftMouseDown:
                case NSRightMouseDown:
                case NSOtherMouseDown:
                    clickable=YES;
                    break;
                case 100:
                case 101:
				case 102:
                    draggable=YES;
                    break;
                case NSMouseEntered:
                    break;
                default:
                    break;
            }
        }
        
        if (visible){
            NSWindow *window=[anchorWindows objectForKey:key];
            if (!window){
				NSArray *components=[key componentsSeparatedByString:@":"];
				int anchor=[[components objectAtIndex:1] intValue];
				int screenNum=[[components objectAtIndex:0] intValue];
				
				//	NSLog(@"%d %x",anchor,screenNum);
				if (anchor==QSMaxYAnchor && screenNum==mainScreenNum){
					//	NSLog(@"skipping menu edge");
				}else{
					
					window=[QSMouseTriggerView triggerWindowWithAnchor:anchor
														   onScreenNum:screenNum];
					[anchorWindows setObject:window forKey:key];
					//NSLog(@"Creating anchor window %@",key);
					[[window contentView]setToolTip:nil];
				}
            }
            [[window contentView] setToolTip:[tips componentsJoinedByString:@"\r"]];
            [window orderFront:self];
            [window setIgnoresMouseEvents:!(clickable || draggable)];
        }else{
            [anchorWindows removeObjectForKey:key];
        }
    }
}

-(void)enableCaptureMode{
    
    int i;
    for(i=1;i<9;i++){
        NSString *key=[NSString stringWithFormat:@"%d",i];
        NSWindow *window=[anchorWindows objectForKey:key];
        if (!window){
            window=[QSMouseTriggerView triggerWindowWithAnchor:i onScreen:nil];
            [anchorWindows setObject:window forKey:key];
			// if (VERBOSE)NSLog(@"Creating anchor window %d",i);
            [[window contentView]setToolTip:nil];
        }
        
        [window setIgnoresMouseEvents:NO];
        [window orderFront:self];
        [[window contentView]setCaptureMode:YES];
        
    }
    
}


-(void)disableCaptureMode{
    int i;
    for(i=1;i<9;i++){
        NSWindow *window=[anchorWindows objectForKey:[NSString stringWithFormat:@"%d",i]];
        [[window contentView]setCaptureMode:NO];
        
    }
    [self updateTriggerWindows];
}

- (NSView *) settingsView{
    if (!settingsView){
        [NSBundle loadNibNamed:@"QSMouseTrigger" owner:self];		
	}
	//	NSLog(@"sview %@",settingsView);
    return [[settingsView retain] autorelease];
}











- (void)populateInfoFields{
	NSDictionary *thisTrigger=currentTrigger;
	//NSLog(@"trigger %@",currentTrigger);
	if([[thisTrigger objectForKey:@"type"]isEqualToString:@"QSMouseTrigger"]){
		int eventType=[[thisTrigger objectForKey:@"eventType"]intValue];
		BOOL otherClick=eventType==NSOtherMouseDown;
		
		int modifiersMask=[[thisTrigger objectForKey:@"modifierFlags"]intValue];
		BOOL anywhere=[[thisTrigger objectForKey:@"anywhere"]boolValue] && (otherClick);
		
		[mouseTriggerScreenPopUp removeAllItems];
		id <NSMenuItem>item=[[mouseTriggerScreenPopUp menu] addItemWithTitle:@"All Displays" action:nil keyEquivalent:@""];
		[item setTag:-1];
		
		item=[NSMenuItem separatorItem];
		[item setTag:NSNotFound];
		[[mouseTriggerScreenPopUp menu]addItem:item];
		
		item=	[[mouseTriggerScreenPopUp menu] addItemWithTitle:@"Main Display" action:nil keyEquivalent:@""];
		[item setTag:0];
		item=	[[mouseTriggerScreenPopUp menu] addItemWithTitle:@"Secondary Display" action:nil keyEquivalent:@""];
		[item setTag:1];
		
		item=[NSMenuItem separatorItem];
		[item setTag:NSNotFound];
		[[mouseTriggerScreenPopUp menu]addItem:item];
		
		item=[[mouseTriggerScreenPopUp menu] addItemWithTitle:@"Specific Displays:" action:nil keyEquivalent:@""];
		[item setTarget:nil];
		
		NSEnumerator *e=[[NSScreen screens]objectEnumerator];
		NSScreen *screen;
		while(screen=[e nextObject]){
			NSString *name=[screen deviceName];
			name=[name stringByAppendingString:[[NSString stringWithFormat:@" (%x)",[screen screenNumber]]uppercaseString]];
			
			[[mouseTriggerScreenPopUp menu] addItemWithTitle:name action:nil keyEquivalent:@""];
			
			[item setTag:[screen screenNumber]];
		}
		
		int screenNum=[[thisTrigger objectForKey:@"screen"]intValue];
		if (anywhere)screenNum=-1;
		[mouseTriggerScreenPopUp setEnabled:!anywhere];
		item=[[mouseTriggerScreenPopUp menu]itemWithTag:screenNum];
		if (!item){
			item=[[mouseTriggerScreenPopUp menu] addItemWithTitle:[NSString stringWithFormat:@"Other (%d)",screenNum] action:nil keyEquivalent:@""];
			[item setTag:screenNum];	
		}
		[mouseTriggerScreenPopUp selectItem:item];
		
		NSArray *screens=[NSScreen screens];
		
		if (screenNum==1 && [screens count]>1)
			screenNum=[[[NSScreen screens]objectAtIndex:1]screenNumber];		
		if (screenNum<=0)
			screenNum=[[screens objectAtIndex:0]screenNumber];
		
		[desktopImageView setScreenNumber:screenNum];
		
		
		[menuBarAnchorButton setEnabled:screenNum];
		
		
		
		
		
		BOOL clickEvent=(eventType==NSLeftMouseDown || eventType==NSRightMouseDown || eventType==NSOtherMouseDown);
		
		if (eventType==NSOtherMouseDown)
			eventType+=[[thisTrigger objectForKey:@"buttonNumber"]intValue]-3;
		
		int index=[mouseTriggerTypePopUp indexOfItemWithTag:eventType];
		//NSLog(@"type %@ %d %d",mouseTriggerTypePopUp,eventType,index);
		[mouseTriggerTypePopUp selectItemAtIndex:index];
		
		[anywhereButton setState:anywhere];
		[anywhereButton setHidden:!is1043 || (!otherClick && !modifiersMask)];
		int anchorMask= [[thisTrigger objectForKey:@"anchorMask"]intValue];
		
		int i;
		for (i=1;i<9;i++){
			[[anchorView viewWithTag:i]setState:(anchorMask&(1<<i))];
			[[anchorView viewWithTag:i]setEnabled:!anywhere];
			
		}
		
		
		for (i=17;i<24;i++){
			//  NSLog(@"%@ %d %d",[modifiersView viewWithTag:i],modifiersMask,(modifiersMask&(1<<i)));
			[[modifiersView viewWithTag:i]setState:(modifiersMask&(1<<i))];
		}
		
		int clickCount=MAX(1,[[thisTrigger objectForKey:@"clickCount"]intValue]);
		[mouseTriggerClickCountField setIntValue:clickCount];
		[mouseTriggerClickCountStepper setIntValue:clickCount];
		
		
		[mouseTriggerClickCountField setHidden:!clickEvent];
		[mouseTriggerClickCountStepper setHidden:!clickEvent];
		
		BOOL delayableEvent=clickEvent || (eventType==NSMouseEntered);
		NSNumber *delay=[thisTrigger objectForKey:@"delay"];
		[mouseTriggerDelaySwitch setEnabled:delayableEvent];
		[mouseTriggerDelaySwitch setState:delay && delayableEvent];
		
		[mouseTriggerDelayField setEnabled: delay && delayableEvent];
		[mouseTriggerDelayField setObjectValue:delay];
		
		//        IBOutlet NSTextField *mouseTriggerDelayField;
		
		// IBOutlet NSView *modifiersView;
	}	
}




- (IBAction) setMouseTriggerModifierFlag:(id)sender{
	NSMutableDictionary *thisTrigger=currentTrigger;
	
	int mask=[[thisTrigger objectForKey:@"modifierFlags"]intValue];
	
	if ([sender state])
		mask |= 1<<[sender tag];
	else
		mask &= ~(1<<[sender tag]);
	
	//NSLog(@" %d",mask);
	[thisTrigger setObject:[NSNumber numberWithInt:mask] forKey:@"modifierFlags"];
	[[QSTriggerCenter sharedInstance] triggerChanged:thisTrigger];
	//	[triggerTable reloadData];
	[self populateInfoFields];
}


- (IBAction) setMouseTriggerValueForSender:(id)sender{
	id nextResponder=nil;
	NSMutableDictionary *thisTrigger=currentTrigger;
	if (sender==mouseTriggerClickCountStepper){
		[thisTrigger setObject:[sender objectValue] forKey:@"clickCount"];
	}else if (sender==mouseTriggerDelaySwitch){
		
		if ([sender state]){
			[thisTrigger setObject:[NSNumber numberWithFloat:0.5f] forKey:@"delay"];
			nextResponder=mouseTriggerDelayField;
		}else{
			[[thisTrigger info] removeObjectForKey:@"delay"];
		}
		
	}else if (sender==mouseTriggerDelayField){
		float delay=[sender floatValue];
		
		if (delay>0)
			[thisTrigger setObject:[NSNumber numberWithFloat:delay] forKey:@"delay"];
		else
			[thisTrigger removeObjectForKey:@"delay"];
	}else if (sender==mouseTriggerScreenPopUp){
		
		[thisTrigger setObject:[NSNumber numberWithInt:[[sender selectedItem]tag]] forKey:@"screen"];
		//	NSLog(@"Screen set to: %x",[[sender selectedItem]tag]);
	}else if (sender==anywhereButton){
		[thisTrigger setObject:[sender objectValue] forKey:@"anywhere"];
	}
	[[QSTriggerCenter sharedInstance] triggerChanged:thisTrigger];
	[self populateInfoFields];
	if (nextResponder)
		[[sender window]makeFirstResponder:nextResponder];
}

- (IBAction) setMouseTriggerAnchorMask:(id)sender{
	
	NSMutableDictionary *thisTrigger=currentTrigger;
	int mask=[[thisTrigger objectForKey:@"anchorMask"]intValue];
	
	if ([sender state])
		mask |= 1<<[sender tag];
	else
		mask &= ~(1<<[sender tag]);
	
	[thisTrigger setObject:[NSNumber numberWithInt:mask] forKey:@"anchorMask"];
	[[QSTriggerCenter sharedInstance] triggerChanged:thisTrigger];
	//	[triggerTable reloadData];
}
- (IBAction) setMouseTriggerType:(id)sender{
	
	NSMutableDictionary *thisTrigger=currentTrigger;
	int eventType=[[sender selectedItem]tag];
	int buttonNumber=0;
	switch (eventType){
		case 25: buttonNumber=3; break;
		case 26: eventType=25; buttonNumber=4; break;
		case 27: eventType=25; buttonNumber=5; break;
		default: break;
	}
	
	[thisTrigger setObject:[NSNumber numberWithInt:eventType] forKey:@"eventType"];
	if (buttonNumber)
		[thisTrigger setObject:[NSNumber numberWithInt:buttonNumber] forKey:@"buttonNumber"];
	[[QSTriggerCenter sharedInstance] triggerChanged:thisTrigger];
	//	[triggerTable reloadData];
	[self populateInfoFields];
}




- (void)applicationDidChangeScreenParameters:(NSNotification *)aNotification{
	//NSLog(@"screen change!");
	[anchorArrays removeAllObjects];
	[anchorWindows removeAllObjects];
	for(NSDictionary * trigger in [[QSTriggerCenter sharedInstance]triggers]){
		if ([[trigger objectForKey:@"type"]isEqualToString:@"QSMouseTrigger"]){
			[self disableTrigger:trigger];
			[self enableTrigger:trigger];
		}
	}
	
}



-(id)resolveProxyObject:(id)proxy{
	
	return [self mouseTriggerObject];
}

-(NSArray *)typesForProxyObject:(id)proxy{
	return [[self mouseTriggerObject]types];
}



- (id)mouseTriggerObject { return [[mouseTriggerObject retain] autorelease]; }
- (void)setMouseTriggerObject:(id)newMouseTriggerObject
{
    [mouseTriggerObject autorelease];
    mouseTriggerObject = [newMouseTriggerObject retain];
}

@end





