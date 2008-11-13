

#import <QSCore/QSCore.h>
#import <QSCore/QSProcessMonitor.h>
#import <QSCore/QSLibrarian.h>
#import <QSCore/QSRegistry.h>
#import <QSEffects/QSWindow.h>
#import <QSInterface/QSInterface.h>
#import "QSNimbusProcessSwitcher.h"
#import "QSProcessSource.h"
#import "QSActionProvider_EmbeddedProviders.h"

#import "QSNimbusBackgroundView.h"
#import "QSProcessObjectView.h"
#import <QSInterface/QSFancyObjectCell.h>
#import <QSEffects/QSCGSTransition.h>
#import <math.h>

#define pidForProcess(x) [[[x objectForType:QSProcessType]objectForKey:@"NSApplicationProcessIdentifier"]intValue];

@interface NSWindow (NSTrackingRectsPrivate)
-(void)_clearTrackingRects;
@end

@implementation QSNimbusProcessSwitcher

- (id)init{
	//processViews=[[NSMutableArray arrayWithCapacity:0];
	infoTimer=nil;
	searchString=[[NSMutableString alloc]init];
    NSRect windowRect=fitRectInRect(rectFromSize(NSMakeSize(256,256)),NSInsetRect([[NSScreen mainScreen]frame],64,64),NO);
    QSWindow *window=[[[QSWindow alloc] initWithContentRect:windowRect styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask backing:NSBackingStoreBuffered defer:NO]autorelease];
    [window setBackgroundColor: [NSColor clearColor]];
	[window setAcceptsMouseMovedEvents:YES];
    QSNimbusBackgroundView *contentView=[[[QSNimbusBackgroundView alloc]initWithFrame:NSZeroRect]autorelease];
	[contentView setGlassStyle:QSGlossUpArc];
    [contentView setRadius:-1];
	//	NSColor *textColor=[[NSUserDefaults standardUserDefaults]colorForKey:@"QSAppearance1T"];
	//	NSColor *backColor=[[NSUserDefaults standardUserDefaults]colorForKey:@"QSAppearance1B"];
	//	[contentView setColor:backColor];
	processViewsDict=[[NSMutableDictionary alloc]init];
	
	
    [window setContentView:contentView];
    [window setOpaque:NO];
    [window setLevel:NSMainMenuWindowLevel+1];
    [window setHidesOnDeactivate:NO];
    [window setDelegatesEvents:YES];
    [window setFastShow:YES];
	//[window setShowEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSVExpandEffect",@"transformFn",@"show",@"type",[NSNumber numberWithFloat:0.15],@"duration",nil]];
	[window setHideEffect:[NSDictionary dictionaryWithObjectsAndKeys:@"QSSlightShrinkEffect",@"transformFn",@"hide",@"type",[NSNumber numberWithFloat:.125],@"duration",nil]];
	
    [window setMovableByWindowBackground:NO];
    
    //[window setHasShadow:NO];
    [window setHideOffset:NSZeroPoint];
    [window setShowOffset:NSMakePoint(40,200)];
    infoView=[[NSTextField alloc]initWithFrame:NSMakeRect(0,0,200,200)];
	[infoView setEditable:NO];
	[infoView setSelectable:YES];
	[infoView setBezeled:NO];
	[infoView setDrawsBackground:NO];
	[infoView setAlignment:NSCenterTextAlignment];
	
	[infoView setFont:[NSFont boldSystemFontOfSize:13]];
	
	
	//[infoView setTextColor:textColor];
	
	
	
	selectionView=[[QSObjectView alloc]initWithFrame:NSZeroRect];
	//[selectionView setCell:[[QSProcessObjectCell alloc]init]];
	[[selectionView cell] setHighlightsBy:NSNoCellMask];
	[selectionView setDropMode:QSFullDropMode];
	[[selectionView cell]setImagePosition:NSImageOnly];
    NSMutableArray *types=[[standardPasteboardTypes mutableCopy]autorelease];
    [types addObjectsFromArray:[[QSReg objectHandlers]allKeys]];
    [window registerForDraggedTypes:types];
	
	
	
	
	[contentView bind:@"color"
			 toObject:[NSUserDefaultsController sharedUserDefaultsController]
		  withKeyPath:@"values.QSAppearance1B"
			  options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
												  forKey:@"NSValueTransformerName"]];
	
    [contentView bind:@"innerColor"
			 toObject:[NSUserDefaultsController sharedUserDefaultsController]
		  withKeyPath:@"values.QSAppearance1A"
			  options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName
												  forKey:@"NSValueTransformerName"]];
	
	
    [window  bind:@"hasShadow"
		 toObject:[NSUserDefaultsController sharedUserDefaultsController]
	  withKeyPath:@"values.QSBezelHasShadow"
		  options:nil];
    
	[infoView bind:@"textColor"
		  toObject:[NSUserDefaultsController sharedUserDefaultsController]
	   withKeyPath:@"values.QSAppearance1T"
		   options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	//	[commandView bind:@"textColor"
	//			 toObject:[NSUserDefaultsController sharedUserDefaultsController]
	//		  withKeyPath:@"values.QSAppearance1T"
	//			  options:[NSDictionary dictionaryWithObject:NSUnarchiveFromDataTransformerName forKey:@"NSValueTransformerName"]];
	
	
	
	
	
	
    if (!(self=[super initWithWindow:window])) return nil;
    processViews=[[NSMutableArray alloc]init];
	// [self updateViewsForMouse:NO];
    
    [window setDelegate:self];
	[self updateViewsForMouse:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateViews) name:@"processesChanged" object:nil];
    
    return self;
}

