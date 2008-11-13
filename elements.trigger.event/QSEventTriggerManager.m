//
//  QSMouseTriggerManager.m
//  Quicksilver
//
//  Created by Nicholas Jitkoff on Sun Jun 13 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#import "QSEventTriggerManager.h"
#import <QSCore/QSResourceManager.h>
#import <QSInterface/QSObjectCell.h>
#define QSTriggerCenter NSClassFromString(@"QSTriggerCenter")
@implementation QSEventTriggerManager
-(NSString *)name{
	return @"Event";
}
-(NSImage *)image{
	NSImage *image=[[[QSResourceManager imageNamed:@"GenericApplicationIcon"]copy]autorelease];
	[image setSize:NSMakeSize(16,16)];
	return image;
}
- (void)initializeTrigger:(NSMutableDictionary *)trigger{
}

+ (id)sharedInstance{
    static QSEventTriggerManager *_sharedInstance = nil;
    if (!_sharedInstance){
        _sharedInstance = [[[self class] allocWithZone:[self zone]] init];
    }
    return _sharedInstance;
}

- (id) init{
    if (self=[super init]){
		triggersByEvent=[[NSMutableDictionary alloc]init];
		[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(eventTriggered:) name:QSEventNotification object:nil];
		[self addObserver:self
			   forKeyPath:@"currentTrigger"
				  options:0
				  context:nil];
	}
    return self;
} 
- (void)awakeFromNib{
	
    QSObjectCell *objectCell = [[[QSObjectCell alloc] init] autorelease];
	
    //imageAndTextCell = [[[QSImageAndTextCell alloc] init] autorelease];
	//  [imageAndTextCell setWraps:NO];
    [[triggerObjectsTable tableColumnWithIdentifier: kItemName] setDataCell:objectCell];
    [[[triggerObjectsTable tableColumnWithIdentifier: kItemName]dataCell] setFont:[NSFont systemFontOfSize:11]];
 
	
}
- (void)triggerObjects{
	return [NSMutableArray array];	
	
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
	[self populateInfoFields];
}
-(void)eventTriggered:(NSNotification *)notif{
	id object=[notif userInfo];
	if ([object isKindOfClass:[NSDictionary class]])object=[object objectForKey:@"object"];
	[self handleTriggerEvent:[notif object] withObject:object];	
}

-(NSMutableArray *)triggerArrayForEvent:(NSString *)event{
	if (!event)return nil;
	NSMutableArray *array=[triggersByEvent objectForKey:event];
	if (!array)
		[triggersByEvent setValue:(array=[NSMutableArray array]) forKey:event];
	return array;
}

-(BOOL)enableTrigger:(NSDictionary *)entry{
	NSString *event=[entry objectForKey:kEventTrigger];
	NSDictionary *eventInfo=[[QSReg tableNamed:kQSTriggerEvents]objectForKey:event];
	NSString *providerClass=[eventInfo objectForKey:@"provider"];
	id provider=[QSReg getClassInstance:providerClass];
	
	NSMutableArray *triggerArray=[self triggerArrayForEvent:event];
	if ([triggerArray count]==0){
		if ([provider respondsToSelector:@selector(enableEventObserving:)])
			[provider enableEventObserving:event];
	}
	[triggerArray addObject:entry];
	
	if ([provider respondsToSelector:@selector(addObserverForEvent:trigger:)])
		[provider addObserverForEvent:event trigger:entry];
	
	
    return YES;
}



-(BOOL)disableTrigger:(NSDictionary *)entry{
	NSString *event=[entry objectForKey:kEventTrigger];
	NSDictionary *eventInfo=[[QSReg tableNamed:kQSTriggerEvents]objectForKey:event];
	NSString *providerClass=[eventInfo objectForKey:@"provider"];
	id provider=[QSReg getClassInstance:providerClass];
	
	NSMutableArray *triggerArray=[self triggerArrayForEvent:event];
	
	if ([provider respondsToSelector:@selector(removeObserverForEvent:trigger:)])
		[provider removeObserverForEvent:event trigger:entry];
	
	[triggerArray removeObject:entry];
	
	if ([triggerArray count]==0){
		if ([provider respondsToSelector:@selector(disableEventObserving:)])
			[provider disableEventObserving:event];
	}
    return YES;
}


