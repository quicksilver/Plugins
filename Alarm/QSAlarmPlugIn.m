//
//  QSAlarmPlugIn.m
//  QSAlarmPlugIn
//
//  Created by Nicholas Jitkoff on 7/11/05.
//  Copyright __MyCompanyName__ 2005. All rights reserved.
//

#import "QSAlarmPlugIn.h"
#import <QSCore/QSCommand.h>
#import <QSCore/QSExecutor.h>
#import <QSCore/QSTypes.h>
#import <QSCore/QSRegistry.h>
@implementation QSAlarmPlugIn
- (id)init {
    self = [self initWithWindowNibName:@"QSAlarmWindow"];
    if (self) {
		
		//	NSLog(@"plugs %@",installedPlugIns); 
	}
    return self;
}
- (void)awakeFromNib{
	
	[alarmTabView setDrawsBackground:NO];	
}
- (IBAction)run:(id)sender
{
	[[[commandObjectView objectValue]objectForType:QSCommandType]execute];
	[[self window] orderOut: nil];
	//	[[NSApplication sharedApplication] stopModalWithCode: NSOKButton];
	[NSApp endSheet:[self window] returnCode:NSOKButton];
}

- (IBAction)cancel:(id)sender
{
	[[self window] orderOut: nil];
	//	[[NSApplication sharedApplication] stopModalWithCode: NSCancelButton];
    [NSApp endSheet:[self window] returnCode:NSCancelButton];
}
- (IBAction)snooze:(id)sender
{
	[[self window] orderOut: nil];
	//	[[NSApplication sharedApplication] stopModalWithCode: NSCancelButton];
    [NSApp endSheet:[self window] returnCode:NSAlertOtherReturn];
}
- (void)finishSnooze:(NSTimer *)timer;
{
	id object=[timer userInfo];
	[self alarmWithObject:object];
}

- (QSObject *)alarmNow:(QSObject *)dObject{
	[self alarmWithObject:dObject];
	return nil;
}
- (void)alarmWithObject:(QSObject *)object;
{
		[self window];
	NSString *textValue=nil;
	QSObject *objectValue=nil;
	QSObject *commandValue=nil;
	NSLog(@"type %@",[object primaryType]);
	if ([[object primaryType]isEqualToString:QSCommandType]){
		commandValue=object;
		[alarmTabView selectTabViewItemWithIdentifier:@"command"];
	}else if ([[object primaryType]isEqualToString:QSTextType]){
		textValue=[object stringValue];
		[alarmTabView selectTabViewItemWithIdentifier:@"text"];
	}else{		
		objectValue=object;
		[alarmTabView selectTabViewItemWithIdentifier:@"object"];
	}
	
	[textView setString:textValue?textValue:@""];

	[objectView setObjectValue:object];
	[objectTitleField setStringValue:objectValue?[objectValue displayName]:@""];
		
	[commandNameField setStringValue:commandValue?[commandValue displayName]:@""];
	[commandObjectView setObjectValue:commandValue];
	
	

	[[objectView cell] setImagePosition:NSImageOnly];
	[alarmTabView display];
	
	
	
	
	[[self window]setHidesOnDeactivate:NO];
	[[self window]setLevel:NSFloatingWindowLevel];
	[[self window]reallyCenter];
	[[NSSound soundNamed:@"Glass"]play];
	[[self window]orderFront:nil];
	int result=[NSApp runModalForWindow:[self window]];
	if (result==NSAlertOtherReturn){
		[NSTimer scheduledTimerWithTimeInterval:MAX([snoozeField floatValue]*60,0.5f) target:self selector:@selector(finishSnooze:) userInfo:object repeats:NO];
	}
	
}

- (QSObject *)alarm:(QSObject *)dObject afterDelay:(QSObject *)iObject;
{
	QSCommand *command=[QSCommand commandWithDirectObject:dObject actionObject:[QSExec actionForIdentifier:@"QSAlarmNowAction"]indirectObject:nil];
	QSObject *commandObject=[command objectValue];
	[[QSReg getClassInstance:@"QSCommandObjectHandler"]executeCommand:commandObject afterDelay:iObject];
	return nil;
}
- (QSObject *)alarm:(QSObject *)dObject atTime:(QSObject *)iObject;
{
	QSCommand *command=[QSCommand commandWithDirectObject:dObject actionObject:[QSExec actionForIdentifier:@"QSAlarmNowAction"]indirectObject:nil];
	QSObject *commandObject=[command objectValue];
	[[QSReg getClassInstance:@"QSCommandObjectHandler"]executeCommand:commandObject atTime:iObject];
	return nil;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject{
	QSObject *textObject=[QSObject textProxyObjectWithDefaultValue:@""];
	return [NSArray arrayWithObject:textObject]; 
}

@end