- (NSRect)frameForWindowWithItemCount:(int)i atPoint:(NSPoint)point inRect:(NSRect)rect{
    NSRect screenRect=[[NSScreen mainScreen]frame];
	
    float diameter= 128*M_SQRT2*(1 + 1/sin(M_PI/i));
    //float diameter= 128*M_SQRT2*(1 + i/M_PI);
    //1 + 1 / cos( (M_PI_2 * (n-2)) / n)
    
    // float diameter=circumference/M_PI;   
	if (point.x<0){
		point.x=NSMidX(rect);
		point.y=NSMidY(rect);
	}
	//diameter=MIN(diameter,0.875*MIN(NSWidth(screenRect),NSHeight(screenRect)));
	
	diameter=MIN(600,MAX(144,-16+2*MIN(diameter,MIN(point.x-NSMinX(rect),MIN(NSMaxX(rect)-point.x,MIN(point.y-NSMinY(rect),NSMaxY(rect)-point.y)))))); 
	// distance to closest edge minus 16
	
    float size=diameter;
    NSRect windowRect=constrainRectToRect(NSMakeRect(point.x-size/2,point.y-size/2,size,size),rect);
    return windowRect;
}
- (void)mouseEntered:(NSEvent *)theEvent{
	//NSLog(@"mouse entexr %@",theEvent);
	// [[self window]makeFirstResponder:[theEvent userData]];
}
- (void)mouseExited:(NSEvent *)theEvent{
}

- (int)pidForProcess:(QSObject *)thisProcess{
	
}