-(void)handleTriggerEvent:(NSString *)event withObject:(id)object{
	if (VERBOSE)	NSLog(@"Event:%@\r%@",event, object);	
	NSEnumerator *e=[[self triggerArrayForEvent:event]objectEnumerator];
	QSTrigger *trigger;
	[self setEventTriggerObject:object];
	while (trigger=[e nextObject]){
		
		float delay=[[trigger objectForKey:@"eventDelay"]floatValue];
		BOOL oneTime=[[trigger objectForKey:@"eventOneTime"]boolValue];
		BOOL idle=[[trigger objectForKey:@"eventWaitTillIdle"]boolValue];
		
		//	if (oneTime)
		//		[trigger setOneTime:YES];
		
		if (delay){
			if (idle){
				[trigger performSelector:@selector(execute) withObject:nil afterDelay:delay extend:NO];
			}else{
				[trigger performSelector:@selector(execute) withObject:nil afterIdleFor:delay repeat:NO];
			}
			
		}else{
			[trigger execute];	
		}
	}
	
}

- (NSString *)descriptionForTrigger:(NSDictionary *)dict{
	NSString *event=[dict objectForKey:kEventTrigger];
	NSDictionary *eventInfo=[[QSReg tableNamed:kQSTriggerEvents]objectForKey:event];
	return [eventInfo objectForKey:@"name"];
}

- (NSView *) settingsView{
    if (!settingsView){
        [NSBundle loadNibNamed:@"QSEventTrigger" owner:self];
	}
    return [[settingsView retain] autorelease];
}

- (IBAction)updateTrigger:(id)sender{
	[[QSTriggerCenter sharedInstance] triggerChanged:[self currentTrigger]];
}

- (IBAction)setEventType:(id)sender{
	[self disableTrigger:[self currentTrigger]];
	[[self currentTrigger] setObject:[[sender selectedItem]representedObject]forKey:@"eventTrigger"];
	[[QSTriggerCenter sharedInstance] triggerChanged:[self currentTrigger]];
	[self enableTrigger:[self currentTrigger]];
	
}

- (void)populateInfoFields{
	NSDictionary *thisTrigger=[self currentTrigger];
	//	NSLog(@"populate for %@",thisTrigger);
	[eventPopUp removeAllItems];
	
	NSDictionary *events=[QSReg tableNamed:kQSTriggerEvents];
	
	
	NSSortDescriptor *typeDesc=[NSSortDescriptor descriptorWithKey:@"type" ascending:YES];
	NSSortDescriptor *nameDesc=[NSSortDescriptor descriptorWithKey:@"name" ascending:YES];
	NSEnumerator *ke=[[events keysSortedByValueUsingDescriptors:[NSArray arrayWithObjects:typeDesc,nameDesc,nil]]objectEnumerator];
	
	
	NSString *key;
	NSDictionary *event;
	NSString *type=nil;
	NSMenuItem *item=nil;
	while(key=[ke nextObject]){ 
		event=[events objectForKey:key];
		NSString *newType=[event objectForKey:@"type"];
		if (![type isEqualToString:newType]){
			type=newType;
			if (type){
				if ([[eventPopUp menu]numberOfItems])
					[[eventPopUp menu]addItem:[NSMenuItem separatorItem]];
				item=[[eventPopUp menu]addItemWithTitle:type action:nil keyEquivalent:@""];
				[item setTarget:self];
				[item setEnabled:NO];
			}
		}
		item=[[eventPopUp menu]addItemWithTitle:[event objectForKey:@"name"]
										 action:nil
								  keyEquivalent:@""];
		//	NSLog(@"Event %@",[event objectForKey:@"name"]);
		NSImage *image=[[QSResourceManager imageNamed:[event objectForKey:@"icon"]]duplicateOfSize:NSMakeSize(16,16)];
		[item setImage:image];
		[item setRepresentedObject:key];
		
	}
	int index=[[eventPopUp menu]indexOfItemWithRepresentedObject:[[self currentTrigger] objectForKey:@"eventTrigger"]];
	[eventPopUp selectItemAtIndex:index];
	
}


- (IBAction) setMouseTriggerValueForSender:(id)sender{
	
	[self populateInfoFields];
}




-(id)resolveProxyObject:(id)proxy{
	return [self eventTriggerObject];
}

-(NSArray *)typesForProxyObject:(id)proxy{
	return [[self eventTriggerObject]types];
}





- (id)eventTriggerObject { return [[eventTriggerObject retain] autorelease]; }
- (void)setEventTriggerObject:(id)newEventTriggerObject
{
    [eventTriggerObject autorelease];
    eventTriggerObject = [newEventTriggerObject retain];
}

@end