- (void)updateViews{[self updateViewsForMouse:NO];}
- (void)updateViewsForMouse:(BOOL)forMouse{	
	int index=[self currentAppIndex];
	
	NSMutableArray *oldProcessViews=[processViews mutableCopy];
	[processViews removeAllObjects];
	
    NSArray *processes= [[QSProcessMonitor sharedInstance]getVisibleProcesses];
	
    int i;
	NSRect screenFrame=[[NSScreen mainScreen]frame];
	screenFrame.size.height-=22; //don't cover menu bar
    NSRect newWindowFrame=[self frameForWindowWithItemCount:[processes count] atPoint:forMouse?[NSEvent mouseLocation]:NSMakePoint(-1,-1) inRect:screenFrame];
	//logRect(newWindowFrame);
	//[[self window]setFrame:newFrame display:YES animate:YES];
	
	BOOL visible=[[self window]isVisible];
	
	NSMutableArray *animations=[NSMutableArray arrayWithCapacity:[processes count]+3];
	
	[[self window]setFrame:newWindowFrame display:YES animate:YES];
	
	//[animations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
	//		[self window],NSViewAnimationTargetKey,
	//		[NSValue  valueWithRect:newWindowFrame],NSViewAnimationEndFrameKey,
	//		nil]];
	//	
	
	
	[processes makeObjectsPerformSelector:@selector(loadIcon)];
	[processes makeObjectsPerformSelector:@selector(setRetainsIcon:) withObject:[NSNumber numberWithBool:YES]];
	
	QSObjectView *view=nil;
	QSObjectView *lastView=nil;
	QSObject *thisProcess=nil;
	int count=[processes count];
	for(i=0;i<count;i++){
		
		NSRect newViewFrame=[self frameForItem:i of:count inFrame:newWindowFrame];
		
		thisProcess=[processes objectAtIndex:i];
		int pid=pidForProcess(thisProcess);
		if (view=[[[self window]contentView]viewWithTag:pid]){
			
			[oldProcessViews removeObject:view];
			if (visible)
				[animations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					view,NSViewAnimationTargetKey,
					[NSValue valueWithRect:newViewFrame],NSViewAnimationEndFrameKey,
					nil]];
			else
				[view setFrame:newViewFrame];
		}else{
			
			
			view=[[[QSProcessObjectView alloc]initWithFrame:[self frameForItem:i of:[processes count] inFrame:newWindowFrame]]autorelease];
			[[view cell] setHighlightsBy:NSNoCellMask];
			[view setDropMode:QSActionDropMode];
			[view setObjectValue:thisProcess];
			[view setTag:pid];
			[view setAutoresizingMask:0];
			[[view cell]setImagePosition:NSImageOnly];
			[[[self window]contentView]addSubview:view];
			if (visible)
				[animations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
					view,NSViewAnimationTargetKey,
					[NSValue valueWithRect:newViewFrame],NSViewAnimationEndFrameKey,
					NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,
					nil]];
			else
				[view setFrame:newViewFrame];
			//	logRect(newViewFrame);
		}
		[processViews addObject:view];
		
		[lastView setNextKeyView:view];
		//if (i==0)[[self window]setInitialFirstResponder:view];
		
		lastView=view;
	}
	
	
	foreach(oldView,oldProcessViews){
		if (visible)
		[animations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			oldView,NSViewAnimationTargetKey,
			NSViewAnimationFadeOutEffect,NSViewAnimationEffectKey,
			nil]];
	}
	
	NSArray *subviews=processViews;
	
	
	if (index==NSNotFound)index=0;
	if (index>[subviews count])index=0;
	if ([subviews count]>1)
		[[self window]makeFirstResponder:[processViews objectAtIndex:index]];
	float innerSize=[self innerRadiusForFrame:newWindowFrame]*2;
	
	
	BOOL iconOnly=innerSize<=128*M_SQRT2;
	NSRect innerRect=centerRectInRect(rectFromSize(NSMakeSize(innerSize,innerSize)),rectFromSize(newWindowFrame.size));
	float iconSize=MIN(192,innerSize/2);
	NSRect iconRect=NSMakeRect(innerRect.origin.x+(innerSize-iconSize)/2,innerRect.origin.y+(innerSize-iconSize),iconSize,iconSize);
	if (iconOnly){
		iconSize=innerSize/M_SQRT2;
		iconRect=centerRectInRect(rectFromSize(NSMakeSize(iconSize,iconSize)),innerRect);
	}
	
	[animations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
		selectionView,NSViewAnimationTargetKey,
		[NSValue valueWithRect:iconRect],NSViewAnimationEndFrameKey,
		nil]];
	
	[selectionView setFrame:iconRect];
	
	if (!iconOnly){
		[infoView setFrame:NSMakeRect(innerRect.origin.x,innerRect.origin.y,innerRect.size.width,innerRect.size.height-iconSize*1)];
		[infoView setFont:[NSFont systemFontOfSize:MIN(24,NSHeight([infoView frame])/12)]];
		[[[self window]contentView]addSubview:infoView positioned:NSWindowBelow relativeTo:nil];
		if (visible){
			[infoView setHidden:NO];
		}
		[animations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			infoView,NSViewAnimationTargetKey,
			NSViewAnimationFadeInEffect,NSViewAnimationEffectKey,
			nil]];
		
	}else{
		if (visible)
			[animations addObject:[NSDictionary dictionaryWithObjectsAndKeys:
			infoView,NSViewAnimationTargetKey,
			NSViewAnimationFadeOutEffect,NSViewAnimationEffectKey,
			nil]];
		else
			[infoView setHidden:YES];
		
	}
	//	NSLog(@"innerSize:%f %f",innerSize,NSWidth(newWindowFrame)/2-64*M_SQRT2);
	[[[self window]contentView]setInnerRadius:innerSize/2];
	[[[self window]contentView]addSubview:selectionView positioned:NSWindowBelow relativeTo:nil];
	
	//QSCGSTransition *t=[QSCGSTransition transitionWithWindow:[self window]
	//													type:9 option:CGSDown duration:0.5f];
	
	
	if (visible){
	NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:animations];
	[animation setDuration:0.5];
	//[animation setAnimationCurve:NSAnimationLinear];
	[animation setAnimationBlockingMode:NSAnimationBlocking];
	
	//[animation setFrameRate:20];
	[animation setDelegate:self];	
	[animation startAnimation];
	}
	
	//	NSLog(@"removing %@",[animation delegate]);
	if (iconOnly)
		[infoView removeFromSuperview];
	[oldProcessViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	//[[self window]display];
	[processViews makeObjectsPerformSelector:@selector(updateTrackingRect)];
	
	//	[t runTransition:0.5];
	//	NSLog(@"tend");
}

- (void)animation:(NSAnimation*)animation didReachProgressMark:(NSAnimationProgress)progress{
	NSLog(@"prog");	
}
- (void)flagsChanged:(NSEvent *)theEvent{
	//NSLog(@"flags %d",[theEvent keyCode]);
	if (([theEvent modifierFlags]&flags)!=flags){
		//NSLog(@"flags %d %d",[theEvent modifierFlags],flags);
		if (!shouldStick){
			[self selectAndDeactivate:self];
		}
	}else if ([theEvent modifierFlags]&NSShiftKeyMask){
		NSEvent *keyUp=[NSApp nextEventMatchingMask:NSFlagsChangedMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.125] inMode:NSDefaultRunLoopMode dequeue:NO];
		//NSLog(@"shift %@",keyUp);
		if (keyUp && !([keyUp modifierFlags]&NSShiftKeyMask)){
			[self prevApp];	
		}
		
		
	}
}

- (void)switchToNextApp{
	//NSLog(@"next");
	if (![[self window]isVisible])
		[self showSwitcherCentered];
	else
		[self nextApp];
}
- (void)switchToPrevApp{
	if (![[self window]isVisible])
		[self showSwitcherCentered];
	//NSLog(@"prev");
	[self prevApp];
}

- (void)showSwitcherCentered{
	if (!centeredLocation){
		//NSLog(@"drawcentered");
		[self updateViewsForMouse:NO];
		centeredLocation=YES;
	}
	[self showSwitcher];
}
- (void)showSwitcherUnderMouse{
	//NSLog(@"show under mouse");
	if (![[self window]isVisible]){
	[self updateViewsForMouse:YES];
	centeredLocation=NO;
	
	//NSLog(@"show under mouse2");
	[self reallyShowSwitcher];
	}else{
		[self deactivate:nil];	
	}
}


- (void)showSwitcher{
	//Capture all Events
	BOOL switchNow=NO;
	shouldStick=NO;
	NSDate *fastSwitchDate=[NSDate dateWithTimeIntervalSinceNow:0.2];
    NSEvent *keyUp=[NSApp nextEventMatchingMask:NSAnyEventMask untilDate:fastSwitchDate inMode:NSDefaultRunLoopMode dequeue:YES];
	if ([keyUp type]==NSSystemDefined){
		keyUp=[NSApp nextEventMatchingMask:NSFlagsChangedMask untilDate:fastSwitchDate inMode:NSDefaultRunLoopMode dequeue:YES];
		if (keyUp) switchNow=YES;
	}else if ([keyUp type]==NSFlagsChanged){
		keyUp=[NSApp nextEventMatchingMask:NSAnyEventMask untilDate:fastSwitchDate inMode:NSDefaultRunLoopMode dequeue:YES];
		if ([keyUp type]==NSSystemDefined) switchNow=YES;
		
	}
	if (switchNow){
		[[NSWorkspace sharedWorkspace]activateApplication:[[QSProcessMonitor sharedInstance]previousApplication]];
	}else{ // Show switcher
		[self reallyShowSwitcher];
		//if (shouldStick=([keyUp type]==NSFlagsChanged);
}
}

- (void)reallyShowSwitcher{
	[NSApp setGlobalKeyEquivalentTarget:self];
	
	flags=[[NSApp currentEvent]modifierFlags];
	[super activate:self];
	[self selectCurrentProcess];
	[[self window]makeKeyAndOrderFront:self];  
	//keyUp=[NSApp nextEventMatchingMask:NSFlagsChangedMask|NSKeyDownMask untilDate:[NSDate dateWithTimeIntervalSinceNow:0.5] inMode:NSDefaultRunLoopMode dequeue:NO];
	
}


- (void)selectCurrentProcess{
	int pid=[[[[QSProcessMonitor sharedInstance]currentApplication]valueForKey:@"NSApplicationProcessIdentifier"]intValue];
	[[self window] makeFirstResponder:[[[self window]contentView]viewWithTag:pid]];
}

- (float)currentAppLocation{
    NSArray *subviews=processViews;
	//	NSLog(@"%@ %@",[subviews valueForKey:@"objectValue"],[self currentApplication]);
    int index=[[subviews valueForKey:@"objectValue"]indexOfObject:[self currentApplication]];
    return (float)index/[subviews count];
}
- (int)currentAppIndex{
    NSArray *subviews=processViews;
	//  return [subviews indexOfObject:[[self window] firstResponder]];
	//NSLog(@"%d %@",[[subviews valueForKey:@"objectValue"]count],[self currentApplication]);
    return[[subviews valueForKey:@"objectValue"]indexOfObject:[self currentApplication]];
	
	
}

- (void)prevApp{
    NSWindow *window=[self window];
    
    NSArray *subviews=processViews;
    int index=[subviews indexOfObject:[window firstResponder]];
    int count=[subviews count];
    if (!count)return;
	
	QSObjectView *view=[subviews objectAtIndex:(--index+count)%count];
    [window makeFirstResponder:view];
	
	[self processViewSelected:view];
}

- (void)nextApp{
    NSWindow *window=[self window];
    
    NSArray *subviews=processViews;
    int index=[subviews indexOfObject:[window firstResponder]];
	QSObjectView *view=nil;
	if (index!=NSNotFound){
		int count=[subviews count];
		if (!count)return;
		int newIndex=(index+1)%count;
		
		//	NSLog(@"index %d %d",index,newIndex);
		view=[subviews objectAtIndex:newIndex];
	}else{
		view=[subviews objectAtIndex:0];
	}
	
    [window makeFirstResponder:view];
    /*
     int i;
     float j;
     for(j=1;j>0;j-=0.1){
         
         for(i=0;i<[subviews count];i++){
             NSLog(@"%d",(i+count-index)%count);
             [[subviews objectAtIndex:i]setFrame:
                 [self frameForItem:fmod(((float)(i+count-index)+j),count) of:count]];
             // [[subviews objectAtIndex:i]setNeedsDisplay:YES];
         }
         
         [[self window]displayIfNeeded];
     }
     */
	[self processViewSelected:view];
}

- (void)firstResponderChanged:(id)responder{
	[self processViewSelected:responder];
	//logRect([responder frame]);
}

-(void)processViewSelected:(QSObjectView *)view{
	if ([view isKindOfClass:[QSObjectView class]]){
		[self setCurrentApplication:[view objectValue]];
	}
}
- (QSObject *)currentApplication {
    return [[currentApplication retain] autorelease];
}

- (void)setCurrentApplication:(QSObject *)value {
    if (currentApplication != value) {
        [currentApplication release];
        currentApplication = [value retain];
		
		NSString *info=nil;
		NSDictionary *dict=[value objectForType:QSProcessType];
		info=[self infoForApplication:dict showStats:NO];
		[selectionView setObjectValue:value];
		[infoView setStringValue:info?info:@""];
		[self resetInfoTimer];
    }
}

- (void)disableInfoTimer{
	[infoTimer invalidate];
	[infoTimer release];
	infoTimer=nil;
}
- (void)resetInfoTimer{
	[self disableInfoTimer];
	infoTimer=[[NSTimer scheduledTimerWithTimeInterval:0.667
												target:self selector:@selector(updateApplicationInfo) userInfo:nil repeats:YES]retain];
}

- (void)updateApplicationInfo{
	NSDictionary *dict=[[self currentApplication]objectForType:QSProcessType];
	NSString *info=[self infoForApplication:dict showStats:YES];
	[infoView setStringValue:info];
}


-(NSString *)infoForApplication:(NSDictionary *)appDictionary showStats:(BOOL)showStats{
	NSString *info= [NSString stringWithFormat:@"%@\r\rID: %@\rPID:\t%@",
		
		[appDictionary objectForKey:@"NSApplicationName"],
		[appDictionary objectForKey:@"NSApplicationBundleIdentifier"],
		[appDictionary objectForKey:@"NSApplicationProcessIdentifier"]
		//[[[appDictionary objectForKey:@"NSApplicationPath"]stringByDeletingLastPathComponent]stringByAbbreviatingWithTildeInPath],
		];
	
	if (showStats){
		int pid=[[appDictionary objectForKey:@"NSApplicationProcessIdentifier"]intValue];
		NSString *str=[NSString stringWithFormat:@"ps -aux -ww -p %d",pid];
		FILE *file = popen( [str UTF8String], "r" );
		NSString *output=nil;
		if( file )
		{
			char buffer[512];
			size_t length;
			
			length = fread( buffer, 1, sizeof( buffer ), file );
			output=[[[NSString alloc]initWithBytes:buffer length:length encoding:NSUTF8StringEncoding]autorelease];
			pclose( file );
		}
		NSCharacterSet *whitespace=[NSCharacterSet whitespaceCharacterSet];
		NSScanner *sc=[NSScanner scannerWithString:output];
		[sc scanUpToString:@"\n" intoString:nil];
		NSString *time=nil;
		float cpu,mem,vsz,rss; //tt//stat
		[sc scanUpToCharactersFromSet:whitespace intoString:nil];
		[sc scanUpToCharactersFromSet:whitespace intoString:nil];
		[sc scanFloat:&cpu];
		[sc scanFloat:&mem];
		[sc scanFloat:&vsz];
		[sc scanFloat:&rss];
		
		[sc scanUpToCharactersFromSet:whitespace intoString:nil];
		[sc scanUpToCharactersFromSet:whitespace intoString:nil];
		[sc scanUpToCharactersFromSet:whitespace intoString:&time];
		
		[sc scanUpToCharactersFromSet:whitespace intoString:nil];
		
		vsz=vsz/1024;
		rss=rss/1024;
		if (cpu)
			info =  [info stringByAppendingFormat:@"\n%.2f%% of CPU",cpu];
		else
			info =  [info stringByAppendingFormat:@"\nNo CPU usage",cpu];
		
		info =  [info stringByAppendingFormat:@"\nLaunched at %@",time];
		info =  [info stringByAppendingFormat:@"\n%.1f%% of Memory (%.0fM, %.0fM v)",mem,rss,vsz];
	}
	return info;
}

-(void)moveInDirection:(int)direction{
	if ([[NSApp currentEvent]type]==NSKeyDown){
		if ([[NSApp currentEvent]isARepeat])
			direction=lastDirection;
		else
			lastDirection=direction;
    }
    if (direction)
        [self prevApp];
    else 
        [self nextApp];
}



- (void)moveRight:(id)sender{[self moveInDirection:([self currentAppLocation]>0.25 && [self currentAppLocation]<0.75 )];}

-(void)moveLeft:(id)sender{
	[self moveInDirection:([self currentAppLocation]<0.25 || [self currentAppLocation]>0.75 )];
}
-(void)moveUp:(id)sender{
	//NSLog(@"loc %f",[self currentAppLocation]);
	[self moveInDirection:([self currentAppLocation]<0.5)];
}

-(void)moveDown:(id)sender{[self moveInDirection:([self currentAppLocation]>0.5) ];}


- (IBAction)deactivate:(id)sender{
	[NSApp setGlobalKeyEquivalentTarget:nil];
	[self disableInfoTimer];
	[super deactivate:self];	
    [[self window]orderOut:self];
}

- (IBAction)selectAndDeactivate:(id)sender{
    QSObject *selectedObject=[self currentApplication];
    [self deactivate:self];	
    [[QSLib actionForIdentifier:@"FileOpenAction"]performOnDirectObject:selectedObject indirectObject:nil];
}



- (void)insertText:(id)insertString{
	if ([searchString isEqualToString:@" "]){
		[QSPreferredCommandInterface actionActivate:[self currentApplication]];
		return;
	}
	[searchString appendString:insertString];
	
	[self performSelector:@selector(clearSearch) withObject:nil afterDelay:0.4 extend:YES];
	NSArray *objects=[processViews valueForKey:@"objectValue"];
	NSArray *array=[QSLib scoredArrayForString:searchString inSet:objects];
	//NSLog(@"search: %@ %@",searchString,array);
	if ([array count])
		[[self window]makeFirstResponder:[processViews objectAtIndex:[objects indexOfObject:[array objectAtIndex:0]]]];
	
}
- (void)clearSearch{
	[searchString setString:@""];	
}
- (void)cancelOperation:(id)sender{
    [self deactivate:sender];
}


- (void)windowDidResignKey:(NSNotification *)aNotification{
	[self deactivate:self];
}

- (BOOL)handleKeyEvent:(NSEvent *)theEvent{
	QSObject *selectedObject=[(QSObjectView *)[[self window]firstResponder]objectValue];
	NSNumber * keyHit = [NSNumber numberWithUnsignedInt: [[theEvent charactersIgnoringModifiers] characterAtIndex:0]];
	if ([theEvent type]==NSKeyUp)return NO;
	
	if ([theEvent keyCode]==48){ // Tab
		[theEvent modifierFlags]&NSShiftKeyMask ? [self prevApp] : [self nextApp];
		return YES;
	}
	
	if ([theEvent keyCode]==53){ // Escape
		
		[self deactivate:nil];
		return YES;
	}
	
	if (([theEvent modifierFlags]&NSShiftKeyMask) || ([theEvent modifierFlags]&NSCommandKeyMask)){
		//NSLog(@"keyequivevent: %@",theEvent	);
		switch ([keyHit unsignedIntValue]){
			case 'Q':
				[[QSLib actionForIdentifier:kAppQuitAction]performOnDirectObject:selectedObject indirectObject:nil];
				break;
			case 'H':
				[[QSLib actionForIdentifier:kAppHideAction]performOnDirectObject:selectedObject indirectObject:nil];break;
				break;
			case 'R':
				[[QSLib actionForIdentifier:kFileRevealAction]performOnDirectObject:selectedObject indirectObject:nil];
				break;
			case ' ':
				[self deactivate:self];
				[[QSReg preferredCommandInterface]executePartialCommand:[NSArray arrayWithObjects:selectedObject,nil]];
				break;
			default:
				break;
		}
		return YES;
	}else{
		
		
		switch ([keyHit unsignedIntValue]){
			case NSUpArrowFunctionKey:
				[self moveUp:nil];
				break;
			case NSDownArrowFunctionKey:
				[self moveDown:nil];
				break;
			case NSRightArrowFunctionKey:
				[self moveRight:nil];
				break;
			case NSLeftArrowFunctionKey:
				[self moveLeft:nil];
				break;
				
			case '\r':
				
				[self selectAndDeactivate:nil];
				break;
				
			default:
				[self insertText:[theEvent characters]];
				break;
		}
		
	}
	
	return YES;
}

static float ax=0;
static float ay=0;
#define MULTIPLIER 1
- (BOOL)shouldSendEvent:(NSEvent *)theEvent{ 
	if ([theEvent type]==NSKeyDown || [theEvent type]==NSKeyUp){
		[self handleKeyEvent:theEvent];
        return NO;
    }else if ([theEvent type]==NSFlagsChanged){
		[self flagsChanged:theEvent];	
	}else if ([theEvent type]==NSScrollWheel){
		scrollX+=[theEvent deltaX];
		scrollY+=[theEvent deltaY];
		
		
		int count=[processViews count];
		float angle=fmod(1-atan2f(scrollX,scrollY)/(2*M_PI),1);
		
		float currentAngle=[self currentAppLocation];
		float distance=fmodf(currentAngle-angle+1,1);
		if (hypotf(scrollX,scrollY)>20.0){
			if (MIN(distance,1-distance)>0.5/count){
				distance<0.5?[self prevApp]:[self nextApp];
				scrollX/=4;
				scrollY/=4;
			}
		}
		//int index=(int)roundf(angle*count)%count;
		
		//NSLog(@"scroll %f: %d of %d (%f)",hypotf(scrollX,scrollY),index,count, distance);
		
		
		
		//	[[self window] makeFirstResponder:[processViews objectAtIndex:index]];
		
		return NO;
		if ([theEvent deltaY]>0)
			[self moveUp:nil];
		else
			[self moveDown:nil];
		
		if ([theEvent deltaX]>0)
			[self moveLeft:nil];
		else
			[self moveRight:nil];
		
		return NO;
		//	[self moveInDirection:([self currentAppLocation]<0.25 || [self currentAppLocation]>0.75 )];}
		
}
//NSLog(@"Unhandled %@",theEvent);

return YES;
}
- (void)insertTab:(id)sender{
	[self nextApp]; 
}
- (void)insertBacktab:(id)sender{
	[self prevApp]; 
}
- (void)complete:(id)sender{
    [self cancelOperation:sender];
}
- (void)noop:(id)sender{
    [self cancelOperation:sender];
}
- (void)performClose:(id)sender{
    [self cancelOperation:sender];
}



- (void)doCommandBySelector:(SEL)aSelector{
    if (VERBOSE &&![self respondsToSelector:aSelector])
        //NSLog(@"Unhandled Command: %@",NSStringFromSelector(aSelector));
		[super doCommandBySelector:aSelector];
}


/*
 - (void)keyDown:(NSEvent *)theEvent{
     if ([[theEvent charactersIgnoringModifiers]isEqualToString:@"q"])
         NSLog(@"quit");
     else{
         //    NSLog(@"event %@",theEvent); 
         [self nextApp];  
     }
     //  [super keyDown:theEvent];
 }
 - (void)keyUp:(NSEvent *)theEvent{
     //    NSLog(@"event %@",theEvent); 
     [self nextApp];  
     [super keyUp:theEvent];
 }
 */
- (float)diameterForProcessCount:(int)count inDiameter:(float)diameter{
	float itemDiameter=diameter*M_PI/(count+M_PI); //the pi in denominator accounts for inset by radius of smaller circles
	itemDiameter=MIN(128*M_SQRT2,itemDiameter);
	//NSLog(@"diameter %f %f",itemDiameter,diameter*M_PI);
    return itemDiameter;
}
- (float)innerRadiusForFrame:(NSRect)frame{
	float diameter=NSWidth(frame);
	return diameter/2 - [self diameterForProcessCount:[processViews count] inDiameter:diameter];
}




- (NSRect)frameForItem:(float)i of:(int)j inFrame:(NSRect)windowFrame{
    float radius=NSWidth(windowFrame)/2;
	float itemDiameter=[self diameterForProcessCount:j inDiameter:NSWidth(windowFrame)];
	float itemSize=itemDiameter/M_SQRT2;
    NSRect rect=NSMakeRect(0,0,itemSize,itemSize);
    float innerRadius=radius-itemDiameter/2;
    
    float angle = M_PI*2*((float)i/j);
    float x=sin(angle);
    float y=cos(angle);
    
    //NSLog(@"%f %f %f",angle,x,y);
    
    rect.origin.x=radius + x*innerRadius - NSWidth(rect)/2;
    rect.origin.y=radius + y*innerRadius - NSHeight(rect)/2;
    rect.origin.x=(int)rect.origin.x;
	rect.origin.y=(int)rect.origin.y;
    return rect;
    
}




@end
